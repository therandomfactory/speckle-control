#!/usr/bin/tclsh
#
# REDIS commands (via socket 6379)
#
# keys * - list all keys
# hgetall wiyn:key - get all values
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

proc redisReader { fh } {
global TELEMETRY
    while  { [gets $fh res] > -1 } {
###      debuglog "redis : $res"
      if { [lindex $res 0] == "timestamp" || [string range $res 0 3] == "tcs." } {
         set id $res
         gets $fh res ; gets $fh res
         set TELEMETRY($id) [string trim $res "\{\}"]
      }
    }
}

proc redisConnect { } {
  global REDIS
   set handle [socket -async $REDIS(ip) 6379]
   fconfigure $handle -buffering line
   fconfigure $handle -blocking 0
   set REDIS(handle) $handle
}

proc redisUpdate { } {
global REDIS
   foreach key "tcs-geometry tcs-target tcs-time tcs-telescop tcs-weather" {
     puts $REDIS(handle) "hgetall wiyn:$key"
   }
   after 100
   redisReader $REDIS(handle)
}


proc redisPrint { } {
global TELEMETRY
   foreach i [lsort [array names TELEMETRY]] {
      debuglog "$i = $TELEMETRY($i)"
   }
}

