#!/usr/bin/wish
#
# Define the global environment, everything lives under /opt/apogee
# Change NESSI_DIR to move the code somewhere else
#
set NESSI_DIR $env(NESSI_DIR)
set DEBUG 1
set RAWTEMP 0
set NESSIGUI 1
set NOBLT 1
set where [exec ip route]
set gw [lindex $where 2]
set SCOPE(telescope) GEMINI
set SCOPE(site) GEMINI_N
set SCOPE(latitude) 19:49:00
set SCOPE(longitude) 155:28:00
if { $gw == "140.252.61.1" || $env(TELESCOPE) == "WIYN" } {
  set SCOPE(latitude) 31:57:11.78
  set SCOPE(longitude) 07:26:27.97
  set SCOPE(telescope) WIYN
  set SCOPE(site) KPNO
}
set now [clock seconds]
set FLOG [open /tmp/nessiLog_[set now].log w]
exec xterm -e tail -f /tmp/nessiLog_[set now].log &

proc debuglog { msg } {
global FLOG
   puts $FLOG $msg
   flush $FLOG
}


#
# Load the procedures
#
source $NESSI_DIR/wiyn-scripts/general.tcl
source $NESSI_DIR/wiyn-scripts/display.tcl
source $NESSI_DIR/wiyn-scripts/temperature.tcl
###source $NESSI_DIR/wiyn-scripts/calibration.tcl
source $NESSI_DIR/wiyn-scripts/observe.tcl


# Create the status window. This window is used to display informative messages
# during initialization.
#

toplevel .status -width 500 -height 100
wm title .status "NESSI Instrument Control"
wm geometry .status +20+30
label .status.msg -bg LightBlue -fg Black -text Initialising -width 50 -font "Helvetica 30 bold"
pack .status.msg


#
# Define the path to the shared libraries.
# These libraries are used to add facilities to the default tcl/tk
# wish shell. 
#
set libs $NESSI_DIR/lib
load $libs/liboriel.so

#
# Load the tcl interface to FITS (Flexible image transport system) disk files
# FITS is the standard disk file format for Astronomical data
#

showstatus "Loading FitsTcl"
if { $tcl_platform(os) != "Darwin" } {
  load $libs/libfitstcl.so
  set dl so
} else {
  set dl dylib
}

# Prepare for Ccd image buffering package
package ifneeded ccd 1.0       [load $libs/libccd.$dl]

# Load packages provided by dynamically loadable libraries
showstatus "Loading CCD package"
package require ccd

lappend auto_path $libs/BWidget-1.2.1
package require BWidget
proc getlocaltime { } {exec date}


set SCOPE(datadir) $env(HOME)

#
#  Define globals for temperature control

set TEMPS ""
set STATUS(tempgraph) 1
set FRAME 1
set STATUS(readout) 0




#
#  Update status display
#
showstatus "Building user interface"
set SCOPE(instrument) "NESSI"
set SCOPE(equinox) "2000.0"

#
#  Create countdown window widgets
#
set f "Helvetica -30 bold"
toplevel .countdown -bg orange -width 535 -height 115
label .countdown.lf -text "Frame # " -bg orange -font $f
label .countdown.lt -text "Seconds : " -bg orange -font $f
label .countdown.f -text "???" -bg orange -font $f
label .countdown.t -text "???" -bg orange -font $f
place .countdown.lf -x 10 -y 40
place .countdown.f -x 140 -y 40
place .countdown.lt -x 230 -y 40
place .countdown.t -x 380 -y 40
wm withdraw .countdown


#
#  Create main window and its menus
#
wm title . "NESSI Instrument Control"
frame .mbar -width 520 -height 30 -bg gray
menubutton .mbar.file -text "File" -fg black -bg gray -menu .mbar.file.m
menubutton .mbar.observe -text "Observe" -fg black -bg gray -menu .mbar.observe.m
menubutton .mbar.temp -text "Temperature" -fg black -bg gray -menu .mbar.temp.m
menubutton .mbar.help -text "Help" -fg black -bg gray -menu .mbar.help.m
menubutton .mbar.tools -text "Tools" -fg black -bg gray -menu .mbar.tools.m
pack .mbar
place .mbar.file -x 0 -y 0
place .mbar.observe -x 80 -y 0
place .mbar.temp -x 150 -y 0
place .mbar.tools -x 300 -y 0
place .mbar.help -x 460 -y 0
menu .mbar.file.m 
menu .mbar.observe.m
menu .mbar.temp.m
menu .mbar.tools.m
menu .mbar.help.m
#.mbar.file.m add command -label "Open" -command fileopen
.mbar.file.m add command -label "Save" -command savestate
#.mbar.file.m add command -label "Save As" -command filesaveas
.mbar.file.m add command -label "Exit" -command shutdown
.mbar.observe.m add command -label "Single" -command "observe single"
.mbar.observe.m add command -label "Snap-roi-128" -command "observe region128"
.mbar.observe.m add command -label "Snap-roi-256" -command "observe region256"
.mbar.observe.m add command -label "Snap-roi-512" -command "observe region512"
.mbar.observe.m add command -label "Reset full-frame" -command "observe fullframe"
.mbar.temp.m add command -label "Cooler on" -command "setpoint on"
.mbar.temp.m add command -label "Cooler off" -command "setpoint off"
.mbar.temp.m add command -label "Cooler to ambient" -command  {set ok [confirmaction "Ramp temperature to ambient"] ; if {$ok} {setpoint amb}}
.mbar.temp.m add command -label "Plot averaged temps" -command {set RAWTEMP 0}
.mbar.temp.m add command -label "Plot raw temps" -command {set RAWTEMP 1}
.mbar.tools.m add command -label "Engineering" -command "nessiGuiMode engineeringGui"
.mbar.help.m add command -label "Users Guide" -command {exec firefox file:/opt/apogee/doc/user-guide.html &}
.mbar.tools.m add command -label "Observing" -command "nessiGuiMode observingGui"
.mbar.tools.m add command -label "Filter Editor" -command "wm deiconify .filters"

proc nessiGuiMode { mode } {
global NESSI
  wm geometry . $NESSI($mode)
}

#
#  Initialize telescope/user variables
#
frame .main -bg gray -width 640 -height 330
pack .main -side bottom
set iy 10
foreach item "target propid ra dec equinox observer telescope instrument site latitude longitude" {
   label .main.l$item -bg gray -fg black -text $item
   place .main.l$item -x 300 -y $iy
   entry .main.v$item -bg white -fg black -relief sunken -width 12 -textvariable SCOPE($item)
   place .main.v$item -x 400 -y $iy
   incr iy 24 
}

#
#  Create main observation management widgets
#
#
if { $tcl_platform(os) != "Darwin" } {
   set bwkey label
   set bwfont labelfont
} else {
   set bwkey text
   set bwfont font
}

if { [lindex [package version BWidget] end] >= 1.8 } {
 set bwkey text
 set bwfont font
 SpinBox .main.exposure -width 10  -range "0.0 1048.75 1" -textvariable SCOPE(exposure)
 place .main.exposure -x 100 -y 20
 SpinBox .main.numexp -width 10   -range "1 1000 1" -textvariable SCOPE(numframes)
 place .main.numexp -x 100 -y 50
 set opts "Object Focus Acquire Flat SkyFlat Dark Zero"
 ComboBox .main.exptype -width 10  -values "$opts" -textvariable SCOPE(exptype)
 SpinBox .main.numseq -width 10   -range "1 100 1" -textvariable SCOPE(numseq)
 place .main.numseq -x 100 -y 106
 place .main.exptype -x 100 -y 80
 label .main.lexp -text Exposure -bg gray
 label .main.lnum -text "Num. Frames" -bg gray
 label .main.lseq -text "Num. Seq." -bg gray
 label .main.ltyp -text "Exp. Type" -bg gray
 place .main.lexp -x 20 -y 23
 place .main.lnum -x 20 -y 53
 place .main.ltyp -x 20 -y 83
 place .main.lseq -x 20 -y 107
} else {
 SpinBox .main.exposure -width 7 -$bwkey "Exposure (in seconds) : " -font fixed -$bwfont "fixed"  -range "0.0 1048.75 1" -textvariable SCOPE(exposure)
 place .main.exposure -x 20 -y 20
 SpinBox .main.numexp -width 12 -$bwkey "Number of frames : " -font fixed  -$bwfont "fixed"  -range "1 1000 1" -textvariable SCOPE(numframes)
 place .main.numexp -x 20 -y 50
 set opts "Object Focus Acquire Flat SkyFlat Dark Zero"
 ComboBox .main.exptype -width 15 -$bwkey "Exposure type : " -font fixed -$bwfont "fixed"  -values "$opts" -textvariable SCOPE(exptype)
 place .main.exptype -x 20 -y 80
}
set SCOPE(exptype) Object
button .main.seldir -width 24 -text "Configure data directory" -command "choosedir data data"
place .main.seldir -x 20 -y 275
label .main.lname -bg gray -fg black -text "File name :"
place .main.lname -x 20 -y 135
entry .main.imagename -width 12 -bg white -fg black -textvariable SCOPE(imagename)
place .main.imagename -x 100 -y 135


.main.imagename insert 0 test
entry .main.seqnum -width 6 -bg white -fg black -textvariable SCOPE(seqnum)
place .main.seqnum -x 205 -y 136
set SCOPE(seqnum) 1
button .main.observe -width 5 -height 2 -text "Observe" -bg gray -command startsequence
button .main.abort -width 5 -height 2 -text "Abort" -relief sunken -bg gray -command abortsequence
place .main.observe -x 20  -y 167
place .main.abort   -x 120 -y 167

checkbutton .main.autodisplay -bg gray  -text "Automatic display" -variable SCOPE(autodisplay)
place .main.autodisplay -x 20 -y 217
checkbutton .main.overwrite -bg gray  -text "Overwrite files" -variable SCOPE(overwrite)
place .main.overwrite -x 170 -y 217
set SCOPE(lobias) 0
set SCOPE(hibias) 0
set SCOPE(comptimer) 0
entry .main.lobias -bg white -fg black -width 6 -textvariable SCOPE(lobias)
entry .main.hibias -bg white -fg black -width 6 -textvariable SCOPE(hibias)
place .main.lobias -x 220 -y 244
place .main.hibias -x 280 -y 244

checkbutton .main.autobias -bg gray  -text "Automatic bias subtraction" -variable SCOPE(autobias)
place .main.autobias -x 20 -y 244
.main.abort configure -relief sunken -fg LightGray
set SCOPE(autodisplay) 1
set SCOPE(autobias) 0
set SCOPE(autocalibrate) 0
set SCOPE(overwrite) 0
set STATUS(abort) 0
set STATUS(pause) 0
set STATUS(readout) 0



#
#  Define a default sub-region
#  
set ACQREGION(xs) 1
set ACQREGION(xe) 256
set ACQREGION(ys) 1
set ACQREGION(ye) 256
set LASTACQ none

#
#  Set up the default structures for temperaure control/plotting
#
set LASTTEMP 0.0
set TIMES "0"
set SETPOINTS "0.0"
set AVGTEMPS "0.0"
set i -60
set xdata ""
set ydata ""
set ysetp ""
while { $i < 0 } {
  lappend xdata $i
  lappend ydata $AVGTEMPS
  lappend ysetp $SETPOINTS
  incr i 1
}

source $NESSI_DIR/wiyn-scripts/plotchart.tcl
#set f [.p.props getframe Temperature]
toplevel .tplot -width 500 -height 220 -bg white
canvas .tplot.plot -width 500 -height 220
set TEMPWIDGET [::Plotchart::createStripchart .tplot.plot  "0 60 10" "-80 30 10"]
$TEMPWIDGET dataconfig setpoint -color yellow
$TEMPWIDGET dataconfig ccd -color blue
$TEMPWIDGET title "Temps.  (setpoint=yellow, ccd=blue)"
$TEMPWIDGET xtext Sample
$TEMPWIDGET ytext Temp.
place .tplot.plot -x 0 -y 0
wm withdraw .tplot


#
#
#  Call the camera setup code, and the telescope setup code
#
showstatus "Initializing camera"
source  $NESSI_DIR/wiyn-scripts/camera_init.tcl
set STATUS(busy) 0





set CCDID 0
set RAWTEMP 0
set REMAINING 0


#
#  Set defaults for observation parameters
#

set OBSPARS(Object) "1.0 1 1"
set OBSPARS(Focus)  "0.1 1 1"
set OBSPARS(Acquire) "1.0 1 1"
set OBSPARS(Flat)    "1.0 1 1"
set OBSPARS(Dark)    "100.0 1 0"
set OBSPARS(Zero)    "0.01 1 0"
set OBSPARS(Skyflat) "0.1 1 1"

set LASTBIN(x) 1
set LASTBIN(y) 1
#######setutc
set d  [split $SCOPE(obsdate) "-"]
set SCOPE(equinox) [format %7.2f [expr [lindex $d 0]+[lindex $d 1]./12.]]

#
#  Do the actual setup of the GUI, to sync it with the camera status
#

source $NESSI_DIR/wiyn-scripts/nessi_gui.tcl

trace variable CONFIG w watchconfig
trace variable SCOPE w watchscope


#
#  Reset to the last used configuration if available
#

if { [file exists $env(HOME)/.apgui.tcl] } {
   source $env(HOME)/.apgui.tcl
}

#
#  Fix the date
#

set SCOPE(obsdate) [join "[lrange $now 1 2] [lindex $now 4]" -]  
#set SCOPE(StartCol) $CONFIG(geometry.StartCol)
#set SCOPE(StartRow) $CONFIG(geometry.StartRow) 
#set SCOPE(NumCols)  $CONFIG(geometry.NumCols) 
#set SCOPE(NumRows)  $CONFIG(geometry.NumRows) 
set SCOPE(darktime) 0.0
#
#  Start monitoring the temperature
#
##monitortemp
wm withdraw .status
wm geometry . +20+30
#setfullframe

focus .

#
#  Stop the user from destroying the windows by accident
#

wm protocol .countdown WM_DELETE_WINDOW {wm withdraw .countdown}
wm protocol .status WM_DELETE_WINDOW {wm withdraw .status}
wm protocol .       WM_DELETE_WINDOW {wm withdraw .status}

#ap7p  set_biascols 1 7, set bic 4
#kx260 set_biascols 1 5, set bic 2

nessiGuiMode observingGui




