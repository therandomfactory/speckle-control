#!/usr/bin/tclsh

#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2. If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2017 The Random Factory (www.randomfactory.com) 
#
#


set SPECKLE_DIR $env(SPECKLE_DIR)

proc loadFiltersConfig { fname } {
global SPECKLE_DIR NESCONFIG FWHEELS SCOPE
   if { $SCOPE(telescope) == "GEMINI" } {  
      set fname "[set fname].gemini"
   }
   if { [file exists $SPECKLE_DIR/$fname] == 0 } {
     errordialog "Filters configuration file $SPECKLE_DIR/$fname\n does not exist"
   } else {
     source $SPECKLE_DIR/filtersConfiguration
     set NESCONFIG(picoChange) 0
   }
}

proc saveFiltersConfig { fname } {
global SPECKLE_DIR  NESCONFIG FWHEELS
   set fcfg [open $SPECKLE_DIR/$fname w]
   puts $fcfg  "#!/usr/bin/tclsh
   echoFiltersConfig $fcfg
   close $fcfg
   set NESCONFIG(picoChange) 0
   debuglog "Saved Filters configuration in $SPECKLE_DIR/$fname"
}

proc logFiltersConfig { } {
global FLOG
  echoFiltersConfig $FLOG
}

proc echoFiltersConfig { {fcfg stdout} } {
global FWHEELS
   puts $fcfg  "# Filters stage configuration parameters
"
   foreach i "red blue" {
     foreach p "port 1 2 3 4 5 6" {
         puts $fcfg "set FWHEELS($i,$p) \"$FWHEELS($i,$p)\""
     }
     puts $fcfg ""
   }
}

proc selectfilter { id n } {
global FILTERWHEEL FWHEELS MAXFILTERS
  set i 1
  while { $i <= $MAXFILTERS } {
     .filters.f$id$i configure -relief raised -bg gray -activebackground gray
     incr i 1
  }
  .filters.f$id$n configure -bg yellow -activebackground yellow
  update
  set result [setOrielFilter $FWHEELS($id,handle) $n]
  set msg [split $result \n]
  if { [string range [lindex $msg 3] 0 9] == "USB error:" } {
    set it [ tk_dialog .d "SPECKLE Filter Wheel $id" "$result" {} -1 OK]
  } else {
    .filters.f$id$n configure -bg green -relief sunken -activebackground green
    mimicMode $id filter $FWHEELS($id,$n)
    if { $id == "red" } {
      .lowlevel.rfilter configure -text "Filter = $FWHEELS(red,$n)"
    }
    if { $id == "blue" } {
      .lowlevel.bfilter configure -text "Filter = $FWHEELS(blue,$n)"
    }
    set FWHEELS($id,position) $n
    if { [info proc adjustTeleFocus] != "" } {
       set delta  [expr $FWHEELS($id,$FWHEELS($id,position),focus) - $FWHEELS(focusoffset)]
       adjustTeleFocus $delta
       set FWHEELS(focusoffset) $FWHEELS($id,$FWHEELS($id,position),focus)
    }
  }
}

proc findWheels { } {
global FWSERIAL
   set fw [split [exec lsusb] \n]
   set id 1
   foreach i $fw {
      if { [lindex $i 6] == "Newport" } {
         set iusb($id) [string trim [lindex $i 1]:[lindex $i 3] :]
         set info [exec lsusb -v -s $iusb($id)]
         set FWSERIAL($iusb($id)) [lindex $info [expr [lsearch $info iSerial] +2]]
         incr id 1
      }
   }
}



foreach a "red blue" {
  foreach i "1 2 3 4 5 6" {
     set FWHEELS($a,$i,focus) 0
  }
}
set FWHEELS(focusoffset) 0

set MAXFILTERS 6
destroy .filters
toplevel .filters -bg gray
wm title .filters "SPECKLE Filter Wheels control"
label .filters.lpos   -text "Red Position" -bg gray -fg black
label .filters.lname  -text "Red Filter Name" -bg gray -fg black
label .filters.lfocus -text "Red Focus offset" -bg gray -fg black
label .filters.lbpos   -text "Blue Position" -bg gray -fg black
label .filters.lbname  -text "Blue Filter Name" -bg gray -fg black
label .filters.lbfocus -text "Blue Focus offset" -bg gray -fg black
place .filters.lpos -x 30 -y 20
place .filters.lname -x 150 -y 20
place .filters.lfocus -x 290 -y 20
place .filters.lbpos -x 400 -y 20
place .filters.lbname -x 520 -y 20
place .filters.lbfocus -x 680 -y 20

wm geometry .filters 773x[expr $MAXFILTERS*35 + 110]+10+170
set i 0
set iy 50
while { $i < $MAXFILTERS } {
   incr i 1
   button .filters.fred$i -text "$i" -relief raised -bg gray -fg black -command "selectfilter red $i" -width 8
   entry  .filters.namered$i -textvariable FWHEELS(red,$i) -bg LightBlue -fg black -width 20
   entry  .filters.focusred$i -textvariable FWHEELS(red,$i,focus) -bg LightBlue -fg black -width 8
   place  .filters.fred$i -x 20 -y $iy
   button .filters.fblue$i -text "$i" -relief raised -bg gray -fg black -command "selectfilter blue $i" -width 8
   entry  .filters.nameblue$i -textvariable FWHEELS(blue,$i) -bg LightBlue -fg black -width 20
   entry  .filters.focusblue$i -textvariable FWHEELS(blue,$i,focus) -bg LightBlue -fg black -width 8
   place  .filters.fblue$i -x 390 -y $iy
   incr iy 3
   place  .filters.namered$i -x 130 -y $iy
   place  .filters.focusred$i -x 310 -y $iy
   place  .filters.nameblue$i -x 500 -y $iy
   place  .filters.focusblue$i -x 690 -y $iy
   incr iy 30
}

button .filters.load -text "Load configuration" -fg black -bg green -width 32 -command "loadFiltersConfig filtersConfiguration"
button .filters.save -text "Save configuration" -fg black -bg green -width 32 -command "saveFiltersConfig"
button .filters.exit -text "Close" -fg black -bg orange -width 32 -command "wm withdraw .filters"
place .filters.load -x 10 -y [expr $iy+30]
place .filters.save -x 262 -y [expr $iy+30]
place .filters.exit -x 502 -y [expr $iy+30]




proc filterWheelHelp { }  {
  puts stdout "Filter Wheel commands :
tcl	Command         Function
open			Open a connection
close			Close connection
getID	IDN?		Query to determine filter wheel model and firmware revision.
setPos	FILT X		Sets the active filter position to value X (1-6)
getPos	FILT?		Query to determine the active filter position (1-6)
setFlt	FLTX ID		Set the  filter type/lable in position X
getFlt	FLTX ID?	Query to determine the  filter type/label in position X
next	NEXT		Increments the filter position clockwise by 1 position
prev	PREV		Increments the filter position counter clockwise by 1 position	
manual	MBTN (Y/N)	Sets the manual push button mode to enable (Y) or disable (N)
status	STB?		Query to determine the status of the unit
reset	RST		Resets the controller to default settings & operation
clear	CLS		Clears any status error messages
setHS	HSHK X		Set the unit handshake mode
getHS	HSHK?		Query to determine the hanshake mode of the unit
dotest	TST		Initiates a system self test
getTest	TST?		Query to determine the self test status/result
"
}

proc fwService { arm op {p1 ""} {p2 ""} {p3 ""} } {
global FWHEEL
   switch $op {
       open    {}
       close   {}
       getID   {}
       setPos  {}
       getPos  {}
       setFlt  {}
       getFlt  {}
       next    {}
       prev    {}
       manual  {}
       status  {}
       reset   {}
       clear   {}
       setHS   {}
       getHS   {}
       dotest  {}
       getTest {}
  }
}

proc resetFilterWheel { id } {
   oriel_write_cmd $id RST
   after 7000
   set res [oriel_read_result $id]
   oriel_write_cmd $id FILT?
   after 200
   set res [oriel_read_result $id]
   return $res
}

proc setOrielFilter { id n } {
   oriel_write_cmd $id FILT?
   after 200
   set res [oriel_read_result $id]
   set cpos [string range $res 4 4]
   set npos [expr $n - $cpos]
   while { $npos > 0 } {
      oriel_write_cmd $id NEXT
      incr npos -1
      after 2000
      set res [oriel_read_result $id]
   }
   while { $npos < 0 } {
      oriel_write_cmd $id PREV
      incr npos 1
      after 2000
      set res [oriel_read_result $id]
   }
   oriel_write_cmd $id FILT?
   after 200
   set res [oriel_read_result $id]
   set cpos [string range $res 4 4]
   if { $cpos == $n } {
      return $n
   }
   return -1
}



loadFiltersConfig filtersConfiguration
#### in gui.tcl now load $env(SPECKLE_DIR)/lib/liboriel.so

foreach p "1 2 3 4 5 6" {
  if { $FWHEELS(red,$p) == "clear" } {
     set FWHEELS(red,clear) $p
  }
  if { $FWHEELS(blue,$p) == "clear" } {
     set FWHEELS(blue,clear) $p
  }
}


set FWHEELS(sim) 0
if { [info exists env(SPECKLE_SIM)] } {
   set simdev [split $env(SPECKLE_SIM) ,]
   if { [lsearch $simdev filter] > -1 } {
       set FWHEELS(sim) 1
       debuglog "Filter wheels in SIMULATION mode"
  }
}

if { $FWHEELS(sim) == 0 } {
  findWheels
  set f1 [oriel_connect 1]
  set sn1 $FWSERIAL([lindex $f1 1])
  if { $sn1 == $FWHEELS(red,serialnum) } {set FWHEELS(red,handle) 1}
  if { $sn1 == $FWHEELS(blue,serialnum) } {set FWHEELS(blue,handle) 1}

  set f2 [oriel_connect 2]
  set sn2 $FWSERIAL([lindex $f2 1])
  if { $sn2 == $FWHEELS(red,serialnum) } {set FWHEELS(red,handle) 2}
  if { $sn2 == $FWHEELS(blue,serialnum) } {set FWHEELS(blue,handle) 2}
  showstatus "Initializing filter wheel 1"
  resetFilterWheel 1

  showstatus "Initializing filter wheel 2"
  resetFilterWheel 2
  debuglog "Moving filter wheels to clear positions"
  selectfilter red $FWHEELS(red,clear)
  selectfilter blue $FWHEELS(blue,clear)
}  

wm withdraw .filters




