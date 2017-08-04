#!/usr/bin/tclsh

#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2.1. If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2017 The Random Factory (www.randomfactory.com) 
#
#


set NESSI_DIR $env(NESSI_DIR)



proc loadZaberConfig { fname } {
global NESSI_DIR ZABERS
   if { [file exists $NESSI_DIR/$fname] == 0 } {
     errordialog "Zaber configuration file $NESSI_DIR/$fname\n does not exist"
   } else {
     source $NESSI_DIR/zabersConfiguration
     set NESCONFIG(zaberChange) 0
   }
}

proc saveZaberConfig { fname } {
global NESSI_DIR ZABERS
   set fcfg [open $NESSI_DIR/$fname w]
   puts $fcfg  "#!/usr/bin/tclsh
   echoZaberConfig $fcfg
   close $fcfg
   set NESCONFIG(zaberChange) 0
   debuglog "Saved Zaber configuration in $NESSI_DIR/$fname"
}

proc logZaberConfig { } {
global FLOG
  echoZaberConfig $FLOG
}

proc echoZaberConfig { fcfg } {
global ZABERS
   puts $fcfg  "# Zaber stage configuration parameters
set ZABERS(port) $ZABERS(port)
"
   foreach i "A B " {
     foreach p "device speckle wide home engineer" {
         puts $fcfg "set ZABERS($i,$p) \"$ZABERS($i,$p)\""
     }
     puts $fcfg ""
   }
   foreach p "device in out home" {  
     puts $fcfg "set ZABERS(rotator,$p) \"$ZABERS(rotator,$p)\""
   }
}


proc zaberConnect { name } {
global ZABERS
   set handle -1
   if { [info exists ZABERS(sim)] } {
      set handle 1
   } else {
      set handle [za_connect $ZABERS(port) ]
   }
   if { $handle < 0 } {
     errordialog "Failed to connect to Zaber $name"
   } else {
     debuglog "Zabers connected to port $ZABERS(port) - OK"
     set ZABERS(handle) $handle
   }
   return $handle
}

proc zaberParseResponse { name } {
global ZABERS
  if { $ZABERS(handle) > 0 } {
     set result [za_receive $ZABERS(handle) ]
     set ZABERS($name,[lindex $result 1]) "lrange $result 2 end]
     debuglog "Zaber response : $result"
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

proc zaberGoto { device pos } {
global ZABERS
  set newp $ZABERS($device,$pos)
  set res [zaberSetPos $device $newp]
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


set simzaber 0
if { [info exists env(NESSI_SIM)] } {
   set simdev [split $env(NESSI_SIM) ,]
   if { [lsearch $simdev zaber] > -1 } {
       set simzaber 1
   }
}

if { $simzaber } {
     proc za_send { handle cmd } {
        global ZABERS
        set ZABERS(sim) $cmd
     }
     proc za_receive { handle } {
        global ZABERS
        set cmd $ZABERS(sim)
        set dev [string trim [lindex $cmd 0] "/"]
        set res [lrange $cmd 1 end]
        return "$dev $res"
     }
} else {
   load $env(NESSI_DIR)/lib/libzaber.so
}





