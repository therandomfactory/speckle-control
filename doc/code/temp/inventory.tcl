#!/usr/bin/tclsh

set nandor 0
set nwheel 0
set nzaber 0
set FWHEELS(sim) 0
set ZABERS(sim) 0

set inventory [split [exec lsusb] \n]
foreach d $inventory {
   if { [lindex $d 6] == "Andor" } {incr nandor 1}
   if { [lindex $d 6] == "Newport" } { incr nwheel 1}
   if { [lrange $d 6 end] == "Future Technology Devices International, Ltd FT232 USB-Serial (UART) IC" } {
     incr nzaber 1
   }
}

puts stdout "Found $nandor Andor cameras"
puts stdout "Found $nwheel Filter wheels"
puts stdout "Found $nzaber Zaber serial devices"

if { $nandor == 0 } {
  set INSTRUMENT(red) 0
  set INSTRUMENT(blue) 0
  puts stdout "********************************************************************************"
  puts stdout "******************** WARNING - NO ANDOR CAMERAS DETECTED  **********************"
  puts stdout "*********************          CAMERAS IN SIMULATION MODE **********************"
  puts stdout "********************************************************************************"
}

if { $nandor == 1 } {
  set cams [exec ps axw | grep andor]]
  set proc [lindex [split $cams \n] 1]
  set id [lindex $proc 6]
  set INSTRUMENT(red) 0
  set INSTRUMENT(blue) 0
  if { $id == 1 } {
    set INSTRUMENT(red) 1
  } else {
    set INSTRUMENT(blue) 1
  }
  puts stdout "********************************************************************************"
  puts stdout "******************** WARNING - SINGLE ANDOR CAMERAS DETECTED *******************"
  puts stdout "*********************          ONE CAMERA IN SIMULATION MODE *******************"
  puts stdout "********************************************************************************"
}

set res [catch {exec $env(SPECKLE_DIR)/oriel/testFilterExists.tcl} ok]
if { $nwheel == 0 || $res == 1 } {
  set FWHEELS(sim) 1
  puts stdout "********************************************************************************"
  puts stdout "******************** WARNING - NO FILTER WHEELS DETECTED  **********************"
  puts stdout "*********************          FILTERS IN SIMULATION MODE **********************"
  puts stdout "********************************************************************************"
}

if { $nzaber == 0 || $ZABERS(sim) == 1 } {
  set ZABERS(sim) 1
  puts stdout "********************************************************************************"
  puts stdout "******************** WARNING - NO ZABER DEVICES DETECTED  **********************"
  puts stdout "*********************          ZABERS IN SIMULATION MODE  **********************"
  puts stdout "********************************************************************************"
}

if { [info exists env(INVENTORY_EXIT)] } { 
  exit
}



