
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


