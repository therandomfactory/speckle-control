#
# Gemini translations for TELEMETRY array
#
proc geminiConnect { scope } {
global GEMINICFG
   set handle -1
   set handle [socket $GEMINICFG($scope,ip) 7283]
   fconfigure $handle -buffering line -blocking 0
   if { $handle < 0 } {
     errordialog "Failed to connect to Gemini service at $GEMINICFG($scope,ip) port 7283"
   } else {
     debuglog "Connected to Gemini $GEMINICFG($scope,ip) port 7283 - OK"
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
}

proc echoGeminiTelemetry { } {
global GEMINI TELEMETRY
   set all [lsort [array names GEMINI]]
   foreach t $all {
      debuglog "Gemini $t = $TELEMETRY($GEMINI($t))"
   }
}

proc debuglog { msg } {puts stdout $msg}


set GEMINICFG(north,ip) 10.1.203.20

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


