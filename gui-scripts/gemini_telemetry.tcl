## \file gemini_telemetry.tcl
# \brief This contains procedures to gather Gemini telescope telemetry
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
## Documented proc \c geminiConnect .
# \param[in] scope Telescope id , north or south
#
# Connect to the telemery server
#
# Globals :
#		GEMINICFG - Gemini specific proprties
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
   set GEMINICFG(site) $scope
   puts $GEMINICFG(handle) "get airmass"
   gets $GEMINICFG(handle) rec
   return $handle
}

## Documented proc \c flushGemini .
#
# Flush the socket buffers
#
# Globals :
#		GEMINICFG - Gemini specific proprties
#
proc flushGemini { } {
global GEMINICFG
   while { [gets $GEMINICFG(handle) rec] > -1 } {
      debuglog "flushed $rec"
   }
}



## Documented proc \c updateGeminiTelemetry .
#
# Update telemetry by querying server
#
# Globals :\n
#		GEMINICFG - Gemini specific proprties\n
#		GEMINI - Gemini specific items\n
#		TELEMETRY - Global telemetry array for headers and database
#
proc updateGeminiTelemetry { } {
global GEMINI GEMINICFG TELEMETRY SCOPE
   set all [lsort [array names GEMINI]]
   foreach t $all {
      set ok "none"
      catch { set ok [puts $GEMINICFG(handle) "get $t\n"] } res
      if { $ok == "none" } { 
        debuglog "Gemini telemetry lost - reconnecting"
        geminiConnect $GEMINICFG(site)
      }
   }
   after 500
   while { [gets $GEMINICFG(handle) rec] > -1 } {
      if { [info exists GEMINI([lindex $rec 1])] } {
        set TELEMETRY($GEMINI([lindex $rec 1])) [lrange $rec 2 end]
        debuglog "Got $rec"
      } else {
        debuglog "Got unknown $rec"
      }
   }
   echoGeminiTelemetry
   set TELEMETRY(speckle.scope.instrument) $SCOPE(instrument)
   set SCOPE(ProgID) $TELEMETRY($GEMINI(programid))
   set SCOPE(ra) $TELEMETRY($GEMINI(targetra))
   set SCOPE(dec) $TELEMETRY($GEMINI(targetdec))
   set SCOPE(target) $TELEMETRY($GEMINI(targetname))
   set SCOPE(telescope)  $TELEMETRY($GEMINI(telescope))
   set TELEMETRY(tcs.target.name) $SCOPE(target)
#   set all [lsort [array names GEMINI]]
#   foreach i $all {
#      set CACHETELEMETRY($GEMINI($t)) $TELEMETRY($GEMINI($t))
#   }
}

## Documented proc \c echoGeminiTelemetry .
#
# Print out the Gemini telemetry to debug log
#
# Globals :\n
#		GEMINI - Gemini specific items\n
#		TELEMETRY - Global telemetry array for headers and database
#
proc echoGeminiTelemetry { } {
global GEMINI TELEMETRY
   set all [lsort [array names GEMINI]]
   foreach t $all {
      debuglog "Gemini $t = $TELEMETRY($GEMINI($t))"
   }
}

## Documented proc \c simGeminiTelemetry .
#
# Simulate Gemini telemetry
#
# Globals :\n
#		GEMINI - Gemini specific items\n
#		TELEMETRY - Global telemetry array for headers and database\n
#		CACHETELEMETRY - Cached Global telemetry
#
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

## Documented proc \c speckleTelemetryUpdate .
#
# Simulate Gemini telemetry
#
# Globals :\n
#		GEMINI - Gemini specific items\n
#		TELEMETRY - Global telemetry array for headers and database\n
#		CACHETELEMETRY - Cached Global telemetry\n
#		SCOPE - Array of telescope properties\n
#		FITSKEY - Array of FITS keywords for headers\n
#		ANDOR_CFG - Array of Andor camera parameters\n
#		CAM - Camera id , 0 or 1\n
#		IMGMETA - Image metadata
#
proc speckleTelemetryUpdate { } {
global SCOPE TELEMETRY FITSKEY IMGMETA ANDOR_CFG CAM
   updateGeminiTelemetry
   foreach i [array names SCOPE] {
       set TELEMETRY(speckle.scope.$i) $SCOPE($i)
   }
   foreach i [array names FITSKEY] {
      if { [info exists IMGMETA([lindex [split $i .] end],value)] } {
          set TELEMETRY($i) $IMGMETA([lindex [split $i .] end],value)
      }
  }
  set TELEMETRY(speckle.andor.head) "iXon"
  set TELEMETRY(speckle.andor.acquisition_mode) $ANDOR_CFG(acquisition)
  set TELEMETRY(speckle.andor.kinetic_time) $ANDOR_CFG(kineticcycletime)
  set TELEMETRY(speckle.andor.num_exposures) $ANDOR_CFG(numseq)
  set TELEMETRY(speckle.andor.exposure_total) [expr $ANDOR_CFG(numseq)*$ANDOR_CFG(setexposure)]
  set TELEMETRY(speckle.andor.read_mode) $ANDOR_CFG(readmode)
  set TELEMETRY(speckle.andor.fullframe) [lrange $ANDOR_CFG(configure) 2 5]
  set TELEMETRY(speckle.andor.hbin) [lindex $ANDOR_CFG(configure) 0]
  set TELEMETRY(speckle.andor.vbin) [lindex $ANDOR_CFG(configure) 1]
  set TELEMETRY(speckle.andor.roi) [lrange $ANDOR_CFG(configure) 2 5]
  set TELEMETRY(speckle.andor.datatype) $ANDOR_CFG(fitsbits)
  set TELEMETRY(speckle.andor.em_gain) $ANDOR_CFG(emccdgain)
  set TELEMETRY(speckle.andor.vertical_speed) [lindex $ANDOR_CFG(verticalspeeds) $ANDOR_CFG(vsspeed)]
  set TELEMETRY(speckle.andor.amplifier) $ANDOR_CFG(outputamp)
  set TELEMETRY(speckle.andor.preamp_gain) $ANDOR_CFG(preampgain)
  set TELEMETRY(speckle.andor.serial_number) $ANDOR_CFG($CAM,SerialNumber)
  set TELEMETRY(speckle.andor.target_temperature) $ANDOR_CFG(temperature)
  set TELEMETRY(speckle.andor.numaccum)  $ANDOR_CFG(numberaccumulations)
  set TELEMETRY(speckle.andor.frametransfer) $ANDOR_CFG(frametransfer)
  set TELEMETRY(speckle.andor.numberkinetics) $ANDOR_CFG(numberkinetics)
  set TELEMETRY(speckle.andor.accumulationcycletime) $ANDOR_CFG(accumulationcycletime)
  set TELEMETRY(speckle.andor.ccdtemp) $ANDOR_CFG(ccdtemp)
}

# \encdode

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
set ANDOR_CFG(vsspeed) 1
set ANDOR_CFG(outputamp) 0
set ANDOR_CFG(preampgain) 1
set ANDOR_CFG(0,SerialNumber) 12345
set ANDOR_CFG(1,SerialNumber) 54321
set ANDOR_CFG(temperature) 0.0
set ANDOR_CFG(inputzaber) "NA"
set ANDOR_CFG(fieldzaber) "NA"
set ANDOR_CFG(numberaccumulations) 0
set ANDOR_CFG(frametransfer) 1
set ANDOR_CFG(numberkinetics) 0
set ANDOR_CFG(accumulationcycletime) 0.0
set ANDOR_CFG(ccdtemp) 0.0
set ANDOR_CFG(filter) "NA"


set GEMINICFG(north,ip) 10.2.44.60
set GEMINICFG(north,port) 7283

set GEMINI(airmass)	tcs.telescope.airmass
set GEMINI(azimuth)	tcs.azimuth.mapper
set GEMINI(azerror) 	tcs.azimuth.error
set GEMINI(elevation) 	tcs.elevation.mapper
set GEMINI(elerror) 	tcs.elevation.error
set GEMINI(focus) 	tcs.telescope.focus
set GEMINI(beam)  	tcs.telescope.beam
set GEMINI(framepa) 	tcs.telescope.pa
set GEMINI(guiding) 	tcs.telescope.guiding
set GEMINI(ha) 		tcs.telescope.ha
set GEMINI(humidity) 	tcs.weather.humidity
set GEMINI(instraa) 	tcs.telescope.instraa
set GEMINI(instrpa) 	tcs.telescope.instrpa
set GEMINI(localtime) 	tcs.time.local
set GEMINI(lst) 	tcs.time.LAST
set GEMINI(mjd) 	tcs.time.MJD
set GEMINI(offsetdec) 	tcs.telescope.decoffset
set GEMINI(offsetra) 	tcs.telescope.raoffset
set GEMINI(programid) 	speckle.scope.obsid
set GEMINI(rotator) 	tcs.nir.position
set GEMINI(targetname) 	speckle.scope.target
set GEMINI(targetra) 	tcs.target.az
set GEMINI(targetdec) 	tcs.target.alt
set GEMINI(targetepoch) tcs.target.epoch
set GEMINI(targetframe) tcs.target.state
set GEMINI(telescope) 	speckle.scope.name
set GEMINI(telra) 	tcs.telescope.ra
set GEMINI(teldec) 	tcs.telescope.dec
set GEMINI(userfocus) 	tcs.telescope.userfocus
set GEMINI(utc) 	tcs.time.UT1
set GEMINI(utcdate) 	tcs.time.date
set GEMINI(zd) 		tcs.telescope.zenithdist


