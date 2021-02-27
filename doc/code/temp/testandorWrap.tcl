
set SPECKLE_DIR $env(SPECKLE_DIR)

set SPECKLE_DIR $env(SPECKLE_DIR)
load $SPECKLE_DIR/lib/andorTclInit.so
load $SPECKLE_DIR/lib/libfitstcl.so
load $SPECKLE_DIR/lib/libccd.so
load $SPECKLE_DIR/lib/libguider.so

source $SPECKLE_DIR/andor/andor.tcl
source $SPECKLE_DIR/andorsConfiguration

set ncam [GetAvailableCameras]
puts stdout "Detected $ncam cameras"

andorConnect 1
puts stdout "Connected to camera 0"

andorConfigure 0 1 1 1 256 1 256 0 0 0 0
andorSetup 0 1 
puts stdout "Configured camera 0 for ccd mode"

set ANDOR_CFG(0,SerialNumber) "X-[GetCameraSerialNumber]"
puts stdout "Camera 0 is serial number $ANDOR_CFG(0,SerialNumber) = $ANDORS($ANDOR_CFG(0,SerialNumber)) arm"

foreach i "GetCameraSerialNumber GetEMAdvanced GetEMCCDGain GetFIFOUsage GetFilterMode GetImageRotate GetKeepCleanTime GetMaximumExposure GetMaximumNumberRingExposureTimes GetMinimumImageLength GetMinimumNumberInSeries GetNumberADChannels GetNumberAmp GetNumberDevices GetNumberFKVShiftSpeeds GetNumberHorizontalSpeeds GetNumberIO GetNumberPreAmpGains GetNumberRingExposureTimes GetNumberVSAmplitudes GetNumberVSSpeeds GetNumberVerticalSpeeds GetReadOutTime GetStartUpTime GetStatus GetTotalNumberImagesAcquired" {
   set ANDOR_CFG(0,[string range $i 3 end]) [$i]
   puts stdout "$i = $ANDOR_CFG(0,[string range $i 3 end])"
}

set shmid [andorConnectShmem 512 512]
initds9 [lindex $shmid 0] 512 512
andorPrepDataCube
SetExposureTime 0.04
refreshds9 40 1000
set count 0
while { $count < 1000 } {
  incr count 1
  andorGetData 0
  andorDisplayFrame 0 256 256 1
  after 10
}
andorDisplayAvgFFT 0 256 256 1000
andorAbortAcq
andorShutDown


