#!/usr/bin/tclsh
## \file redisquery.tcl
# \brief This contains procedures for interacting with the Redis telemetry service at WIYN
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) \n
#\n
#
#
# REDIS commands (via socket 6379)\n
#\n
# keys * - list all keys\n
# hgetall wiyn:key - get all values\n
#
#
#\code
## Documented proc \c redisReader .
# \param[in] fh Socket handle of Redis server connection
#
#  Read any new data from the Redis server
#
# Globals :
#		TELEMETRY - Array of telemetry items for headers and database usage
#
proc redisReader { fh } {
global TELEMETRY
    while  { [gets $fh res] > -1 } {
###      debuglog "redis : $res"
      if { [lindex $res 0] == "timestamp" || [string range $res 0 3] == "tcs." ||  [string range $res 0 3] == "dcs." ||  [string range $res 0 3] == "oss." } {
         set id $res
         gets $fh res ; gets $fh res
         set TELEMETRY($id) [string trim $res "\{\}"]
      }
    }
}

## Documented proc \c redisConnect .
#
#  Make a socket connection to the Redis server (WIYN only)
#
#
# Globals :
#		REDIS - Array of Redis server configuration
#
proc redisConnect { } {
  global REDIS
   set handle [socket -async $REDIS(ip) 6379]
   fconfigure $handle -buffering line
   fconfigure $handle -blocking 0
   set REDIS(handle) $handle
}

## Documented proc \c redisUpdate .
#
#  Send a set of Redis queries to update all the WIYN telemetry
#
#
# Globals :
#		REDIS - Array of Redis server configuration
#
proc redisUpdate { } {
global REDIS
   foreach key "tcs-geometry tcs-time tcs-telescop tcs-weather oss-secondary dcs-elevation dcs-azimuth" {
     puts $REDIS(handle) "hgetall wiyn:$key"
   }
   after 100
   redisReader $REDIS(handle)
}


## Documented proc \c redisPrint .
#
#  Print the current Redis telemetry values to the log
#
#
# Globals :
#		TELEMETRY - Array of telemetry items for headers and database usage
#
proc redisPrint { } {
global TELEMETRY
   foreach i [lsort [array names TELEMETRY]] {
      debuglog "$i = $TELEMETRY($i)"
   }
}

proc updateRedisTelemetry { item value } {
global REDIS
   catch {
     puts $REDIS(handle) "hset wiyn:speckle.status $item \"$value\""   
   }
}


# \endcode

# Redis commands : 
#   keys *  - list all the key sets
#   hset wiyn:speckle.test key "value"
#

set TLMKEYS "
wiyn:tcs-nir

wiyn:tcs-weather
timestamp
tcs.weather.pressure
tcs.weather.relhumdome
tcs.weather.relhumout
tcs.weather.windspeed
tcs.weather.winddir
tcs.weather.refa
tcs.weather.refb
tcs.weather.dometemp
tcs.weather.outsidetemp

wiyn:dcs-azimuth
dcs.azimuth.ra

wiyn:dcs-elevation
dcs.elevation.dec

wiyn:ias-caliblamps

wiyn:tcs-time
timestamp
tcs.time.UTC
tcs.time.delta_AT
tcs.time.delta_UT
tcs.time.tai
tcs.time.tdt
tcs.time.tdb
tcs.time.UT1
tcs.time.GMST
tcs.time.GAST
tcs.time.LAST

wiyn:oss-counterbalance
wiyn:hydra-guider

wiyn:tcs-telescop
timestamp
tcs.telescope.azoffset
tcs.telescope.mnirbeta
tcs.telescope.wnirbeta
tcs.telescope.airmass
tcs.telescope.hourangle
tcs.telescope.paraangle
tcs.telescope.zenithdist
tcs.telescope.ra
tcs.telescope.dec
tcs.telescope.raoffset
tcs.telescope.decoffset

wiyn:hydra-field
wiyn:tcs-cass
wiyn:tcs-dome
wiyn:oss-secondary
wiyn:computer_room_temp
wiyn:dcs-mdcs
wiyn:dcs-nir
wiyn:tcs-azimuth
wiyn:hydra-gripper
wiyn:dcs-dome
wiyn:dcs-elevation
wiyn:ias-adc
wiyn:bsa-main
wiyn:oss-thermocouple
wiyn:tcs-elevation
wiyn:dcs-mnir
wiyn:tcs-mnir
wiyn:oss-flatfield
wiyn:ias-wfscam
wiyn:oss-tertiary
wiyn:ias-powersupply
wiyn:tcs-geometry
wiyn:bsa-thermal
wiyn:pms
wiyn:ias-focusprobe
wiyn:ias-guideprobe
wiyn:icc-camera
wiyn:hydra-assign

wiyn:tcs-target
timestamp
tcs.target.epoch
tcs.target.equinox
tcs.target.alt
tcs.target.az
tcs.target.altoffset
tcs.target.azoffset
tcs.target.altmotion
tcs.target.azmotion
tcs.target.parallax
tcs.target.speed
tcs.target.wavelength
tcs.target.name
tcs.target.tracking

wiyn:oss-mirror"

set REDIS(ip) wiyn-db.kpno.noao.edu


