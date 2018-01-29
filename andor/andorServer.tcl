#!/usr/bin/wish

set NESSI_DIR $env(NESSI_DIR)
load $NESSI_DIR/lib/andorTclInit.so
load $NESSI_DIR/lib/libfitstcl.so
load $NESSI_DIR/lib/libccd.so
load $NESSI_DIR/lib/libguider.so

source $NESSI_DIR/andor/andor.tcl
source $NESSI_DIR/andorsConfiguration

set cameraNum $argv
puts stdout "Establishing server for camera $cameraNum"

set ncam [GetAvailableCameras]
puts stdout "Detected $ncam cameras"

set handle -1
set handle [andorConnectCamera $cameraNum]
if { $handle < 0} {exit}

puts stdout "Connected to camera $cameraNum, handle = $handle"
set CAM [expr $cameraNum - 1]

andorConfigure $CAM 1 1 1 256 1 256 0 0 0 0
puts stdout "Configured camera id $CAM for ccd mode"
set ANDOR_CFG(red) -1
set ANDOR_CFG(blue) -1
set ANDOR_CFG($CAM,SerialNumber) "X-[GetCameraSerialNumber]"
puts stdout "Camera $CAM is serial number $ANDOR_CFG($CAM,SerialNumber) = $ANDORS($ANDOR_CFG($CAM,SerialNumber)) arm"
if { $ANDOR_CFG($CAM,SerialNumber) == $ANDORS(red,serialnum) }  {
  set ANDOR_CFG(red) $CAM
  puts stdout "ANDOR_CFG(red) = $ANDOR_CFG(red)"
  set ANDOR_ARM red
}
if { $ANDOR_CFG($CAM,SerialNumber) == $ANDORS(blue,serialnum) } {
  set ANDOR_CFG(blue) $CAM
  puts stdout "ANDOR_CFG(blue) = $ANDOR_CFG(blue)"
  set ANDOR_ARM blue
}
foreach i "GetCameraSerialNumber GetEMAdvanced GetEMCCDGain GetFIFOUsage GetFilterMode GetImageRotate GetKeepCleanTime GetMaximumExposure GetMaximumNumberRingExposureTimes GetMinimumImageLength GetMinimumNumberInSeries GetNumberADChannels GetNumberAmp GetNumberDevices GetNumberFKVShiftSpeeds GetNumberHorizontalSpeeds GetNumberIO GetNumberPreAmpGains GetNumberRingExposureTimes GetNumberVSAmplitudes GetNumberVSSpeeds GetNumberVerticalSpeeds GetReadOutTime GetStartUpTime GetStatus GetTotalNumberImagesAcquired" {
     set ANDOR_CFG($CAM,[string range $i 3 end]) "[$i]"
     puts stdout "$CAM : $i = $ANDOR_CFG($CAM,[string range $i 3 end])"
}
SetExposureTime 0.04


set shmid [andorConnectShmem 512 512]
puts stdout "memory buffers @ $shmid"
initds9 [lindex $shmid 0] 512 512
andorPrepDataCube

proc acquireDataCube { exp n } {
global ANDOR_CFG
  refreshds9 [expr int($exp*2000)] [expr $n*3]
  set t [clock seconds]
  set count 0
  while { $count < $n } {
    incr count 1
    if { $ANDOR_CFG(red) > -1} {
      andorGetData $ANDOR_CFG(red)
      andorStoreFrame $ANDOR_CFG(red) test_red_[set t].fits 256 256 $count $n
      andorDisplayFrame $ANDOR_CFG(red) 256 256 1
    }
    if { $ANDOR_CFG(blue) > -1 } {
      andorGetData $ANDOR_CFG(blue)
      andorStoreFrame $ANDOR_CFG(blue) test_blue_[set t].fits 256 256 $count $n
      andorDisplayFrame $ANDOR_CFG(blue) 256 256 1
    }
    update idletasks
    after 1
  }
  if { $ANDOR_CFG(red) > -1} {
    andorDisplayAvgFFT $ANDOR_CFG(red) 256 256 $n
    catch {andorAbortAcq $ANDOR_CFG(red)}
  }
  if { $ANDOR_CFG(blue) > -1} {
    andorDisplayAvgFFT $ANDOR_CFG(blue) 256 256 $n
    catch {andorAbortAcq $ANDOR_CFG(blue)}
  }
  puts stdout "Finished acquisition"
}


proc shutDown { } {
  andorShutDown
}

proc doService {sock msg} {
global TLM SCOPE CAM ANDOR_ARM
    puts stdout "echosrv:$msg"
    switch [lindex $msg 0] {
         shutdown        { shutDown ; puts $sock "OK"; exit }
         acquire         { after 10 "acquireDataCube [lindex $msg 1] [lindex $msg 2]" ; puts $sock "Acquiring"}
         version         { puts $sock "1.0" }
         setemccd        { SetEMCCDGain [lindex $msg 1] ; puts $sock "OK"}
         whicharm        { puts $sock $ANDOR_ARM }
         setexposure     { SetExposureTime [lindex $msg 1] ; puts $sock "OK"}
         configure       { set hbin [lindex $msg 1]
                           set vbin [lindex $msg 2]
                           set vstart [lindex $msg 3]
                           set vend [lindex $msg 4]
                           set hstart [lindex $msg 5]
                           set hend [lindex $msg 6]
                           set preamp_gain [lindex $msg 7]
                           set vertical_speed [lindex $msg 8]
                           set ccd_horizontal_speed [lindex $msg 9]
                           set em_horizontal_speed [lindex $msg 10]
                           andorConfigure $CAM $vbin $hstart $hend $vstart $vend $preamp_gain $vertical_speed $ccd_horizontal_speed $em_horizontal_speed
			   puts $sock "OK"
                         }
         default         { if { [string range [lindex $msg 0] 0 3] == "Get" } {
                             puts $sock [eval [lindex $msg 0]]
                           } else {
                             puts $sock "ERROR: unknown $msg"
                           }
                         }
    }
}


wm withdraw .

# Handles the input from the client and  client shutdown
proc  svcHandler {sock} {
  set l [gets $sock]    ;# get the client packet
  if {[eof $sock]} {    ;# client gone or finished
     close $sock        ;# release the servers client channel
  } else {
    doService $sock $l
  }
}

# Accept-Connection handler for Server.
# called When client makes a connection to the server
# Its passed the channel we're to communicate with the client on,
# The address of the client and the port we're using
#
# Setup a handler for (incoming) communication on
# the client channel - send connection Reply and log connection
proc accept {sock addr port} {

  # if {[badConnect $addr]} {
  #     close $sock
  #     return
  # }

  # Setup handler for future communication on client socket
  fileevent $sock readable [list svcHandler $sock]

  # Note we've accepted a connection (show how get peer info fm socket)
  puts "Accept from [fconfigure $sock -peername]"

  # Read client input in lines, disable blocking I/O
  fconfigure $sock -buffering line -blocking 0

  # Send Acceptance string to client
  #  puts $sock "$addr:$port, You are connected to the echo server."
  #  puts $sock "It is now [exec date]"

  # log the connection
  puts "Accepted connection from $addr at [exec date]"
}

 


# Create a server socket on port $svcPort.
# Call proc accept when a client attempts a connection.
set svcPort [expr 2000 + $cameraNum]
socket -server accept $svcPort
vwait events    ;# handle events till variable events is set


