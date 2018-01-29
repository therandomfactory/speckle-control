

set NESSI_DIR $env(NESSI_DIR)
load $NESSI_DIR/lib/andorTclInit.so
load $NESSI_DIR/lib/libfitstcl.so
load $NESSI_DIR/lib/libccd.so
load $NESSI_DIR/lib/libguider.so

source $NESSI_DIR/andor/andor.tcl
source $NESSI_DIR/andorsConfiguration

set ncam [GetAvailableCameras]
puts stdout "Detected $ncam cameras"

andorConnectCamera 1
puts stdout "Connected to camera(s)"

foreach CAM "0" {
  andorConfigure $CAM 1 1 1 256 1 256 0 0 0 0
#  andorSetup $CAM 1 
  puts stdout "Configured camera $CAM for ccd mode"

  set ANDOR_CFG($CAM,SerialNumber) "X-[GetCameraSerialNumber]"
  puts stdout "Camera $CAM is serial number $ANDOR_CFG($CAM,SerialNumber) = $ANDORS($ANDOR_CFG($CAM,SerialNumber)) arm"
  if { $ANDOR_CFG($CAM,SerialNumber) == $ANDORS(red,serialnum) }  {set ANDOR_CFG(red) $CAM}
  if { $ANDOR_CFG($CAM,SerialNumber) == $ANDORS(blue,serialnum) } {set ANDOR_CFG(blue) $CAM}

  foreach i "GetCameraSerialNumber GetEMAdvanced GetEMCCDGain GetFIFOUsage GetFilterMode GetImageRotate GetKeepCleanTime GetMaximumExposure GetMaximumNumberRingExposureTimes GetMinimumImageLength GetMinimumNumberInSeries GetNumberADChannels GetNumberAmp GetNumberDevices GetNumberFKVShiftSpeeds GetNumberHorizontalSpeeds GetNumberIO GetNumberPreAmpGains GetNumberRingExposureTimes GetNumberVSAmplitudes GetNumberVSSpeeds GetNumberVerticalSpeeds GetReadOutTime GetStartUpTime GetStatus GetTotalNumberImagesAcquired" {
     set ANDOR_CFG($CAM,[string range $i 3 end]) "[$i]"
     puts stdout "$CAM : $i = $ANDOR_CFG($CAM,[string range $i 3 end])"
  }
  SetExposureTime 0.04
}

set shmid [andorConnectShmem 512 512]
initds9 [lindex $shmid 0] 512 512
andorPrepDataCube

proc acquireDataCubes { exp n } {
global INSTRUMENT ANDOR_CFG
  refreshds9 [expr int($exp*1000)] $n
  set count 0
  while { $count < $n } {
    incr count 1
    if { $INSTRUMENT(red) } {
      andorGetData $ANDOR_CFG(red)
      andorDisplayFrame $ANDOR_CFG(red) 256 256 1
    }
    if { $INSTRUMENT(blue) } {
      andorGetData $ANDOR_CFG(blue)
      andorDisplayFrame $ANDOR_CFG(blue) 256 256 1
    }
    update idletasks
    after 1
  }
  if { $INSTRUMENT(red) } {
    andorDisplayAvgFFT $ANDOR_CFG(red) 256 256 $n
    andorAbortAcq $ANDOR_CFG(red)
  }
  if { $INSTRUMENT(blue) } {
    andorDisplayAvgFFT $ANDOR_CFG(blue)  256 256 $n
    andorAbortAcq $ANDOR_CFG(blue) 
  }
}


proc shutDown { } {
  andorShutDown
}

