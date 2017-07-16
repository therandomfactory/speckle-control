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

proc loadPicosConfig { fname } {
global NESSI_DIR NESCONFIG PICOS
   if { [file exists $NESSI_DIR/$fname] == 0 } {
     errordialog "Picos configuration file $NESSI_DIR/$fname\n does not exist"
   } else {
     source $NESSI_DIR/PICOSConfiguration
     set NESCONFIG(picoChange) 0
   }
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
   puts $fcfg  "# Picos stage configuration parameters
"
   foreach i "A B " {
     foreach p "ip in out home engineer" {
         puts $fcfg "set PICOS($i,$p) \"$PICOS($i,$p)\""
     }
     puts $fcfg ""
   }
}


proc picoConnect { name } {
global PICOS
   set handle -1
   set handle [socket $PICOS($name,ip) 23]
   fconfigure $s -buffering line
   if { $handle < 0 } {
     errordialog "Failed to connect to Picomotor at  $PICOS($name,ip)"
   } else {
     debuglog "Picomotor connected to port $PICOS($name,ip) - OK"
     set PICOS($name,handle) $handle
   }
   return $handle
}

proc picoCommand { name cmd } {
global PICOS
   debuglog "Commanding $name picomotor - $cmd"
   puts $PICOS($name,handle) $cmd
   gets $PICOS($name,handle) rec
   return $rec
} 

proc picoSet { name par {value ""} } {
global PICOS
   switch $par {
      enable         { set res [picoCommand $name MON] }
      disable        { set res [picoCommand $name MOF] }
      poslimit       { set res [picoCommand $name FLI] }
      neglimit       { set res [picoCommand $name RLI] }
      position       { set res [picoCommand $name ABS A1=$value G] }
      acceleration   { set res [picoCommand $name ACC M0=$value] }
      offset         { set res [picoCommand $name REL A1=$value G] }
      stop           { set res [picoCommand $name STO] }
      velocity       { set res [picoCommand $name VEL M0=$value] }
      reset          { set res [picoCommand $name INI] }
      in             { set res [picoCommand $name ABS A1=$PICOS($name,in) G] }
      out            { set res [picoCommand $name ABS A1=$PICOS($name,out) G] }
      home           { set res [picoCommand $name ABS A1=$PICOS($name,home) G] }
      engineer       { set res [picoCommand $name ABS A1=$PICOS($name,engineer) G] }
  }
}

proc picoGet { name par value } {
global PICOS
   switch $par {
     acceleration   { set PICOS($name,acceleration) [lindex [split [picoCommand $name ACC] "=" 1] }
     position       { set PICOS($name,position)     [lindex [split [picoCommand $name POS] "=" 1] }
     velocity       { set PICOS($name,velocity)     [lindex [split [picoCommand $name VEL] "=" 1] }
     status         { set PICOS($name,status)       [lindex [split [picoCommand $name STA] "=" 1] }
   }
}

proc picoMonitor { } {
global PICOS
  if { $PICOS(ipoll) > 0 } {
    picoGet A position
    picoGet A status
    picoGet B position
    picoGet B status
    after $PICOS(ipoll) picoMonitor
  }
}


picoUseCurrentPos { name station } {
global PICOS NESCONFIG
   set PICOS($name,station) [picoGet $name position]
   debuglog "picomotor A $tation set to $PICOS($name,station)"
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




