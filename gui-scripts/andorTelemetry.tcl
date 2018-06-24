

proc updateAndorTelemetry { arm } {
global ANDOR_CFG CAMSTATUS TELEMETRY SPECKLE_DIR SCOPE ANDOR_ROI CAM
   set TELEMETRY(speckle.andor.head) "Andor iXon Emccd"
   if { $ANDOR_CFG($arm,EMCCDGain) > 0 } {
     set TELEMETRY(speckle.andor.acquisition_mode) "CCD"
   } else {
     set TELEMETRY(speckle.andor.acquisition_mode) "Electron Multiplying"
   }
   set TELEMETRY(speckle.andor.int_time) $ANDOR_CFG($arm,ExposureTime)
   set TELEMETRY(speckle.andor.kinetic_time) $ANDOR_CFG($arm,KineticCycleTime)
   set TELEMETRY(speckle.andor.numaccum) $ANDOR_CFG($arm,NumberAccumulations)
   set TELEMETRY(speckle.andor.accumulationcycle) $ANDOR_CFG($arm,AccumulationCycleTime)
   set TELEMETRY(speckle.andor.read_mode) "Frame transfer"
   set TELEMETRY(speckle.andor.fullframe) "1,1024,1,1024"
   set TELEMETRY(speckle.andor.hbin) $ANDOR_CFG($arm,hbin)
   set TELEMETRY(speckle.andor.roi) "$ANDOR_ROI(xs),$ANDOR_ROI(xe),$ANDOR_ROI(ys),$ANDOR_ROI(ye)"
   set TELEMETRY(speckle.andor.vbin) $ANDOR_CFG($arm,vbin)
   set TELEMETRY(speckle.andor.datatype) $ANDOR_CFG($arm,fitsbits)
   set TELEMETRY(speckle.andor.filter) $SCOPE(filter)
   set dll [string range [file tail [glob $SPECKLE_DIR/lib/libUSBI2C.so.*.0]] 13 end]
   set TELEMETRY(speckle.andor.sw_version) $dll
   set TELEMETRY(speckle.andor.exposure_total) [expr $ANDOR_CFG($arm,KineticCycleTime) * $ANDOR_CFG($arm,ExposureTime) * $ANDOR_CFG($arm,NumberAccumulations)]
   set TELEMETRY(speckle.andor.em_gain) $ANDOR_CFG($arm,EMCCDGain)
   set TELEMETRY(speckle.andor.vertical_speed) $ANDOR_CFG($arm,VSSpeed) 
   set TELEMETRY(speckle.andor.amplifier) $ANDOR_CFG($arm,OutputAmplifier)
   set TELEMETRY(speckle.andor.preamp_gain) $ANDOR_CFG($arm,PreAmpGain)
   set TELEMETRY(speckle.andor.serial_number) $ANDOR_CFG($CAM,SerialNumber) 
   set TELEMETRY(speckle.andor.target_temperature) $ANDOR_CFG($arm,SetTemperature)
   set TELEMETRY(speckle.andor.ccdtemp) $ANDOR_CFG(ccdtemp) 
   set TELEMETRY(speckle.andor.prescans) 0
   set TELEMETRY(speckle.andor.bias_estimate) $ANDOR_CFG(bias)
   set TELEMETRY(speckle.andor.peak_estimate) $ANDOR_CFG(peak)
   set now [exec date -u +%Y-%m-%dT%H:%M:%S.0]
   set TELEMETRY(speckle.scope.recid) [set now]_$SCOPE(telescope)_$TELEMETRY(tcs.target.name)"
   set TELEMETRY(speckle.andor.read_mode) "Image"
   set TELEMETRY(speckle.scope.site) $SCOPE(telescope)
}

#set initial defaults
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
set TELEMETRY(tcs.weather.rawiq) "UNKNOWN"
set TELEMETRY(tcs.weather.rawcc) "UNKNOWN"
set TELEMETRY(tcs.weather.rawwv) "UNKNOWN"
set TELEMETRY(tcs.weather.rawbg) "UNKNOWN"
set SCOPE(numexp) 1



