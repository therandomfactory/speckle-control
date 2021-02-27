## \file general.tcl
# \brief This contains general purpouse procedures
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
## Documented proc \c debuglog .
# \param[in] msg Current GUI intialization status
#
# Globals :
#		SPECKLEGUI - Are we running in a GUI , 1 for yes
proc showstatus { msg } {
 global SPECKLEGUI
  if { $SPECKLEGUI } {
    .status.msg configure -text "$msg"
    update
  } else {
    puts stdout "$msg"
  }
}



## Documented proc \c debuglog .
# \param[in] type Type of image
# \param[in] Name of image
#
#  Globals    :\n
#  
#               CALS - Calibration run parmaeters\n
#               CATALOGS - Catalog configurations\n
#               SCOPE -	Telescope parameters, gui setup
#
proc choosedir { type name} {
global CALS CATALOGS SCOPE env
   if { $type == "data" } {
     set cfg [tk_chooseDirectory -initialdir $env(HOME)/data]
     if { $cfg != "" } {
       set SCOPE(datadir) $cfg
       .main.seldir configure -text "$cfg"
       commandAndor red "datadir $cfg"
       commandAndor blue "datadir $cfg"
       set SCOPE(datadir) $cfg
       catch {
         set all [lsort [glob $SCOPE(datadir)/[set SCOPE(preamble)]*.fits]]
         set last [split [lindex $all end] _]
         set SCOPE(seqnum) [expr [string trimleft [string range [file tail $last] 10 13] 0] + 1]
       }
     }
   } else {
     set cfg [tk_chooseDirectory -initialdir $CALS(home)/$name]
   }
   if { [string length $cfg] > 0 } {
     if { [file exists $cfg] == 0 } {
        exec mkdir -p $cfg
     }
     switch $type {
         calibrations {set CALS($name,dir) $cfg }
         catalogs     {set CATALOGS($name,dir) $cfg }
     }
   }
}




## Documented proc \c setutc .
#
#  Set UT time and date
#
#  Globals    :
#  
#               SCOPE -	Telescope parameters, gui setup
#
proc setutc { {id 0} } {
global SCOPE CAMSTATUS
  set now [split [exec  date -u +%Y-%m-%d,%T.%U] ,]
  set SCOPE(obsdate) [lindex $now 0]
  set SCOPE(timeobs) [lindex $now 1]
}






## Documented proc \c confirmaction .
#
#  Generic confirmation dialog popoup
#
proc confirmaction { msg } {
   set it [ tk_dialog .d "Confirm" "$msg ?" {} -1 No "Yes"]           
   return $it
}






## Documented proc \c toggle .
# \param[in] win Window identifier
#
#  Toggle a window's visibility
#
proc toggle { win } {
   if { [winfo ismapped $win] } { 
      wm withdraw $win
   } else {
      wm deiconify $win
   }
}

# \endcode



