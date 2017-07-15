
proc newdata { name par state type value } {
global TELEMETRY
#  puts stdout "got $name = $value"
  set TELEMETRY($name) [join [split $value "\{\}\""] " "]
  set TELEMETRY($name,t) $type
}

proc fitshdrrecord { key type value text } {
global TOMPG
  set record ""
  set v1 [lindex $value 0]
  set fmt 18.13e
  if { [llength [split $type _]] > 1 } {
     set fmt [lindex [split $type _] 1]
     set type [lindex [split $type _] 0]     
  } else {
     if { $type == "float" || $type == "double" } {
        if { $value == "" } {set value 0.0}
        if { [expr abs($value)] < 9999.9 } {
           set fmt 18.3f
        }
     }
  }
  switch $type {
     string  {
              set record "[format %-8s $key]= '[format %-18s $value]'"
             }
     integer {
              set record "[format %-8s $key]=  [format %19d $value]"
             }
     boolean {
              set record "[format %-8s $key]=  [format %19s $value]"
             }
     float   {
              set record [string toupper "[format %-8s $key]=  [format %$fmt $v1]"]
             }
     double  {
              set record [string toupper "[format %-8s $key]=  [format %$fmt $v1]"]
             }
  }
  set record "$record /[format %-48s $text]"
  return "$record"
}

proc gettlm { item } {
  set it [lindex [wiyn info $item] 0]
}

proc xpak_header { image } {
global TELEMETRY PSIL_CONFIG
   set fid [fits open $image]
   set r [fitshdrrecord UT float [gettlm tcs.time.UT1] "UT1"]
   $fid put keyword $r
   set r [fitshdrrecord LAST float [gettlm tcs.time.LAST] "Local sidereal time"]
   $fid put keyword $r
   set r [fitshdrrecord OBSDATE string [exec date -u +%Y-%m-%dT%H:%M:%S.0]  "UT date/time"]
   $fid put keyword $r
   set r [fitshdrrecord TARGAZ string [radians_to_hms [gettlm tcs.target.az]] "Target AZ"]
   $fid put keyword $r
   set r [fitshdrrecord TARGALT string [radians_to_dms [gettlm tcs.target.alt]] "Target ALT"]
   $fid put keyword $r
   set r [fitshdrrecord EPOCH float [gettlm tcs.target.epoch] "Target EPOCH"]
   $fid put keyword $r
   set r [fitshdrrecord EQUINOX float [gettlm tcs.target.equinox] "Target EQUINOX"]
   $fid put keyword $r
   set r [fitshdrrecord RA string [gettlm tcs.telescope.ra] "RA"]
   $fid put keyword $r
   set r [fitshdrrecord DEC string [gettlm tcs.telescope.dec] "DEC"]
   $fid put keyword $r
   set r [fitshdrrecord AIRMASS float [gettlm tcs.telescope.zenithdist] "ZD"]
   $fid put keyword $r
   set r [fitshdrrecord ZD float [gettlm tcs.telescope.airmass] "Airmass"]
   $fid put keyword $r
   set r [fitshdrrecord FOCUS float [getFocus] "Focus"]
   $fid put keyword $r
   set r [fitshdrrecord AZ string [radians_to_dms [gettlm tcs.azimuth.mapper]] "Azimuth"]
   $fid put keyword $r
   set r [fitshdrrecord ALT string [radians_to_dms [gettlm tcs.elevation.mapper]] "Elevation"]
   $fid put keyword $r
   set r [fitshdrrecord BINNING integer $PSIL_CONFIG(1,binning) "Pixel Binning"]
   $fid put keyword $r
   set r [fitshdrrecord PIXEL float [expr $PSIL_CONFIG(1,binning)*0.052] "Pixel scale in microns"]
   $fid put keyword $r
   set r [fitshdrrecord ROTANGLE string [radians_to_dms [gettlm tcs.mnir.position]] "Rotator position"]
   $fid put keyword $r
   set r [fitshdrrecord ROTOFF string [radians_to_dms [gettlm tcs.mnir.offset]] "Rotator offset"]
   $fid put keyword $r
   fits close $fid
}

proc getFocus { } {
    set posa [lindex [wiyn info oss.secondary.posa] 0]
    set posb [lindex [wiyn info oss.secondary.posb] 0]
    set posc [lindex [wiyn info oss.secondary.posc] 0]
    set current -99990.
    catch {set  current [expr  ($posa+$posc)/2.0/8.0 ]}
    return $current
}

load /usr/local/gwc/lib/libnames.so
load /usr/local/gwc/lib/libmsg.so
load /usr/local/gwc/lib/libgwc.so
connect wiyn tkxpak

load /usr/local/gui/lib/libxtcs.so
load /usr/local/gui/lib/libfitstcl.so

foreach i "tcs.time tcs.target tcs.telescope tcs.mnir tcs.azimuth tcs.elevation oss.secondary" {
   wiyn stevent $i "newdata $i" foreach
}



#      a)  date/time
#     (b)  Target RA/DEC/EPOCH/EQUINOX
#     (c)   Telescope RA/DEC/EPOCH/EQUINOX
#     (d)  MNIR angle in degrees!  either ±180d or 0 to 360d
#     (e)  MNIR offset angle in degrees!
#     (f)  airmass, ZD, parallactic angle
#     (g) focus, secondary
#     (h) Azimuth and Elevation
#     (i)  Binning factor
#     (j)  proper pixel scale according to binning:  1x1 is 0.052 arcsec/pixel 


