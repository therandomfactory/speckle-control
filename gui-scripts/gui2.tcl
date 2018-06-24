#!/usr/bin/wish
#
# Define the global environment, everything lives under /opt/apogee
# Change SPECKLE_DIR to move the code somewhere else
#
set SPECKLE_DIR $env(SPECKLE_DIR)
set DEBUG 1
set RAWTEMP 0
set SPECKLEGUI 1
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
set FLOG [open /tmp/speckleLog_[set now].log w]
exec xterm -e tail -f /tmp/speckleLog_[set now].log &

proc debuglog { msg } {
global FLOG
   puts $FLOG $msg
   flush $FLOG
}


#
# Load the procedures
#
source $SPECKLE_DIR/gui-scripts/general.tcl
source $SPECKLE_DIR/gui-scripts/display.tcl
source $SPECKLE_DIR/gui-scripts/temperature.tcl
###source $SPECKLE_DIR/gui-scripts/calibration.tcl
source $SPECKLE_DIR/gui-scripts/observe.tcl


# Create the status window. This window is used to display informative messages
# during initialization.
#

toplevel .status -width 500 -height 100
wm title .status "Speckle Instrument Control"
wm geometry .status +20+30
label .status.msg -bg LightBlue -fg Black -text Initialising -width 50 -font "Helvetica 30 bold"
pack .status.msg


#
# Define the path to the shared libraries.
# These libraries are used to add facilities to the default tcl/tk
# wish shell. 
#
set libs $SPECKLE_DIR/lib
load $libs/liboriel.so

#
# Load the tcl interface to FITS (Flexible image transport system) disk files
# FITS is the standard disk file format for Astronomical data
#

showstatus "Loading FitsTcl"
load $libs/libfitstcl.so

# Prepare for Ccd image buffering package
package ifneeded ccd 1.0       [load $libs/libccd.so]

# Load packages provided by dynamically loadable libraries
showstatus "Loading CCD package"
package require ccd

lappend auto_path $libs/bwidget1.9.8
package require BWidget
proc getlocaltime { } {exec date}


set SCOPE(datadir) $env(HOME)/data

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
set SCOPE(instrument) "SPECKLE"
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
wm title . "Speckle Instrument Control"
frame .mbar -width 936 -height 30 -bg gray
menubutton .mbar.file -text "File" -fg black -bg gray -menu .mbar.file.m
menubutton .mbar.observe -text "Set ROI's" -fg black -bg gray -menu .mbar.observe.m
menubutton .mbar.temp -text "Temperature" -fg black -bg gray -menu .mbar.temp.m
menubutton .mbar.help -text "Help" -fg black -bg gray -menu .mbar.help.m
menubutton .mbar.tools -text "Tools" -fg black -bg gray -menu .mbar.tools.m
pack .mbar
place .mbar.file -x 0 -y 0
place .mbar.observe -x 80 -y 0
place .mbar.temp -x 180 -y 0
place .mbar.tools -x 300 -y 0
place .mbar.help -x 880 -y 0
menu .mbar.file.m 
menu .mbar.observe.m
menu .mbar.temp.m
menu .mbar.tools.m
menu .mbar.help.m
#.mbar.file.m add command -label "Open" -command fileopen
.mbar.file.m add command -label "Save" -command savespecklegui
#.mbar.file.m add command -label "Save As" -command filesaveas
.mbar.file.m add command -label "Exit" -command shutdown
.mbar.observe.m add command -label "Snap-roi-128" -command "observe region128"
.mbar.observe.m add command -label "Snap-roi-256" -command "observe region256"
.mbar.observe.m add command -label "Snap-roi-512" -command "observe region512"
.mbar.observe.m add command -label "Adjust ROI" -command "observe manual"
.mbar.observe.m add command -label "Reset full-frame" -command "observe fullframe"
.mbar.temp.m add command -label "Cooler on" -command "setpoint on"
.mbar.temp.m add command -label "Cooler off" -command "setpoint off"
.mbar.temp.m add command -label "Cooler to ambient" -command  {set ok [confirmaction "Ramp temperature to ambient"] ; if {$ok} {setpoint amb}}
.mbar.temp.m add command -label "Plot averaged temps" -command {set RAWTEMP 0}
.mbar.temp.m add command -label "Plot raw temps" -command {set RAWTEMP 1}
.mbar.tools.m add command -label "Engineering" -command "speckleGuiMode engineeringGui"
.mbar.help.m add command -label "Users Guide" -command {exec firefox file:/opt/apogee/doc/user-guide.html &}
.mbar.tools.m add command -label "Observing" -command "speckleGuiMode observingGui"
.mbar.tools.m add command -label "Filter Editor" -command "wm deiconify .filters"
.mbar.tools.m add command -label "Camera status" -command "cameraStatuses"

proc speckleGuiMode { mode } {
global SPECKLE
  wm geometry . $SPECKLE($mode)
}



#
#  Initialize telescope/user variables
#
frame .main -bg gray -width 936 -height 330
pack .main -side bottom
set iy 10
foreach item "target ProgID ra dec telescope instrument" {
   label .main.l$item -bg gray -fg black -text $item
   place .main.l$item -x 300 -y $iy
   entry .main.v$item -bg white -fg black -relief sunken -width 12 -textvariable SCOPE($item) -justify right
   place .main.v$item -x 400 -y $iy
   incr iy 24 
}

#
#  Create main observation management widgets
#
#
set bwkey text
set bwfont font
SpinBox .main.exposure -width 10  -range "0.0 1048.75 1" -textvariable SCOPE(exposure) -justify right
place .main.exposure -x 100 -y 20
SpinBox .main.numexp -width 10   -range "1 1000 1" -textvariable SCOPE(numframes) -justify right
place .main.numexp -x 100 -y 50
set opts "Object Focus Acquire Flat SkyFlat Dark Zero"
ComboBox .main.exptype -width 10  -values "$opts" -textvariable SCOPE(exptype) -justify right
SpinBox .main.numseq -width 10   -range "1 100 1" -textvariable SCOPE(numseq) -justify right
place .main.numseq -x 100 -y 106
label .main.laccum -text "Accum." -bg gray
SpinBox .main.numaccum -width 10   -range "1 10000 1" -textvariable SCOPE(numaccum) -justify right
place .main.exptype -x 100 -y 80
place .main.numaccum -x 250 -y 106
label .main.lexp -text Exposure -bg gray
label .main.lnum -text "Num. Frames" -bg gray
label .main.lseq -text "Num. Seq." -bg gray
label .main.ltyp -text "Exp. Type" -bg gray
place .main.laccum -x 200 -y 106
place .main.lexp -x 20 -y 23
place .main.lnum -x 20 -y 53
place .main.ltyp -x 20 -y 83
place .main.lseq -x 20 -y 107

set SCOPE(exptype) Object
set SCOPE(numaccum) 1
set SCOPE(numseq) 1

button .main.seldir -width 38 -text "Configure data directory" -command "choosedir data data"
place .main.seldir -x 20 -y 286
label .main.lname -bg gray -fg black -text "File name :"
place .main.lname -x 20 -y 135
entry .main.imagename -width 18 -bg white -fg black -textvariable SCOPE(imagename) -justify right
place .main.imagename -x 100 -y 135

label .main.rcamtemp -bg gray -fg blue -text "???.?? degC" -bg gray
place .main.rcamtemp -x 353 -y 2
label .main.bcamtemp -bg gray -fg blue -text "???.?? degC" -bg gray
place .main.bcamtemp -x 453 -y 2






.main.imagename insert 0 test
entry .main.seqnum -width 6 -bg white -fg black -textvariable SCOPE(seqnum) -justify right
place .main.seqnum -x 270 -y 135
set SCOPE(seqnum) 1
button .main.observe -width 5 -height 2 -text "Observe" -bg gray -command startsequence
button .main.abort -width 5 -height 2 -text "Abort" -relief sunken -bg gray -command abortsequence
place .main.observe -x 20  -y 167
place .main.abort   -x 120 -y 167

label .main.lsim -text "Simulate :" -bg gray
checkbutton .main.simandor -bg gray  -text "Andors" -variable ANDORS(sim) -highlightthickness 0
checkbutton .main.simzaber -bg gray  -text "Zabers" -variable ZABERS(sim) -highlightthickness 0
checkbutton .main.simfilter -bg gray  -text "Filters" -variable FWHEELS(sim) -highlightthickness 0
checkbutton .main.simtlm -bg gray  -text "Telemetry" -variable SPKTELEM(sim) -highlightthickness 0
place .main.lsim -x 20 -y 227
place .main.simandor -x 150 -y 227
place .main.simzaber -x 250 -y 227
place .main.simfilter -x 250 -y 252
place .main.simtlm -x 150 -y 252


if { $SCOPE(telescope) == "GEMINI" } {
  checkbutton .main.simpico -bg gray  -text "Picos" -variable PICOS(sim) -highlightthickness 0
  place .main.simpico -x 85 -y 227
}
   
menubutton .main.rawiq -text "DQ - image" -width 21 -fg black -bg gray -menu .main.rawiq.m -relief raised
menu .main.rawiq.m
.main.rawiq.m add command -label "RAWIQ 20%" -command "dataquality rawiq 20"
.main.rawiq.m add command -label "RAWIQ 70%" -command "dataquality rawiq 70"
.main.rawiq.m add command -label "RAWIQ 85%" -command "dataquality rawiq 85"
.main.rawiq.m add command -label "RAWIQ ANY" -command "dataquality rawiq ANY"
place .main.rawiq -x 362 -y 200

menubutton .main.rawcc -text "DQ - cloud" -width 21 -fg black -bg gray -menu .main.rawcc.m -relief raised
menu .main.rawcc.m
.main.rawcc.m add command -label "RAWCC 50%" -command "dataquality rawcc 50"
.main.rawcc.m add command -label "RAWCC 50%" -command "dataquality rawcc 70"
.main.rawcc.m add command -label "RAWCC 80%" -command "dataquality rawcc 80"
.main.rawcc.m add command -label "RAWCC ANY" -command "dataquality rawcc ANY"
place .main.rawcc -x 362 -y 230

menubutton .main.rawwv -text "DQ - water" -width 21 -fg black -bg gray -menu .main.rawwv.m -relief raised
menu .main.rawwv.m
.main.rawwv.m add command -label "RAWWV 20%" -command "dataquality rawwv 20"
.main.rawwv.m add command -label "RAWWV 50%" -command "dataquality rawwv 50"
.main.rawwv.m add command -label "RAWWV 80%" -command "dataquality rawwv 80"
.main.rawwv.m add command -label "RAWWV ANY" -command "dataquality rawwv ANY"
place .main.rawwv -x 362 -y 260

menubutton .main.rawbg -text "DQ - bg" -width 21 -fg black -bg gray -menu .main.rawbg.m -relief raised
menu .main.rawbg.m
.main.rawbg.m add command -label "RAWBG 20%" -command "dataquality rawbg 20"
.main.rawbg.m add command -label "RAWBG 50%" -command "dataquality rawbg 50"
.main.rawbg.m add command -label "RAWBG 80%" -command "dataquality rawbg 80"
.main.rawbg.m add command -label "RAWBG ANY" -command "dataquality rawbg ANY"
place .main.rawbg -x 362 -y 290

proc dataquality { type value } {
global DATAQUAL DATAQUALT TELEMETRY
   set DATAQUAL($type) $value
   set TELEMETRY(tcs.weather.$type) $value
   .main.[set type] configure -text "DQ $DATAQUALT($type) : $value"
}

foreach q "rawbg rawcc rawwv rawiq" { set DATAQUAL($q) UNKNOWN }
set DATAQUALT(rawiq) image
set DATAQUALT(rawcc) cloud
set DATAQUALT(rawwv) water
set DATAQUALT(rawbg) bg



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
#  Set up the default structures for temperature control/plotting
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

source $SPECKLE_DIR/gui-scripts/plotchart.tcl
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
showstatus "Initializing cameras"
source  $SPECKLE_DIR/gui-scripts/camera_init.tcl
resetSingleAndors fullframe
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

source $SPECKLE_DIR/gui-scripts/speckle_gui.tcl

trace variable CONFIG w watchconfig
trace variable SCOPE w watchscope


#
#  Reset to the last used configuration if available
#
set SCOPE(datadir) $env(HOME)/data


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

speckleGuiMode observingGui




