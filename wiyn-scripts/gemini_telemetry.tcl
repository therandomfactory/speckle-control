#
# Gemini translations for TELEMETRY array
#

proc geminiConnect { scope } {
global GEMINICFG
   set handle -1
   set handle [socket $GEMINICFG($scope,ip) $GEMINICFG($scope,port)]
   fconfigure $handle -buffering line -blocking 0
   if { $handle < 0 } {
     errordialog "Failed to connect to Gemini service at $GEMINICFG($scope,ip) port $GEMINICFG($scope,port) "
   } else {
     debuglog "Connected to Gemini $GEMINICFG($scope,ip) port $GEMINICFG($scope,port) - OK"
     set GEMINICFG(handle) $handle
   }
   puts $GEMINICFG(handle) "get airmass"
   gets $GEMINICFG(handle) rec
   return $handle
}

proc flushGemini { } {
global GEMINI GEMINICFG TELEMETRY
   while { [gets $GEMINICFG(handle) rec] > -1 } {
      debuglog "flushed $rec"
   }
}



proc updateGeminiTelemetry { } {
global GEMINI GEMINICFG TELEMETRY
   set all [lsort [array names GEMINI]]
   foreach t $all {
      puts $GEMINICFG(handle) "get $t\n"
   }
   after 500
   while { [gets $GEMINICFG(handle) rec] > -1 } {
      if { [info exists GEMINI([lindex $rec 1])] } {
        set TELEMETRY($GEMINI([lindex $rec 1])) [lindex $rec 2]
        debuglog "Got $rec"
      } else {
        debuglog "Got unknown $rec"
      }
   }
   echoGeminiTelemetry
   set all [lsort [array names GEMINI]]
#   foreach i $all {
#      set CACHETELEMETRY($GEMINI($t)) $TELEMETRY($GEMINI($t))
#   }
}

proc echoGeminiTelemetry { } {
global GEMINI TELEMETRY
   set all [lsort [array names GEMINI]]
   foreach t $all {
      debuglog "Gemini $t = $TELEMETRY($GEMINI($t))"
   }
}

proc simGeminiTelemetry { } {
global GEMINI TELEMETRY CACHETELEMETRY
   set TELEMETRY($GEMINI(airmass)) 1.000
   set TELEMETRY($GEMINI(azerror)) +00:00:00.00
   set TELEMETRY($GEMINI(azimuth)) +90:00:00.00
   set TELEMETRY($GEMINI(beam)) A
   set TELEMETRY($GEMINI(elerror)) +00:00:00.00
   set TELEMETRY($GEMINI(elevation)) +90:00:00.00
   set TELEMETRY($GEMINI(focus)) 0.000
   set TELEMETRY($GEMINI(framepa)) FK5
   set TELEMETRY($GEMINI(guiding)) Off
   set TELEMETRY($GEMINI(ha)) -0.0927
   set TELEMETRY($GEMINI(humidity)) 20.0
   set TELEMETRY($GEMINI(instraa)) 0.000
   set TELEMETRY($GEMINI(instrpa)) 0.000
   set TELEMETRY($GEMINI(localtime)) 14:06:10.7
   set TELEMETRY($GEMINI(lst)) 15:23:07.9
   set TELEMETRY($GEMINI(mjd)) 5.80420042909375e+04
   set TELEMETRY($GEMINI(offsetdec)) 0.000
   set TELEMETRY($GEMINI(offsetra)) -7776000.000
   set TELEMETRY($GEMINI(programid)) None
   set TELEMETRY($GEMINI(rotator)) 0.000
   set TELEMETRY($GEMINI(targetdec)) 0.00000000
   set TELEMETRY($GEMINI(targetepoch)) 2000.0
   set TELEMETRY($GEMINI(targetframe)) FK5
   set TELEMETRY($GEMINI(targetname)) Gemini-North
   set TELEMETRY($GEMINI(targetra)) 0.00000000
   set TELEMETRY($GEMINI(teldec)) +19:47:50.66
   set TELEMETRY($GEMINI(telescope)) Gemini-North
   set TELEMETRY($GEMINI(telra)) 16:01:21.495
   set TELEMETRY($GEMINI(userfocus)) 0.000
   set TELEMETRY($GEMINI(utc)) 00:06:10.7
   set TELEMETRY($GEMINI(utcdate)) 2017-10-16
   set TELEMETRY($GEMINI(zd)) 0.0000
   set all [lsort [array names GEMINI]]
   foreach t $all {
      set CACHETELEMETRY($GEMINI($t))  $TELEMETRY($GEMINI($t))
   }
}

proc nessiTelemetryUpdate { } {
global SCOPE TELEMETRY FITSKEY IMGMETA ANDOR_CFG CAM
   updateGeminiTelemetry
   foreach i [array names SCOPE] {
       set TELEMETRY(nessi.scope.$i) $SCOPE($i)
   }
   foreach i [array names FITSKEY] {
      if { [info exists IMGMETA([lindex [split $i .] end],value)] } {
          set TELEMETRY($i) $IMGMETA([lindex [split $i .] end],value)
      }
   }
  set TELEMETRY(nessi.andor.head) "iXon"
  set TELEMETRY(nessi.andor.acquisition_mode) $ANDOR_CFG(acquisition)
  set TELEMETRY(nessi.andor.kinetic_time) $ANDOR_CFG(kineticcycletime)
  set TELEMETRY(nessi.andor.num_exposures) $ANDOR_CFG(numseq)
  set TELEMETRY(nessi.andor.exposure_total) [expr $ANDOR_CFG(numseq)*$ANDOR_CFG(setexposure)]
  set TELEMETRY(nessi.andor.read_mode) $ANDOR_CFG(readmode)
  set TELEMETRY(nessi.andor.fullframe) [lrange $ANDOR_CFG(configure) 2 5]
  set TELEMETRY(nessi.andor.hbin) [lindex $ANDOR_CFG(configure) 0]
  set TELEMETRY(nessi.andor.vbin) [lindex $ANDOR_CFG(configure) 1]
  set TELEMETRY(nessi.andor.roi) [lrange $ANDOR_CFG(configure) 2 5]
  set TELEMETRY(nessi.andor.datatype) $ANDOR_CFG(fitsbits)
  set TELEMETRY(nessi.andor.em_gain) $ANDOR_CFG(emccdgain)
  set TELEMETRY(nessi.andor.vertical_speed) [lindex $ANDOR_CFG(verticalspeeds) $ANDOR_CFG(vsspeed)]
  set TELEMETRY(nessi.andor.amplifier) $ANDOR_CFG(outputamp)
  set TELEMETRY(nessi.andor.preamp_gain) $ANDOR_CFG(preampgain)
  set TELEMETRY(nessi.andor.serial_number) $ANDOR_CFG($CAM,SerialNumber)
  set TELEMETRY(nessi.andor.target_temperature) $ANDOR_CFG(temperature)
  set TELEMETRY(nessi.andor.inputzaber) $ANDOR_CFG(inputzaber)
  set TELEMETRY(nessi.andor.fieldzaber) $ANDOR_CFG(fieldzaber)
  set TELEMETRY(nessi.andor.numaccum)  $ANDOR_CFG(numberaccumulations)
  set TELEMETRY(nessi.andor.frametransfer) $ANDOR_CFG(frametransfer)
  set TELEMETRY(nessi.andor.numberkinetics) $ANDOR_CFG(numberkinetics)
  set TELEMETRY(nessi.andor.accumulationcycletime) $ANDOR_CFG(accumulationcycletime)
  set TELEMETRY(nessi.andor.ccdtemp) $ANDOR_CFG(ccdtemp)
  set TELEMETRY(nessi.andor.filter) $ANDOR_CFG(filter)
}

set ANDOR_CFG(verticalspeeds) "0 0 0 0"
set CAM 0
set ANDOR_CFG(acquisition) 0
set ANDOR_CFG(kineticcycletime) 0.0
set ANDOR_CFG(numseq) 1
set ANDOR_CFG(setexposure) 0.0
set ANDOR_CFG(readmode) 0
set ANDOR_CFG(configure) "1 1 1 1024 1 1024 0 0 0 0"
set ANDOR_CFG(fitsbits) default
set ANDOR_CFG(emccdgain) 0
set ANDOR_CFG(vsspeed) 0
set ANDOR_CFG(outputamp) 0
set ANDOR_CFG(preampgain) 0
set ANDOR_CFG(0,SerialNumber) 12345
set ANDOR_CFG(1,SerialNumber) 54321
set ANDOR_CFG(temperature) 0.0
set ANDOR_CFG(inputzaber) "NA"
set ANDOR_CFG(fieldzaber) "NA"
set ANDOR_CFG(numberaccumulations) 0
set ANDOR_CFG(frametransfer) 0
set ANDOR_CFG(numberkinetics) 0
set ANDOR_CFG(accumulationcycletime) 0.0
set ANDOR_CFG(ccdtemp) 0.0
set ANDOR_CFG(filter) "NA"


set GEMINICFG(north,ip) 10.2.44.60
set GEMINICFG(north,port) 7283

set GEMINI(airmass) tcs.telescope.airmass
set GEMINI(azimuth) tcs.azimuth.mapper
set GEMINI(azerror) tcs.azimuth.error
set GEMINI(elevation) tcs.elevation.mapper
set GEMINI(elerror) tcs.elevation.error
set GEMINI(focus) tcs.telescope.focus
set GEMINI(beam)  tcs.telesscope.beam
set GEMINI(framepa) tcs.telescope.pa
set GEMINI(guiding) tcs.telescope.guiding
set GEMINI(ha) tcs.telescope.ha
set GEMINI(humidity) tcs.weather.humidity
set GEMINI(instraa) tcs.telescope.instraa
set GEMINI(instrpa) tcs.telescope.instrpa
set GEMINI(localtime) tcs.time.local
set GEMINI(lst) tcs.time.LAST
set GEMINI(mjd) tcs.time.MJD
set GEMINI(offsetdec) tcs.telescope.decoffset
set GEMINI(offsetra) tcs.telescope.raoffset
set GEMINI(programid) nessi.scope.program
set GEMINI(rotator) tcs.nir.position
set GEMINI(targetname) nessi.scope.name
set GEMINI(targetra) tcs.target.az
set GEMINI(targetdec) tcs.target.alt
set GEMINI(targetepoch) tcs.target.epoch
set GEMINI(targetframe) tcs.target.state
set GEMINI(telescope) nessi.scope.name
set GEMINI(telra) tcs.telescope.ra
set GEMINI(teldec) tcs.telescope.dec
set GEMINI(userfocus) tcs.telescope.userfocus
set GEMINI(utc) tcs.time.UT1
set GEMINI(utcdate) tcs.time.date
set GEMINI(zd) tcs.telescope.zenithdist


