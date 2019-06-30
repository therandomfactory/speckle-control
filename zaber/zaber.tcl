#!/usr/bin/wish
## \file zaber.tcl
# \brief This contains procedures for Zaber device control
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) \n
#\n
#
# Arm A = blue
# Arm B = red
#
#\code
#

## Documented proc \c errordialog .
#
#  Print error message
#
proc errordialog { msg } {puts stdout $msg}

## Documented proc \c loadZaberConfig .
# \param[in] fname Name of configuration file
#
#  Load zaber device configrations
#
#
# Globals :\n
#		ZABERS - Array of Zaber device configuration and state\n
#		SCOPE - Array of telescope parameters\n
#		SPECKLE_DIR - Directory path of speckle code
#
proc loadZaberConfig { {fname zabersConfiguration} } {
global SPECKLE_DIR ZABERS env
   if { $env(TELESCOPE) == "GEMINI" } {  
      set fname "[set fname].gemini"
      if { $env(GEMINISITE) == "south" } {
        set fname "[set fname]S"
      }
   } else {
      set fname "[set fname].wiyn"
   }
   if { [file exists $SPECKLE_DIR/$fname] == 0 } {
     errordialog "Zaber configuration file $SPECKLE_DIR/$fname\n does not exist"
   } else {
     source $SPECKLE_DIR/$fname
     debuglog "Loaded Zaber configuration from $SPECKLE_DIR/$fname"
   }
}

## Documented proc \c saveZaberConfig .
# \param[in] fname Name of configuration file
#
#  Save zaber device configrations
#
#
# Globals :\n
#		ZABERS - Array of Zaber device configuration and state\n
#		SPECKLE_DIR - Directory path of speckle code
#
proc saveZaberConfig { fname } {
global SPECKLE_DIR ZABERS env
   if { $env(TELESCOPE) == "GEMINI" } {  
      set fname "[set fname].gemini"
      if { $env(GEMINISITE) == "south" } {
        set fname "[set fname]S"
      }
   } else {
      set fname "[set fname].wiyn"
   }
   set fcfg [open $SPECKLE_DIR/$fname w]
   puts $fcfg  "#!/usr/bin/tclsh"
   echoZaberConfig $fcfg
   close $fcfg
   debuglog "Saved Zaber configuration in $SPECKLE_DIR/$fname"
}

## Documented proc \c logZaberConfig .
# \param[in] fname Name of configuration file
#
#  Log zaber configuration info
#
#
# Globals :\n
#		FLOG - File handle of open log file
#
proc logZaberConfig { } {
global FLOG
  echoZaberConfig $FLOG
}

## Documented proc \c echoZaberConfig .
# \param[in] fcfg File handle to log to
#
#  Print zaber configuration info
#
#
# Globals :\n
#		ZABERS - Array of Zaber device configuration and state\n
#		SCOPE - Array of telescope parameters
#
proc echoZaberConfig { {fcfg stdout} } {
global ZABERS env
   puts $fcfg  "# Zaber stage configuration parameters
set ZABERS(port) $ZABERS(port)
"
   foreach i "A B " {
     foreach p "device speckle wide" {
         puts $fcfg "set ZABERS($i,$p) \"$ZABERS($i,$p)\""
     }
     puts $fcfg ""
   }
   foreach p "device speckle wide" {  
     puts $fcfg "set ZABERS(input,$p) \"$ZABERS(input,$p)\""
   }
   if { $env(TELESCOPE) == "GEMINI" } {
     foreach p "device extend stow" {  
       puts $fcfg "set ZABERS(pickoff,$p) \"$ZABERS(pickoff,$p)\""
     }
     foreach p "device extend stow" {  
       puts $fcfg "set ZABERS(focus,$p) \"$ZABERS(focus,$p)\""
     }
   }
   flush $fcfg
}

## Documented proc \c zaberPrintProperties .
# \param[in] fd File handle to log to
#
#  Print zaber properties and values
#
#
# Globals :\n
#		ZABERS - Array of Zaber device configuration and state\n
#		ZPROPERTIES - Array of device properties
#		SCOPE - Array of telescope parameters
#
proc zaberPrintProperties { {fd stdout} } {
global ZABERS ZPROPERTIES env
   if { $env(TELESCOPE) == "WIYN" } {
    puts $fd "Property		A	B	input"
    foreach p [split $ZPROPERTIES \n] {
       puts $fd "[format %-20s $p]	$ZABERS(A,$p)	$ZABERS(B,$p)	$ZABERS(input,$p)"
     }
   }
   if { $env(TELESCOPE) == "GEMINI" } {
     puts $fd "Property		A	B	input	pickoff		focus"
     foreach p [split $ZPROPERTIES \n] {
       puts $fd "[format %-20s $p]	$ZABERS(A,$p)	$ZABERS(B,$p)	$ZABERS(input,$p)	$ZABERS(pickoff,$p)	$ZABERS(focus,$p)"
     }
   }
}


## Documented proc \c zaberConnect .
#
#  Connect to zabers devices usb serial port
#
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberConnect { } {
global ZABERS
   set handle -1
   if { $ZABERS(sim) } {
     set ZABERS(handle) -1
     debuglog "Zabers in SIMULATION mode"
     return
   } else {
      if { [file exists $ZABERS(port)] }  {
         set handle [open $ZABERS(port) RDWR]
      }
      if { $handle < 0 } {
         set handle [open $ZABERS(port2) RDWR]
      }
      fconfigure $handle -buffering none
      fconfigure $handle -blocking 0
      fconfigure $handle -mode 115200,n,8,1
      fileevent $handle readable [list zaberReader $handle]
    }
   if { $handle < 0 } {
     errordialog "Failed to connect to Zaber $name"
   } else {
     debuglog "Zabers connected to port $ZABERS(port) - OK"
     set ZABERS(handle) $handle
   }
   return $handle
}

## Documented proc \c zaberDisconnect .
#
#  Disconnect from zabers devices usb serial port
#
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberDisconnect { } {
global ZABERS
   debuglog "Disconnecting from Zabers"
   close $ZABERS(handle)
}

## Documented proc \c homeZabers .
#
#  Send all zabers to the HOME position
#
#
# Globals :
#		SCOPE - Array of telescope configuration
proc homeZabers { } {
global env
   zaberCommand A home
   zaberCommand B home
   zaberCommand input home
   if { $env(TELESCOPE) == "GEMINI" } {
      zaberCommand focus home
      zaberCommand pickoff home
   }
   after 7000 zaberCheck
}

## Documented proc \c zaberCommand .
# \param[in] name Name of device
# \param[in] Command string
#
#  Send a command to a zaber device
#
#
# Globals :\n
#		ZABERS - Array of Zaber device configuration and state\n
#		ZPROP - Commanded property name\n
#		ZNAME - Commanded device name\n
#		ZSIMPROP - Simulated property value
#
proc zaberCommand { name cmd } {
global ZABERS ZPROP ZNAME ZSIMPROP
  if { $ZABERS(handle) > 0 } {
     set ZPROP none
     set ZNAME $name
     set ZSIMPROP ""
     if { [lindex $cmd 0] == "get" || [lindex $cmd 0] == "set" } {
         set ZPROP [lindex $cmd 1]
     }
     if { [lindex $cmd 0] == "move" } { set ZPROP pos }
     if { $ZABERS(sim) && [lindex $cmd 0] == "set" } {
        set ZSIMPROP [lindex $cmd 2]
     } else {
       debuglog "Sending zaber command /$ZABERS($name,device) $cmd"
       set result [puts $ZABERS(handle) "/$ZABERS($name,device) $cmd\r\n"]
       after 100 update
     }
  }
}

## Documented proc \c zaberCheck .
#
#  Query zaber for current settings
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberCheck { } {
global ZABERS env
 if { $ZABERS(sim) == 0 } {
  foreach s "A B input" {
    zaberCommand $s "get pos"
    after 200
    zaberReader $ZABERS(handle)
    set ZABERS($s,readpos) $ZABERS($s,pos)
    if { [expr abs($ZABERS($s,pos) - $ZABERS($s,speckle))] < 5 } {set ZABERS($s,readpos) "speckle"}
    if { [expr abs($ZABERS($s,pos) - $ZABERS($s,wide))] < 5 } {set ZABERS($s,readpos) "wide"}
  }
  .mimicSpeckle.zaberA configure -text "Zaber A : $ZABERS(A,pos) : $ZABERS(A,readpos)"
  .mimicSpeckle.zaberB configure -text "Zaber B : $ZABERS(B,pos) : $ZABERS(B,readpos)"
  .mimicSpeckle.zaberInput configure -text "Zaber Input : $ZABERS(input,pos) : $ZABERS(input,readpos)"
  if { $env(TELESCOPE) == "GEMINI" } { 
    zaberCommand focus "get pos"
    after 200
    zaberReader $ZABERS(handle)
    set ZABERS(focus,readpos) $ZABERS(focus,pos)
    if { [expr abs($ZABERS(focus,pos) - $ZABERS(focus,extend))] < 5 } {set ZABERS(focus,readpos) "extend"}
    if { [expr abs($ZABERS(focus,pos) - $ZABERS(focus,stow))] < 5 } {set ZABERS(focus,readpos) "stow"}
    zaberCommand pickoff "get pos"
     after 200
    zaberReader $ZABERS(handle)
    set ZABERS(pickoff,readpos) $ZABERS(pickoff,pos)
    if { [expr abs($ZABERS(pickoff,pos) - $ZABERS(pickoff,extend))] < 5 } {set ZABERS(pickoff,readpos) "extend"}
    if { [expr abs($ZABERS(pickoff,pos) - $ZABERS(pickoff,stow))] < 5 } {set ZABERS(pickoff,readpos) "stow"}
    .mimicSpeckle.zaberFocus configure -text "Zaber Focus : $ZABERS(focus,pos) : $ZABERS(focus,readpos)"
    .mimicSpeckle.zaberPickoff configure -text "Zaber Pickoff : $ZABERS(pickoff,pos) : $ZABERS(pickoff,readpos)"
  }
 }
}


## Documented proc \c zaberReader .
# \param[in] fh Socket handle
#
#  Read all available zaber feedback
#
# Globals :\n
#		ZABERS - Array of Zaber device configuration and state\n
#		ZPROP - Commanded property name\n
#		ZNAME - Commanded device name\n
#		ZSIMPROP - Simulated property value
#
proc zaberReader { fh } {
global ZABERS ZPROP ZNAME ZSIMPROP
  if { $ZABERS(sim) } {
    if { $ZSIMPROP != "" } {
       set ZABERS($ZNAME,$ZPROP) $ZSIMPROP
    }
  } else {
    if { ![eof $fh] } {
      set res [gets $fh]
      debuglog "zaber : $res"
      if { [lindex $res 2] == "OK" } {
              set ZABERS($ZNAME,$ZPROP) "[lindex $res 5]"
      }
    }
  }
}

## Documented proc \c zaberGetProperties .
# \param[in] name Name of device
#
#  Send commands to query all property values
#
# Globals :\n
#		ZABERS - Array of Zaber device configuration and state\n
#		ZPROPERTIES - Array of device properties
#
proc zaberGetProperties { name } {
global ZABERS ZPROPERTIES
   foreach p [split $ZPROPERTIES \n] {
       zaberCommand $name "get $p"
       after 100
       update
   }
}


## Documented proc \c zaberSetPos .
# \param[in] name Name of device
# \param[in] pos Position value
#
#  Send commands set a device position
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberSetPos  { name pos } {
global ZABERS
   if { $ZABERS(sim) } {
     debuglog "Zaber simulate : $name $pos"
   } else {
     zaberCommand $name  "move abs $pos"
   }
}



## Documented proc \c zaberJogger .
# \param[in] op  Operation
#
#  Send commands set a device position
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberJogger  { op } {
global ZABERS
    switch $op {
        red   { 
                set ZABERS(jogtarget) $ZABERS(red) ; .lowlevel.jogz configure -text "Zaber = $ZABERS(red)"
                .lowlevel.vzab configure -text $ZABERS($ZABERS(jogtarget),pos)
              }
        blue  { 
                set ZABERS(jogtarget) $ZABERS(blue) ; .lowlevel.jogz configure -text "Zaber = $ZABERS(blue)"
                .lowlevel.vzab configure -text $ZABERS($ZABERS(jogtarget),pos)
              }
        focus -
        pickoff -
        input { 
                set ZABERS(jogtarget) $op ; .lowlevel.jogz configure -text "Zaber = $op"
                .lowlevel.vzab configure -text $ZABERS($ZABERS(jogtarget),pos)
              }
        plus  { 
                set newpos [expr $ZABERS($ZABERS(jogtarget),pos) + $ZABERS(delta)]
                zaberCommand $ZABERS(jogtarget) "move rel $ZABERS(delta)"
                .lowlevel.vzab configure -text $newpos
                after 500 zaberCheck
                set ZABERS($ZABERS(jogtarget),pos) $newpos
              }
        minus { 
                set newpos [expr $ZABERS($ZABERS(jogtarget),pos) - $ZABERS(delta)]
                zaberCommand $ZABERS(jogtarget) "move rel -$ZABERS(delta)" 
                .lowlevel.vzab configure -text $newpos
                after 500 zaberCheck
                set ZABERS($ZABERS(jogtarget),pos) $newpos
              }
        home  { 
                zaberCommand  $ZABERS(jogtarget) home
                after 500 zaberCheck
              }
   }
}

## Documented proc \c zaberSetProperty .
# \param[in] name Name of device
# \param[in] property Name of property
# \param[in] value New value for property
#
#  Send commands set a device property
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberSetProperty { name property value } {
   zaberCommand $name "set $property $value"
}
 

## Documented proc \c zaberEngpos .
# \param[in] name Name of device
#
#  Send defvice to a named position
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberEngpos { name } {
global ZABERS
  set newp $ZABERS($name,target)
  set res [zaberSetPos $name $newp]
}


## Documented proc \c zaberGoto .
# \param[in] name Name of device
#
#  Send device to a named position and update mimic diagram
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberGoto { name pos } {
global ZABERS
  set newp $ZABERS($name,$pos)
  set res [zaberSetPos $name $newp]
  if { $name == "input"  } {
    mimicMode input $pos
  } else {
    catch {mimicMode $ZABERS($name,arm) $pos}
  }
  after 7000 zaberCheck
}

## Documented proc \c zaberConfigurePos .
# \param[in] name Name of device
# \param[in] property Name of property
# \param[in] value New value for property
#
#  Send device to a named position and update mimic diagram
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberConfigurePos { name property {value current} } {
global ZABERS
    if { $value == "current" } {
        set ZABERS($name,$property) $ZABERS($name,pos)
    } else {
        set ZABERS($name,$property) $value
    }   
}

## Documented proc \c zaberHelp .
#
#  Print zaber command menu
#
proc zaberHelp { } {
global ZABERS
   puts stdout "
Supported commands : 
    estop
    home
    speckle
    wide
    in
    out
    move abs nnn
    move rel nnn
    set xxx
"
}

## Documented proc \c zaberStopAll .
#
#  Stop all zaber device motion
#
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc zaberStopAll { } {
global ZABERS
  debuglog "Zabers estop"
  foreach d [array names ZABERS] {
     if { [lindex [split $d ,] 1] == "device" } {
        set id [lindex [split $d ,] 0]
        puts stdout "Requested estop for device $id"
        zaberCommand $id estop
     }
  }
}

## Documented proc \c positionZabers .
#
#  Move all zabers to requested station
#
proc positionZabers { station } {
   debuglog "Configure Zabers for $station"
   if { $station == "fullframe" } {
      zaberGoto A wide   
      zaberGoto B wide
      zaberGoto input wide
   }
   if { $station == "roi" } {
      zaberGoto A speckle  
      zaberGoto B speckle
      zaberGoto input speckle
   }
   after 7000 zaberCheck
}

## Documented proc \c positionSpeckle .
#
#  Move zabers to Speckle mode positions
#
#
# Globals :
#		ZABERS - Array of Zaber device configuration and state
#
proc positionSpeckle { arm station } {
global ZABERS
   debuglog "Configure $arm Zaber for $station"
   if { $station == "fullframe" } {
      if { $ZABERS(A,arm) == $arm } {zaberGoto A wide} 
      if { $ZABERS(B,arm) == $arm } {zaberGoto B wide} 
      zaberGoto input wide
   }
   if { $station == "roi" } {
      if { $ZABERS(A,arm) == $arm } {zaberGoto A speckle} 
      if { $ZABERS(B,arm) == $arm } {zaberGoto B speckle} 
      zaberGoto input speckle
   }
   after 7000 zaberCheck
}



## Documented proc \c zaberService .
#
#  Optional routine to setup zabers as a server
#
#
proc zaberService { name cmd {a1 ""} {a2 ""} } {
   switch $cmd {
      estop       {zaberStopAll}
      home        {zaberCommand $name home}
      speckle     {zaberGoto $name speckle}
      in          {zaberCommand $name in}
      out         {zaberCommand $name out}
      wide        {zaberGoto $name wide}
      move        {zaberCommand $name "move $a1 $a2"}
      set         {zaberSetProperty $a1 $a2}
   }
}


# \endcode

if { [info exists env(SPECKLE_SIM)] } {
   set simdev [split $env(SPECKLE_SIM) ,]
   if { [lsearch $simdev zaber] > -1 } {
       set ZABERS(sim) 1
   }
}



set ZPROPERTIES "system.serial
deviceid
system.axiscount
version
version.build
system.voltage
system.access
comm.rs232.baud
comm.protocol
comm.rs232.protocol
stream.numbufs
stream.numstreams
comm.checksum
comm.alert
comm.address
system.led.enable
accel
driver.temperature
pos
limit.min
limit.max
limit.home.pos
motion.index.dist
motion.accelonly
motion.decelonly
maxspeed
driver.current.run
driver.current.hold
driver.current.max
resolution"

set SPECKLE_DIR $env(SPECKLE_DIR)
loadZaberConfig
echoZaberConfig
set ZABERS($ZABERS(A,arm)) A
set ZABERS($ZABERS(B,arm)) B

zaberConnect
set ZSIMPROP ""
if { $ZABERS(sim) == 0 } {
  zaberGetProperties A
  zaberGetProperties B
  zaberGetProperties input
  if { $env(TELESCOPE) == "GEMINI" } { zaberGetProperties pickoff ; zaberGetProperties focus }
  zaberPrintProperties
  zaberCommand A home
  zaberCommand B home
  zaberCommand input home
  after 3000
  zaberGoto A wide
  zaberGoto B wide
  zaberGoto input wide
  if { $env(TELESCOPE) == "GEMINI" } {
       set ZABERS(focus,readpos) 999999
       set ZABERS(pickoff,readpos) 999999
  }
} else {
  set ZABERS(input,readpos) 999999
  set ZABERS(A,readpos) 999999
  set ZABERS(B,readpos) 999999
  set ZABERS(input,pos) 999999
  set ZABERS(A,pos) 999999
  set ZABERS(B,pos) 999999
}

set ZABERS(delta) 10


