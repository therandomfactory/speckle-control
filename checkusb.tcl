## \file checkusb.tcl
# \brief This contains a procedure to check the usb devices
#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2 If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) 
#
#
#
#\code
## Documented proc \c debuglog .
# \param[in] devices List of keyword to identify speckle devices
#
# Test the user rw permissions of the USB devices
#
proc checkUsbPermissions { {devices "Andor Newport" } } {
   set all [split [exec lsusb] \n]
   if { [file exists /dev/bus/usb] } {
     foreach d $all {
       if { [lsearch $d $devices] > -1 } {
         set id [string trim "/dev/bus/usb/[lindex $d 1]/[string trim [lindex $d 3] :]" ]
         set perm [exec ls -l $id]
         if { [string range $perm 7 8] != "rw" } {
            puts stdout "Insufficient permissions for device $device"
         }
       }
     }
   }
   if { [file exists /proc/bus/usb] } {
     foreach d $all {
       if { [lsearch $d $devices] > -1 } {
         set id [string trim "/proc/bus/usb/[lindex $d 1]/[string trim [lindex $d 3] :]" ]
         set perm [exec ls -l $id]
         if { [string range $perm 7 8] != "rw" } {
            puts stdout "Insufficient permissions for device $d"
         }
       }
     }
   }
   foreach device "/dev/ttyUSB0 /dev/ttyUSB1" {
     if { [file exists $device] } {
       set perm [exec ls -l $device]
       if { [string range $perm 7 8] != "rw" } {
          puts stdout "Insufficient permissions for device $device"
       }
     }
   }
}

#\endcode


