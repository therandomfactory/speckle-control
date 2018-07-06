
#
#  This file contains the tcl code to provide automated FITS header
#  construction. The contents of predefined headers are read from a
#  datafile. Another file specifies the relationship between FITS
#  keywords and MPG router stream parameters, and between SPECKLE
#  controller configuration items and FITS keywords.
#

set PDEBUG 0
set STREAMS ""
set SPECKLEHDRLOG [open /tmp/$env(USER)_headerInfo.log a]
puts $SPECKLEHDRLOG "Startup at [exec date]"
set SEQNUM 1

if { [info exists env(TELESCOPE)] } {
     set TOMPG $env(TELESCOPE)
} else {
     puts stdout "SPECKLE Diagnostics - Telescope environment not defined"
}


proc loadstreamdefs { {from telem.conf} } {
global TELEMETRY STREAMS PDEBUG FITSKEY FITSTXT
  set fin [open $from r]
  while { [gets $fin rec] > -1 } {
    if { [string trim $rec] != "" } {
     if { [string range $rec 0 0] != "#" } {
       if { [lindex $rec 0] == "stream" || [lindex $rec 0] == "category"} {
         lappend STREAMS [lindex $rec 1]
         set cstream [lindex $rec 1]
         if { $PDEBUG } {debuglog "Definition of $cstream"}
       } else {
         set TELEMETRY($cstream.[lindex $rec 0]) "NA"
         set FITSKEY($cstream.[lindex $rec 0]) [lindex $rec 1]
         set FITSTXT($cstream.[lindex $rec 0]) [lrange $rec 2 end]
         if { $PDEBUG } {debuglog "   parameter  $cstream.[lindex $rec 0]"}
       }
     }
    }
  }
  close $fin
}



proc loadhdrdefs { {from headers.conf} } {
global HEADERS PDEBUG ACTIVE
  set fin [open $from r]
  while { [gets $fin rec] > -1 } {
    if { [string trim $rec] != "" } {
     if { [string range $rec 0 0] != "#" } {
       if { [lindex $rec 0] == "header" } {
         set chdr [lindex $rec 1]
         set HEADERS($chdr) ""
         if { $PDEBUG } {debuglog "Definition of header $chdr"}
       } else {
         lappend HEADERS($chdr) [lindex $rec 0]
         if { $PDEBUG } {debuglog "   $chdr + [lindex $rec 0]"}
       }
     }
    }
  }
  close $fin
}




proc subscribestreams { } {
global STREAMS PDEBUG TOMPG ACTIVE
  foreach s $STREAMS {
   if { [info exists ACTIVE($s)] } {
    set stat 0
    catch {set stat [$TOMPG subscribe $s]
    }
    if { $stat == 0 } {return error}
    if { $PDEBUG } {debuglog "Subscribed to stream $s"}
   }
  }
}


proc newdata { name par state type value } {
global TELEMETRY
##  puts stdout "got $name = $value"
  set TELEMETRY($name) [join [split $value "\{\}\""] " "]
  set TELEMETRY($name,t) $type
}


proc activatestreams { } {
global TOMPG HEADERS ACTIVE
  switch $TOMPG {
     kpno_36  { set type tcs-36 }
     kpno_09m  { set type tcs-36 }
     kpno_2m   { set type tcs-2m }
     kpno_4m   { set type tcs-4m }
     wiyn      { set type wiyn-speckle }
     gemini    { set type gemini-speckle }
  }
  foreach i $HEADERS($type) {
     set stream [join [lrange [split $i "."] 0 1] "."]
     set ACTIVE($stream) 1
  }
}



proc fillheader { args } {
global TELEMETRY PDEBUG HEADERS TOMPG FITSKEY FITSTXT SEQNUM ACTIVE SCOPE
global FROMSTARTEXP CACHETELEMETRY ANDOR_ARM
  set fhead ""
  speckleTelemetryUpdate
  updateAndorTelemetry $ANDOR_ARM
  set type wiyn-speckle
  if { $SCOPE(telescope) == "GEMINI" } {set type gemini-speckle}
  set fhead "[fitshdrrecord HDR_REV string {3.00 18-Feb-2008} Header-Rev ]\n" 
  foreach i $HEADERS($type) {
     if { $PDEBUG > 1 } {debuglog "processing $i"}
     if { [info exists FITSKEY($i)] } {
       set key $FITSKEY($i)
       set text $FITSTXT($i)
     } else {
       set key [string toupper [lindex [split $i .] 2] ]
       set text "from $i"
     }
     if { $key == "PROC" } {
       set cmd "[lindex $text  0] \"$TELEMETRY($i)\""
       set key [lindex $text 1]
       set text [lrange $text 2 end]
       set type string
       catch {set type "$TELEMETRY($i,t)"}
       set value "$TELEMETRY($i)"
       if { [info exists FROMSTARTEXP($key)] }  { 
          set value $CACHETELEMETRY($i)
       }
       if { $value == "Attribute" && $key != "FOCUS" } {
          set type string
          set value "Not available"
       } else {
         set parse [eval $cmd]
         set value [lrange $parse 1 end]
         set type [lindex $parse 0]
       }
     } else {
###       set current [$TOMPG info $i]
### for testing
       set value NA
       catch {set value "$TELEMETRY($i)"}
#       if { [info exists FROMSTARTEXP($key)] } { 
#          set value $CACHETELEMETRY($i)
#       }
       set type string
       if { $SCOPE(telescope) == "wiyn" } {
          catch {set type "$TELEMETRY($i,t)"}
          if { $value == "Attribute" } {
             set type string
             set value "Not available"
          }
       }
     }
     set new [fitshdrrecord $key $type $value $text ]
     if { [string trim [lindex [split $new "/"] 0]] != "" } {
       if { $PDEBUG > 1 } {debuglog "HEADER->$new"}
       set fhead "$fhead$new\n"
     } else {
       debuglog "No value for $key"
     }
  }
  set fhead "$fhead[fitshdrrecord OBSID string [obsid] Observation-ID]\n"
  set fhead "$fhead[fitshdrrecord SPKLESEQ integer $SEQNUM SPECKLENFO-sequence]\n"
  set fhead "$fhead[fitshdrrecord SPKLEDAT string [lrange [exec date] 1 3] SPECKLENFO-timestamp]"
  if { [string trim [lindex $args 1]] != "" } {
    set fdbg [open [lindex $args 1] w]
    puts $fdbg "$fhead"
    close $fdbg
    set fhead "OK"
  }
  incr SEQNUM  1
  return "$fhead"
}

proc headerComments { fid } {
global SCOPE
  set spos [llength [$fid dump -l]]
  set cmt [split $SCOPE(comments) "|"]
  if { $cmt != "" } {
    foreach l $cmt {
      incr spos 1
      $fid insert keyword $spos "COMMENT   $l" 0
    }
  }
}

proc bgcountdown { c } {
  .countdown configure -bg $c
  foreach w "lf lt f t" {
      .countdown.$w configure -bg $c
  }
  update
}

proc countdown { op } {
global FRAME STATUS SCOPE
  set time $STATUS(countdown)
  if { $op == "off" || $STATUS(abort) } {
     place .countdown -y 1000
     wm geometry . 520x440
     preparebuttons
     if { $FRAME == $SCOPE(numframes) } {
       set SCOPE(numframes) 1
     }
     set STATUS(countdown) 0
     return
  }
  .countdown.f configure -text $FRAME
  .countdown.t configure -text $time
  if { $STATUS(pause) == 0 } {
      incr time -1
  } else {
      .countdown.t configure -text "$time (HOLD)"
  }
  set STATUS(countdown) $time
  if { $time < 0 } {
    bgcountdown yellow
  } else {
    bgcountdown orange
  }
  if { [winfo y .countdown] == 1000 } {
     wm geometry . 520x555
     place .countdown -x 0 -y 440
  }
  if { $time > -1 } {
     update
     after 850 countdown $time
  } else {
     if { $STATUS(readout) } {
       .countdown.t configure -text "READING"
     }
  }
}


proc getInterval { id op } {
global TIMER
   switch $op {
       start {
               set TIMER($id) [clock clicks]
               set delta 0
             }
       read  {
               set delta [expr abs([clock clicks] - $TIMER($id))/1000000.]
             }
   }
   return $delta
}

proc obsid {  } {
  set obsid "wiyn.speckle.20[exec date -u +\%y\%m\%dT\%H\%M\%S]"
  return $obsid
}


proc notheaderGeometry { fid } {
global IMGSTAT IMGMETA
   set r [fitshdrrecord DATASEC string [calculateXSEC DATASEC] "image portion of frame"]
   $fid put keyword $r
   set r [fitshdrrecord ORIGSEC string [calculateXSEC ORIGSEC] "original size full frame "]
   $fid put keyword $r
   set r [fitshdrrecord CCDSEC string [calculateXSEC CCDSEC] "orientation to full frame "]
   $fid put keyword $r
   set r [fitshdrrecord BIASSEC string [calculateXSEC BIASSEC]  "overscan portion of frame"]
   $fid put keyword $r
   set r [fitshdrrecord TRIMSEC string [calculateXSEC TRIMSEC]  "region to be extracted "]
   $fid put keyword $r
}



proc fitshdrrecord { key type value text } {
global TOMPG
  set record ""
  set v1 [lindex $value 0]
  set fmt 18.4f
  if { [llength [split $type _]] > 1 } {
     set fmt [lindex [split $type _] 1]
     set type [lindex [split $type _] 0]     
  }
  if { $value == "NA" } {set type string}
  switch $type {
     string  {
              set record "[format %-8s $key]= [format %18s '$value']"
             }
     integer {
              set record "[format %-8s $key]=  [format %19d [expr int($value)]]"
             }
     boolean {
              set record "[format %-8s $key]=  [format %19s $value]"
             }
     float   {
              if { [expr abs($value)] < 10000 } {set fmt 18.6f}
              set record [string toupper "[format %-8s $key]=  [format %$fmt $v1]"]
             }
     double  {
              if { [expr abs($value)] < 10000 } {set fmt 18.6f}
              set record [string toupper "[format %-8s $key]=  [format %$fmt $v1]"]
             }
  }
  set record "$record /[format %-48s $text]"
#  if { $TOMPG == "wiyn" } {
#      set record "|TELESCOPE       seqstar $record"
#  }
  return "$record"
}


proc appendHeader { imgname } {
global SPECKLEHDRLOG SCOPE env TELEMETRY
  set hdr [fillheader $env(TELESCOPE)-$SCOPE(instrument)]
  puts $SPECKLEHDRLOG "$hdr"
  set fid [fits open $imgname]
  foreach rec [split $hdr \n] {
     $fid put keyword "$rec"
  }
  if { [info proc headerStandard] == "headerStandard" } {
     headerStandard $fid
  }
  if { [info proc headerGeometry] == "headerGeometry" } {
     headerGeometry $fid
  }
  if { [info proc headerAstrometry] == "headerAstrometry" } {
     headerAstrometry $fid $TELEMETRY(tcs.telescope.ra) $TELEMETRY(tcs.telescope.dec) 
  }
  if { [info proc header$SCOPE(instrument)] == "header$SCOPE(instrument)" } {
     eval {header$SCOPE(instrument) $fid}
  }
  if { [info proc headerComments] == "headerComments" } {
     fits close $fid
     set fid [fits open $imgname]
     headerComments $fid
  }
  fits close $fid
}

set TELEMETRY(tcs.telescope.ra) 12:00:00
set TELEMETRY(tcs.telescope.dec) 00:00:00

proc jdtout { jd } {
  set f [expr $jd - int($jd) + 0.29166666]
  set hms [radians_to_hms [expr $f*2.*3.14159265359]]
}



proc hdrtest { args } {
   puts stdout "$args"
}

proc calculateXSEC { name } {
global IMGMETA SCOPE
  set imgcols [expr int($IMGMETA(imageCols,postvalue))]
  set imgrows [expr int($IMGMETA(imageRows,postvalue))]
  set scicols [expr int($IMGMETA(sciCols,postvalue))]
  set scirows [expr int($IMGMETA(sciRows,postvalue))]
  set oricols [expr int($IMGMETA(pxlCols,postvalue)/$SCOPE(colBin))]
  set orirows [expr int($IMGMETA(pxlRows,postvalue)/$SCOPE(rowBin))]
  switch $name {
      DATASEC {
                 set sec "\[1:$scicols,1:$scirows\]"
              }  
      ORIGSEC {
                 set sec "\[1:$oricols,1:$orirows\]"
              }  
      CCDSEC  {
#must change to scistart:sciend for subrasters
# maybe xStart:scicols,yStart:scirows
                 set sec "\[1:$scicols,1:$scirows\]"
              }  
      TRIMSEC {
                 set sec "\[1:$scicols,1:$scirows\]"
              }  
      BIASSEC {
                 set startx [expr int($IMGMETA(sciCols,postvalue)+$IMGMETA(xPreScan,postvalue)+3)]
                 set endx   [expr int($IMGMETA(imageCols,postvalue)-3)]
                 set sec "\[$startx:$endx,1:$scirows\]"
              }  
  }
  return "$sec"
}


proc cachetelemetry { } {
global TELEMETRY CACHETELEMETRY
   foreach i [array names TELEMETRY] {
       set CACHETELEMETRY($i) $TELEMETRY($i)
   }
}


proc getFocus { } {
    set posa [lindex [wiyn info oss.secondary.posa] 0]
    set posb [lindex [wiyn info oss.secondary.posb] 0]
    set posc [lindex [wiyn info oss.secondary.posc] 0]
    set current -99990.
    catch {set  current [expr  ($posa+$posc)/2.0/8.0 ]}
    return $current
}


proc dummytest { } {
global TELEMETRY
  set TELEMETRY(tcs.time.UTC) "2450213.183315 float"
  set TELEMETRY(tcs.time.tdt) "2450213.184035 float"
  set TELEMETRY(tcs.time.LAST) "0.037653 float"
  set TELEMETRY(tcs.time.delta_AT) "30 integer"
  set TELEMETRY(tcs.time.delta_UT) "0.546810 float"
  set TELEMETRY(tcs.time.tai) "2450213.183662 float"
  set TELEMETRY(tcs.time.tdb) "2450213.184035 float"
  set TELEMETRY(tcs.time.UT1) "2450213.183321 float"
  set TELEMETRY(tcs.time.GMST) "1.985395  float"
  set TELEMETRY(tcs.time.GAST) "1.985412 float"
}

#
#  Initialisation code from here onwards....
#
set SPECKLE_DIR $env(SPECKLE_DIR)
load $SPECKLE_DIR/lib/libfitstcl.so

###load /usr/local/gui/lib/libxtcs.so

source $SPECKLE_DIR/gui-scripts/headerSpecials.tcl
source $SPECKLE_DIR/gui-scripts/astrometry.tcl
source $SPECKLE_DIR/gui-scripts/andorTelemetry.tcl
loadstreamdefs $SPECKLE_DIR/gui-scripts/telem-[string tolower $env(TELESCOPE)].conf
loadhdrdefs $SPECKLE_DIR/gui-scripts/headers.conf
if { $env(TELESCOPE) == "WIYN" } {
  source $SPECKLE_DIR/gui-scripts/redisquery.tcl
  redisConnect
  redisUpdate
  puts stdout "Connected to REDIS server"
}

foreach i "LSTHDR ELMAP AZMAP TRACK EPOCH TARGRA 
        TARGDEC RA DEC RAOFFST DECOFFST ZD AIRMASS
        ROTANGLE FOCUS ROTPORT FOLDPOS" {
   set FROMSTARTEXP($i) 1
}

proc dummyappendHeader { args } {
    puts stdout "appendHeader is commented out!!!!"
}

after 5000 cachetelemetry


