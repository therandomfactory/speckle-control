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
set PICOS(ipoll) 1000

proc loadPicosConfig { {fname picomotorConfiguration} } {
global NESSI_DIR NESCONFIG PICOS
   if { [file exists $NESSI_DIR/$fname] == 0 } {
     errordialog "Picos configuration file $NESSI_DIR/$fname\n does not exist"
   } else {
     source $NESSI_DIR/$fname
     set NESCONFIG(picoChange) 0
   }
   logPicosConfig
   debuglog "Loaded PICO configuration"
}

proc savePicosConfig { fname } {
global NESSI_DIR  NESCONFIG PICOS
   set fcfg [open $NESSI_DIR/$fname w]
   puts $fcfg  "#!/usr/bin/tclsh
   echoPicosConfig $fcfg
   close $fcfg
   set NESCONFIG(picoChange) 0
   debuglog "Saved Picos configuration in $NESSI_DIR/$fname"
}

proc logPicosConfig { } {
global FLOG
  echoPicosConfig $FLOG
}

proc echoPicosConfig { fcfg } {
global PICOS
   puts $fcfg  "# Picos stage configuration parameters : [exec date]"
   foreach i "X Y " {
     foreach p "ip in out home engineer jog++ jog+ jog-- jog-" {
         puts $fcfg "set PICOS($i,$p) \"$PICOS($i,$p)\""
     }
     puts $fcfg ""
   }
   flush $fcfg
}


proc picosConnect { axis } {
global PICOS
   set handle -1
   set handle [socket $PICOS(ip) 23]
   fconfigure $s -buffering line
   if { $handle < 0 } {
     errordialog "Failed to connect to Picomotor at  $PICOS($axis,ip)"
   } else {
     debuglog "Picomotor connected to port $PICOS($axis,ip) - OK"
     set PICOS(handle) $handle
   }
   return $handle
}

proc picoCommand { axis cmd } {
global PICOS
   debuglog "Commanding $axis picomotor - $cmd"
   if { $PICOS(sim) } {
     set rec "SIM $axis $cmd"
     set ctype [lindex $cmd 0]
     if { $ctype == "POS" } {
        set PICOS($axis,position) [lindex [split $cmd "= "] 2]
     }
     if { $ctype == "REL" } {
        set delta [lindex [split $cmd "= "] 2]
        set PICOS($axis,position) [expr $PICOS($axis,position) + $delta]
     }
     set PICOS($axis,current) $PICOS($axis,position)
   } else {
     debuglog "Sending PICO command $axis $cmd"
     puts $PICOS(handle) "$PICOS($axis) $cmd"
     after 100
     gets $PICOS(handle) rec
   }
   return $rec
} 

proc picoSet { axis par {value ""} } {
global PICOS
   debuglog "PICO command set $axis $par $value"
   switch $par {
      disable        { set res [picoCommand $axis AB] }
      stop           { set res [picoCommand $axis ST] }
      position       { set res [picoCommand $axis "PA"] }
      acceleration   { set res [picoCommand $axis "AC"] }
      offset         { set res [picoCommand $axis "PR"] }
      velocity       { set res [picoCommand $axis "VA] }
      reset          { set res [picoCommand $axis "RS"] }
      in             { set res [picoCommand $axis "PA $PICOS($axis,in)"] }
      out            { set res [picoCommand $axis "PA $PICOS($axis,out)"] }
      home           { set res [picoCommand $axis "PA $PICOS($axis,home)"] }
  }
}

proc picosInitialize { } {
global PICOS
   debuglog "Initializing PICO stages"
   picoSet X out
   picoSet Y out
}

proc picosInPosition { } {
   debuglog "Set PICO position to in "
   picoSet X in
   picoSet Y in
}

proc picosOutPosition { } {
   debuglog "Set PICO position to out"
   picoSet X out
   picoSet Y out
}

proc jogPico { axis delta } {
global PICOS
   debuglog "Jog PICO $axis $delta"
   picoSet $axis offset $PICOS($axis,jog[set delta])
}



proc picoGet { axis par } {
global PICOS
   if { $PICOS(sim) } {
     debuglog "SIM $axis,$par = $PICOS($axis,$par)"
   } else {
     switch $par {
        acceleration   { set PICOS($axis,acceleration) [lindex [split [picoCommand $axis AC?] "="] 1] }
        position       { set PICOS($axis,position)     [lindex [split [picoCommand $axis TP?] "="] 1] }
        velocity       { set PICOS($axis,velocity)     [lindex [split [picoCommand $axis VA?] "="] 1] }
        status         { set PICOS($axis,status)       [lindex [split [picoCommand $axis MD?] "="] 1] }
        home           { set PICOS($axis,home)         [lindex [split [picoCommand $axis DH?] "="] 1] }
        ident          { set PICOS($axis,ident)        [lindex [split [picoCommand $axis *IDN?] "="] 1] }
      }
   }
   debuglog "Got PICO $axis $par = $PICOS($axis,$par)"
   return $PICOS($axis,$par)
}

proc picoMonitor { } {
global PICOS
  if { $PICOS(ipoll) > 0 } {
    picoGet X position
    picoGet X status
    picoGet Y position
    picoGet Y status
    after $PICOS(ipoll) picoMonitor
  }
}


proc picoUseCurrentPos { station } {
global PICOS NESCONFIG
   set PICOS(X,$station) [picoGet X position]
   debuglog "picomotor X $station set to $PICOS(X,$station)"
   set PICOS(Y,$station) [picoGet Y position]
   debuglog "picomotor Y $station set to $PICOS(Y,$station)"
   set NESCONFIG(picoChange) 1
}


proc picoHelp { } {
global PICOS
   puts stdout "
Supported commands : 
   picoSet \[ enable | disable | poslimit | neglimit | stop | reset \]
   picoSet \[ position | acceleration | velocity \]  value
   picoGet \[ position | acceleration | velocity | status \]
"
}

loadPicosConfig
set PICOS(sim) 0
if { [info exists env(NESSI_SIM)] } {
   set simdev [split $env(NESSI_SIM) ,]
   if { [lsearch $simdev picomotor] > -1 } {
       set PICOS(sim) 1
       set PICOS(X,position) 0 
       set PICOS(Y,position) 0
   } else {
       picosConnect 
   }
}

picosInitialize


