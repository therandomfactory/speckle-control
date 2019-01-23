## \file andorTelemetry.tcl
# \brief This contains procedures for updating camera telemetry items
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
## Documented proc \c updateAndorTelemetry .
# \param[in] arm Instrument arm red/blue
#
#  Update the items of telemetry related to camera specifics, used for populating\n
# the headers and database
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		SPECKLE_DIR - Directory path to speckle code\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue
#		ANDOR_ROI - Region of interest parameters\n
#		CAM - Andor camera id used in the C code, 0 or 1\n
#		TELEMETRY - Array of telemetry items for header/database usage
#		SCOPE - Array of telescope information
#		CAMSTATUS - Camera parameters
#
proc updateAndorTelemetry { arm } {
global ANDOR_CFG CAMSTATUS TELEMETRY SPECKLE_DIR SCOPE ANDOR_ROI CAM ANDOR_ARM
   set state(0) "Off"
   set state(1) "On"
   set TELEMETRY(speckle.andor.head) "Andor iXon Emccd"
   if { $ANDOR_CFG($arm,EMCCDGain) > 0 } {
     set TELEMETRY(speckle.andor.amplifier) "Electron Multiplying"
     set TELEMETRY(speckle.andor.emccdmode) "On"
   } else {
     set TELEMETRY(speckle.andor.amplifier) "CCD"
     set TELEMETRY(speckle.andor.emccdmode) "Off"
   }
   set TELEMETRY(speckle.andor.imagename) "[set ANDOR_CFG(imagename)][string range [set ANDOR_ARM] 0 0].fits"
   set TELEMETRY(speckle.andor.acquisition_mode) "Single scan"
   if { $TELEMETRY(speckle.andor.numberkinetics) > 1}  { set TELEMETRY(speckle.andor.acquisition_mode) "Kinetics mode" }
   set TELEMETRY(speckle.andor.int_time) $ANDOR_CFG($arm,ExposureTime)
   set TELEMETRY(speckle.andor.kinetic_time) $ANDOR_CFG($arm,KineticCycleTime)
   set TELEMETRY(speckle.andor.exptime) $ANDOR_CFG($arm,ExposureTime)
   set TELEMETRY(speckle.andor.numaccum) $ANDOR_CFG($arm,NumberAccumulations)
   if { $TELEMETRY(speckle.andor.numaccum) > 1}  { set TELEMETRY(speckle.andor.acquisition_mode) "Kinetics + Accumulate mode" }
   set TELEMETRY(speckle.andor.accumulationcycle) $ANDOR_CFG($arm,AccumulationCycleTime)
   set TELEMETRY(speckle.andor.read_mode) "Frame transfer"
   set TELEMETRY(speckle.andor.fullframe) "1,1024,1,1024"
   set TELEMETRY(speckle.andor.frametransfer) $state($ANDOR_CFG($arm,FrameTransferMode))
   set TELEMETRY(speckle.andor.biasclamp) $state($ANDOR_CFG($arm,BaselineClamp))
   set TELEMETRY(speckle.andor.hbin) $ANDOR_CFG($arm,hbin)
   set TELEMETRY(speckle.andor.roi) "$ANDOR_ROI(xs),$ANDOR_ROI(xe),$ANDOR_ROI(ys),$ANDOR_ROI(ye)"
   set TELEMETRY(speckle.andor.vbin) $ANDOR_CFG($arm,vbin)
   set TELEMETRY(speckle.andor.datatype) $ANDOR_CFG($arm,fitsbits)
   set dll [string range [file tail [glob $SPECKLE_DIR/lib/libUSBI2C.so.*.0]] 13 end]
   set TELEMETRY(speckle.andor.sw_version) $dll
   set TELEMETRY(speckle.andor.exposure_total) [expr $ANDOR_CFG($arm,NumberKinetics) * $ANDOR_CFG($arm,ExposureTime) * $ANDOR_CFG($arm,NumberAccumulations)]
   set TELEMETRY(speckle.andor.em_gain) $ANDOR_CFG($arm,EMCCDGain)
   set TELEMETRY(speckle.andor.preamp_gain) [expr $ANDOR_CFG($arm,PreAmpGain) +1]
   set TELEMETRY(speckle.andor.serial_number) $ANDOR_CFG($CAM,SerialNumber) 
   set TELEMETRY(speckle.andor.target_temperature) $ANDOR_CFG($arm,Temperature)
   set TELEMETRY(speckle.andor.ccdtemp) $ANDOR_CFG(ccdtemp) 
   set TELEMETRY(speckle.andor.prescans) 0
   set TELEMETRY(speckle.andor.vertical_speed) $ANDOR_CFG(VSSpeed,$ANDOR_CFG($CAM,VSSpeed))
   if { $TELEMETRY(speckle.andor.amplifier) == 0 } {
      set TELEMETRY(speckle.andor.horizontal_speed) $ANDOR_CFG(EMHSSpeed,$ANDOR_CFG($CAM,EMHSSpeed))
   } else {
      set TELEMETRY(speckle.andor.horizontal_speed) $ANDOR_CFG(HSSpeed,$ANDOR_CFG($CAM,HSSpeed))
   }
   set TELEMETRY(speckle.andor.bias_estimate) $ANDOR_CFG(bias)
   set TELEMETRY(speckle.andor.peak_estimate) $ANDOR_CFG(peak)
   set now [exec date -u +%Y-%m-%dT%H:%M:%S.0]
   set TELEMETRY(speckle.scope.recid) [set SCOPE(obsdate)]_$SCOPE(telescope)"
   set TELEMETRY(speckle.andor.read_mode) "Image"
   set TELEMETRY(speckle.scope.site) $SCOPE(telescope)
   set TELEMETRY(speckle.scope.ProgID) $SCOPE(ProgID)
}

## Documented proc \c showTelemetry .
#
#  Print the values of all the telemetry items
#
#
# Globals :
#		TELEMETRY - Array of telemetry items for header/database usage
proc showTelemetry { } {
global TELEMETRY
   foreach i [lsort [array names TELEMETRY]] {
      puts stdout "TELEMETRY($i) = $TELEMETRY($i)"
   }
}

# \endcode

#set initial defaults
set ANDOR_CFG(VSSpeed,0) "0.6"
set ANDOR_CFG(VSSpeed,1) "1.13"
set ANDOR_CFG(VSSpeed,2) "2.2"
set ANDOR_CFG(VSSpeed,3) "4.33"
set ANDOR_CFG(EMHSSpeed,0) "30"
set ANDOR_CFG(EMHSSpeed,1) "20"
set ANDOR_CFG(EMHSSpeed,2) "10"
set ANDOR_CFG(EMHSSpeed,3) "1"
set ANDOR_CFG(HSSpeed,0) "1"
set ANDOR_CFG(HSSpeed,1) "0.1"

set ANDOR_CFG(red,hbin) 1
set ANDOR_CFG(red,vbin) 1
set ANDOR_CFG(blue,hbin) 1
set ANDOR_CFG(blue,vbin) 1
set ANDOR_ROI(xs) 1
set ANDOR_ROI(xe) 1024
set ANDOR_ROI(ys) 1
set ANDOR_ROI(ye) 1024
set ANDOR_CFG(bias) 0
set ANDOR_CFG(peak) 0
set ANDOR_CFG(red,fitsbits) 32
set ANDOR_CFG(blue,fitsbits) 32
set ANDOR_CFG(ccdtemp) 0.0

set SCOPE(filter) "clear"
set SCOPE(ProgID) "test"
set SCOPE(telescope) $env(TELESCOPE)
set TELEMETRY(speckle.andor.head) "Andor iXon Emccd"
set TELEMETRY(speckle.andor.acquisition_mode) "CCD"
set TELEMETRY(speckle.andor.int_time) 1.0
set TELEMETRY(speckle.andor.kinetic_time) 0.0
set TELEMETRY(speckle.andor.numaccum) 1
set TELEMETRY(speckle.andor.accumulationcycle) 0.0
set TELEMETRY(speckle.andor.numberkinetics) 1
set TELEMETRY(speckle.andor.acquisition_mode) "CCD"
set TELEMETRY(speckle.andor.read_mode) "Frame transfer"
set TELEMETRY(speckle.andor.numberkinetics) 1
set TELEMETRY(speckle.andor.frametransfer) "On"
set TELEMETRY(speckle.andor.biasclamp) "On"
set TELEMETRY(speckle.andor.fullframe) "1,1024,1,1024"
set TELEMETRY(speckle.andor.hbin) $ANDOR_CFG(red,hbin)
set TELEMETRY(speckle.andor.roi) "1,1024,1,1024"
set TELEMETRY(speckle.andor.vbin) $ANDOR_CFG(red,vbin)
set TELEMETRY(speckle.scope.datatype) 32
set TELEMETRY(speckle.andor.datatype) long
set dll [string range [file tail [glob $env(SPECKLE_DIR)/lib/libUSBI2C.so.*.0]] 13 end]
set TELEMETRY(speckle.andor.sw_version) $dll
set TELEMETRY(speckle.andor.exposure_total) 1.0
set TELEMETRY(speckle.andor.em_gain) 0
set TELEMETRY(speckle.andor.vertical_speed)  0
set TELEMETRY(speckle.andor.amplifier)  1
set TELEMETRY(speckle.andor.preamp_gain)  0
set TELEMETRY(speckle.andor.serial_number) ""
set TELEMETRY(speckle.andor.target_temperature) -60.0
set TELEMETRY(speckle.andor.ccdtemp) 0.0
set TELEMETRY(speckle.andor.prescans) 0
set TELEMETRY(speckle.andor.bias_estimate) 0
set TELEMETRY(speckle.andor.peak_estimate) 0
set TELEMETRY(speckle.andor.exposureStart) [clock milliseconds]
set TELEMETRY(speckle.andor.exposureEnd) [clock milliseconds]
set TELEMETRY(speckle.scope.site) $SCOPE(telescope)
set TELEMETRY(tcs.weather.rawiq) 0
set TELEMETRY(tcs.weather.rawcc) 0
set TELEMETRY(tcs.weather.rawwv) 0
set TELEMETRY(tcs.weather.rawbg) 0
set SCOPE(numexp) 1



