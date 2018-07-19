#!/usr/bin/tclsh

set DEV(6001) "Zabers USB"

set prog [exec which lsusb]
set uall [split [exec $prog] \n]
foreach d $uall {
   set id [lindex $d 5]
   set manu [lindex [split $id :] 0]
   set devi [lindex [split $id :] 1]
   if { $manu == "0403" } {
    if { [info exists DEV($devi)] } {
      set path [string trim "/proc/bus/usb/[lindex $d 1]/[lindex $d 3]" :]
      if { [file exists $path] } {
        puts stdout "Found Zabers $DEV($devi) : $d, path $path"
        puts stdout "Invoking sudo chmod to alter rw device permissions..."
        puts stdout "sudo chmod a+rw $path"
        exec sudo chmod a+rw $path
      }
      set path [string trim "/dev/bus/usb/[lindex $d 1]/[lindex $d 3]" :]
      if { [file exists $path] } {
        puts stdout "Found Zabers $DEV($devi) : $d, path $path"
        puts stdout "Invoking sudo chmod to alter rw device permissions..."
        puts stdout "sudo chmod a+rw $path"
        exec sudo chmod a+rw $path
      }
    }
   }
}


