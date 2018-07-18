## \file headerBuilder.tcl
# \brief This contains procedures to assemble the FITS headers
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) \n
#\n
#
#  This file contains the tcl code to provide automated FITS header\n
#  construction. The contents of predefined headers are read from a\n
#  datafile. Another file specifies the relationship between FITS\n
#  keywords and MPG router stream parameters, and between SPECKLE\n
#  controller configuration items and FITS keywords.\n
#
#
#\code
## Documented proc \c loadstreamdefs .
# \param[in] from File to read stream definitions from
#
#
# Globals :\n
#		TELEMETRY - Array of telemetry items for headers and database usage\n
#		STREAM - Array of telemetry stream names\n
#		PDEBUG - Debug verbosity\n
#		FITSKEY - Array of FITS keywords\n
#		FITSTXT - Array of FITS header descriptions
#
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



## Documented proc \c loadhdrdefs .
# \param[in] from File to read header definitions from
#
#
# Globals :\n
#		HEADERS - Names of header types\n
#		PDEBUG - Debug verbosity
#
proc loadhdrdefs { {from headers.conf} } {
global HEADERS PDEBUG
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





## Documented proc \c fillheader .
# \param[in] args Optional arguments , scope-instrument identifier
#
#  Create a FITS header structure with all the required keywords
#
# Globals :\n
#		TELEMETRY - Array of telemetry items for headers and database usage\n
#		SEQNUM - Sequence number\n
#		CACHETELEMETRY - Cache of telemetry items\n
#		PDEBUG - Debug verbosity\n
#		HEADERS - Names of header types\n
#		FITSKEY - Array of FITS keywords\n
#		FITSTXT - Array of FITS header descriptions\n
#		FROMSTARTEXP - Array of values to use from exposure start
#		ANDOR_ARM - Instrument arm, red or blue
#
proc fillheader { args } {
global TELEMETRY PDEBUG HEADERS FITSKEY FITSTXT SEQNUM SCOPE
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

## Documented proc \c headerComments .
# \param[in] fid FITS file handle of open file
#
#  Add comments to FITS header
#
# Globals :
#		SCOPE - Array of Telescope information
#
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


## Documented proc \c getInterval .
# \param[in] id A timer identifier
#
#  Get interval since a timer was started
#
# Globals :
#		TIMER - Array of timers
#
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

## Documented proc \c obsid .
#
#  Generate an observstion identifier
#
proc obsid {  } {
  set obsid "wiyn.speckle.20[exec date -u +\%y\%m\%dT\%H\%M\%S]"
  return $obsid
}


## Documented proc \c notheaderGeometry .
# \param[in] fid FITS file handle of open file
#
#  Placeholder for eventual geometry header info 
#
proc notheaderGeometry { fid } {
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



## Documented proc \c fitshdrrecord .
# \param[in] key A FITS header keyword
# \param[in] type Type of the information, integer, float, double, string
# \param[in] value The data value
# \param[in] text The text description of the item
#
#  Format a FITS header record
#
proc fitshdrrecord { key type value text } {
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
              set record "[format %-8s $key]= [format %18s '[string trim $value]']"
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
              if { [expr abs($value)] < 1 } {set fmt 18.12f}
              set record [string toupper "[format %-8s $key]=  [format %$fmt $v1]"]
             }
  }
  set record "$record /[format %-48s $text]"
#  if { $TOMPG == "wiyn" } {
#      set record "|TELESCOPE       seqstar $record"
#  }
  return "$record"
}


## Documented proc \c appendHeader .
# \param[in] imgname Name of FITS file
#
#  Add the FITS header information to a file
#
# Globals :\n
#		TELEMETRY - Array of telemetry items for headers and database usage\n
#		SCOPE - Array of telescope parameters\n
#		env - Environment variables\n
#		SPECKLEHDRLOG - Cache of header details
#
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


## Documented proc \c jdtout .
# \param[in] jd Julian date
#
#  Calculate UT from Julian date
#
proc jdtout { jd } {
  set f [expr $jd - int($jd) + 0.29166666]
  set hms [radians_to_hms [expr $f*2.*3.14159265359]]
}

## Documented proc \c calculateXSEC .
# \param[in] name Geometry section name
#
#  Calculate image geometry header data
#
#
# Globals :\n
#		SCOPE - Array of telescope parameters\n
#		IMGMETA - Image geometry metadata
#
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


## Documented proc \c ccachetelemetry .
#
# Keep a cached copy of the telemetry
#
proc cachetelemetry { } {
global TELEMETRY CACHETELEMETRY
   foreach i [array names TELEMETRY] {
       set CACHETELEMETRY($i) $TELEMETRY($i)
   }
}


## Documented proc \c getFocus .
#
# Calculate WIYN focus setting
#
proc getFocus { } {
    set posa [lindex [wiyn info oss.secondary.posa] 0]
    set posb [lindex [wiyn info oss.secondary.posb] 0]
    set posc [lindex [wiyn info oss.secondary.posc] 0]
    set current -99990.
    catch {set  current [expr  ($posa+$posc)/2.0/8.0 ]}
    return $current
}

# \endcode

#
#  Initialisation code from here onwards....
#
set PDEBUG 0
set STREAMS ""
set TELEMETRY(tcs.telescope.ra) 12:00:00
set TELEMETRY(tcs.telescope.dec) 00:00:00
set SPECKLEHDRLOG [open /tmp/$env(USER)_headerInfo.log a]
puts $SPECKLEHDRLOG "Startup at [exec date]"
set SEQNUM 1

if { [info exists env(TELESCOPE)] } {
     set TOMPG $env(TELESCOPE)
} else {
     puts stdout "SPECKLE Diagnostics - Telescope environment not defined"
}

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
} else {
  proc redisquery { } { }
  source $SPECKLE_DIR/gui-scripts/gemini_telemetry.tcl
  geminiConnect north
}

foreach i "LSTHDR ELMAP AZMAP TRACK EPOCH TARGRA 
        TARGDEC RA DEC RAOFFST DECOFFST ZD AIRMASS
        ROTANGLE FOCUS ROTPORT FOLDPOS" {
   set FROMSTARTEXP($i) 1
}


after 5000 cachetelemetry


