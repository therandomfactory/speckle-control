#!/usr/bin/tclsh

#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2. If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2017 The Random Factory (www.randomfactory.com) 
#
#


set NESSI_DIR $env(NESSI_DIR)

proc loadFiltersConfig { fname } {
global NESSI_DIR NESCONFIG FWHEELS
   if { [file exists $NESSI_DIR/$fname] == 0 } {
     errordialog "Filters configuration file $NESSI_DIR/$fname\n does not exist"
   } else {
     source $NESSI_DIR/filtersConfiguration
     set NESCONFIG(picoChange) 0
   }
}

proc saveFiltersConfig { fname } {
global NESSI_DIR  NESCONFIG FWHEELS
   set fcfg [open $NESSI_DIR/$fname w]
   puts $fcfg  "#!/usr/bin/tclsh
   echoFiltersConfig $fcfg
   close $fcfg
   set NESCONFIG(picoChange) 0
   debuglog "Saved Filters configuration in $NESSI_DIR/$fname"
}

proc logFiltersConfig { } {
global FLOG
  echoFiltersConfig $FLOG
}

proc echoFiltersConfig { fcfg } {
global FWHEELS
   puts $fcfg  "# Filters stage configuration parameters
"
   foreach i "A B " {
     foreach p "port 1 2 3 4 5 6" {
         puts $fcfg "set FWHEELS($i,$p) \"$FWHEELS($i,$p)\""
     }
     puts $fcfg ""
   }
}






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

proc fwCommand { arm op {p1 ""} {p2 ""} {p3 ""} } {
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


