
set NESSI_DIR $env(NESSI_DIR)

load $NESSI_DIR/lib/andorTclInit.so
load $NESSI_DIR/lib/libfitstcl.so
load $NESSI_DIR/lib/libccd.so
load $NESSI_DIR/lib/libguider.so

source $NESSI_DIR/andor/andor.tcl
source $NESSI_DIR/andorsConfiguration

set ncam [GetAvailableCameras]
puts stdout "Detected $ncam cameras"

andorConnect 1
puts stdout "Connected to camera 0"

andorConfigure 0 1 1 1 256 1 256 0 0 0 0
andorSetup 0 1 
puts stdout "Configured camera 0 for ccd mode"

set ANDOR_CFG(0,SerialNumber) "X-[GetCameraSerialNumber]"
puts stdout Camera 0 is serial number $ANDOR_CFG(0,SerialNumber) = $ANDORS(ANDOR_CFG(0,SerialNumber)) arm"

foreach i "GetCameraSerialNumber GetEMAdvanced GetEMCCDGain GetFIFOUsage GetFilterMode GetImageRotate GetKeepCleanTime GetMaximumExposure GetMaximumNumberRingExposureTimes GetMinimumImageLength GetMinimumNumberInSeries GetNumberADChannels GetNumberAmp GetNumberDevices GetNumberFKVShiftSpeeds GetNumberHorizontalSpeeds GetNumberIO GetNumberPreAmpGains GetNumberRingExposureTimes GetNumberVSAmplitudes GetNumberVSSpeeds GetNumberVerticalSpeeds GetReadOutTime GetStartUpTime GetStatus GetTotalNumberImagesAcquired" {
   set ANDOR_CFG(0,[string range $i 3 end]) [$i]
   puts stdout "$i = $ANDOR_CFG(0,[string range $i 3 end])"
}

set shmid [andorConnectShmem 256 256]
initds9 [lindex $shmid 0] 256 256
set count 0
andorStartAcquisition
refreshds9 40 1000
while { $count < 1000 } {
  incr count 1
  andorGetAcquiredData 0
  andorDisplayFrame 0 256 256 1
  after 10
}
andorAbortAcquisition

