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
  set STATUS(observing) 0
  andorSetControl 0 abort 0
  .main.observe configure -text "Observe" -bg green -relief raised -command startsequence
  .main.abort configure -bg gray -relief sunken -fg LightGray
  mimicMode red close
  mimicMode blue close
 .lowlevel.p configure -value 0
 .lowlevel.seqp configure -value 0
}

 
## Documented proc \c observe .
#  \param[in] op - Operation specifier
#  \param[in] id - Camera id (for multi-camera use) (optional, default is 0)
# 
#  This procedure configures the frame size, full or ROI
#
#  Globals    :  
#               SCOPE	- Telescope parameters, gui setup
#
proc observe { op {id 0} } {
global SCOPE ANDOR_CFG
  if { $ANDOR_CFG(videomode) == 0 } {
    switch $op {
      region64  {acquisitionmode 64}
      region128 {acquisitionmode 128}
      region256 {acquisitionmode 256}
      region512 {acquisitionmode 512}
      region768 {acquisitionmode 768}
      regionall {acquisitionmode 1024}
      manual    {acquisitionmode manual}
      multiple {continuousmode $SCOPE(exposure) 999999 $id}
      fullframe {setfullframe}
    }
    if { $op == "regionall" } {set op "fullframe"}
    .main.rois configure -text "Set ROI's ($op)"
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
global SCOPE CONFIG LASTACQ ANDOR_DEF ANDOR_CFG
   set CONFIG(geometry.BinX)      1
   set CONFIG(geometry.BinY)      1
   set CONFIG(geometry.StartCol)  1
   set CONFIG(geometry.StartRow)  1
   set CONFIG(geometry.NumCols)   [lindex [split $ANDOR_DEF(fullframe) ,] 1]
   set CONFIG(geometry.NumRows)   [lindex [split $ANDOR_DEF(fullframe) ,] 3]
   mimicMode red roi 1024x1024
   mimicMode blue roi 1024x1024
   if { $ANDOR_CFG(kineticMode) } {
     commandAndor red "setframe fullframe"
     commandAndor blue "setframe fullframe"
   } else {
     commandAndor red "setframe fullkinetic"
     commandAndor blue "setframe fullkinetic"
   }
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
  updateRedisTelemetry mode acquiring
  if { $rdim != "manual"} {
        set ANDOR_CFG(binning) 1
        commandAndor red  "setbinning $ANDOR_CFG(binning) $ANDOR_CFG(binning)"
        commandAndor blue "setbinning $ANDOR_CFG(binning) $ANDOR_CFG(binning)"
        commandAndor red  "setframe fullframe"
        commandAndor blue "setframe fullframe"
###        positionZabers fullframe
  }
  set numframes $SCOPE(numframes)
  set numseq $SCOPE(numseq)
  set SCOPE(numframes) 1
  set SCOPE(numseq) 1
  if { $rdim != "manual" } {
    set LASTACQ "fullframe"
    startsequence ignore
    set SCOPE(seqnum) [expr $SCOPE(seqnum) -1]
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
    set SCOPE(blue,bias) [expr int([lindex $resb 2])]
    set SCOPE(blue,peak) [expr int([lindex $resb 3])]
  }
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
        puts stdout "selected blue region $r"
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
#    .lowlevel.rmode configure -text "Mode=ROI"
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
#    .lowlevel.rmode configure -text "Mode=Wide field"
    if { $ANDOR_CFG(kineticMode) } {
      commandAndor red "setframe fullkinetic"
      commandAndor blue "setframe fullkinetic"
    } else {
      commandAndor red "setframe fullframe"
      commandAndor blue "setframe fullframe"
    }
  }
  set SCOPE(numframes) $numframes
  set SCOPE(numseq) $numseq
}


## Documented proc \c checkgain .
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
     set res [exec $SPECKLE_DIR/gui-scripts/autogain.py $SPECKLE_DIR/$table $INSTRUMENT(red,emgain) $SCOPE(red,peak)]
     if { [lindex [split $res \n] 6] == "Changes to EM Gain are recommended." } {
       if { $INSTRUMENT(red,autoemccd) } {
         set newgain [lindex [split [lindex [lindex [split $res \n] 7] 3] =] 1]
         commandAndor red "emccdgain $newgain"
debuglog "want to set red emgain to $newgain"
         set INSTRUMENT(red,emgain) $newgain
       } else {
         set it [tk_dialog .d "RED CAMERA EM GAIN" $res {} -1 "NO" "OK"]
         if { $it } {
            set INSTRUMENT(red,emgain) $newgain
         }
       }
     }
   }
  }
  catch { 
   if { $INSTRUMENT(blue,emcheck) } {
     set res [exec $SPECKLE_DIR/gui-scripts/autogain.py $SPECKLE_DIR/$table $INSTRUMENT(blue,emgain) $SCOPE(blue,peak)]
     if { [lindex [split $res \n] 6] == "Changes to EM Gain are recommended." } {
       if { $INSTRUMENT(blue,autoemccd) } {
         set newgain [lindex [split [lindex [lindex [split $res \n] 7] 3] =] 1]
         set INSTRUMENT(blue,emgain) $newgain
debuglog "want to set blue emgain to $newgain"
       } else {
          set it [tk_dialog .d "BLUE CAMERA EM GAIN" $res {} -1 "NO" "OK"]
          if { $it } {
            set INSTRUMENT(blue,emgain) $newgain
          }
       }
     }
   }
  }
}

## Documented proc \c checkDataRate .
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
      .lowlevel.datarate configure -text "Data Rate : $ANDOR_CFG(mbps) MB/s" -fg yellow
   } else {
      .lowlevel.datarate configure -text "Data Rate : $ANDOR_CFG(mbps) MB/s" -fg NavyBlue
   }
}

## Documented proc \c updateTemps .
# 
#  This routine checks the temperatures
#
#
proc updateTemps { } {
     set redtemp  [lindex [commandAndor red gettemp] 0]
     set bluetemp  [lindex [commandAndor blue gettemp] 0]
     mimicMode red temp "[format %5.1f [lindex $redtemp 0]] degC"
     mimicMode blue temp "[format %5.1f [lindex $bluetemp 0]] degC"
     if { $redtemp > -55 } {
        .main.rcamtemp configure -fg orange
     } else {
        .main.rcamtemp configure -fg blue
     }
     if { $bluetemp > -55 } {
        .main.bcamtemp configure -fg orange
     } else {
        .main.bcamtemp configure -fg blue
     }
     .main.rcamtemp configure -text "[format %5.1f [lindex $redtemp 0]] degC"
     .main.bcamtemp configure -text "[format %5.1f [lindex $bluetemp 0]] degC"
}

## Documented proc \c prepsequence .
# 
#  This routine prepares for a sequence of exposures. 
#
#  Globals    :  
#               SCOPE	- Telescope parameters, gui setup
#		ANDOR_DEF - Andor defaults
#		ANDOR_CFG - Array of camera settings
#               SCOPE	- Telescope parameters, gui setup
#		DATAQUAL - Array of data quality information
#		INSTRUMENT - Array of instrument configuration data
#
proc prepsequence { } {
global SCOPE DATAQUAL INSTRUMENT TELEMETRY STATUS
global ANDOR_CCD ANDOR_EMCCD ANDOR_CFG
 redisUpdate
 catch {updateGeminiTelemetry}
 specklesynctelem red
 specklesynctelem blue
 set SCOPE(exposureStart) [expr [clock milliseconds]/1000.0]
 .lowlevel.p configure -value 0.0
 .lowlevel.seqp configure -value 0
 if { $SCOPE(numaccum) > 1 } {
    setfitsbits ULONG_IMG
 } else {
    setfitsbits USHORT_IMG
 }
 setBinning
 commandAndor red  "readmode 4"
 commandAndor blue "readmode 4"
 speckleshutter red auto
 speckleshutter blue auto
 if { $STATUS(exposureMode) == "clone" } {
   set SCOPE(exposureRed) $SCOPE(exposure)
   commandAndor red  "setexposure $SCOPE(exposure)"
 } else {
   if { [checkAutoFilter] == 0 } {
      foreach i "1 2 3 4 5 6" { set FWHEELS(red,$i,exp) $SCOPE(exposureRed) }
   }
   commandAndor red  "setexposure $SCOPE(exposureRed)"
 }
 commandAndor blue "setexposure $SCOPE(exposure)"
 commandAndor red  "imagetype $SCOPE(exptype)"
 commandAndor blue "imagetype $SCOPE(exptype)"
# commandAndor red  "triggermode 1"
# commandAndor blue "triggermode 1"
 commandAndor red  "frametransfer $ANDOR_CFG(red,frametransfer)"
 commandAndor blue "frametransfer $ANDOR_CFG(blue,frametransfer)"
 commandAndor red  "accumulationcycletime 0.0"
 commandAndor blue "accumulationcycletime 0.0"
 commandAndor red  "numberaccumulations $SCOPE(numaccum)"
 commandAndor blue "numberaccumulations $SCOPE(numaccum)"
 commandAndor red  "numberkinetics $SCOPE(numframes)"
 commandAndor blue "numberkinetics $SCOPE(numframes)"
 commandAndor red  "kineticcycletime 0.0"
 commandAndor blue "kineticcycletime 0.0"
 set tred [commandAndor red "gettimings"]
 set tblue [commandAndor blue "gettimings"]
 commandAndor red  "programid $SCOPE(ProgID)"
 commandAndor blue "programid $SCOPE(ProgID)"
 if { [lsearch [split $SCOPE(ProgID) "-"] "FT"] > -1 } {
   set TELEMETRY(speckle.scope.release) [getPropDate 6]
 } else {
   set TELEMETRY(speckle.scope.release) [getPropDate 12]
 }
 commandAndor red  "autofitds9 $INSTRUMENT(red,fitds9)"
 commandAndor blue "autofitds9 $INSTRUMENT(blue,fitds9)"
 set chk [checkgain]
 if { $INSTRUMENT(red,emccd) } {
   commandAndor red "outputamp $ANDOR_EMCCD"
   commandAndor red "emadvanced $INSTRUMENT(red,highgain)"
   commandAndor red "emccdgain $INSTRUMENT(red,emgain)"
   commandAndor red "hsspeed 0 $ANDOR_CFG(red,EMHSSpeed)"
 } else {
   commandAndor red "outputamp $ANDOR_CCD"
   commandAndor red "hsspeed 1 $ANDOR_CFG(red,HSSpeed)"
 }
 if { $INSTRUMENT(blue,emccd) } {
   commandAndor blue "outputamp $ANDOR_EMCCD"
   commandAndor blue "emadvanced $INSTRUMENT(blue,highgain)"
   commandAndor blue "emccdgain $INSTRUMENT(blue,emgain)"
   commandAndor blue "hsspeed 0 $ANDOR_CFG(blue,EMHSSpeed)"
 } else {
   commandAndor blue "outputamp $ANDOR_CCD"
   commandAndor blue "hsspeed 1 $ANDOR_CFG(blue,HSSpeed)"
 }
 commandAndor red  "vsspeed $ANDOR_CFG(red,VSSpeed)"
 commandAndor blue "vsspeed $ANDOR_CFG(blue,VSSpeed)"
 if { $ANDOR_CFG(kineticMode) } {
    commandAndor red  "acquisitionmode 5"
    commandAndor blue "acquisitionmode 5"
 } else {
    if { $SCOPE(numaccum) > 1 } {
      commandAndor red  "acquisitionmode 2"
      commandAndor blue "acquisitionmode 2"
    } else {
      commandAndor red  "acquisitionmode 1"
      commandAndor blue "acquisitionmode 1"
    }
 }
 debuglog "Red camera timings are $tred,  Blue camera timings are $tblue"
 commandAndor red  "dqtelemetry $DATAQUAL(rawiq) $DATAQUAL(rawcc) $DATAQUAL(rawwv) $DATAQUAL(rawbg)"
 commandAndor blue "dqtelemetry $DATAQUAL(rawiq) $DATAQUAL(rawcc) $DATAQUAL(rawwv) $DATAQUAL(rawbg)"
 commandAndor red   "extraheaders $TELEMETRY(speckle.scope.release) $TELEMETRY(tcs.telescope.guider)"
 commandAndor blue  "extraheaders $TELEMETRY(speckle.scope.release) $TELEMETRY(tcs.telescope.guider)"
 commandAndor red "datadir $SCOPE(datadir)"
 commandAndor blue "datadir $SCOPE(datadir)"
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
#		FWHEELS - Filter data
#               OBSPARS	- Default observation parameters
#               STATUS	- Exposure status
#               DEBUG	- Set to 1 for verbose logging
#		TELEMETRY - Array of telemetry for headers and database usage
#		DATAQUAL - Array of data quality information
#		INSTRUMENT - Array of instrument configuration data
#
proc startsequence { {save keep} } {
global SCOPE OBSPARS FWHEELS STATUS DEBUG REMAINING LASTACQ TELEMETRY DATAQUAL SPECKLE_FILTER INSTRUMENT
global ANDOR_CCD ANDOR_EMCCD ANDOR_CFG ANDOR_SHUTTER
if { $ANDOR_CFG(videomode) == 0 } {
 set iseqnum 0
 set STATUS(observing) 1
 prepsequence
 cameraStatuses
 catch {
  set x [andorSetControl 0 frame 0]
  set x [andorSetControl 1 frame 0]
 }
 if { $SCOPE(exptype) == "Test" } {
    exec rm -f $SCOPE(datadir)/TESTr.fits
    exec rm -f $SCOPE(datadir)/TESTb.fits
    commandAndor red "imagename TEST 1"
    commandAndor blue "imagename TEST 1"
    acquireTest
    set STATUS(observing) 0
    return
 }
 set autofilter [checkAutoFilter blue]
 set rautofilter [checkAutoFilter red]
 set FWHEELS(red,exposure) $SCOPE(exposure)
 set FWHEELS(blue,exposure) $SCOPE(exposure)
 set SCOPE(maxExposure) $SCOPE(exposure)
 while { $autofilter != "" } {
   set bfilter [lindex $autofilter 0]
   if { $bfilter > 0 } {
    selectfilter blue $bfilter
    commandAndor blue "filter $SPECKLE_FILTER(blue,current)"
    commandAndor blue "emccdgain $FWHEELS(blue,$bfilter,emgain)"
    set FWHEELS(blue,exposure) $FWHEELS(blue,$bfilter,exp)
    set SCOPE(exposure) $FWHEELS(blue,$bfilter,exp)
    commandAndor blue  "setexposure $SCOPE(exposure)"
   }
   set rfilter [lindex $rautofilter 0]
   if { $rfilter > 0 } {
    selectfilter red $rfilter
    commandAndor red  "filter $SPECKLE_FILTER(red,current)"
    commandAndor red "emccdgain $FWHEELS(red,$rfilter,emgain)"
    set FWHEELS(red,exposure) $FWHEELS(red,$rfilter,exp)
    set SCOPE(exposureRed) $FWHEELS(red,$rfilter,exp)
    commandAndor red "setexposure $SCOPE(exposureRed)"
    if { $SCOPE(exposureRed) > $  } {
        set SCOPE(maxExposure) $SCOPE(exposureRed)
    }
   }
   set autofilter [lrange $autofilter 1 end]
   set rautofilter [lrange $rautofilter 1 end]
   set iseqnum 0
   updateRedisTelemetry mode observing
   updateRedisTelemetry exposure $SCOPE(exptype)
   set STATUS(abort) 0
   while { $iseqnum < $SCOPE(numseq) && $STATUS(abort) == 0  } {
    .lowlevel.p configure -value 0
    set ifrmnum 0
    incr iseqnum 1
    .lowlevel.seqp configure -value [expr $iseqnum*100/$SCOPE(numseq)]
    .main.abort configure -bg orange -relief raised -fg black -command abortsequence
    while { $ifrmnum < $SCOPE(numframes) } {
     set clncmt [join [split [.main.comment get 0.0 end] "\`\"\'\[\]\{\}\&\%\$\\"] _]
     set cmt [join [split [string trim $clncmt] \n] "|"]
     commandAndor red "comments $cmt"
     commandAndor blue "comments $cmt"
     incr ifrmnum 1
     set dfrmnum $ifrmnum
     set OBSPARS($SCOPE(exptype)) "$SCOPE(exposure) $SCOPE(numframes) $SCOPE(shutter)"
     set STATUS(abort) 0
     .main.observe configure -text "working" -bg yellow -relief sunken
     .main.abort configure -bg orange -relief raised -fg black -command abortsequence
     wm geometry .countdown
     set i 1
     if { $SCOPE(exptype) == "Zero" || $SCOPE(exptype) == "Dark" } {
       speckleshutter red close
       speckleshutter blue close
      } else {
       speckleshutter red during
       speckleshutter blue during
     }
     after 200
     if { $save == "ignore" } {
        exec rm -f $SCOPE(datadir)/forROIr.fits
        exec rm -f $SCOPE(datadir)/forROIb.fits
        commandAndor red "imagename forROI 1"
        commandAndor blue "imagename forROI 1"
     } else {
       commandAndor red "imagename $SCOPE(imagename)[format %4.4d $SCOPE(seqnum)] $SCOPE(overwrite)"
       commandAndor blue "imagename $SCOPE(imagename)[format %4.4d $SCOPE(seqnum)] $SCOPE(overwrite)"
     }
     incr SCOPE(seqnum) 1
     updateTemps
     if { $STATUS(exposureMode) == "clone" } {
       set tpredict [expr [lindex [commandAndor red status] 15] - 0.001]
       if { $tpredict > $SCOPE(exposure) } {
          set SCOPE(exposure) $tpredict
          .main.exposure configure -entryfg red
       } else {
          .main.exposure configure -entryfg black
       }
     }
     if { $LASTACQ == "fullframe" } {
        set TELEMETRY(speckle.andor.mode) "fullframe"
     } else {
        set TELEMETRY(speckle.andor.mode) "roi"
     }
     set doneset 0
     if { $SCOPE(numframes) > 1 } {
           checkDatarate
           acquireCubes
           set ifrmnum $SCOPE(numframes)
           set perframe [expr $SCOPE(maxExposure)*$SCOPE(numaccum)]
           set totaltime [expr $perframe * 2.0 * $SCOPE(numframes) +5]
     } else {
           .lowlevel.datarate configure -text ""
           set perframe $SCOPE(maxExposure)
           set totaltime [expr $perframe * $SCOPE(numframes) +1]
           acquireFrames
           after 1000
     }
     set now [clock seconds]
     andorSetControl 0 frame 0
     while { $i < $SCOPE(numframes)  && $STATUS(abort) == 0} {
        set elapsedtime [expr [clock seconds] - $now]
        if { $DEBUG} {debuglog "$iseqnum  / $SCOPE(numseq) : $SCOPE(exptype) frame $i"}
        after 20
        if { $LASTACQ == "fullframe" } {
           set i $SCOPE(numframes)
           if { $SCOPE(exposure) > 1 } {
              longExpProgress $SCOPE(maxExposure)
           } else {
              after [expr int($SCOPE(maxExposure)*1000)]
           }
        } else {
           set i [andorGetControl 0 frame]
           if { $SCOPE(exposure) > 1 } {
              longExpProgress $SCOPE(maxExposure)
           } else {
              after [expr int($SCOPE(maxExposure)*1010)]
           }
        }
        .lowlevel.p configure -value [expr $i*100/$SCOPE(numframes)]
        .lowlevel.progress configure -text "Observation status : Frame $i   Exposure $dfrmnum   Sequence $iseqnum / $SCOPE(numseq)"
        if { $elapsedtime > $totaltime } { set i $SCOPE(numframes) ; set doneset 1}
        update
     }
     debuglog "Exited frames loop"
     set SCOPE(exposureEnd) [expr [clock milliseconds]/1000.0]
     .main.observe configure -text "Observe" -bg green -relief raised
     .main.abort configure -bg gray -relief sunken -fg LightGray
#     speckleshutter red close
#     speckleshutter blue close
     .lowlevel.p configure -value 0
     .lowlevel.progress configure -text "Observation status : Idle"
     if { $STATUS(abort) && $autofilter == "" } {
        updateRedisTelemetry mode idle
        .lowlevel.p configure -value 0
        .lowlevel.seqp configure -value 0
        audioNote
        set STATUS(observing) 0
        return
     }
    }
   }
 }
 updateRedisTelemetry mode idle
 after 500
 abortsequence
 audioNote
 if { $SCOPE(autoclrcmt) && $save == "keep" } {.main.comment delete 0.0 end }
}
}

proc longExpProgress { exp } {
   set t 0
   while { $t <= $exp } {
      .lowlevel.p configure -value [expr $t*100/$exp]
       incr t 1
       after 1000
       update
   }
   after 300
   .lowlevel.p configure -value 0
}



# \endcode


set SCOPE(red,bias) 0
set SCOPE(blue,bias) 0
set SCOPE(red,peak) 0
set SCOPE(blue,peak) 0
set STATUS(observing) 0

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






