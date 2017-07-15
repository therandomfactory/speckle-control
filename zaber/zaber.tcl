#!/usr/bin/tclsh

#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2.1. If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2017 The Random Factory (www.randomfactopry.com) 
#
#


set NESSI_DIR $env(NESSI_DIR)

set ZABERS(A,port) /dev/ttyACM0
set ZABERS(B,port) /dev/ttyACM1
set ZABERS(rotator,port) /dev/ttyUSB1


proc loadZaberConfig { fname } {
global NESSI_DIR ZABERS
   if { [file exists $NESSI_DIR/$fname] == 0 } {
     errordialog "Zaber configuration file $NESSI_DIR/$fname\n does not exist"
   } else {
     set i 0
     set fin [open $NESSI_DIR/$fname]
     while { [gets $fin rec] > -1 } {
         incr i 1
         set ZABERS([lindex $rec 0],device) $i
         set ZABERS($i,name) [lindex $rec 0]
         set ZABERS($i,unit1) [lindex $rec 1]
         set ZABERS($i,unit2) [lindex $rec 2]
         set ZABERS($i,aliuOut) [lrange $rec 3 4]
         set ZABERS($i,dichroicOut) [lindex $rec 5 6]
         set ZABERS($i,aliuIn) [lrange $rec 7 8]
         set ZABERS($i,dichroicIn) [lindex $rec 8 9]
     }
     close $fin
   }
}

proc saveZaberConfig { fcfg } {
global ZABERS
   puts $fcfg  "# Zaber stage configuration parameters"
   foreach i "1 2" {
     foreach p "name unit1 unit2 aliuOut dichroicOut aliuIn dichroicIn" {
         puts $fcfg "set ZABERS($i,$p) \"$ZABERS($i,$p)\""
     }
   }
}


proc zaberConnect { name } {
global ZABERS
   set handle -1
   if { $name == "JOUFLU_A" } {set handle [za_connect $ZABERS(A,port) ] }
   if { $name == "JOUFLU_B" } {set handle [za_connect $ZABERS(B,port) ] }
   if { $name == "Rotator"  } {set handle [za_connect $ZABERS(Rotator,port) ] }
   if { $handle < 0 } {
     errordialog "Failed to connect to Zaber $name"
   }
   set ZABERS($name,handle) $handle
   return $handle
}

proc zaberParseResponse { name } {
global ZABERS
  if { $ZABERS($name,handle) > 0 } {
     set result [za_receive $ZABERS($name,handle) ]
     set ZABERS($name,[lindex $result 1]) "lrange $result 2 end]
  } else {
     errordialog "Zaber handle not valid in zaberParseResponse - $name"
  }
}


proc zaberSetPos  { name axis pos } {
global ZABERS
  if { $ZABERS($name,$handle)  > 0 } {
     set result [za_send $handle "/$device $axis set pos $pos"]
     after 100 "zaberParseResponse $handle"
  } else {
     errordialog "Zaber handle not valid in zaberSetPos - $handle"
  }
}

proc zaberSetDevice { handle cmd setting value } {
global ZABERS
  if { $handle > 0 } {
     set result [za_send $handle "/$cmd $setting $value"]
     after 100 "zaberParseResponse $handle"
  } else {
     errordialog "Zaber handle not valid in zaberSetDevice - $handle"
  }
}

proc zaberLed { handle state } {
global ZABERS
  if { $handle > 0 } {
     set result [za_send $handle "/set system.led.enable $state"]
     after 100 "zaberParseResponse $handle"
  } else {
     errordialog "Zaber handle not valid in zaberLed - $handle"
  }
}

proc zaberHelp { } {
global ZABERS
   puts stdout "
Supported commands : 
    home
    move max nnn
    move abs nnn
    move rel nnn
    renumber
    stepsize nnn
    led 0/1
    set xxx
"
}






