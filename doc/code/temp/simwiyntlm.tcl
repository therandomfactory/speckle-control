#!/usr/bin/tclsh
## \file simwiymtlm.tcl
# \brief This contains procedures for simulating the telemetry service at WIYN
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) \n
#\n
#
#\code


## Documented proc \c simWIYNTelemetry .
#
# Simulate WIYN telemetry
#
# Globals :\n
#		TELEMETRY - Global telemetry array for headers and database\n
#		CACHETELEMETRY - Cached Global telemetry
#
proc simWIYNTelemetry { } {
global WIYNTLM TELEMETRY CACHETELEMETRY
   set TELEMETRY($WIYNTLM(airmass)) 1.000
   set TELEMETRY($WIYNTLM(azerror)) +00:00:00.00
   set TELEMETRY($WIYNTLM(azimuth)) +90:00:00.00
   set TELEMETRY($WIYNTLM(elerror)) +00:00:00.00
   set TELEMETRY($WIYNTLM(elevation)) +90:00:00.00
   set TELEMETRY($WIYNTLM(focus)) 0.000
   set TELEMETRY($WIYNTLM(framepa)) FK5
   set TELEMETRY($WIYNTLM(guiding)) Off
   set TELEMETRY($WIYNTLM(ha)) 0.0
   set TELEMETRY($WIYNTLM(humidity)) 20.0
   set TELEMETRY($WIYNTLM(instraa)) 0.000
   set TELEMETRY($WIYNTLM(instrpa)) 0.000
   set TELEMETRY($WIYNTLM(localtime)) 00:00:00.0
   set TELEMETRY($WIYNTLM(lst)) 00:00:00.0
   set TELEMETRY($WIYNTLM(mjd)) 999999.
   set TELEMETRY($WIYNTLM(offsetdec)) 0.000
   set TELEMETRY($WIYNTLM(offsetra)) 0.000
   set TELEMETRY($WIYNTLM(programid)) None
   set TELEMETRY($WIYNTLM(rotator)) 0.000
   set TELEMETRY($WIYNTLM(targetdec)) 0.00000000
   set TELEMETRY($WIYNTLM(targetepoch)) 2000.0
   set TELEMETRY($WIYNTLM(targetframe)) FK5
   set TELEMETRY($WIYNTLM(targetname)) WIYN
   set TELEMETRY($WIYNTLM(targetra)) 0.00000000
   set TELEMETRY($WIYNTLM(teldec)) 00:00:00.0
   set TELEMETRY($WIYNTLM(telescope)) WIYN
   set TELEMETRY($WIYNTLM(telra)) 00:00:00.0
   set TELEMETRY($WIYNTLM(userfocus)) 0.000
   set TELEMETRY($WIYNTLM(utc)) 00:00:00.0
   set TELEMETRY($WIYNTLM(utcdate)) 2000-01-01
   set TELEMETRY($WIYNTLM(zd)) 0.0000
   set all [lsort [array names WIYNTLM]]
   foreach t $all {
      set CACHETELEMETRY($WIYNTLM($t))  $TELEMETRY($WIYNTLM($t))
   }
}


# \endcode


set TELEMETRY(speckle.scope.release) "Not used"
set TELEMETRY(tcs.telescope.guiding) "Off"

set WIYNTLM(airmass) 	tcs.telescope.airmass
set WIYNTLM(azimuth) 	tcs.azimuth.mapper
set WIYNTLM(azerror) 	tcs.azimuth.error
set WIYNTLM(elevation) 	tcs.elevation.mapper
set WIYNTLM(elerror) 	tcs.elevation.error
set WIYNTLM(focus) 	tcs.telescope.focus
set WIYNTLM(framepa) 	tcs.telescope.pa
set WIYNTLM(guiding) 	tcs.telescope.guiding
set WIYNTLM(ha) 	tcs.telescope.ha
set WIYNTLM(humidity) 	tcs.weather.humidity
set WIYNTLM(instraa) 	tcs.telescope.instraa
set WIYNTLM(instrpa) 	tcs.telescope.instrpa
set WIYNTLM(localtime) 	tcs.time.local
set WIYNTLM(lst) 	tcs.time.LAST
set WIYNTLM(mjd) 	tcs.time.MJD
set WIYNTLM(offsetdec) 	tcs.telescope.decoffset
set WIYNTLM(offsetra)	tcs.telescope.raoffset
set WIYNTLM(programid) 	speckle.scope.obsid
set WIYNTLM(rotator) 	tcs.nir.position
set WIYNTLM(targetname) speckle.scope.name
set WIYNTLM(targetra) 	tcs.target.az
set WIYNTLM(targetdec) 	tcs.target.alt
set WIYNTLM(targetepoch) tcs.target.epoch
set WIYNTLM(targetframe) tcs.target.state
set WIYNTLM(telescope) 	speckle.scope.name
set WIYNTLM(telra) 	tcs.telescope.ra
set WIYNTLM(teldec) 	tcs.telescope.dec
set WIYNTLM(userfocus) 	tcs.telescope.userfocus
set WIYNTLM(utc) 	tcs.time.UT1
set WIYNTLM(utcdate) 	tcs.time.date
set WIYNTLM(zd) 	tcs.telescope.zenithdist


