#!/usr/bin/wish
## \file andorCameraServer.tcl
# \brief This contains procedures for the camera servers
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
## Documented proc \c debuglog .
# \param[in] msg Text of debug message
#
#  Output a debug message to the log file. Log files are saved in the /tmp
#  directory with names like /tmp/speckle_12345678.log
#
proc debuglog { msg } {
   puts stdout $msg
}

## Documented proc \c cAndorSetProperty .
# \param[in] arm Name of intrument arm red/blue
# \param[in] prop Camera property name
# \param[in] val Value to set the the property to 
# \param[in] val2 Optional second value for HSSpeed usage
#
#  This wraps the low level (C) shared library calls which set camera properties
#  e.g it will call methods like SetExpsoureTime. It records the results of 
#  sucessfull calls in the ANDOR_CFG array for easy access from the tcl side
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue
#
proc cAndorSetProperty { cam prop val {val2 ""} } {
global ANDOR_CFG ANDOR_ARM
  set res "SetProperty failed"
  catch {
   if { $prop == "HSSpeed" } {
      if { $val == 0 } { set res [andorSetProperty $cam HSSpeed 0 $val2] ; set prop EMHSSpeed}
      if { $val == 1 } { set res [andorSetProperty $cam HSSpeed 1 $val2]}
      set val $val2
   } else {
     set res [andorSetProperty $cam $prop $val]
   }
   if { $res == "" } {
     set ANDOR_CFG($cam,$prop) $val
     set ANDOR_CFG($ANDOR_ARM,$prop) $val
     puts stdout "Setting ANDOR_CFG($ANDOR_ARM,$prop) to $val"
   } else {
     set ANDOR_CFG($cam,$prop) "fail -$res"
     set ANDOR_CFG($ANDOR_ARM,$prop) "fail - $val"
     puts stdout "ERROR Setting ANDOR_CFG($ANDOR_ARM,$prop) to $val"
   }
  }
  return $res
}

## Documented proc \c setutc .
#
# Set the UT time and data globals
#
#
# Globals :
#		SCOPE - Array of telescope settings
#
proc setutc { {id 0} } {
global SCOPE CAMSTATUS
  set now [split [exec  date -u +%Y-%m-%d,%T.%U] ,]
  set SCOPE(obsdate) [lindex $now 0]
  set SCOPE(obstime) [lindex $now 1]
}



wm withdraw .

set SPECKLE_DIR $env(SPECKLE_DIR)
load $SPECKLE_DIR/lib/andorTclInit.so
load $SPECKLE_DIR/lib/libfitstcl.so
load $SPECKLE_DIR/lib/libccd.so
load $SPECKLE_DIR/lib/libguider.so
set ckey [string tolower $env(TELESCOPE)]
source $SPECKLE_DIR/andor/andor.tcl
source $SPECKLE_DIR/andorsConfiguration.[set ckey]
source $SPECKLE_DIR/gui-scripts/headerBuilder.tcl 
source $SPECKLE_DIR/gui-scripts/camera_init.tcl 
if { $env(TELESCOPE) == "GEMINI" } {
  proc redisUpdate { } { }
  set SCOPE(telescope) "GEMINI"
  set SCOPE(instrument) "Alopeke"
  source $SPECKLE_DIR/gui-scripts/gemini_telemetry.tcl 
  set GEMINITLM(sim) 0
  if { [info exists env(SPECKLE_SIM)] } {
    set simdev [split $env(SPECKLE_SIM) ,]
    if { [lsearch $simdev telemetry] > -1 } {
       set GEMINITLM(sim) 1
       debuglog "Gemini telemetry in SIMULATION mode"
       simGeminiTelemetry
   }
  } else {
    geminiConnect north
  }
} else {
  set SCOPE(telescope) WIYN
}


set cameraNum [lindex $argv 0]
set hstart [lindex $argv 1]
set hend   [lindex $argv 2]
set vstart [lindex $argv 3]
set vend   [lindex $argv 4]
set SPECKLE_DATADIR $env(SPECKLE_DATADIR)

debuglog "Establishing server for camera $cameraNum"
debuglog "hstart =  $hstart"
debuglog "hend =  $hend"
debuglog "vstart =  $vstart"
debuglog "vend =  $vend"
set ncam [GetAvailableCameras]
debuglog "Detected $ncam cameras"

set handle -1
set handle [andorConnectCamera $cameraNum]
if { $handle < 0} {exit}

debuglog "Connected to camera $cameraNum, handle = $handle"
set CAM [expr $cameraNum - 1]
cAndorSetProperty $CAM OutputAmplifier 0
cAndorSetProperty $CAM AcquisitionMode 1
cAndorSetProperty $CAM ReadMode 4
set ANDOR_CFG(fitds9) 0
set ANDOR_CFG($CAM,PreAmpGain) 1
set ANDOR_CFG($CAM,VSSpeed) 1
set ANDOR_CFG($CAM,HSSpeed) 0
set ANDOR_CFG($CAM,EMHSSpeed) 1
set ANDOR_CFG($CAM,hbin) 1
set ANDOR_CFG($CAM,vbin) 1
set ANDOR_CFG(configure) "1 1 1 1024 1 1024 1 1 0 1"
andorConfigure $CAM 1 1 1 1024 1 1024 $ANDOR_CFG($CAM,PreAmpGain) $ANDOR_CFG($CAM,VSSpeed) $ANDOR_CFG($CAM,HSSpeed) $ANDOR_CFG($CAM,EMHSSpeed)
debuglog "Configured camera id $CAM for ccd mode"

set ANDOR_CFG(red) -1
set ANDOR_CFG(blue) -1
set ANDOR_CFG($CAM,SerialNumber) "X-[GetCameraSerialNumber]"
debuglog "Camera $CAM is serial number $ANDOR_CFG($CAM,SerialNumber) = $ANDORS($ANDOR_CFG($CAM,SerialNumber)) arm"
if { $ANDOR_CFG($CAM,SerialNumber) == $ANDORS(red,serialnum) }  {
  set ANDOR_CFG(red) $CAM
  debuglog "ANDOR_CFG(red) = $ANDOR_CFG(red)"
  set ANDOR_ARM red
  set ANDOR_CFG(cmap) Heat
}
if { $ANDOR_CFG($CAM,SerialNumber) == $ANDORS(blue,serialnum) } {
  set ANDOR_CFG(blue) $CAM
  debuglog "ANDOR_CFG(blue) = $ANDOR_CFG(blue)"
  set ANDOR_ARM blue
  set ANDOR_CFG(cmap) Cool
}
foreach i "GetCameraSerialNumber GetEMAdvanced GetEMCCDGain GetFIFOUsage GetFilterMode GetImageRotate GetKeepCleanTime GetMaximumExposure GetMaximumNumberRingExposureTimes GetMinimumImageLength GetMinimumNumberInSeries GetNumberADChannels GetNumberAmp GetNumberDevices GetNumberFKVShiftSpeeds GetNumberHorizontalSpeeds GetNumberIO GetNumberPreAmpGains GetNumberRingExposureTimes GetNumberVSAmplitudes GetNumberVSSpeeds GetNumberVerticalSpeeds GetReadOutTime GetStartUpTime GetStatus GetTotalNumberImagesAcquired" {
     set ANDOR_CFG($CAM,[string range $i 3 end]) "[$i]"
     debuglog "$CAM : $i = $ANDOR_CFG($CAM,[string range $i 3 end])"
}

set shmid [andorConnectShmem[set CAM] 1024 1024]
debuglog "$ANDOR_ARM memory buffers @ $shmid"
set shmid2 [andorConnectShmem2]
debuglog "Andors control registers @ $shmid2"

set DS9 ds9[set ANDOR_ARM]
initads9 [lindex $shmid 0] 1024 1024
set TELEMETRY(tcs.telescope.ra) "12:00:00"
set TELEMETRY(tcs.telescope.dec) "32:00:00"
set SCOPE(telescope) $env(TELESCOPE)

set ANDOR_CFG(shmem) [lindex $shmid 0]
exec xpaset -p $DS9 single
exec xpaset -p $DS9 zoom to fit
exec xpaset -p $DS9 scale zscale
if { $ANDOR_ARM == "red" } {
   exec xpaset -p $DS9 cmap Heat
} else {
   exec xpaset -p $DS9 cmap Cool
}

andorPrepDataFrame
cAndorSetProperty $CAM Temperature -60
cAndorSetProperty $CAM Cooler 1
cAndorSetProperty $CAM OutputAmplifier 0
cAndorSetProperty $CAM AcquisitionMode 1
cAndorSetProperty $CAM ReadMode 4
cAndorSetProperty $CAM Shutter 0
cAndorSetProperty $CAM ExposureTime 0.04
cAndorSetProperty $CAM FrameTransferMode 1
cAndorSetProperty $CAM KineticCycleTime 0.0
cAndorSetProperty $CAM NumberAccumulations 1
cAndorSetProperty $CAM NumberKinetics 1
cAndorSetProperty $CAM AccumulationCycleTime 0.0
cAndorSetProperty $CAM EMAdvanced 1
cAndorSetProperty $CAM EMCCDGain 1
cAndorSetProperty $CAM VSSpeed 1
cAndorSetProperty $CAM BaselineClamp 1
cAndorSetProperty $CAM PreAmpGain 0
cAndorSetProperty $CAM HSSpeed 1 0
cAndorSetProperty $CAM HSSpeed 0 1
set ANDOR_CFG($ANDOR_ARM,min) 300
set ANDOR_CFG($ANDOR_ARM,peak) 1000
	
# Special incantations to "make things work"
#SetAcquisitionMode 5
#PrepareAcquisition
#andorStartAcq
#after 1000
#andorAbortAcq

## Documented proc \c connectads9 .
#
#  Reconnect to a ds9 instance
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		CAM - Andor camera id used in the C code, 0 or 1
#
proc connectads9 { } {
global ANDOR_CFG CAM SPECKLE_DIR DS9 ANDOR_ARM
   initads9 $ANDOR_CFG(shmem) 1024 1024
   exec xpaset -p $DS9 single
   if { $ANDOR_CFG(fitds9) } {
      exec xpaset -p $DS9 zoom to fit
   } else {
      exec xpaset -p $DS9 zoom 1
   }
   exec xpaset -p $DS9 scale zscale
   if { $ANDOR_ARM == "red" } {
      exec xpaset -p $DS9 cmap Heat
   } else {
      exec xpaset -p $DS9 cmap Cool
   }
   exec xpaset -p $DS9 source $SPECKLE_DIR/andor/ds9refresher.tcl
   debuglog "Reconnected to ds9 $DS9"
}

## Documented proc \c warmUpCamera .
#
#  Warm up the camera
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		CAM - Andor camera id used in the C code, 0 or 1
#
proc warmUpCamera { } {
global ANDOR_CFG CAM ANDOR_ARM
   cAndorSetProperty $CAM "Temperature -20.0"
   set warming 1
   while { $warming } {
      set tnow [andorGetProperty $CAM temperature]
      if { $tnow > -21  } {set warming 0}
      after 5000
   }
   cAndorSetProperty $CAM Cooler 0
}


## Documented proc \c showstatus .
#
#  Prints the current camera settings to the debug log
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		CAM - Andor camera id used in the C code, 0 or 1
#
proc showstatus { } {
global CAM ANDOR_CFG
  foreach i "GetCameraSerialNumber GetEMAdvanced GetEMCCDGain GetFIFOUsage GetFilterMode GetImageRotate GetKeepCleanTime GetMaximumExposure GetMaximumNumberRingExposureTimes GetMinimumImageLength GetMinimumNumberInSeries GetNumberADChannels GetNumberAmp GetNumberDevices GetNumberFKVShiftSpeeds GetNumberHorizontalSpeeds GetNumberIO GetNumberPreAmpGains GetNumberRingExposureTimes GetNumberVSAmplitudes GetNumberVSSpeeds GetNumberVerticalSpeeds GetReadOutTime GetStartUpTime GetStatus GetTotalNumberImagesAcquired" {
     set ANDOR_CFG($CAM,[string range $i 3 end]) "[$i]"
     debuglog "$CAM : $i = $ANDOR_CFG($CAM,[string range $i 3 end])"
  }
  foreach i "Shutter FrameTransferMode OutputAmplifier EMHSSpeed HSSpeed VSSpeed PreAmpGain ReadMode AcquisitionMode KineticCycleTime NumberAccumulations NumberKinetics AccumulationCycleTime EMCCDGain EMAdvanced" {
     debuglog "$CAM : $i = $ANDOR_CFG($CAM,$i)"
     lappend s $ANDOR_CFG($CAM,$i)
  }
  set t [andorGetProperty $CAM timings]
  foreach x $t { lappend s $x }
  return $s
} 


## Documented proc \c resetCamera .
# \param[in] mode The new camera mode , either fullframe or roi
#
#  Reset the camera frame dimensions, binning and readout parameters
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		CAM - Andor camera id used in the C code, 0 or 1
#
proc resetCamera { mode } {
global CAM ANDOR_CFG
   andorShutDown
   set handle [andorConnectCamera [expr $CAM+1]]
   if { $mode == "fullframe" } {
     debuglog "Connected to camera $CAM for fullframe, handle = $handle"
     andorConfigure $CAM $ANDOR_CFG($CAM,hbin) $ANDOR_CFG($CAM,vbin) 1 1024 1 1024 $ANDOR_CFG($CAM,PreAmpGain) $ANDOR_CFG($CAM,VSSpeed) $ANDOR_CFG($CAM,HSSpeed) $ANDOR_CFG($CAM,EMHSSpeed)
   }
   if { $mode == "roi" } {
     debuglog "Connected to camera $CAM for ROI, handle = $handle"
     andorConfigure $CAM $ANDOR_CFG($CAM,hbin) $ANDOR_CFG($CAM,vbin) 1 256 1 256 $ANDOR_CFG($CAM,PreAmpGain) $ANDOR_CFG($CAM,VSSpeed) $ANDOR_CFG($CAM,HSSpeed) $ANDOR_CFG($CAM,EMHSSpeed)
   }
}

## Documented proc \c configureFrame .
# \param[in] mode The new camera mode , either fullframe or roi
#
#  Reset the camera frame dimensions, binning and readout parameters, and acquisition
#  mode for either single frame or kinetics
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		ANDOR_ROI - Region of interest parameters\n
#		CAM - Andor camera id used in the C code, 0 or 1\n
#		SCOPE - Array of telescope settings
#
proc configureFrame { mode } {
global CAM ANDOR_ROI ANDOR_CFG SCOPE TELEMETRY
   if { $mode == "fullframe" } {
     debuglog "Configure camera $CAM for fullframe"
     andorConfigure $CAM $ANDOR_CFG($CAM,hbin) $ANDOR_CFG($CAM,vbin) 1 1024 1 1024 $ANDOR_CFG($CAM,PreAmpGain) $ANDOR_CFG($CAM,VSSpeed) $ANDOR_CFG($CAM,HSSpeed) $ANDOR_CFG($CAM,EMHSSpeed)
     cAndorSetProperty $CAM AcquisitionMode 1
     set TELEMETRY(speckle.andor.kinetic_mode) 0
     cAndorSetProperty $CAM OutputAmplifier 0
     set SCOPE(numframes) 1
   }
   if { $mode == "roi" } {
     debuglog "Configure camera $CAM for ROI : $ANDOR_ROI(xs) $ANDOR_ROI(xe) $ANDOR_ROI(ys) $ANDOR_ROI(ye)"
     andorConfigure $CAM $ANDOR_CFG($CAM,hbin) $ANDOR_CFG($CAM,vbin)  $ANDOR_ROI(xs) $ANDOR_ROI(xe) $ANDOR_ROI(ys) $ANDOR_ROI(ye) $ANDOR_CFG($CAM,PreAmpGain) $ANDOR_CFG($CAM,VSSpeed) $ANDOR_CFG($CAM,HSSpeed) $ANDOR_CFG($CAM,EMHSSpeed)
     set TELEMETRY(speckle.andor.kinetic_mode) 1
     if { $ANDOR_CFG($CAM,NumberAccumulations) > 1 } {
        cAndorSetProperty $CAM AcquisitionMode 2
     } else {
       cAndorSetProperty $CAM AcquisitionMode 3
    }
     cAndorSetProperty $CAM OutputAmplifier 0
   }
   if { $mode == "fullkinetic" } {
     debuglog "Configure camera $CAM for fullframe"
     andorConfigure $CAM $ANDOR_CFG($CAM,hbin) $ANDOR_CFG($CAM,vbin) 1 1024 1 1024 $ANDOR_CFG($CAM,PreAmpGain) $ANDOR_CFG($CAM,VSSpeed) $ANDOR_CFG($CAM,HSSpeed) $ANDOR_CFG($CAM,EMHSSpeed)
     set TELEMETRY(speckle.andor.kinetic_mode) 1
     if { $ANDOR_CFG($CAM,NumberAccumulations) > 1 } {
        cAndorSetProperty $CAM AcquisitionMode 2
     } else {
        cAndorSetProperty $CAM AcquisitionMode 3
     }
     cAndorSetProperty $CAM OutputAmplifier 0
   }
}

## Documented proc \c acquireDataFrame .
# \param[in] exp Exposure time in seconds 
#
#  Take a single exposure
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		SPECKLE_DATADIR - Directory path to data storage\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue
#		ACQREGION - Region of interest parameters\n
#		CAM - Andor camera id used in the C code, 0 or 1\n
#		DS9 - Name of ds9 executable for display ds9red or ds9blue
#		TELEMETRY - Array of telemetry items for header/database usage
#
proc acquireDataFrame { exp } {
global ANDOR_CFG SPECKLE_DATADIR ANDOR_ARM DS9 TELEMETRY ACQREGION CAM
    debuglog "Starting $ANDOR_ARM full-frame with exposure = $exp"
    redisUpdate
    setutc
    set t [clock seconds]
    set ACQREGION(geom) 1024
    set dimen [expr $ACQREGION(geom)/$ANDOR_CFG(binning)]
    set TELEMETRY(speckle.andor.exposureStart) [expr [clock microseconds]/1000000.]
    set TELEMETRY(speckle.andor.numexp) 1
    set TELEMETRY(speckle.andor.numberkinetics) 0
    exec xpaset -p $DS9 shm array shmid $ANDOR_CFG(shmem) \\\[xdim=$dimen,ydim=$dimen,bitpix=32\\\]
    cAndorSetProperty $CAM ExposureTime $exp
    if { $ANDOR_CFG(red) > -1} {
      set TELEMETRY(speckle.andor.peak_estimate) [andorGetData $ANDOR_CFG(red)]
      andorSaveData $ANDOR_CFG(red) $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]r.fits $dimen $dimen 1 1
      set TELEMETRY(speckle.andor.exposureEnd) [expr [clock microseconds]/1000000.]
      appendHeader $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]r.fits
      after 400
      exec xpaset -p $DS9 frame 2
      exec xpaset -p $DS9 cmap $ANDOR_CFG(cmap)
      exec xpaset -p $DS9 file $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]r.fits
    }
    if { $ANDOR_CFG(blue) > -1 } {
      set TELEMETRY(speckle.andor.peak_estimate) [andorGetData $ANDOR_CFG(blue)]
      andorSaveData $ANDOR_CFG(blue) $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]b.fits $dimen $dimen 1 1
      set TELEMETRY(speckle.andor.exposureEnd) [expr [clock microseconds]/1000000.]
      appendHeader $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]b.fits
      after 400
      exec xpaset -p $DS9 frame 2
      exec xpaset -p $DS9 cmap $ANDOR_CFG(cmap)
      exec xpaset -p $DS9 file $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]b.fits
    }
    if { $ANDOR_CFG(fitds9) } {
       exec xpaset -p $DS9 zoom to fit
    } else {
       exec xpaset -p $DS9 zoom 1
    }
    puts stdout "$TELEMETRY(speckle.andor.peak_estimate)"
    updateds9wcs $TELEMETRY(tcs.telescope.ra) $TELEMETRY(tcs.telescope.dec)
    updateDatabase
}

## Documented proc \c acquireDataROI .
# \param[in] exp Exposure time in seconds 
# \param[in] x Starting column number
# \param[in] y Starting row number
# \param[in] n Number of exposures
#  Take exposures of a region of interest
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		SPECKLE_DATADIR - Directory path to data storage\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue
#		CAM - Andor camera id used in the C code, 0 or 1\n
#		DS9 - Name of ds9 executable for display ds9red or ds9blue
#		TELEMETRY - Array of telemetry items for header/database usage
#
proc acquireDataROI { exp x y n } {
global ANDOR_CFG SPECKLE_DATADIR ANDOR_ARM DS9 TELEMETRY ACQREGION CAM
    debuglog "Starting $ANDOR_ARM ROI sequence with exposure = $exp"
    redisUpdate
    setutc
    set t [clock seconds]
    cAndorSetProperty $CAM ExposureTime $exp
    set ACQREGION(geom) $n
    set TELEMETRY(speckle.andor.exposureStart) [expr [clock microseconds]/1000000.]
    if { $ANDOR_CFG(red) > -1} {
      andorSetROI $ANDOR_CFG(red) $x [expr $x+$n-1] $y [expr $y+$n-1] 1
      andorGetData $ANDOR_CFG(red)
      andorSaveData $ANDOR_CFG(red) $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]r.fits $n $n 1 1
      appendHeader $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]r.fits
      after 400
      exec xpaset -p $DS9 frame 1
      exec xpaset -p $DS9 cmap $ANDOR_CFG(cmap)
      exec xpaset -p $DS9 file $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]r.fits
    }
    if { $ANDOR_CFG(blue) > -1 } {
      andorSetROI $ANDOR_CFG(blue) $x [expr $x+$n-1] $y [expr $y+$n-1] 1
      andorGetData $ANDOR_CFG(blue)
      andorSaveData $ANDOR_CFG(blue) $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]b.fits $n $n 1 1
      appendHeader $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]b.fits
      after 400
      exec xpaset -p $DS9 frame 1
      exec xpaset -p $DS9 cmap $ANDOR_CFG(cmap)
      exec xpaset -p $DS9 file $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]b.fits
    }
    if { $ANDOR_CFG(fitds9) } {
       exec xpaset -p $DS9 zoom to fit
    } else {
       exec xpaset -p $DS9 zoom 1
    }
    set TELEMETRY(speckle.andor.exposureEnd) [expr [clock microseconds]/1000000.]
    updateds9wcs $TELEMETRY(tcs.telescope.ra) $TELEMETRY(tcs.telescope.dec)
}


## Documented proc \c acquireDataCube .
# \param[in] cid Camera Id , 0 or 1
# \param[in] fname FITS file name
# \param[in] nx Column count
# \param[in] ny Row count
# \param[in] count Current frame number
# \param[in] n Number of frames
#
#  Save cube exposures in kinetic mode
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties
#
proc andorSaveData { cid fname nx ny count n } {
global ANDOR_CFG
  switch $ANDOR_CFG(fitsbits) { 
      16   -
      20   { andorStoreFrameI2 $cid $fname $nx $ny $count $n }
      32   -
      40   { andorStoreFrameI4 $cid $fname $nx $ny $count $n }
      -32  { andorStoreFrame   $cid $fname $nx $ny $count $n }
  }
}

## Documented proc \c acquireDataCube .
# \param[in] exp Exposure time in seconds 
# \param[in] x Starting column number
# \param[in] y Starting row number
# \param[in] npix Frame dimension (x and y)
#
#  Take data cube exposures in kinetic mode
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		SPECKLE_DATADIR - Directory path to data storage\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue\n
#		ANDOR_ROI - Region of interest parameters\n
#		DS9 - Name of ds9 executable for display ds9red or ds9blue\n
#		TELEMETRY - Array of telemetry items for header/database usage
#
proc acquireDataCube { exp x y npix n } {
global ANDOR_CFG SPECKLE_DATADIR ANDOR_ARM ANDOR_ARM ANDOR_ROI DS9 TELEMETRY ACQREGION CAM
  debuglog "Starting $ANDOR_ARM roi cube sequence with exposure = $exp x=$x y=$y geom=$npix n=$n"
  redisUpdate
  setutc
  set scset [exec xpaget $DS9 scale]
  set ACQREGION(geom) $npix
  if { $ANDOR_ARM == "blue" } {
    exec xpaset -p $DS9 frame 1
    exec xpaset -p $DS9 shm array shmid $ANDOR_CFG(shmem) \\\[xdim=$npix,ydim=$npix,bitpix=32\\\]
    exec xpaset -p $DS9 cmap Cool
    if { $scset == "zscale" } {
      exec xpaset -p $DS9 scale limits $ANDOR_CFG(blue,min) [expr $ANDOR_CFG(blue,peak)*$ANDOR_CFG(scalepeak)]
    }
  }
  if { $ANDOR_ARM == "red" } {
    exec xpaset -p $DS9 frame 1
    exec xpaset -p $DS9 shm array shmid $ANDOR_CFG(shmem) \\\[xdim=$npix,ydim=$npix,bitpix=32\\\]
    exec xpaset -p $DS9 cmap Heat
    if { $scset == "zscale" } {
       exec xpaset -p $DS9 scale limits $ANDOR_CFG(red,min) [expr $ANDOR_CFG(red,peak)*$ANDOR_CFG(scalepeak)]
    }
  }
  if { $ANDOR_CFG(fitds9) } {
      exec xpaset -p $DS9 zoom to fit
  } else {
       exec xpaset -p $DS9 zoom 1
  }
  updateds9wcs $TELEMETRY(tcs.telescope.ra) $TELEMETRY(tcs.telescope.dec)
  refreshads9 [expr int($exp*2000)] [expr $n*4]
  set TELEMETRY(speckle.andor.numexp) $n
  set TELEMETRY(speckle.andor.exposureStart) [expr [clock microseconds]/1000000.]
  set TELEMETRY(speckle.andor.numberkinetics) $n
  cAndorSetProperty $CAM ExposureTime $exp
  if { $ANDOR_CFG(red) > -1} {
     andorSetROI $ANDOR_CFG(red) $x [expr $x+$npix-1] $y [expr $y+$npix-1] 1
  }
  if { $ANDOR_CFG(blue) > -1} {
     andorSetROI $ANDOR_CFG(blue) $x [expr $x+$npix-1] $y [expr $y+$npix-1] 1
  }
  set count 0
  set dofft 0
  debuglog "FITSBITS = $ANDOR_CFG(fitsbits)"
  if { $npix < 1024 } {set dofft [andorGetControl 0 showfft]}
  if { $ANDOR_CFG(red) > -1} {
      andorGetSingleCube $ANDOR_CFG(red) $n $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]r.fits $ANDOR_CFG(fitsbits) $dofft
  }
  if { $ANDOR_CFG(blue) > -1 } {
      andorGetSingleCube $ANDOR_CFG(blue) $n $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]b.fits $ANDOR_CFG(fitsbits) $dofft
  }
  update idletasks
  set TELEMETRY(speckle.andor.exposureEnd) [expr [clock microseconds]/1000000.]
  if { $ANDOR_CFG(red) > -1} {
    appendHeader $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]r.fits
    if { $dofft } {
      andorDisplaySingleFFT $ANDOR_CFG(red) $npix $npix $n
      exec xpaset -p $DS9 save fits $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]rfft.fits
    }
    catch {andorAbortAcq $ANDOR_CFG(red)}
    set ANDOR_CFG(red,min) [andorGetControl $ANDOR_CFG(red) min]
    set ANDOR_CFG(red,peak) [andorGetControl $ANDOR_CFG(red) peak]
    set TELEMETRY(speckle.andor.peak_estimate) $ANDOR_CFG(red,peak) 
  }
  if { $ANDOR_CFG(blue) > -1} {
    appendHeader $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]b.fits
    if { $dofft } {
      andorDisplaySingleFFT $ANDOR_CFG(blue) $npix $npix $n
      exec xpaset -p $DS9 save fits $SPECKLE_DATADIR/[set ANDOR_CFG(imagename)]bfft.fits
    }
    catch {andorAbortAcq $ANDOR_CFG(blue)}
    set ANDOR_CFG(blue,min) [andorGetControl $ANDOR_CFG(blue) min]
    set ANDOR_CFG(blue,peak) [andorGetControl $ANDOR_CFG(blue) peak]
    set TELEMETRY(speckle.andor.peak_estimate) $ANDOR_CFG(blue,peak) 
  }
  updateDatabase
  debuglog "Finished acquisition"
}


## Documented proc \c acquireFastVideo .
# \param[in] exp Exposure time in seconds 
# \param[in] x Starting column number
# \param[in] y Starting row number
# \param[in] npix Frame dimension (x and y)
#
#  Take fast exposures in kinetic mode, but only display them
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		SPECKLE_DATADIR - Directory path to data storage\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue\n
#		ANDOR_ROI - Region of interest parameters\n
#		DS9 - Name of ds9 executable for display ds9red or ds9blue\n
#		TELEMETRY - Array of telemetry items for header/database usage
#
proc acquireFastVideo { exp x y npix n } {
global ANDOR_CFG SPECKLE_DATADIR ANDOR_ARM ANDOR_ARM ANDOR_ROI DS9 TELEMETRY CAM
  debuglog "Starting fast video sequence with exposure = $exp x=$x y=$y geom=$npix n=$n"
  set scset [exec xpaget $DS9 scale]
  if { $ANDOR_ARM == "blue" } {
    exec xpaset -p $DS9 frame 1
    exec xpaset -p $DS9 shm array shmid $ANDOR_CFG(shmem) \\\[xdim=$npix,ydim=$npix,bitpix=32\\\]
    exec xpaset -p $DS9 cmap Cool
    if { $scset == "zscale" } {
      exec xpaset -p $DS9 scale limits $ANDOR_CFG(blue,min) [expr $ANDOR_CFG(blue,peak)*$ANDOR_CFG(scalepeak)]
    }
  }
  if { $ANDOR_ARM == "red" } {
    exec xpaset -p $DS9 frame 1
    exec xpaset -p $DS9 shm array shmid $ANDOR_CFG(shmem) \\\[xdim=$npix,ydim=$npix,bitpix=32\\\]
    exec xpaset -p $DS9 cmap Heat
    if { $scset == "zscale" } {
      exec xpaset -p $DS9 scale limits $ANDOR_CFG(red,min) [expr $ANDOR_CFG(red,peak)*$ANDOR_CFG(scalepeak)]
    }
  }
  if { $ANDOR_CFG(fitds9) } {
       exec xpaset -p $DS9 zoom to fit
  } else {
       exec xpaset -p $DS9 zoom 1
  }
  updateds9wcs $TELEMETRY(tcs.telescope.ra) $TELEMETRY(tcs.telescope.dec)
  refreshads9 [expr int($exp*2000)] [expr $n*4]
  set TELEMETRY(speckle.andor.numexp) $n
  set TELEMETRY(speckle.andor.exposureStart) [clock seconds]
  set TELEMETRY(speckle.andor.numberkinetics) $n
  cAndorSetProperty $CAM ExposureTime $exp
  if { $ANDOR_CFG(red) > -1} {
     andorSetROI $ANDOR_CFG(red) $x [expr $x+$npix-1] $y [expr $y+$npix-1] 1
  }
  if { $ANDOR_CFG(blue) > -1} {
     andorSetROI $ANDOR_CFG(blue) $x [expr $x+$npix-1] $y [expr $y+$npix-1] 1
  }
  set count 0
  set dofft 0
  if { $ANDOR_CFG(red) > -1} {
      andorFastVideo $ANDOR_CFG(red) $n
  }
  if { $ANDOR_CFG(blue) > -1 } {
      andorFastVideo $ANDOR_CFG(blue) $n
  }
  update idletasks
  set TELEMETRY(speckle.andor.exposureEnd) [clock seconds]
  if { $ANDOR_CFG(red) > -1} {
#    if { $dofft } {andorDisplaySingleFFT $ANDOR_CFG(red) $npix $npix $n}
    catch {andorAbortAcq $ANDOR_CFG(red)}
    set ANDOR_CFG(red,min) [andorGetControl $ANDOR_CFG(red) min]
    set ANDOR_CFG(red,peak) [andorGetControl $ANDOR_CFG(red) peak]
  }
  if { $ANDOR_CFG(blue) > -1} {
#    if { $dofft } {andorDisplaySingleFFT $ANDOR_CFG(blue) $npix $npix $n}
    catch {andorAbortAcq $ANDOR_CFG(blue)}
    set ANDOR_CFG(blue,min) [andorGetControl $ANDOR_CFG(blue) min]
    set ANDOR_CFG(blue,peak) [andorGetControl $ANDOR_CFG(blue) peak]
  }
  debuglog "Finished Video run"
}

set FITSBITS(SHORT_IMG)    16
set FITSBITS(LONG_IMG)     32
set FITSBITS(FLOAT_IMG)   -32
set FITSBITS(USHORT_IMG)   20
set FITSBITS(ULONG_IMG)    40
### not supported
#set FITSBITS(LONGLONG_IMG) 64
#set FITSBITS(BYTE_IMG)     8 
#set FITSBITS(DOUBLE_IMG)  -64
set ANDOR_CFG(fitsbits) $FITSBITS(USHORT_IMG)
set ANDOR_CFG(scalepeak) 1.2

## Documented proc \c updateDatabase .
#
#  Update the SQL database with a record of the current FITS dataset
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue\n
#		TELEMETRY - Array of telemetry items for header/database usage\n
#		SCOPE - Array of telescope information
#
proc updateDatabase { } {
global ANDOR_ARM ANDOR_CFG TELEMETRY SCOPE CAM
   set finsert [open /tmp/insert_$ANDOR_ARM.sql w]
   set amp "CCD Amplifier"
   if { $ANDOR_CFG($ANDOR_ARM,OutputAmplifier) == 0 } { set amp "ECMMD Amplifier" }
   puts $finsert "INSERT INTO Speckle_Observations VALUES (NOW(6),'$SCOPE(ProgID)','$TELEMETRY(tcs.target.name)','$ANDOR_CFG(imagename)','$TELEMETRY(speckle.scope.datatype)',$TELEMETRY(speckle.andor.preamp_gain),$TELEMETRY(speckle.andor.em_gain),$TELEMETRY(speckle.andor.bias_estimate),$TELEMETRY(speckle.andor.peak_estimate),$TELEMETRY(speckle.andor.int_time),$TELEMETRY(speckle.andor.exposureStart),$TELEMETRY(speckle.andor.exposureEnd),'$SCOPE(filter)','$amp',$TELEMETRY(speckle.andor.numexp),$TELEMETRY(speckle.andor.numaccum),'$TELEMETRY(speckle.andor.roi)',$ANDOR_CFG($CAM,hbin),$ANDOR_CFG($CAM,vbin),'$TELEMETRY(tcs.telescope.ra)','$TELEMETRY(tcs.telescope.dec)',$TELEMETRY(tcs.weather.rawiq),$TELEMETRY(tcs.weather.rawcc),$TELEMETRY(tcs.weather.rawwv),$TELEMETRY(tcs.weather.rawbg));"
   close $finsert
   catch {exec mysql speckle --user=root < /tmp/insert_$ANDOR_ARM.sql >& /tmp/insert_$ANDOR_ARM.log &}
}

## Documented proc \c configReadout .
# \param[in] amp Amplifier id
# \param[in] hsspeed Horizontal readout rate
# \param[in] vsspeed Vertical shift speed
# \param[in] vsamplitude Vertical shift amplitude
# \param[in] preampgain Preamp gain index
# \param[in] emgain EMCCD gain setting
# \param[in] emgainmode EMCCD Advanced mode setting
#
#  Control the camera readout parameters with user friendly names 
#
#
# Globals :\n
#		ANDOR_CCD - Number of conventional amplifier\n
#		CAM - Andor camera id used in the C code, 0 or 1\n
#		ANDOR_EMCCD - Number of EMCCD amplifier\n
#		ANDOR_CODE - Indexes to arrays of speed identifiers
#
proc configReadout { amp hsspeed vsspeed vsamplitude preampgain emgain emgainmode } {
global ANDOR_CCD ANDOR_EMCCD ANDOR_CODE CAM
   if { $amp == $ANDOR_CCD } {
      set res [cAndorSetProperty $CAM OutputAmplifier $amp]
      if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res}
      switch hsspeed { 
          1Mhz    { set res [cAndorSetProperty $CAM HSSpeed 1 0] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          0.1Mhz  { set res [cAndorSetProperty $CAM HSSpeed 1 1] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
      }
   }
   if { $amp == $ANDOR_EMCCD } {
      set res [cAndorSetProperty $CAM OutputAmplifier $amp]
      if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res}
      switch hsspeed { 
          30Mhz  { set res [cAndorSetProperty $CAM HSSpeed 0 0] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          20Mhz  { set res [cAndorSetProperty $CAM HSSpeed 0 1] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          10Mhz  { set res [cAndorSetProperty $CAM HSSpeed 0 2] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          1Mhz   { set res [cAndorSetProperty $CAM HSSpeed 0 3] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
      }
      set res [cAndorSetProperty $CAM EMCCDGain $emgain]
      if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res}
      switch $emgainmode {
          255     { set res [cAndorSetProperty $CAM EMGainMode  0] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          4095    { set res [cAndorSetProperty $CAM EMGainMode  1] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          linear  { set res [cAndorSetProperty $CAM EMGainMode  2] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          real    { set res [cAndorSetProperty $CAM EMGainMode  3] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
      }
   }
   switch vsspeed { 
	  4.33usec   { set res [cAndorSetProperty $CAM VSSpeed 4] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          2.2usec    { set res [cAndorSetProperty $CAM VSSpeed 3] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          1.13usec   { set res [cAndorSetProperty $CAM VSSpeed 2] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          0.6usec    { set res [cAndorSetProperty $CAM VSSpeed 1] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
   }
   switch vsamplitude { 
	  normal   { set res [cAndorSetProperty $CAM VSAmplitude 0] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          +1       { set res [cAndorSetProperty $CAM VSAmplitude 1] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          +2       { set res [cAndorSetProperty $CAM VSAmplitude 2] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          +3       { set res [cAndorSetProperty $CAM VSAmplitude 3] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          +4       { set res [cAndorSetProperty $CAM VSAmplitude 4] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
   }
   switch preampgain { 
	  1        { set res [cAndorSetProperty $CAM PreAmpGain 1] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
          2        { set res [cAndorSetProperty $CAM PreAmpGain 2] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
	  3        { set res [cAndorSetProperty $CAM PreAmpGain 3] ; if { $res != $ANDOR_CODE(DRV_SUCCESS) } {return $res} }
   }
   return "OK"
}


## Documented proc \c printreadoutcfgs .
#
#  Print the possible camera readout parameter configurations
#
proc printreadoutcfgs { } {
    set amp CCD
    foreach hsspeed "1MHz 100KHz" {
      foreach vsspeed "4.33usec 2.2usec 1.13usec 0.6sec" {
        foreach preamp "1 2" {
         foreach vsamplitude "normal +1 +2 +3 +4" {
            puts stdout "Amp=$amp hspeed=$hsspeed preamp=$preamp vspeed=$vsspeed vsamplitude=$vsamplitude"
         }
        }
      }
    }
    set amp EMCCD
    foreach hsspeed "30MHz 20MHz 10MHz 1MHz" {
      foreach vsspeed "4.33usec 2.2usec 1.13usec 0.6sec" {
        foreach preamp "1 2" {
         foreach vsamplitude "normal +1 +2 +3 +4" {
           foreach emmode "255 4095 linear real" {
             puts stdout "Amp=$amp hspeed=$hsspeed preamp=$preamp vspeed=$vsspeed emmode=$emmode vsamplitude=$vsamplitude"
           }
         }
       }
      }
    }
}


## Documented proc \c testreadoutcfgs .
#
#  Test the possible camera readout parameter configurations
#
proc testreadoutcfgs { } {
global ANDOR_RET CAM
    set amp 1
    foreach hsspeed "1Mhz 100KHz" {
      foreach vsspeed "4.33usec 2.2usec 1.13usec 0.6usec" {
        foreach preamp "0 1" {
#         foreach vsamplitude "normal +1 +2 +3 +4" {
            andorStartAcq
            while { [GetStatus] != 20073 } {
              after 500
            }
            set t [andorGetProperty $CAM timings]
            puts stdout "exp=$t [configReadout $amp $hsspeed $vsspeed normal $preamp 0 0] - Amp=$amp hspeed=$hsspeed preamp=$preamp vspeed=$vsspeed"
#         }
        }
      }
    }
    set amp 0
    foreach hsspeed "30MHz 20MHz 10MHz 1MHz" {
      foreach vsspeed "4.33usec 2.2usec 1.13usec 0.6usec" {
        foreach preamp "0 1" {
#         foreach vsamplitude "normal +1 +2 +3 +4" {
#           foreach emmode "255 4095 linear real" {
              andorStartAcq
              while { [GetStatus] != 20073 } {
                after 500
              }
             set t [andorGetProperty $CAM timings]
             puts stdout "exp=$t [configReadout $amp $hsspeed $vsspeed normal $preamp 0 0] Amp=$amp hspeed=$hsspeed preamp=$preamp vspeed=$vsspeed"
#          }
#        }
       }
      }
    }
}



## Documented proc \c locateStar .
# \param[in] steps Number of pixel offset per sampling
# \param[in] smooth Size of sampling box to average
#
#  Find the brightest object in an image
#
#
# Globals :
#		ANDOR_CFG - Array of camera configuration items
#
proc locateStar { steps smooth } {
global ANDOR_CFG
  if { $ANDOR_CFG(red) > -1} {
     set res [andorLocateStar $ANDOR_CFG(red) $steps $smooth]
   }  
  if { $ANDOR_CFG(blue) > -1} {
     set res [andorLocateStar $ANDOR_CFG(blue) $steps $smooth]
  }  
  return $res
}

## Documented proc \c selectROI .
# \param[in] idim Size of rfegion of interest (x and y)
#
#  Find the brightest object , and select an ROI of the requried size around it
#  Show the region on ds9
#
#
# Globals :\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue\n
#		ANDOR_ROI - Region of interest parameters\n
#		DS9 - Name of ds9 executable for display ds9red or ds9blue
#
proc selectROI { idim } {
global ANDOR_ARM ANDOR_ROI DS9
  set xy [locateStar 20 5]
  set x [lindex $xy 0]
  set y [lindex $xy 1]
  set xs [expr $x - $idim/2]
  set xe [expr $x + $idim/2 -1]
  if { $xs < 1 } { set xs 1 ; set xe $idim}
  if { $xe > 1024 } {set xe 1024 ; set xs [expr 1024-$idim+1]}
  set ys [expr $y - $idim/2]
  set ye [expr $y + $idim/2 -1]
  if { $ys < 1 } { set ys 1 ; set ye $idim}
  if { $ye > 1024 } {set ye 1024 ; set ys [expr 1024-$idim+1]}
  exec xpaset -p $DS9 regions deleteall
  exec echo "box [expr $xs+$idim/2] [expr $ys+$idim/2] $idim $idim 0" | xpaset  $DS9 regions
  set ANDOR_ROI(xs) $xs
  set ANDOR_ROI(xe) $xe
  set ANDOR_ROI(ys) $ys
  set ANDOR_ROI(ye) $ye
  debuglog "$ANDOR_ARM ROI measured as $xs , $xe , $ys , $ye [lrange $xy 2 3]"
  return "$xy"
}

## Documented proc \c forceROI .
# \param[in] idim Size of rfegion of interest (x and y)
#
#  Force the position of an ROI of the requried size
#
#
# Globals :\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue\n
#		ANDOR_ROI - Region of interest parameters
#
proc forceROI { xs xe ys ye } {
global ANDOR_ARM ANDOR_ROI
  set ANDOR_ROI(xs) $xs
  set ANDOR_ROI(xe) $xe
  set ANDOR_ROI(ys) $ys
  set ANDOR_ROI(ye) $ye
  debuglog "$ANDOR_ARM ROI user selected as $xs , $xe , $ys , $ye"
}



## Documented proc \c shutDown .
#
#  Shutdown the camera servers and exit
#
#
proc shutDown { } {
  debuglog "Waiting for camera to warm up"
  warmUpCamera
  debuglog "Shutting down Andor acqusition server"
  andorShutDown
  exit
}

## Documented proc \c doService .
# \param[in] sock The socket handle
# \param[in] msg The command message and parameters
#
#  Process a command received via socket interface
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		SPECKLE_DATADIR - Directory path to data storage\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue
#		CAM - Andor camera id used in the C code, 0 or 1\n
#		FITSBITS - Fits numerical codes translation for data types
#		TELEMETRY - Array of telemetry items for header/database usage\n
#		SCOPE - Array of telescope parameters
#
proc doService {sock msg} {
global SCOPE CAM ANDOR_ARM ANDOR_CFG TELEMETRY SPECKLE_DATADIR FITSBITS
    debuglog "echosrv:$msg"
    set ANDOR_CFG([lindex $msg 0]) [lrange $msg 1 end]
    switch [lindex $msg 0] {
         shutdown        { shutDown ; puts $sock "OK"; exit }
         reset           { resetCamera [lindex $msg 1] ; puts $sock "OK"}
         grabframe       { after 10 "acquireDataFrame [lindex $msg 1]" ; puts $sock "Acquiring frame"}
         setroi          { set res [selectROI [lindex $msg 1]] ; puts $sock "$res"}
         grabroi         { after 10 "acquireDataROI [lindex $msg 1] [lindex $msg 2] [lindex $msg 3] [lindex $msg 4]" ; puts $sock "Acquiring roi"}
         version         { puts $sock "1.0" }
         grabcube        { after 10 "acquireDataCube [lindex $msg 1] [lindex $msg 2] [lindex $msg 3] [lindex $msg 4] [lindex $msg 5]" ; puts $sock "Acquiring cube"}
         fastVideo       { after 10 "acquireFastVideo [lindex $msg 1] [lindex $msg 2] [lindex $msg 3] [lindex $msg 4] [lindex $msg 5]" ; puts $sock "Fastvideo starts"}
         setframe        { configureFrame [lindex $msg 1] ;  puts $sock "OK"}
         setbinning      { set ANDOR_CFG($CAM,hbin) [lindex $msg 1] ; set ANDOR_CFG($CAM,vbin) [lindex $msg 2] ; set ANDOR_CFG(binning) [lindex $msg 1] ;puts $sock "OK"}
         scalepeak       { set ANDOR_CFG(scalepeak) [lindex $msg 1] ; puts $sock "OK"}
         fitsbits        { set ANDOR_CFG(fitsbits) $FITSBITS([lindex $msg 1]) ; puts $sock "OK"}
         whicharm        { puts $sock $ANDOR_ARM }
         gettimings      { set it [andorGetProperty $CAM timings] ; puts $sock $it }
         forceroi        { forceROI  [lindex $msg 1] [lindex $msg 2] [lindex $msg 3] [lindex $msg 4] ; puts $sock "OK"}
         locatestar      { puts $sock "[locateStar [lindex $msg 1] [lindex $msg 2]]" }
         datadir         { set SPECKLE_DATADIR [lindex $msg 1] ; puts $sock "OK"}
         imagename       { set ANDOR_CFG(imagename) [lindex $msg 1] ; set SCOPE(datadir) [lindex $msg 1] ; set ANDOR_CFG(overwrite) [lindex $msg 2] ; puts $sock "OK"}
         imagetype       { set TELEMETRY(speckle.scope.imagetype) [lindex $msg 1] ; puts $sock "OK"}
         gettemp         { set it [andorGetProperty $CAM temperature] ; set ANDOR_CFG(ccdtemp) [lindex $it 0] ; puts $sock $it }
         status          { set it [showstatus] ; puts $sock $it}
         shutter         { set it [cAndorSetProperty $CAM Shutter [lindex $msg 1]] ; puts $sock $it}
         frametransfer   { set it [cAndorSetProperty $CAM FrameTransferMode [lindex $msg 1]] ; puts $sock $it}
         outputamp       { set it [cAndorSetProperty $CAM OutputAmplifier [lindex $msg 1]] ; puts $sock $it}
         emadvanced      { set it [cAndorSetProperty $CAM EMAdvanced [lindex $msg 1]] ; puts $sock $it}
         baseclamp       { set it [cAndorSetProperty $CAM BaselineClamp [lindex $msg 1]] ; puts $sock $it}
         emccdgain       { set it [cAndorSetProperty $CAM EMCCDGain [lindex $msg 1]] ; puts $sock $it}
         hsspeed         { set it [cAndorSetProperty $CAM HSSpeed [lindex $msg 1] [lindex $msg 2]] ; puts $sock $it}
         vsspeed         { set it [cAndorSetProperty $CAM VSSpeed [lindex $msg 1]] ; puts $sock $it}
         vsamplitude     { set it [cAndorSetProperty $CAM VSAmplitude [lindex $msg 1]] ; puts $sock $it}
         preampgain      { set it [cAndorSetProperty $CAM PreAmpGain [lindex $msg 1]] ; puts $sock $it}
         readmode        { set it [cAndorSetProperty $CAM ReadMode [lindex $msg 1]] ; puts $sock $it}
         acquisition     { set it [cAndorSetProperty $CAM AcquisitionMode [lindex $msg 1]] ; puts $sock $it}
         kineticcycletime      { set it [cAndorSetProperty $CAM KineticCycleTime [lindex $msg 1]] ; puts $sock $it}
         numberaccumulations   { set it [cAndorSetProperty $CAM NumberAccumulations [lindex $msg 1]] ; puts $sock $it}
         numberkinetics        { set it [cAndorSetProperty $CAM NumberKinetics [lindex $msg 1]] ; puts $sock $it}
         accumulationcycletime { set it [cAndorSetProperty $CAM AccumulationCycleTime [lindex $msg 1]] ; puts $sock $it}
         setexposure     { SetExposureTime [lindex $msg 1] ; puts $sock "OK"}
         triggermode     { SetTriggerMode [lindex $msg 1] ; puts $sock "OK"}
         setspoolmode    { cAndorSetProperty $CAM Spool [lindex $msg 1] ; puts $sock "OK"}
         settemperature  { SetTemperature [lindex $msg 1] ; puts $sock "OK"}
         setcooler       { cAndorSetProperty $CAM Cooler [lindex $msg 1] ; puts $sock "OK"}
         positiontelem   { set TELEMETRY(speckle.andor.inputzaber) [lindex $msg 1]
                           set TELEMETRY(speckle.andor.fieldzaber) [lindex $msg 2]
                           set TELEMETRY(speckle.andor.filter) [lindex $msg 3]
                           puts $sock "OK"
                         }
         dqtelemetry     { set TELEMETRY(tcs.weather.rawiq) [lindex $msg 1]
                           set TELEMETRY(tcs.weather.rawcc) [lindex $msg 2]
                           set TELEMETRY(tcs.weather.rawwv) [lindex $msg 3]
                           set TELEMETRY(tcs.weather.rawbg) [lindex $msg 4]
                           puts $sock "OK"
                         }
         programid       { set SCOPE(ProgID) [lindex $msg 1] ; puts $sock "OK" }
         filter          { set SCOPE(filter) [lindex $msg 1] ; puts $sock "OK" }
         readoutcfg      { set res [configReadout [lindex $msg 1] [lindex $msg 2] [lindex $msg 3] [lindex $msg 4] [lindex $msg 5] [lindex $msg 6] [lindex $msg 7]] ; puts $sock $res}
         comments        { set SCOPE(comments) [lrange $msg 1 end] ;  puts $sock "OK" }
         connectds9      { connectads9 ; puts $sock "OK" }
         autofitds9      { set ANDOR_CFG(fitds9) [lindex $msg 1] ;  puts $sock "OK" }
         configure       { set ANDOR_CFG($CAM,hbin) [lindex $msg 1]
                           set ANDOR_CFG($CAM,vbin) [lindex $msg 2]
                           set ANDOR_ROI(xs) [lindex $msg 3]
                           set ANDOR_ROI(xe) [lindex $msg 4]
                           set ANDOR_ROI(ys) [lindex $msg 5]
                           set ANDOR_ROI(ye) [lindex $msg 6]
                           set ANDOR_CFG($CAM,PreAmpGain) [lindex $msg 7]
                           set ANDOR_CFG($CAM,VSSpeed) [lindex $msg 8]
                           set ANDOR_CFG($CAM,HSSpeed) [lindex $msg 9]
                           set ANDOR_CFG($CAM,EMHSSpeed) [lindex $msg 10]
     			   andorConfigure $CAM $ANDOR_CFG($CAM,hbin) $ANDOR_CFG($CAM,vbin)  $ANDOR_ROI(xs) $ANDOR_ROI(xe) $ANDOR_ROI(ys) $ANDOR_ROI(ye) $ANDOR_CFG($CAM,PreAmpGain) $ANDOR_CFG($CAM,VSSpeed) $ANDOR_CFG($CAM,HSSpeed) $ANDOR_CFG($CAM,EMHSSpeed)
			   puts $sock "OK"
                         }
         default         { if { [string range [lindex $msg 0] 0 2] == "Get" } {
                             puts $sock [eval [lindex $msg 0]]
                           } else {
                             if { [string range [lindex $msg 0] 0 2] == "Set" } {
                                puts $sock [eval [lindex $msg 0] [lindex $msg 1]]

