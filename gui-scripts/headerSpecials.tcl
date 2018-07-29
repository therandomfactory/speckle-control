## \file headerSpecials.tcl
# \brief This contains procedures to process header items
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) \n
#\n
#
#
#  Special decoding routines, autocalled by virtue of specifiying "PROC routine-name"\n
#  in the telem.conf telemetry configuration file\n
#
#
#\code
## Documented proc \c catchra .
# \param[in] value Value of header data to be processed
#
# Process RA header item
#
proc catchra { value } {
global TELEMETRY
   if { [string trim $TELEMETRY(tcs.target.state)] == "Helio. mean FK5" } {
      set value [expr $value/3.1415926*12.]
      if { $value > 24.0 } {set value [expr $value-24.0]}
     return [catchhms $value]
   } else {
     return "Not-available"
   }
}

## Documented proc \c catchdec .
# \param[in] value Value of header data to be processed
#
# Process DEC header item
#
proc catchdec { value } {
global TELEMETRY
   if { [string trim $TELEMETRY(tcs.target.state)] ==  " Helio. mean FK5" } {
     set value [expr $value/3.1415926*180.]
     return [catchdms $value]
   } else {
     return "Not-available"
   }
}

## Documented proc \c catchst .
# \param[in] value Value of header data to be processed
#
# Process ST header item
#
proc catchst { value } {
global TELEMETRY
  return [catchhms [expr $value/3.141592564689*12.]]
}

## Documented proc \c catchzd .
# \param[in] value Value of header data to be processed
#
# Process ZD header item
#
proc catchzd { value } {
global TELEMETRY
  return "float [format %6.2f [expr $value/3.141592564689*180.]]"
}

## Documented proc \c catchfloat .
# \param[in] value Value of header data to be processed
#
# Process generic floating point header item
#
proc catchfloat { value } {
  return "float $value"
}

## Documented proc \c catchmnir .
# \param[in] value Value of header data to be processed
#
# Process mnir header item
#
proc catchmnir { value } {
global TELEMETRY
  return "float [format %6.2f [expr $value/3.141592564689*180.]]"
}

## Documented proc \c catchint .
# \param[in] value Value of header data to be processed
#
# Process generic integer header item
#
proc catchint { value } {
  return "integer $value"
}

## Documented proc \c catchraddeg .
# \param[in] value Value of header data to be processed
#
# Process generic radians header item
#
proc catchraddeg { value } {
global TELEMETRY
  return "double [format %19.3f [expr $value/3.141592564689*180.]]"
}


## Documented proc \c catchmapper .
# \param[in] value Value of header data to be processed
#
# Process mapper header item
#
proc catchmapper  { value } {
  return [catchdms [expr $value/3.141592564689*180.]]
}

## Documented proc \c catchfocus .
# \param[in] value Value of header data to be processed
#
# Process focus header item
#
proc catchfocus { value } {
global TOMPG
    catch {
       set posa [lindex [wiyn info oss.secondary.posa] 0]
      set posb [lindex [wiyn info oss.secondary.posb] 0]
      set posc [lindex [wiyn info oss.secondary.posc] 0]
    }
    set current -99990.
    catch {set  current [expr  ($posa+$posc)/2.0/8.0 ]}
    return "float $current"
}


## Documented proc \c catchhms .
# \param[in] value Value of header data to be processed
#
# Process generic hms  header item
#
proc catchhms { value } {
   set h [expr int($value)]
   set m [expr int(($value-$h)*60.)]
   set s [format %6.3f [expr ($value-$h-$m/60.)*3600.]]
   set s1 [lindex [split $s .] 0]
   set s2 [lindex [split $s .] 1]
   return "string [format %2.2d $h]:[format %2.2d $m]:[format %2.2d $s1].[format %s $s2]"
}

## Documented proc \c catchdms .
# \param[in] value Value of header data to be processed
#
# Process generic dms header item
#
proc catchdms { value } {
    set sign ""
    if { $value < 0.0 } {set sign "-"}
   set value [expr abs($value)]
   set d [expr int($value)]
   set m [expr int(($value-$d)*60.)]
   set s [format %6.3f [expr ($value-$d-$m/60.)*3600.]]
   set s1 [lindex [split $s .] 0]
   set s2 [lindex [split $s .] 1]
   return "string $sign[format %2.2d $d]:[format %2.2d $m]:[format %2.2d $s1].[format %s $s2]"
}



## Documented proc \c catchtrack .
# \param[in] value Value of header data to be processed
#
# Process tracking header item
#
proc catchtrack { value } {
     if { $value == 1 } {
          set  status "Tracking"
    } else {
          set status "Not tracking"
    }
    return "string $status"
}

## Documented proc \c catchepoch .
# \param[in] value Value of header data to be processed
#
# Process epoch header item
#
proc catchepoch { value } {
global TELEMETRY
  set value $TELEMETRY(tcs.target.epoch)
  return "float [format %7.2f $value]"
}


## Documented proc \c catchequinox .
# \param[in] value Value of header data to be processed
#
# Process equinox header item
#
proc catchequinox { value } {
global TELEMETRY
  set value $TELEMETRY(tcs.target.equinox)
  return "float [format %7.2f $value]"
}

## Documented proc \c catchcoords .
# \param[in] value Value of header data to be processed
#
# Process generic coords header item
#
proc catchcoords { value } {
global TELEMETRY
     switch  $TELEMETRY(tcs.target.state) {
            "Helio. mean FK5"  -
            FK5  {
                       set xlate [radians_to_dms $value]
                       }
            default { set xlate 00:00:00.00 }
     }
      return "string $xlate"
}

## Documented proc \c catchrotangle .
# \param[in] value Value of header data to be processed
#
# Process rotator angle header item
#
proc catchrotangle { value } {
     return "string [radians_to_dms $value]"
}


## Documented proc \c catchrotpos .
# \param[in] value Value of header data to be processed
#
# Process rotator position header item
#
proc catchrotpos { value } {
global TELEMETRY PORT
  if { [lindex [wiyn info oss.tertiary.foldinserted] 0] == "On" } {
      if { $value == 12 } {
         set PORT wnir
      }
      if { $value == 9 } {
         set PORT mnir
      }
   } else {
      set PORT cass
   }
   return "string $PORT"
}

## Documented proc \c catchfold .
# \param[in] value Value of header data to be processed
#
# Process fold mirror header item
#
proc catchfold { value } {
  return "string $value"
}

# \endcode

set TELEMETRY(tcs.target.state) unknown
