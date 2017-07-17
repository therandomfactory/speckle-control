
proc filechecks { fname } {
global SCOPE env
   set dname [file dirname $fname]
   if { [file exists $dname] == 0 } {
      set err "Directory does not exist - creating $dname"
      set it [ tk_dialog .d "No directory" "WARNING: $err" {} -1 "OK"]           
      if { [file writable [file dirname $dname]] == 0 } {
         set err "Cannot create $dname - switching to $env(HOME)"
         set it [ tk_dialog .d "No permission" "WARNING: $err" {} -1 "OK"]           
         set SCOPE(datadir) $env(HOME)
         .main.seldir configure -text $SCOPE(datadir)
         set fname "$env(HOME)/[file tail $fname]"
      } else {
         exec mkdir -p $dname
         .main.seldir configure -text $SCOPE(datadir)
      }
   }
   set dname [file dirname $fname]
   if { [file writable $dname] == 0 } {
      set err "Directory $dname not writable\nSwitching to $env(HOME)"
      set it [ tk_dialog .d "No permission" "WARNING: $err" {} -1 "OK"]           
      set fname "$env(HOME)/[file tail $fname]"
      set SCOPE(datadir) $env(HOME)
      .main.seldir configure -text $SCOPE(datadir)
   }
   set dname [file dirname $fname]
   set spc [lindex  [split [exec df [file dirname $fname]] \n] 1]
   set rpc [string trim [lindex $spc 4] "%"]
   if { $rpc > 95 } {
       set err "Disk more than 95% full"
       set it [ tk_dialog .d "Disk filling up" "WARNING: $err" {} -1 "OK"]           
   }
   if { $rpc > 99 } {
       set err "Disk more than 99% full"
       set it [ tk_dialog .d "Disk FULL" "WARNING: $err\nSwitching to $env(HOME)" {} -1 "OK"]           
       set fname "$env(HOME)/[file tail $fname]"
       set SCOPE(datadir) $env(HOME)
       .main.seldir configure -text $SCOPE(datadir)
   }
   return $fname
}

      