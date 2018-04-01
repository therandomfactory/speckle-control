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
      puts $GEMINICFG(handle) "get $t"
   }
   after 500
   while { [gets $GEMINICFG(handle) rec] > -1 } {
      if { [info exists GEMINI([lindex $rec 1])] } {
        set TELEMETRY($GEMINI([lindex $rec 1])) [lindex $rec 2]
#        debuglog "Got $rec"
      } else {
        debuglog "Got unknown $rec"
      }
   }
   echoGeminiTelemetry
}

proc echoGeminiTelemetry { } {
global GEMINI TELEMETRY
   set all [lsort [array names GEMINI]]
   foreach t $all {
      debuglog "Gemini $t = $TELEMETRY($GEMINI($t))"
   }
}

proc simGeminiTelemetry { } {
global GEMINI TELEMETRY
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

}


set GEMINICFG(north,ip) 0.0.0.0
set GEMINICFG(north,port) 0

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


