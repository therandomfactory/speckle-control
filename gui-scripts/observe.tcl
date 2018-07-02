


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : abortsequence
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure aborts the current exposure or sequence of exposures.
#  It simply sets the global abort flag and resets the GUI widgets.
#
#  Arguments  :
#
 
proc abortsequence { } {
 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
global STATUS
  set STATUS(abort) 1
  andorSetControl 0 abort
  .main.observe configure -text "Observe" -bg gray -relief raised -command startsequence
  .main.abort configure -bg gray -relief sunken -fg LightGray
  mimicMode red close
  mimicMode blue close
}




set STATUS(last) [expr [clock clicks]/1000000.]


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : observe
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This stub routine responds to user selections on the observe menu.
#
#  Arguments  :
#
#               op	-	Operation specifier
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc observe { op {id 0} } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
global SCOPE
  switch $op {
      region128 {acquisitionmode 128}
      region256 {acquisitionmode 256}
      region512 {acquisitionmode 512}
      regionall {acquisitionmode 1024}
      manual    {acquisitionmode manual}
      multiple {continuousmode $SCOPE(exposure) 999999 $id}
      fullframe {setfullframe}
  }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : setfullframe
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This stub routine responds to user selections on the observe menu.
#
#  Arguments  :
#
#               op	-	Operation specifier
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc setfullframe { } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
global SCOPE CONFIG LASTACQ ANDOR_DEF
   set CONFIG(geometry.BinX)      1
   set CONFIG(geometry.BinY)      1
   set CONFIG(geometry.StartCol)  1
   set CONFIG(geometry.StartRow)  1
   set CONFIG(geometry.NumCols)   [lindex [split $ANDOR_DEF(fullframe) ,] 1]
   set CONFIG(geometry.NumRows)   [lindex [split $ANDOR_DEF(fullframe) ,] 3]
   mimicMode red roi 1024x1024
   mimicMode blue roi 1024x1024
   commandAndor red "setframe fullframe"
   commandAndor blue "setframe fullframe"
   set LASTACQ fullframe
   set SCOPE(numseq) 1
   set SCOPE(numframes) 1
}






#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : acquisitionmode
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure controls the specification of a sub-image region using
#  the DS9 image display tool.
#
#  Arguments  :
#
 
proc  acquisitionmode { rdim } {
 
#
#  Globals    :
#  
#               ACQREGION	-	Sub-frame region coordinates
#               CONFIG	-	GUI configuration
global ACQREGION CONFIG LASTACQ SCOPE ANDOR_SOCKET ANDOR_CFG
  puts stdout "rdim == $rdim"
  if { $rdim != "manual"} {
        commandAndor red "setframe fullframe"
        commandAndor blue "setframe fullframe"
###        positionZabers fullframe
  }
  set SCOPE(numseq) 1
  set SCOPE(numframes) 1
  if { $rdim != "manual" && $rdim != 1024} {
    set LASTACQ "fullframe"
    startsequence
    after 2000
  }
  if { $rdim == "manual" } {
    set rdim $ACQREGION(geom)
    set it [tk_dialog .d "Edit regions" "Move the regions in the\n image display tool then click OK" {} -1 "OK"]
#    commandAndor red "forceroi $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)"
#   commandAndor blue "forceroi $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)"
  } else {
    set resr [commandAndor red "setroi $rdim"]
    set SCOPE(red,bias) [lindex $resr 2]
    set SCOPE(red,peak) [lindex $resr 3]
    set resb [commandAndor blue "setroi $rdim"]
    set SCOPE(blue,bias) [lindex $resr 2]
    set SCOPE(blue,peak) [lindex $resr 3]
  }
  set chk [checkgain]
  mimicMode red roi [set rdim]x[set rdim]
  mimicMode blue roi [set rdim]x[set rdim]
  exec xpaset -p ds9red regions system physical
  exec xpaset -p ds9blue regions system physical
  if { $rdim != 1024 } {
  set reg [split [exec xpaget ds9red regions] \n]
  foreach i $reg {
     if { [string range $i 0 8] == "image;box" || [string range $i 0 2] == "box" } {
        set r [lrange [split $i ",()"] 1 4]
        set ACQREGION(rxs) [expr int([lindex $r 0] - [lindex $r 2]/2)]
        set ACQREGION(rys) [expr int([lindex $r 1] - [lindex $r 3]/2)]
        set ACQREGION(rxe) [expr $ACQREGION(rxs) + [lindex $r 2] -1]
        set ACQREGION(rye) [expr $ACQREGION(rys) + [lindex $r 3] -1]
        puts stdout "selected red region $r"
     }
  }
  set reg [split [exec xpaget ds9blue regions] \n]
  foreach i $reg {
     if { [string range $i 0 8] == "image;box" || [string range $i 0 2] == "box" } {
        set r [lrange [split $i ",()"] 1 4]
        set ACQREGION(bxs) [expr int([lindex $r 0] - [lindex $r 2]/2)]
        set ACQREGION(bys) [expr int([lindex $r 1] - [lindex $r 3]/2)]
        set ACQREGION(bxe) [expr $ACQREGION(bxs) + [lindex $r 2] -1]
        set ACQREGION(bye) [expr $ACQREGION(bys) + [lindex $r 3] -1]
        puts stdout "selected red region $r"
     }
  }
  set CONFIG(geometry.StartCol) [expr $ACQREGION(rxs)]
  set CONFIG(geometry.StartRow) [expr $ACQREGION(rys)]
  set CONFIG(geometry.NumCols) $rdim
  set CONFIG(geometry.NumRows) $rdim
  set ACQREGION(geom) $CONFIG(geometry.NumCols)
  debuglog "ROI's are red  = $ACQREGION(rxs) $ACQREGION(rys) $ACQREGION(rxe) $ACQREGION(rye)" 
  debuglog "ROI's are blue = $ACQREGION(bxs) $ACQREGION(bys) $ACQREGION(bxe) $ACQREGION(bye)"
  commandAndor red "setframe roi"
  commandAndor blue "setframe roi"
  set LASTACQ roi
  .lowlevel.rmode configure -text "Mode=ROI"
  .lowlevel.bmode configure -text "Mode=ROI"
  } else {
    set ACQREGION(geom) 1024
    set ACQREGION(rxs) 1
    set ACQREGION(rxe) 1024
    set ACQREGION(rys) 1
    set ACQREGION(rye) 1024
    set ACQREGION(bxs) 1
    set ACQREGION(bxe) 1024
    set ACQREGION(bys) 1
    set ACQREGION(bye) 1024
    if { $ANDOR_CFG(kineticMode) } {
      commandAndor red "setframe fullkinetic"
      commandAndor blue "setframe fullkinetic"
     .lowlevel.rmode configure -text "Mode=FULL"
     .lowlevel.bmode configure -text "Mode=FULL"
    } else {
      commandAndor red "setframe fullframe"
      commandAndor blue "setframe fullframe"
     .lowlevel.rmode configure -text "Mode=Single"
     .lowlevel.bmode configure -text "Mode=Single"
    }
  }
}


proc checkgain { {table table.dat} } {
global SCOPE SPECKLE_DIR
  catch {
   set res [exec $SPECKLE_DIR/gui-scripts/autogain.py $SPECKLE_DIR/$table $SCOPE(red,bias) $SCOPE(red,peak)]
   if { [lindex [split $res \n] 6] == "Changes to EM Gain are recommended." } {
     set it [tk_dialog .d "RED CAMERA EM GAIN" $res {} -1 "OK"]
   }
   set res [exec $SPECKLE_DIR/gui-scripts/autogain.py $SPECKLE_DIR/$table $SCOPE(blue,bias) $SCOPE(blue,peak)]
   if { [lindex [split $res \n] 6] == "Changes to EM Gain are recommended." } {
     set it [tk_dialog .d "BLUE CAMERA EM GAIN" $res {} -1 "OK"]
   }
  }
}

#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : startsequence
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This routine manages a sequence of exposures. It updates bias columns
#  specifications in case they have been changed, then it loops thru
#  a set of frames, updating the countdown window, and calling obstodisk to 
#  do the actual exposures.
#
#  Arguments  :
#
 
proc startsequence { } {
 
#
#  Globals    :
#  
#               SCOPE	-	Telescope parameters, gui setup
#               OBSPARS	-	Default observation parameters
#               FRAME	-	Frame number in a sequence
#               STATUS	-	Exposure status
#               DEBUG	-	Set to 1 for verbose logging
global SCOPE OBSPARS FRAME STATUS DEBUG REMAINING LASTACQ TELEMETRY DATAQUAL SPECKLE_FILTER INSTRUMENT
global ANDOR_CCD ANDOR_EMCCD ANDOR_CFG
 set iseqnum 0
 redisUpdate
 zaberCheck
 specklesynctelem red
 specklesynctelem blue
 set SCOPE(exposureStart) [expr [clock milliseconds]/1000.0]
 .lowlevel.p configure -value 0.0
 speckleshutter red auto
 speckleshutter blue auto
 commandAndor red  "frametransfer $ANDOR_CFG(red,frametransfer)"
 commandAndor blue "frametransfer $ANDOR_CFG(blue,frametransfer)"
 commandAndor red  "numberkinetics $SCOPE(numframes)"
 commandAndor blue "numberkinetics $SCOPE(numframes)"
 commandAndor red  "numberaccumulations $SCOPE(numaccum)"
 commandAndor blue "numberaccumulations $SCOPE(numaccum)"
 commandAndor red  "programid $SCOPE(ProgID)"
 commandAndor blue "programid $SCOPE(ProgID)"
 commandAndor red  "autofitds9 $INSTRUMENT(red,fitds9)"
 commandAndor blue "autofitds9 $INSTRUMENT(blue,fitds9)"
 commandAndor red  "vsspeed $ANDOR_CFG(red,VSSpeed)"
 commandAndor blue "vsspeed $ANDOR_CFG(blue,VSSpeed)"
 if { $INSTRUMENT(red,emccd) } {
   commandAndor red "outputamp $ANDOR_EMCCD"
   commandAndor red "emadvanced $INSTRUMENT(red,highgain)"
   commandAndor red "emccdgain $INSTRUMENT(red,emgain)"
   commandAndor red "hsspeed 0 $ANDOR_CFG(red,EMHSSpeed)"
 } else {
   commandAndor red "outputamp $ANDOR_CCD"
 }
 if { $INSTRUMENT(blue,emccd) } {
   commandAndor blue "outputamp $ANDOR_EMCCD"
   commandAndor blue "emadvanced $INSTRUMENT(blue,highgain)"
   commandAndor blue "emccdgain $INSTRUMENT(blue,emgain)"
   commandAndor blue "hsspeed 0 $ANDOR_CFG(blue,EMHSSpeed)"
 } else {
   commandAndor blue "outputamp $ANDOR_CCD"
 }
 commandAndor red  "dqtelemetry $DATAQUAL(rawiq) $DATAQUAL(rawcc) $DATAQUAL(rawwv) $DATAQUAL(rawbg)"
 commandAndor blue "dqtelemetry $DATAQUAL(rawiq) $DATAQUAL(rawcc) $DATAQUAL(rawwv) $DATAQUAL(rawbg)"
 commandAndor red  "filter $SPECKLE_FILTER(red,current)"
 commandAndor blue "filter $SPECKLE_FILTER(blue,current)"
 set cmt [join [split [string trim [.main.comment get 0.0 end]] \n] "|"]
 commandAndor red "comments $cmt"
 commandAndor blue "comments $cmt"
 commandAndor red "datadir $SCOPE(datadir)"
 commandAndor blue "datadir $SCOPE(datadir)"
 andorSetControl 0 frame 0
 andorSetControl 1 frame 0
 while { $iseqnum < $SCOPE(numseq) } {
  set ifrmnum 0
  while { $ifrmnum < $SCOPE(numframes) } {
   incr iseqnum 1
   incr ifrmnum 1
   set dfrmnum $ifrmnum
   set OBSPARS($SCOPE(exptype)) "$SCOPE(exposure) $SCOPE(numframes) $SCOPE(shutter)"
   set STATUS(abort) 0
   .main.observe configure -text "working" -bg green -relief sunken
   .main.abort configure -bg orange -relief raised -fg black
   wm geometry .countdown
   set i 1
   if { $SCOPE(exptype) == "Zero" || $SCOPE(exptype) == "Dark" } {
     mimicMode red close
     mimicMode blue close
   } else {
     mimicMode red open
     mimicMode blue open
   }
   commandAndor red "imagename $SCOPE(imagename)_[format %6.6d $SCOPE(seqnum)] $SCOPE(overwrite)"
   commandAndor blue "imagename $SCOPE(imagename)_[format %6.6d $SCOPE(seqnum)] $SCOPE(overwrite)"
   if { $LASTACQ == "fullframe" && $SCOPE(numframes) > 1 } {
     commandAndor red "imagename $SCOPE(imagename)_[format %6.6d $SCOPE(seqnum)]_[format %6.6d $ifrmnum] $SCOPE(overwrite)"
     commandAndor blue "imagename $SCOPE(imagename)_[format %6.6d $SCOPE(seqnum)]_[format %6.6d $ifrmnum] $SCOPE(overwrite)"
   }
   incr SCOPE(seqnum) 1
####   flushAndors
   set redtemp  [lindex [commandAndor red gettemp] 0]
   set bluetemp  [lindex [commandAndor blue gettemp] 0]
   mimicMode red temp "[format %5.1f [lindex $redtemp 0]] degC"
   mimicMode blue temp "[format %5.1f [lindex $bluetemp 0]] degC"
   .main.rcamtemp configure -text "[format %5.1f [lindex $redtemp 0]] degC"
   .main.bcamtemp configure -text "[format %5.1f [lindex $bluetemp 0]] degC"
   set tpredict [lindex [commandAndor red status] end]
   if { $LASTACQ == "fullframe" } {
      set TELEMETRY(speckle.andor.mode) "fullframe"
      if { $ANDOR_CFG(kineticMode) } {
         acquireCubes
      } else {
         acquireFrames
      }
      set perframe $SCOPE(exposure)
   } else {
      set TELEMETRY(speckle.andor.mode) "roi"
      acquireCubes
      set ifrmnum $SCOPE(numframes)
      set perframe [expr $SCOPE(exposure)*$SCOPE(numaccum)]
   }
   set now [clock seconds]
   set FRAME 0
   set REMAINING 0
#   countdown [expr int($SCOPE(exposure)*$SCOPE(numframes))]
   while { $i < $SCOPE(numframes) && $STATUS(abort) == 0 } {
      set FRAME $i
      set REMAINING [expr [clock seconds] - $now]
      if { $DEBUG} {debuglog "$SCOPE(exptype) frame $i"}
#      after [expr int($perframe*1000)]
     after 20
      if { $LASTACQ == "fullframe" } {
         incr i 1
      } else {
         set i [andorGetControl 0 frame]
      }
      .lowlevel.p configure -value [expr $i*100/$SCOPE(numframes)]
      .lowlevel.progress configure -text "Observation status : Frame $i   Exposure $dfrmnum   Sequence $iseqnum"
      update
   }
   set SCOPE(exposureEnd) [expr [clock milliseconds]/1000.0]
   .main.observe configure -text "Observe" -bg gray -relief raised
   .main.abort configure -bg gray -relief sunken -fg LightGray
#   speckleshutter red close
#   speckleshutter blue close
   .lowlevel.progress configure -text "Observation status : Idle"
   if { $STATUS(abort) } {return}

  }
 }
 abortsequence
 if { $SCOPE(autoclrcmt) } {.main.comment delete 0.0 end }
}


set SCOPE(red,bias) 0
set SCOPE(blue,bias) 0
set SCOPE(red,peak) 0
set SCOPE(blue,peak) 0

set ACQREGION(geom) 256
set SCOPE(red,bias) 0
set SCOPE(blue,bias) 0
set SCOPE(red,peak) 1
set SCOPE(blue,peak) 1


set ACQREGION(geom) 1024
set ACQREGION(rxs) 1
set ACQREGION(rxe) 1024
set ACQREGION(rys) 1
set ACQREGION(rye) 1024
set ACQREGION(bxs) 1
set ACQREGION(bxe) 1024
set ACQREGION(bys) 1
set ACQREGION(bye) 1024


set ANDOR_CFG(red,VSSpeed) 1
set ANDOR_CFG(blue,VSSpeed) 1
set ANDOR_CFG(red,HSSpeed) 1
set ANDOR_CFG(blue,HSSpeed) 1
set ANDOR_CFG(red,EMHSSpeed) 1
set ANDOR_CFG(blue,EMHSSpeed) 1






