#
#  Special decoding routines, autocalled by virtue of specifiying "PROC routine-name"
#  in the telem.conf telemetry configuration file
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

proc catchdec { value } {
global TELEMETRY
   if { [string trim $TELEMETRY(tcs.target.state)] ==  " Helio. mean FK5" } {
     set value [expr $value/3.1415926*180.]
     return [catchdms $value]
   } else {
     return "Not-available"
   }
}

proc catchst { value } {
global TELEMETRY
  return [catchhms [expr $value/3.141592564689*12.]]
}

proc catchzd { value } {
global TELEMETRY
  return "float [format %6.2f [expr $value/3.141592564689*180.]]"
}

proc catchfloat { value } {
  return "float $value"
}

proc catchmnir { value } {
global TELEMETRY
  return "float [format %6.2f [expr $value/3.141592564689*180.]]"
}

proc catchint { value } {
  return "integer $value"
}

proc catchraddeg { value } {
global TELEMETRY
  return "double [format %19.3f [expr $value/3.141592564689*180.]]"
}


proc catchmapper  { value } {
  return [catchdms [expr $value/3.141592564689*180.]]
}

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


proc catchhms { value } {
   set h [expr int($value)]
   set m [expr int(($value-$h)*60.)]
   set s [format %6.3f [expr ($value-$h-$m/60.)*3600.]]
   set s1 [lindex [split $s .] 0]
   set s2 [lindex [split $s .] 1]
   return "string [format %2.2d $h]:[format %2.2d $m]:[format %2.2d $s1].[format %s $s2]"
}

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



proc catchtrack { value } {
     if { $value == 1 } {
          set  status "Tracking"
    } else {
          set status "Not tracking"
    }
    return "string $status"
}

proc catchepoch { value } {
global TELEMETRY
  set value $TELEMETRY(tcs.target.epoch)
  return "float [format %7.2f $value]"
}


proc catchequinox { value } {
global TELEMETRY
  set value $TELEMETRY(tcs.target.equinox)
  return "float [format %7.2f $value]"
}

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

proc catchrotangle { value } {
     return "string [radians_to_dms $value]"
}


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

proc catchfold { value } {
  return "string $value"
}


set TELEMETRY(tcs.target.state) unknown
