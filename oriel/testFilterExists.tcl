#!/usr/bin/tclsh
proc findWheels { } {
global FWSERIAL
   set fw [split [exec lsusb] \n]
   set id 1
   foreach i $fw {
      if { [lindex $i 6] == "Newport" } {
        catch {
          set iusb($id) [string trim [lindex $i 1]:[lindex $i 3] :]
          set info [exec lsusb -v -s $iusb($id)]
          set FWSERIAL($iusb($id)) [lindex $info [expr [lsearch $info iSerial] +2]
]
          incr id 1
        }
      }
   }
}

load $env(SPECKLE_DIR)/lib/liboriel.so
set f1 [oriel_connect 1]
set f2 [oriel_connect 2]

