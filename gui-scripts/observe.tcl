## \file observe.tcl
# \brief This contains procedures for main observing sequencing
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) \n
#\n
#
#
#\code
## Documented proc \c abortsequence .
# 
#  This procedure aborts the current exposure or sequence of exposures.
#  It simply sets the global abort flag and resets the GUI widgets 
#
#  Globals    :
#  
#               STATUS	-	Exposure status
#
proc abortsequence { } {
global STATUS
  set STATUS(abort) 1
  andorSetControl 0 abort
  .main.observe configure -text "Observe" -bg gray -relief raised -command startsequence
  .main.abort configure -bg gray -relief sunken -fg LightGray
  mimicMode red close
  mimicMode blue close
}

 
## Documented proc \c abortsequence .
#  \param[in] op - Operation specifier
#  \param[in] id - Camera id (for multi-camera use) (optional, default is 0)
# 
#  This procedure aborts the current exposure or sequence of exposures.
#  It simply sets the global abort flag and resets the GUI widgets 
#
#  Globals    :  
#               SCOPE	- Telescope parameters, gui setup
#
proc observe { op {id 0} } {
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



## Documented proc \c setfullframe .
#  \param[in] op - Operation specifier
#  \param[in] id - Camera id (for multi-camera use) (optional, default is 0)
# 
#  This procedure reconfigure the cameras for fullframe operation
#
#  Globals    :  
#               SCOPE	- Telescope parameters, gui setup
#		CONFIG - Image geometry configuration
#		LASTACQ - Type of last image acqusition
#		ANDOR_DEF - Andor defaults
#
proc setfullframe { } {
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





## Documented proc \c acquisitionmode .
#  \param[in] rdim Type of acquisition, fullframe or roi dimension
# 
#  This procedure reconfigures the cameras for fullframe or ROI operation
#
#  Globals    :  
#               SCOPE	- Telescope parameters, gui setup
#		CONFIG - Image geometry configuration
#		LASTACQ - Type of last image acqusition
#		ANDOR_DEF - Andor defaults
#               ACQREGION - Sub-frame region coordinates
#		ANDOR_SOCKET - Andor camera server socket handles
#
proc  acquisitionmode { rdim } {
global ACQREGION CONFIG LASTACQ SCOPE ANDOR_SOCKET ANDOR_CFG
  puts stdout "rdim == $rdim"
  if { $rdim != "manual"} {
        set ANDOR_CFG(binning) 1
        commandAndor red  "setbinning $ANDOR_CFG(binning) $ANDOR_CFG(binning)"
        commandAndor blue "setbinning $ANDOR_CFG(binning) $ANDOR_CFG(binning)"
        commandAndor red  "setframe fullframe"
        commandAndor blue "setframe fullframe"
###        positionZabers fullframe
  }
  set SCOPE(numseq) 1
  set SCOPE(numframes) 1
  if { $rdim != "manual" } {
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
    set SCOPE(red,bias) [expr int([lindex $resr 2])]
    set SCOPE(red,peak) [expr int([lindex $resr 3])]
    set resb [commandAndor blue "setroi $rdim"]
    set SCOPE(blue,bias) [expr int([lindex $resr 2])]
    set SCOPE(blue,peak) [expr int([lindex $resr 3])]
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
    .lowlevel.rmode configure -text "Mode=Wide field"
    if { $ANDOR_CFG(kineticMode) } {
      commandAndor red "setframe fullkinetic"
      commandAndor blue "setframe fullkinetic"
    } else {
      commandAndor red "setframe fullframe"
      commandAndor blue "setframe fullframe"
    }
  }
}


## Documented proc \c acquisitionmode .
#  \param[in] table Table of EM gain thresholds
# 
#  This procedure reconfigures the cameras for fullframe or ROI operation
#
#  Globals    :  
#		SCOPE - Array of telescope configurations
#		SPECKLE_DIR - Directory path of speckle code
#		INSTRUMENT - Array of instrument configuration data
#
proc checkgain { {table table.dat} } {
global SCOPE SPECKLE_DIR INSTRUMENT
  catch {
   if { $INSTRUMENT(red,emcheck) } {
     set res [exec $SPECKLE_DIR/gui-scripts/autogain.py $SPECKLE_DIR/$table $SCOPE(red,bias) $SCOPE(red,peak)]
     if { [lindex [split $res \n] 6] == "Changes to EM Gain are recommended." } {
       set it [tk_dialog .d "RED CAMERA EM GAIN" $res {} -1 "OK"]
     }
   }
   if { $INSTRUMENT(blue,emcheck) } {
     set res [exec $SPECKLE_DIR/gui-scripts/autogain.py $SPECKLE_DIR/$table $SCOPE(blue,bias) $SCOPE(blue,peak)]
     if { [lindex [split $res \n] 6] == "Changes to EM Gain are recommended." } {
       set it [tk_dialog .d "BLUE CAMERA EM GAIN" $res {} -1 "OK"]
     }
   }
  }
}

## Documented proc \c startsequence .
# 
#  This routine checks the data rate
#
#
#  Globals    :  
#               SCOPE	- Telescope parameters, gui setup
#		CONFIG - Image geometry configuration
#		LASTACQ - Type of last image acqusition
#		ANDOR_DEF - Andor defaults
#               ACQREGION - Sub-frame region coordinates
#		ANDOR_CFG - Array of camera settings
proc checkDatarate { } {
global SCOPE ANDOR_CFG ACQREGION
   set ANDOR_CFG(mbps) [expr int(1/$SCOPE(exposure)*2*$ACQREGION(geom)*$ACQREGION(geom)/$ANDOR_CFG(binning)/$ANDOR_CFG(binning)*4/1024/1024)]
   if { $ANDOR_CFG(mbps) > 59 } {
      .lowlevel.datarate configure -text "Data Rate : $ANDOR_CFG(mbps) Mbps" -fg yellow
   } else {
      .lowlevel.datarate configure -text "Data Rate : $ANDOR_CFG(mbps) Mbps" -fg NavyBlue
   }
}

proc updateTemps { } {
     set redtemp  [lindex [commandAndor red gettemp] 0]
     set bluetemp  [lindex [commandAndor blue gettemp] 0]
     mimicMode red temp "[format %5.1f [lindex $redtemp 0]] degC"
     mimicMode blue temp "[format %5.1f [lindex $bluetemp 0]] degC"
     .main.rcamtemp configure -text "[format %5.1f [lindex $redtemp 0]] degC"
     .main.bcamtemp configure -text "[format %5.1f [lindex $bluetemp 0]] degC"
}



## Documented proc \c startsequence .
# 
#  This routine manages a sequence of exposures. It updates bias columns\n
#  specifications in case they have been changed, then it loops thru\n
#  a set of frames, updating the progress bar.
#
#  Globals    :  
#               SCOPE	- Telescope parameters, gui setup
#		CONFIG - Image geometry configuration
#		LASTACQ - Type of last image acqusition
#		ANDOR_DEF - Andor defaults
#               ACQREGION - Sub-frame region coordinates
#		ANDOR_CFG - Array of camera settings
#		ANDOR_SOCKET - Andor camera server socket handles
#		ANDOR_SHUTTER - Shutter mode names
#               SCOPE	- Telescope parameters, gui setup
#               OBSPARS	- Default observation parameters
#               FRAME	- Frame number in a sequence
#               STATUS	- Exposure status
#               DEBUG	- Set to 1 for verbose logging
#		TELEMETRY - Array of telemetry for headers and database usage
#		DATAQUAL - Array of data quality information
#		INSTRUMENT - Array of instrument configuration data
#
proc startsequence { } {
global SCOPE OBSPARS FRAME STATUS DEBUG REMAINING LASTACQ TELEMETRY DATAQUAL SPECKLE_FILTER INSTRUMENT
global ANDOR_CCD ANDOR_EMCCD ANDOR_CFG ANDOR_SHUTTER
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
 setBinning
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
 set cmt [join [split [string trim [.main.comment get 0.0 end]] \n] "|"]
 commandAndor red "comments $cmt"
 commandAndor blue "comments $cmt"
 commandAndor red "datadir $SCOPE(datadir)"
 commandAndor blue "datadir $SCOPE(datadir)"
 andorSetControl 0 frame 0
 andorSetControl 1 frame 0
 set autofilter [checkAutoFilter blue]
 set rautofilter [checkAutoFilter red]
 while { $autofilter != "" } {
   set bfilter [lindex $autofilter 0]
   if { $bfilter > 0 } {
    selectfilter blue $bfilter
    commandAndor blue "filter $SPECKLE_FILTER(blue,current)"
   }
   set rfilter [lindex $rautofilter 0]
   if { $rfilter > 0 } {
    selectfilter red $rfilter
    commandAndor red  "filter $SPECKLE_FILTER(red,current)"
   }
   set autofilter [lrange $autofilter 1 end]
   set rautofilter [lrange $rautofilter 1 end]
   while { $iseqnum < $SCOPE(numseq) } {
    .lowlevel.p configure -value 0
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
       commandAndor red  "shutter $ANDOR_SHUTTER(close)"
       commandAndor blue "shutter $ANDOR_SHUTTER(close)"
       mimicMode red close
       mimicMode blue close
     } else {
       commandAndor red  "shutter $ANDOR_SHUTTER(auto)"
       commandAndor blue "shutter $ANDOR_SHUTTER(auto)"
       mimicMode red open
       mimicMode blue open
     }
     commandAndor red "imagename $SCOPE(imagename)[format %6.6d $SCOPE(seqnum)] $SCOPE(overwrite)"
     commandAndor blue "imagename $SCOPE(imagename)[format %6.6d $SCOPE(seqnum)] $SCOPE(overwrite)"
     if { $LASTACQ == "fullframe" && $SCOPE(numframes) > 1 } {
       commandAndor red "imagename $SCOPE(imagename)[format %6.6d $SCOPE(seqnum)][format %6.6d $ifrmnum] $SCOPE(overwrite)"
       commandAndor blue "imagename $SCOPE(imagename)[format %6.6d $SCOPE(seqnum)][format %6.6d $ifrmnum] $SCOPE(overwrite)"
     }
     incr SCOPE(seqnum) 1
     updateTemps
     set tpredict [lindex [commandAndor red status] 15]
     if { $tpredict > $SCOPE(exposure) } {
##        set SCOPE(exposure) $tpredict
        .main.exposure configure -entryfg red
     } else {
        .main.exposure configure -entryfg black
     } 
     if { $LASTACQ == "fullframe" } {
        set TELEMETRY(speckle.andor.mode) "fullframe"
     } else {
        set TELEMETRY(speckle.andor.mode) "roi"
     }
     if { $ANDOR_CFG(kineticMode) && $SCOPE(numframes) > 1 } {
           checkDatarate
           acquireCubes
           set ifrmnum $SCOPE(numframes)
           set perframe [expr $SCOPE(exposure)*$SCOPE(numaccum)]
           set totaltime [expr $perframe * $SCOPE(numframes) +1]
     } else {
           .lowlevel.datarate configure -text ""
           set perframe $SCOPE(exposure)
           set totaltime [expr $perframe * $SCOPE(numframes) +1]
           acquireFrames
     }
     set now [clock seconds]
     set FRAME 0
     while { $i < $SCOPE(numframes) && $STATUS(abort) == 0 } {
        set FRAME $i
        set elapsedtime [expr [clock seconds] - $now]
        if { $elapsedtime > $totaltime } { set STATUS(abort) 1 }
        if { $DEBUG} {debuglog "$SCOPE(exptype) frame $i"}
        after 20
        if { $LASTACQ == "fullframe" } {
           set i $SCOPE(numframes)
           after [expr int($SCOPE(exposure)*1000)]
        } else {
           set i [andorGetControl 0 frame]
        }
        .lowlevel.p configure -value [expr $i*100/$SCOPE(numframes)]
        .lowlevel.progress configure -text "Observation status : Frame $i   Exposure $dfrmnum   Sequence $iseqnum / $SCOPE(numseq)"
        update
     }
     set SCOPE(exposureEnd) [expr [clock milliseconds]/1000.0]
     .main.observe configure -text "Observe" -bg gray -relief raised
     .main.abort configure -bg gray -relief sunken -fg LightGray
#     speckleshutter red close
#     speckleshutter blue close
     .lowlevel.progress configure -text "Observation status : Idle"
     if { $STATUS(abort) } {return}
    }
   }
 }
 abortsequence
 if { $SCOPE(autoclrcmt) } {.main.comment delete 0.0 end }
}


# \endcode


set SCOPE(red,bias) 0
set SCOPE(blue,bias) 0
set SCOPE(red,peak) 0
set SCOPE(blue,peak) 0

set ACQREGION(geom) 256
set SCOPE(red,bias) 0
set SCOPE(blue,bias) 0
set SCOPE(red,peak) 1
set SCOPE(blue,peak) 1
set STATUS(last) [expr [clock clicks]/1000000.]


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






