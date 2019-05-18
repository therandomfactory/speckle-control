## \file picomotor.tcl
# \brief This contains routines for controlling the picomotors
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) \n
#\n
#
#
#\code
## Documented proc \c loadPicosConfig .
# \param[in] fname Name of configuration file
#
#  Load pico motors configuration
#
# Globals :\n
#		SPECKLE_DIR - Directory path of speckle code\n
#		PICOS - Array of pico configuration data
#
proc loadPicosConfig { {fname picomotorConfiguration} } {
global SPECKLE_DIR PICOS SCOPE env
   set fname "[set fname].[string tolower $SCOPE(telescope)]"
   if { [file exists $SPECKLE_DIR/$fname] == 0 } {
     errordialog "Picos configuration file $SPECKLE_DIR/$fname\n does not exist"
   } else {
     source $SPECKLE_DIR/$fname
     logPicosConfig
   }
   debuglog "Loaded PICO configuration"
}

## Documented proc \c savePicosConfig .
# \param[in] fname Name of configuration file
#
#  Load pico motors configuration
#
# Globals :\n
#		SPECKLE_DIR - Directory path of speckle code\n
#		PICOS - Array of pico configuration data
#
proc savePicosConfig { fname } {
global SPECKLE_DIR PICOS
   set fcfg [open $SPECKLE_DIR/$fname w]
   if { $env(GEMINISITE) == "south" } { 
      set fname "[set fname]S"
   }
   puts $fcfg  "#!/usr/bin/tclsh
   echoPicosConfig $fcfg
   close $fcfg
   debuglog "Saved Picos configuration in $SPECKLE_DIR/$fname"
}

## Documented proc \c logPicosConfig .
#
#  Log pico motors configuration
#
# Globals :\n
#		FLOG - File handle of open log 
#
proc logPicosConfig { } {
global FLOG
  echoPicosConfig $FLOG
}

## Documented proc \c savePicosConfig .
# \param[in] fcfg File handle
#
#  Print pico motors configuration
#
# Globals :\n
#		PICOS - Array of pico configuration data
#
proc echoPicosConfig { fcfg } {
global PICOS
   puts $fcfg  "# Picos stage configuration parameters : [exec date]"
   foreach i "X Y " {
     foreach p "in out home engineer jog++ jog+ jog-- jog-" {
         puts $fcfg "set PICOS($i,$p) \"$PICOS($i,$p)\""
     }
     puts $fcfg ""
   }
   flush $fcfg
}


## Documented proc \c picosConnect .
#
#  Connect to pico motors port
#
# Globals :\n
#		PICOS - Array of pico configuration data
#
proc picosConnect { } {
global PICOS
   set handle -1
   set handle [socket $PICOS(ip) 23]
   fconfigure $handle -buffering line
   fconfigure $handle -blocking 0
   if { $handle < 0 } {
     errordialog "Failed to connect to Picomotor at  $PICOS(ip)"
   } else {
     debuglog "Picomotor connected to port $PICOS(ip) - OK"
     set PICOS(handle) $handle
   }
   return $handle
}

## Documented proc \c picoCommand .
# \param[in] axis Number of axis 1,2,3
# \param[in] cmd  Command text
#
#  Send a command to pico axis 
#
# Globals :\n
#		PICOS - Array of pico configuration data
#
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
     exec curl  -o /tmp/picoresult http://10.2.110.11/cmd_send.cgi?cmd=[set PICOS($axis)][set cmd]%3F\\&submit=Send
     set res [split [exec cat /tmp/picoresult] \n]
     set ack [string trim [lindex $res [expr [lsearch $res "#response"] +2]] ">"]
     debuglog "Response = $ack"
###     puts $PICOS(handle) "$PICOS($axis) $cmd"
###     after 100
###     gets $PICOS(handle) rec
   }
   return $rec
} 

## Documented proc \c picoSet .
# \param[in] axis Number of axis 1,2,3
# \param[in] par  Parameter name
# \param[in] value New value for parameter
#
#  Send a command to pico axis 
#
# Globals :\n
#		PICOS - Array of pico configuration data
#
proc picoSet { axis par {value ""} } {
global PICOS
   debuglog "PICO command set $axis $par $value"
   switch $par {
      disable        { set res [picoCommand $axis AB] }
      stop           { set res [picoCommand $axis ST] }
      position       { set res [picoCommand $axis "PA $value"] }
      acceleration   { set res [picoCommand $axis "AC $value"] }
      offset         { set res [picoCommand $axis "PR $value"] }
      velocity       { set res [picoCommand $axis "VA $value] }
      reset          { set res [picoCommand $axis "RS"] }
      in             { set res [picoCommand $axis "PA $PICOS($axis,in)"] }
      out            { set res [picoCommand $axis "PA $PICOS($axis,out)"] }
      home           { set res [picoCommand $axis "PA $PICOS($axis,home)"] }
  }
}

## Documented proc \c picoSet .
#
#  Initialize the pico motor axes
#
proc picosInitialize { } {
   debuglog "Initializing PICO stages"
   picoSet X RS
   picoSet Y RS
   picoSet Z RS
}

## Documented proc \c picosInPosition .
#
#  Move pico motor axes to in position
#
proc picosInPosition { } {
   debuglog "Set PICO position to in "
   picoSet X in
   picoSet Y in
   picoSet Z in
}

## Documented proc \c picoOutPosition .
#
#  Move pico motor axes to out position
#
proc picosOutPosition { } {
   debuglog "Set PICO position to out"
   picoSet X out
   picoSet Y out
   picoSet Z out
}

## Documented proc \c jogPico .
# \param[in] axis Number of axis 1,2,3
# \param[in] delta Steps to move
#
#  Adjust pico motor axis position
#
# Globals :
#		PICOS - Array of pico configuration data
#
proc jogPico { axis delta } {
global PICOS
   debuglog "Jog PICO $axis $delta"
   picoSet $axis offset $PICOS($axis,jog[set delta])
}



## Documented proc \c picoGet .
# \param[in] axis Number of axis 1,2,3
# \param[in] par Parameter to query
#
#  Get pico axis status
#
# Globals :
#		PICOS - Array of pico configuration data
#
proc picoGet { axis par } {
global PICOS
   if { $PICOS(sim) } {
     debuglog "SIM $axis,$par = $PICOS($axis,$par)"
   } else {
     switch $par {
        acceleration   { set PICOS($axis,acceleration) [picoCommand $axis AC?] }
        position       { set PICOS($axis,position)     [picoCommand $axis TP?] }
        velocity       { set PICOS($axis,velocity)     [picoCommand $axis VA?] }
        status         { set PICOS($axis,status)       [picoCommand $axis MD?] }
        home           { set PICOS($axis,home)         [picoCommand $axis DH?] }
        ident          { set PICOS($axis,ident)        [picoCommand $axis *IDN?] }
      }
   }
#   debuglog "Got PICO $axis $par = $PICOS($axis,$par)"
   puts stdout  "Got PICO $axis $par = $PICOS($axis,$par)"
   return $PICOS($axis,$par)
}

## Documented proc \c picoMonitor .
#
#  Poll axis positions and status
#
# Globals :
#		PICOS - Array of pico configuration data
#
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


## Documented proc \c picoUseCurrentPos .
#
#  Set station position to current axis position
#
# Globals :
#		PICOS - Array of pico configuration data
#
proc picoUseCurrentPos { station } {
global PICOS
   set PICOS(X,$station) [picoGet X position]
   debuglog "picomotor X $station set to $PICOS(X,$station)"
   set PICOS(Y,$station) [picoGet Y position]
   debuglog "picomotor Y $station set to $PICOS(Y,$station)"
}


## Documented proc \c picoHelp .
#
#  Help stub for potential implmentation as a service
#
proc picoHelp { } {
   puts stdout "
Supported commands : 
   picoSet \[ enable | disable | poslimit | neglimit | stop | reset \]
   picoSet \[ position | acceleration | velocity \]  value
   picoGet \[ position | acceleration | velocity | status \]
"
}


# \endcode

set SPECKLE_DIR $env(SPECKLE_DIR)
set PICOS(ipoll) 1000
set PICOS(sim) 0
if { [info exists env(SPECKLE_SIM)] } {
   set simdev [split $env(SPECKLE_SIM) ,]
   if { [lsearch $simdev picomotor] > -1 } {
       set PICOS(sim) 1
       set PICOS(X,position) 0 
       set PICOS(Y,position) 0
   } else {
       loadPicosConfig
###       picosConnect 
       picosInitialize
   }
}

set PICOS(X,jog-) -1
set PICOS(X,jog--) -10
set PICOS(X,jog+) 1
set PICOS(X,jog++) +10

set PICOS(Y,jog-) -1
set PICOS(Y,jog--) -10
set PICOS(Y,jog+) 1
set PICOS(Y,jog++) +10


