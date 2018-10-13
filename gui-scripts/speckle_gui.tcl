## \file speckle_gui.tcl
# \brief This contains procedures for initializing configuration
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

## Documented proc \c speckleTelemetryUpdate .
# 
# Update telemetry data for GUI usage
#
proc speckleTelemetryUpdate { } {
global SCOPE TELEMETRY FITSKEY IMGMETA
   foreach i [array names SCOPE] {
       set TELEMETRY(speckle.scope.$i) $SCOPE($i)
   }
   foreach i [array names FITSKEY] {
      if { [info exists IMGMETA([lindex [split $i .] end],value)] } {
          set TELEMETRY($i) $IMGMETA([lindex [split $i .] end],value)
      }
   }
   if { $SCOPE(telescope) == "WIYN" } {
      redisUpdate
   }
}

 
## Documented proc \c shutdown .
# 
#  Shutdown the cameras , kill the logger and close the GUI
#
#  Globals    :
#               SCOPE - Array of telescope parameters
#	
proc shutdown { {id 0} } {
global SCOPE
   set it [tk_dialog .d "Exit" "Confirm Shutdown" {} -1 "Cancel" "Shutdown"]
   if { $it } {
     if { $SCOPE(telescope) == "GEMINI" } {
        debuglog "Moving Gemini mechanisms to stowed positions"
        catch {picosOutPosition}
        zaberGoto focus stow
        zaberGoto pickoff out
     }
     zaberGoto A wide
     zaberGoto B wide
     zaberGoto input wide
     savespecklegui
     catch { commandAndor red shutdown }
     catch { commandAndor blue shutdown }
     catch { exec xpaset -p ds9 exit }
     after 5000
     catch { exec pkill -9 tail }
     exit
   }
}


## Documented proc \c specklefilter .
# \param[in] arm Instrument arm, red or blue
# \param[in] name Name of selected filter
#
#  Update filter feedback in GUI
#
#  Globals    :
#		SPECKLE_FILTER - Selected filter info
#	
proc specklefilter { arm name } {
global SPECKLE_FILTER
  if { $arm == "red" } {
    .lowlevel.rfilter configure -text "Filter = $name"
  } else {
    .lowlevel.bfilter configure -text "Filter = $name"
  }
  if { $SPECKLE_FILTER($arm,current) != $name } {
    set id [findfilter $arm $name]
    if { $id > 0 } {
       debuglog "Arm $arm select filter $name"
       selectfilter $arm $id
    }
  }
}

## Documented proc \c savespecklegui .
#  Do the actual setup of the GUI, to sync it with the camera status
#
#  Update filter feedback in GUI
#
#  Globals    :\n
#		SCOPE - Array of telescope information\n
#		env - Environment variables
#	
proc savespecklegui { } {
global SCOPE env
   set ignore "longitude latitude site telescope"
   set fout [open $env(HOME)/.specklegui w]
   foreach i [array names SCOPE] {
      if { [lsearch $ignore $i] < 0 } {
        puts $fout "set SCOPE($i) \"$SCOPE($i)\""
      }
   }
   close  $fout
}


## Documented proc \c findfilter .
# \param[in] arm Instrument arm, red or blue
# \param[in] name Name of selected filter
#
#  Find position of named filter
#
#  Globals    :
#		FWHEELS - Array of filter info
#	
proc findfilter { arm name  } {
global FWHEELS
   foreach i "1 2 3 4 5 6"  {
     if { $FWHEELS($arm,$i) == $name } {return $i}
   }
   return 0
}


## Documented proc \c loadconfig .
# \param[in] arm Instrument arm, red or blue
#
#  Load filter configuration data
#
#  Globals    :
#		SPECKLE_DIR - Directory path of speckle code
#	
proc loadconfig { fname } {
global SPECKLE_DIR
   if { $fname == "user" } {
      set it [tk_getOpenFile -initialdir $SPECKLE_DIR/config-scripts]
      if { $it == "" } {return}
      debuglog "Loading configration from $it"
      source $it
   } else {
      debuglog "Loading configration from $SPECKLE_DIR/config-scripts/$fname"
      source $SPECKLE_DIR/config-scripts/$fname
   }
}


## Documented proc \c initFilter .
# \param[in] arm Instrument arm, red or blue
#
# Initalize filter wheel
#
#  Globals    :\n
#		SPECKLE_FILTER - Selected filter info\n
#		FWHEELS - Array of filter info
#	
proc initFilter { arm } {
global SPECKLE_FILTER FWHEELS
   debuglog "Initializing filter wheels ..."
   resetFilterWheel $FWHEELS($arm,handle)
   selectfilter $arm $FWHEELS($arm,clear)
   debuglog "Initialized filter wheels"
}

## Documented proc \c specklesave .
# \param[in] device zaber device name
# GUI hook to save zaber configurations
#
#  Globals    :
#		SPECKLE_DIR - Directory path of speckle code
#
proc specklesave { device } {
global SPECKLE_DIR
   saveZaberConfig zabersConfiguration
   debuglog "Saved zabers configuration"
}

## Documented proc \c speckleload .
# \param[in] device zaber device name
# GUI hook to load zaber configurations
#
#  Globals    :
#		SPECKLE_DIR - Directory path of speckle code
#
proc speckleload { device } {
global SPECKLE_DIR
   source $SPECKLE_DIR/zabersConfiguration
   debuglog "Loaded zabers configuration"
}

## Documented proc \c specklemode .
# \param[in] arm Instrument arm, red or blue
# \param[in] name Name of observingmode
#
#  Configure arm of instrument
#
#  Globals    :\n
#		ANDOR_MODE - Observing mode, fullframe or roi\n
#		LASTACQ - Last used observing mode 
#
proc specklemode { name } {
global ANDOR_MODE LASTACQ
    .lowlevel.rmode configure -text "Mode=$name"
    foreach arm "red blue" {
     debuglog "Setting arm $arm up for $name"
     if { $name == "wide" && $LASTACQ != "fullframe" } {
       commandAndor $arm "setframe fullframe"
       positionSpeckle $arm fullframe
     }
     if { $name == "speckle" && $LASTACQ != "roi" } {
       commandAndor $arm "setframe roi"
       positionSpeckle $arm roi
      }
     debuglog "$arm setup for $name"
    }
}


## Documented proc \c speckleshutter .
# \param[in] arm Instrument arm, red or blue
# \param[in] name Name of observingmode
#
#  Configure camera shutter modes
#
#  Globals    :\n
#		ANDOR_MODE - Observing mode, fullframe or roi\n
#		LASTACQ - Last used observing mode \n
#		ANDOR_SHUTTER - camera shutter selected mode
#
proc speckleshutter { arm name } {
global ANDOR_MODE LASTACQ ANDOR_SHUTTER
    .lowlevel.rshut configure -text "Shutter=$name"
    .lowlevel.bshut configure -text "Shutter=$name"
    mimicMode $arm $name
    if { $name == "during" } { 
       mimicMode $arm close
       commandAndor $arm "shutter $ANDOR_SHUTTER(auto)"
    } else { 
       commandAndor $arm "shutter $ANDOR_SHUTTER($name)"
    }
}

## Documented proc \c andorsetpoint .
# \param[in] arm Instrument arm, red or blue
#
#  Configure camera temperature setpoints from GUI
#
#  Globals    :
#		ANDOR_CFG - Array of Andor camera configuration data
#
proc andorsetpoint { arm } {
global ANDOR_CFG
   debuglog "Set $arm camera temperature setpoint to $ANDOR_CFG($arm,setpoint)"
   commandAndor $arm "settemperature $ANDOR_CFG($arm,setpoint)"
}

## Documented proc \c specklesynctelem .
# \param[in] arm Instrument arm, red or blue
#
#  Synchroize telemetry with GUI widgets
#
#  Globals    :\n
#		DATAQUAL - Array of Data Quality info\n
#		ZABERS - Array of zaber device configuration\n
#		FWHEELS - Array of filter wheel configuration
#
proc specklesynctelem { arm } {
global DATAQUAL ZABERS FWHEELS
   zaberCheck
   set pinputzaber $ZABERS(input,readpos)
   if  { $arm == "red" } {
     set pfieldzaber $ZABERS(A,readpos)
     set pfilter $FWHEELS(red,$FWHEELS(red,position))
   } else {
     set pfieldzaber $ZABERS(B,readpos)
     set pfilter $FWHEELS(blue,$FWHEELS(blue,position))
   }
   commandAndor $arm "positiontelem $pinputzaber $pfieldzaber $pfilter"
   commandAndor $arm "dqtelemetry $DATAQUAL(rawiq) $DATAQUAL(rawcc) $DATAQUAL(rawwv) $DATAQUAL(rawbg)"
}


## Documented proc \c checkemccdgain .
# \param[in] arm Instrument arm, red or blue
#
#  Check EM gain against Advanced mode requirements and setting
#
#  Globals    :
#		INSTRUMENT - Array od instrument configuration
#
proc checkemccdgain { arm } {
global INSTRUMENT
   debuglog "Set $arm camera EMCCD gain to $INSTRUMENT($arm,emccd)"
   commandAndor $arm "emccdgain $INSTRUMENT($arm,emccd)"
   if { $INSTRUMENT($arm,highgain) == 0 || $INSTRUMENT($arm,emccd) == 0 } {
      if { $INSTRUMENT($arm,emgain) > 300 } {set INSTRUMENT($arm,emgain) 300}
      .mbar configure -bg gray
   }
   if { $INSTRUMENT($arm,highgain) && $INSTRUMENT($arm,emccd) } {
      if { $INSTRUMENT($arm,emgain) > 300 } {
         debuglog "$arm camera EMCCD gain >300 WARNING"
         .mbar configure -bg orange
         commandAndor $arm "emadvanced 1"
      } else {
         .mbar configure -bg gray
         commandAndor $arm "emadvanced 0"
      }
   }
   if { $INSTRUMENT($arm,emccd) } {
      commandAndor $arm "outputamp 0"
   } else {
      commandAndor $arm "outputamp 1"
   }
}


## Documented proc \c cameraStatuses .
#
#  Update camera status from servers and update GUI
#
#  Globals    :\n
#		ANDOR_CFG - Array of Andor camera configuration data\n
#		CAMSTATUS - Array of camera statuses for GUI display
#
proc cameraStatuses { } {
global CAMSTATUS ANDOR_CFG
  foreach cam "red blue" {
    set camstatus [commandAndor $cam status]
    if { $camstatus != 0 } {
      set i 0
      foreach p "Shutter FrameTransferMode OutputAmplifier EMHSSpeed HSSpeed VSSpeed PreAmpGain ReadMode AcquisitionMode KineticCycleTime NumberAccumulations NumberKinetics AccumulationCycleTime EMCCDGain EMAdvanced TExposure TAccumulate TKinetics" {
        if { [info exists ANDOR_CFG($p,[lindex $camstatus $i])] } {
          set CAMSTATUS($cam,$p) "$ANDOR_CFG($p,[lindex $camstatus $i])"
        } else {
          set CAMSTATUS($cam,$p) [lindex $camstatus $i]
        }
        incr i 1
      }
    }
  }
  syncgui
  wm deiconify .camerastatus
}


## Documented proc \c showprogress .
#
#  Update progess bar in GUI
#
proc showprogress { x } {
   .lowlevel.p configure -value $x
}

## Documented proc \c andorset .
# \param[in] arm Instrument arm, red or blue
#
#  GUI hooks to configure camera readout parameters
#
#  Globals    :
#		ANDOR_CFG - Array of Andor camera configuration data\n
#
proc andorset { w arm item value } {
global ANDOR_CFG
  set ANDOR_CFG($arm,$item) $value
  .lowlevel.$w configure -text $ANDOR_CFG($item,$value)
  switch $item {
      VSSpeed    { commandAndor $arm "vsspeed $value" }
      HSSpeed    { commandAndor $arm "hsspeed 1 $value" }
      EMHSSpeed  { commandAndor $arm "hsspeed 0 $value" }
      PreAmpGain { commandAndor $arm "preampgain $value" }
      OuputAmplifier { commandAndor $arm "outputamp $value" }
  }
}

## Documented proc \c syncgui .
#
#  Syncrojnize GUI widgets with current camera settings
#
#  Globals    :\n
#		ANDOR_CFG - Array of Andor camera configuration data\n
#		CAMSTATUS - Array of camera statuses for GUI display
#
proc syncgui  { } {
global CAMSTATUS ANDOR_CFG
   .lowlevel.vspeed configure -text $CAMSTATUS(red,VSSpeed)
   .lowlevel.bvspeed configure -text $CAMSTATUS(blue,VSSpeed)
   .lowlevel.ccdhs configure -text $CAMSTATUS(red,HSSpeed)
   .lowlevel.emhs configure -text $CAMSTATUS(red,EMHSSpeed)
   .lowlevel.bccdhs configure -text $CAMSTATUS(blue,HSSpeed)
   .lowlevel.bemhs configure -text $CAMSTATUS(blue,EMHSSpeed)
}


# \endcode

wm title . "Speckle Control"
place .main -x 0 -y 30
place .mbar -x 0
.main configure -width 936
.mbar configure -width 936
place .mbar.help -x 880
set iy 50
foreach item "target ProgID ra dec telescope instrument" {
   place .main.l$item -x 360 -y $iy
   place .main.v$item -x 440 -y $iy

   incr iy 24 
}

.main.vtarget configure -textvariable TELEMETRY(tcs.target.name)
.main.vra configure -textvariable TELEMETRY(tcs.telescope.ra)
.main.vdec configure -textvariable TELEMETRY(tcs.telescope.dec)

set CAMSTATUS(Gain) 1.0
set CAMSTATUS(BinX) 1
set CAMSTATUS(BinY) 1
set CAMSTATUS(Temperature) -100.0
set CAMSTATUS(CoolerMode) 1
set SCOPE(latitude) 31:57:11.78
set SCOPE(longitude) 07:26:27.97
set SCOPE(camera) "Andor iXon Ultra"
set SCOPE(instrument) speckle
set SCOPE(observer) ""
set SCOPE(target) test
set SCOPE(imagetype) OBJECT
set SCOPE(exposure) 1.0
set SCOPE(ra) 00:00:00.00
set SCOPE(dec) +00:00:00.00
set SCOPE(equinox) 2000.0
set SCOPE(secz) 0.0
set SCOPE(filterpos) 0
set SCOPE(filtername) none
set SCOPE(shutter) 1
set now [split [exec  date -u +%Y-%m-%d,%T] ,]
set SCOPE(readout-delay) 999
set SCOPE(obsdate) [exec date -u +%Y-%m-%dT%H:%M:%S.0]
set SCOPE(obstime) [lindex $now 1]

source $SPECKLE_DIR/andor/andor.tcl


menubutton .mbar.config -text "Configurations" -fg black -bg gray -menu .mbar.config.m
menu .mbar.config.m
set cfg [glob $env(SPECKLE_DIR)/config-scripts/*]
foreach i $$cfg { 
   set id [file tail $i]
   .mbar.config.m add command -label "$id" -command "loadconfig $id"
}
.mbar.config.m add command -label "User selected" -command "loadconfig user"
.mbar.config.m add command -label "Save current as" -command "saveconfig"
place .mbar.config -x 380 -y 0



checkbutton .main.bred -bg gray -text "RED ARM" -variable INSTRUMENT(red)  -highlightthickness 0
place .main.bred -x 450 -y 22
checkbutton .main.bblue -bg gray -text "BLUE ARM" -variable INSTRUMENT(blue)  -highlightthickness 0
place .main.bblue -x 350 -y 22

#label .main.astatus -text test -fg black -bg LightBlue
#place .main.astatus -x 20 -y 315
#.main.astatus configure -text "Run:YES   Shut:OPEN   FPS:32/32   Mode:CCD     Temp:ON:-50  Frame:256x256   PGain:10   NumPix:??????"
#label .main.bstatus -text test -bg Orange -fg black
#place .main.bstatus -x 20 -y 340
#.main.bstatus configure -text "Run:YES   Shut:OPEN   FPS:32/32   Mode:CCD     Temp:ON:-50  Frame:256x256   PGain:10   NumPix:??????"
###TBD
#place .main.astatus -x 1000
#place .main.bstatus -x 1000

frame .lowlevel -bg gray -width 620 -height 710
place .lowlevel -x 0 -y 360
label .lowlevel.red -text "RED ARM" -bg red -fg black -width 25
place .lowlevel.red -x 420 -y 3
label .lowlevel.blue -text "BLUE ARM" -bg LightBlue -fg black -width 25
place .lowlevel.blue -x 20 -y 3
#checkbutton .lowlevel.clone -bg gray -text "Clone settings" -variable INSTRUMENT(clone)  -highlightthickness 0
#place .lowlevel.clone -x 240 -y 3

label .lowlevel.lemgain  -bg gray -text "EM Gain"
SpinBox .lowlevel.emgain -width 4  -bg gray50  -range "0 1000 1" -textvariable INSTRUMENT(red,emgain) -command "checkemccdgain red" -validate all -vcmd {validInteger %W %V %P %s 0 4095}
place .lowlevel.lemgain -x 616 -y 103
place .lowlevel.emgain -x 670 -y 100

label .lowlevel.lbemgain  -bg gray -text "EM Gain"
SpinBox .lowlevel.bemgain -width 4  -bg gray  -range "0 1000 1" -textvariable INSTRUMENT(blue,emgain) -command "checkemccdgain blue" -validate all -vcmd {validInteger %W %V %P %s 0 4095}
place .lowlevel.lbemgain -x 220 -y 103
place .lowlevel.bemgain -x 274 -y 100



label .lowlevel.input -text "INPUT" -bg white
place .lowlevel.input -x 280 -y 270
set INSTRUMENT(clone) 0

button .lowlevel.rtempset -bg gray -text "Temp Set" -width 6 -command "andorsetpoint red"
entry .lowlevel.vrtempset -bg white -textvariable ANDOR_CFG(red,setpoint) -width 6  -justify right -validate all -vcmd {validInteger %W %V %P %s -80 20}
place .lowlevel.rtempset -x 528 -y 28
place .lowlevel.vrtempset -x 610 -y 33

button .lowlevel.btempset -bg gray -text "Temp Set" -width 6 -command "andorsetpoint blue"
entry .lowlevel.vbtempset -bg white -textvariable ANDOR_CFG(blue,setpoint) -width 6  -justify right -validate all -vcmd {validInteger %W %V %P %s -80 20}
place .lowlevel.btempset -x 130 -y 28
place .lowlevel.vbtempset -x 210 -y 33


set ANDOR_CFG(red,setpoint) -60
set ANDOR_CFG(blue,setpoint) -60

menubutton .lowlevel.rshut -text Shutter  -width 12 -bg gray80 -menu .lowlevel.rshut.m -relief raised
menu .lowlevel.rshut.m
place .lowlevel.rshut -x 420 -y 30
.lowlevel.rshut.m add command -label "Shutter=During" -command "speckleshutter red during"
.lowlevel.rshut.m add command -label "Shutter=Close" -command "speckleshutter red close"
.lowlevel.rshut.m add command -label "Shutter=Open" -command "speckleshutter red open"

menubutton .lowlevel.bshut -text Shutter  -width 12 -bg gray80 -menu .lowlevel.bshut.m -relief raised
menu .lowlevel.bshut.m
place .lowlevel.bshut -x 20 -y 30
.lowlevel.bshut.m add command -label "Shutter=During" -command "speckleshutter blue during"
.lowlevel.bshut.m add command -label "Shutter=Close" -command "speckleshutter blue close"
.lowlevel.bshut.m add command -label "Shutter=Open" -command "speckleshutter blue open"


checkbutton .lowlevel.rautofit  -bg gray -text "Autofit ds9" -variable INSTRUMENT(red,fitds9) -highlightthickness 0
checkbutton .lowlevel.bautofit  -bg gray -text "Autofit ds9" -variable INSTRUMENT(blue,fitds9) -highlightthickness 0
place .lowlevel.rautofit -x 680 -y 33
place .lowlevel.bautofit -x 280 -y 33

checkbutton .lowlevel.rfxfer  -bg gray -text "Frame Transfer" -variable ANDOR_CFG(red,frametransfer) -highlightthickness 0
checkbutton .lowlevel.bfxfer  -bg gray -text "Frame Transfer" -variable ANDOR_CFG(blue,frametransfer) -highlightthickness 0
place .lowlevel.rfxfer -x 620 -y 3
place .lowlevel.bfxfer -x 220 -y 3
set ANDOR_CFG(red,frametransfer) 1
set ANDOR_CFG(blue,frametransfer) 1

set INSTRUMENT(red,fitds9) 0
set INSTRUMENT(blue,fitds9) 0
set ZABERS(A,target) 0
set ZABERS(B,target) 0
set ZABERS(input,target) 0
set TELEMETRY(speckle.mode.andor) "widefield"

button .lowlevel.zagoto -bg gray -text "Move to" -width 8 -command "zaberEngpos A"
entry .lowlevel.vzagoto -bg white -textvariable ZABERS(A,target) -width 10  -justify right -validate all -vcmd {validInteger %W %V %P %s 0 999999}
place .lowlevel.zagoto -x 420 -y 300
place .lowlevel.vzagoto -x 530 -y 302
button .lowlevel.zawide -bg gray -text "Set WIDE to current" -width 20 -command "zaberConfigurePos A wide"
place .lowlevel.zawide -x 420 -y 340
button .lowlevel.zaspec -bg gray -text "Set SPECKLE to current" -width 20 -command "zaberConfigurePos A speckle"
place .lowlevel.zaspec -x 420 -y 380
button .lowlevel.zahome -bg gray -text "Set HOME to current" -width 20 -command "zaberConfigurePos A home"
place .lowlevel.zahome -x 420 -y 420

button .lowlevel.zigoto -bg gray -text "Move to" -width 8 -command "zaberEngpos input"
entry .lowlevel.vzigoto -bg white -textvariable ZABERS(B,target) -width 10  -justify right -validate all -vcmd {validInteger %W %V %P %s 0 999999}
place .lowlevel.zigoto -x 220 -y 300
place .lowlevel.vzigoto -x 330 -y 302
button .lowlevel.ziwide -bg gray -text "Set WIDE to current" -width 20 -command "zaberConfigurePos input wide"
place .lowlevel.ziwide -x 220 -y 340
button .lowlevel.zispec -bg gray -text "Set SPECKLE to current" -width 20 -command "zaberConfigurePos input speckle"
place .lowlevel.zispec -x 220 -y 380
button .lowlevel.zihome -bg gray -text "Set HOME to current" -width 20 -command "zaberConfigurePos input home"
place .lowlevel.zihome -x 220 -y 420

button .lowlevel.zbgoto -bg gray -text "Move to" -width 8 -command "zaberEngpos B"
entry .lowlevel.vzbgoto -bg white -textvariable ZABERS(B,target) -width 10  -justify right -validate all -vcmd {validInteger %W %V %P %s 0 999999}
place .lowlevel.zbgoto -x 20 -y 300
place .lowlevel.vzbgoto -x 130 -y 302
button .lowlevel.zbwide -bg gray -text "Set WIDE to current" -width 20 -command "zaberConfigurePos B wide"
place .lowlevel.zbwide -x 20 -y 340
button .lowlevel.zbspec -bg gray -text "Set SPECKLE to current" -width 20 -command "zaberConfigurePos B speckle"
place .lowlevel.zbspec -x 20 -y 380
button .lowlevel.zbhome -bg gray -text "Set HOME to current" -width 20 -command "zaberConfigurePos B home"
place .lowlevel.zbhome -x 20 -y 420

menubutton .lowlevel.rmode -text "Mode=wide"  -width 20 -bg gray80 -menu .lowlevel.rmode.m -relief raised
menu .lowlevel.rmode.m
place .lowlevel.rmode -x 745 -y 0
.lowlevel.rmode.m add command -label "Wide Field" -command "specklemode wide"
.lowlevel.rmode.m add command -label "Speckle" -command "specklemode speckle"


menubutton .lowlevel.rfilter -text "Filter = clear"  -width 16 -bg gray80 -menu .lowlevel.rfilter.m -relief raised
menu .lowlevel.rfilter.m
place .lowlevel.rfilter -x 518 -y 70

menubutton .lowlevel.bfilter -text "Filter = clear"  -width 16 -bg gray80 -menu .lowlevel.bfilter.m -relief raised
menu .lowlevel.bfilter.m
place .lowlevel.bfilter -x 118 -y 70


set SPECKLE_FILTER(red,current) clear
set SPECKLE_FILTER(blue,current) clear
set SPECKLE_FILTER(red,wheel) 1
set SPECKLE_FILTER(blue,wheel) 2

set d  [split $SCOPE(obsdate) "-"]
set SCOPE(equinox) [format %7.2f [expr [lindex $d 0]+[lindex $d 1]./12.]]


toplevel .camerastatus -width 400 -height 520 -bg gray
wm title .camerastatus "Camera Configrations" 
label .camerastatus.lred -text "Red Arm" -bg gray
label .camerastatus.lblue -text "Blue Arm" -bg gray
place .camerastatus.lred -x 200 -y 10
place .camerastatus.lblue -x 300 -y 10

set iy 40
foreach p "Shutter FrameTransferMode OutputAmplifier EMAdvanced EMCCDGain EMHSSpeed HSSpeed VSSpeed PreAmpGain ReadMode AcquisitionMode KineticCycleTime NumberAccumulations NumberKinetics AccumulationCycleTime TExposure TAccumulate TKinetics" {
   label .camerastatus.l[set p] -text $p  -bg gray
   label .camerastatus.vred[set p] -textvariable CAMSTATUS(red,$p) -bg gray -fg NavyBlue
   label .camerastatus.vblue[set p] -textvariable CAMSTATUS(blue,$p) -bg gray -fg NavyBlue
   place .camerastatus.l[set p] -x 20 -y $iy
   place .camerastatus.vred[set p] -x 320 -y $iy
   place .camerastatus.vblue[set p] -x 220 -y $iy
   incr iy 25
}
button .camerastatus.done -text "Close" -fg black -bg orange -width 45 -command "wm withdraw .camerastatus"
place .camerastatus.done -x 20 -y 500
wm geometry .camerastatus 430x550+20+20
foreach p "Shutter FrameTransferMode OutputAmplifier EMAdvanced EMCCDGain HSSpeed VSSpeed PreAmpGain ReadMode AcquisitionMode KineticCycleTime NumberAccumulations NumberKinetics AccumulationCycleTime TExposure TAccumulate TKinetics" {
   set CAMSTATUS(red,$p) "???"
   set CAMSTATUS(blue,$p) "???"
}
wm withdraw .camerastatus

set CAMSTATUS(red,TKinetics) 0.04
set CAMSTATUS(blue,TKinetics) 0.04
set CAMSTATUS(red,PreAmpGain) 1
set CAMSTATUS(blue,PreAmpGain) 1

checkbutton .lowlevel.emccd  -bg gray -text "EMCCD" -variable INSTRUMENT(red,emccd) -command "checkemccdgain red"  -highlightthickness 0
checkbutton .lowlevel.hgain  -bg gray -text "High Gain" -variable INSTRUMENT(red,highgain) -command "checkemccdgain red"  -highlightthickness 0
checkbutton .lowlevel.aemccd  -bg gray -text "Auto Set" -variable INSTRUMENT(red,autoemccd) -highlightthickness 0
label .lowlevel.lvspeed  -bg gray -text "VSpeed"

checkbutton .lowlevel.emchk  -bg gray -text "Recommend" -variable INSTRUMENT(red,emcheck) -highlightthickness 0

menubutton .lowlevel.vspeed -width 12 -text "0.6 usec" -fg black -bg gray -menu .lowlevel.vspeed.m -relief raised
menu .lowlevel.vspeed.m
.lowlevel.vspeed.m  add command -label "0.6 usec"  -command "andorset vspeed red VSSpeed 0"
.lowlevel.vspeed.m  add command -label "1.13 usec"  -command "andorset vspeed red VSSpeed 1"
.lowlevel.vspeed.m  add command -label "2.2 usec"  -command "andorset vspeed red VSSpeed 2"
.lowlevel.vspeed.m  add command -label "4.33 usec"  -command "andorset vspeed red VSSpeed 3"

menubutton .lowlevel.emhs  -width 12 -text "30 MHz" -fg black -bg gray -menu .lowlevel.emhs.m -relief raised
menu .lowlevel.emhs.m
.lowlevel.emhs.m  add command -label "30 MHz"  -command "andorset emhs red EMHSSpeed 0"
.lowlevel.emhs.m  add command -label "20 MHz"  -command "andorset emhs red EMHSSpeed 1"
.lowlevel.emhs.m  add command -label "10 MHz"  -command "andorset emhs red EMHSSpeed 2"
.lowlevel.emhs.m  add command -label "1 MHz"   -command "andorset emhs red EMHSSpeed 3"

menubutton .lowlevel.ccdhs -width 12  -text "1 MHz" -fg black -bg gray -menu .lowlevel.ccdhs.m -relief raised
menu .lowlevel.ccdhs.m
.lowlevel.ccdhs.m  add command -label "1 MHz"  -command "andorset ccdhs red HSSpeed 0"
.lowlevel.ccdhs.m  add command -label "100 KHz"  -command "andorset ccdhs red HSSpeed 1"


#SpinBox .lowlevel.vspeed -width 4  -bg gray   -range "0 4 1" -textvariable INSTRUMENT(red,vspeed) -validate all -vcmd {validInteger %W %V %P %s 0 4}
label .lowlevel.lemhs  -bg gray -text "EMCCD HS" 
#SpinBox .lowlevel.emhs -width 4  -bg gray   -range "0 30 1" -textvariable INSTRUMENT(red,emhs) -validate all -vcmd {validInteger %W %V %P %s 0 3}
label .lowlevel.lccdhs  -bg gray -text "CCD HS" 
#SpinBox .lowlevel.ccdhs -width 4  -bg gray  -range "0 30 1" -textvariable INSTRUMENT(red,ccdhs) -validate all -vcmd {validInteger %W %V %P %s 0 3}



place .lowlevel.emccd -x 420 -y 100
place .lowlevel.hgain -x 520 -y 100
place .lowlevel.aemccd -x 725 -y 95
place .lowlevel.lvspeed -x 420 -y 200
place .lowlevel.vspeed -x 520 -y 200
place .lowlevel.lemhs -x 420 -y 230
place .lowlevel.emhs -x 520 -y 230
place .lowlevel.lccdhs -x 420 -y 260
place .lowlevel.ccdhs -x 520 -y 260
place .lowlevel.emchk -x 725 -y 110


checkbutton .lowlevel.bemccd  -bg gray -text "EMCCD" -variable INSTRUMENT(blue,emccd) -command "checkemccdgain blue" -highlightthickness 0
checkbutton .lowlevel.bhgain  -bg gray -text "High Gain" -variable INSTRUMENT(blue,highgain) -command "checkemccdgain blue" -highlightthickness 0
checkbutton .lowlevel.abemccd  -bg gray -text "Auto Set" -variable INSTRUMENT(red,autoemccd) -highlightthickness 0
label .lowlevel.lbvspeed  -bg gray -text "Vspeed"

checkbutton .lowlevel.bemchk  -bg gray -text "Recommend" -variable INSTRUMENT(blue,emcheck) -highlightthickness 0

#SpinBox .lowlevel.bvspeed -width 4  -bg gray   -range "0 4 1" -textvariable INSTRUMENT(blue,vspeed) -validate all -vcmd {validInteger %W %V %P %s 0 4}
label .lowlevel.lbemhs  -bg gray -text "EMCCD HS" 
#SpinBox .lowlevel.bemhs -width 4  -bg gray  -range "0 3 1" -textvariable INSTRUMENT(blue,emhs) -validate all -vcmd {validInteger %W %V %P %s 0 3}
label .lowlevel.lbccdhs  -bg gray -text "CCD HS" 
#SpinBox .lowlevel.bccdhs -width 4  -bg gray  -range "0 3 1" -textvariable INSTRUMENT(blue,ccdhs) -validate all -vcmd {validInteger %W %V %P %s 0 3}


menubutton .lowlevel.bvspeed  -width 12 -text "0.6 usec" -fg black -bg gray -menu .lowlevel.bvspeed.m -relief raised
menu .lowlevel.bvspeed.m
.lowlevel.bvspeed.m  add command -label "0.6 usec"  -command "andorset bvspeed blue VSSpeed 0"
.lowlevel.bvspeed.m  add command -label "1.13 usec"  -command "andorset bvspeed blue VSSpeed 1"
.lowlevel.bvspeed.m  add command -label "2.2 usec"  -command "andorset bvspeed blue VSSpeed 2"
.lowlevel.bvspeed.m  add command -label "4.33 usec"  -command "andorset bvspeed blue VSSpeed 3"

menubutton .lowlevel.bemhs  -width 12 -text "30 MHz" -fg black -bg gray -menu .lowlevel.bemhs.m -relief raised
menu .lowlevel.bemhs.m
.lowlevel.bemhs.m  add command -label "30 MHz"  -command "andorset bemhs blue EMHSSpeed 0"
.lowlevel.bemhs.m  add command -label "20 MHz"  -command "andorset bemhs blue EMHSSpeed 1"
.lowlevel.bemhs.m  add command -label "10 MHz"  -command "andorset bemhs blue EMHSSpeed 2"
.lowlevel.bemhs.m  add command -label "1 MHz"   -command "andorset bemhs blue EMHSSpeed 3"

menubutton .lowlevel.bccdhs  -width 12 -text "1 MHz" -fg black -bg gray -menu .lowlevel.bccdhs.m -relief raised
menu .lowlevel.bccdhs.m
.lowlevel.bccdhs.m  add command -label "1 MHz"  -command "andorset bccdhs blue HSSpeed 0"
.lowlevel.bccdhs.m  add command -label "100 KHz"  -command "andorset bccdhs blue HSSpeed 1"


set ANDOR_CFG(VSSpeed,0) "0.6 usec"
set ANDOR_CFG(VSSpeed,1) "1.13 usec"
set ANDOR_CFG(VSSpeed,2) "2.2 usec"
set ANDOR_CFG(VSSpeed,3) "4.33 usec"
set ANDOR_CFG(EMHSSpeed,0) "30 MHz"
set ANDOR_CFG(EMHSSpeed,1) "20 MHz"
set ANDOR_CFG(EMHSSpeed,2) "10 MHz"
set ANDOR_CFG(EMHSSpeed,3) "1 MHz"
set ANDOR_CFG(HSSpeed,0) "1 MHz"
set ANDOR_CFG(HSSpeed,1) "100 KHz"

set INSTRUMENT(red,emccd) 0
set INSTRUMENT(blue,emccd) 0

place .lowlevel.bemccd -x 20 -y 100
place .lowlevel.bhgain -x 120 -y 100
place .lowlevel.abemccd -x 325 -y 95
place .lowlevel.lbvspeed -x 20 -y 200
place .lowlevel.bvspeed -x 120 -y 200
place .lowlevel.lbemhs -x 20 -y 230
place .lowlevel.bemhs -x 120 -y 230
place .lowlevel.lbccdhs -x 20 -y 260
place .lowlevel.bccdhs -x 120 -y 260
place .lowlevel.bemchk -x 325 -y 110


button .lowlevel.rsave -text Save -bg gray70 -width 6 -command "specklesave red"
button .lowlevel.rload -text Load -bg gray70 -width 6 -command "speckleload red"
place .lowlevel.rsave -x 420  -y 460
place .lowlevel.rload -x 515 -y 460

button .lowlevel.isave -text Save -bg gray70 -width 6 -command "specklesave input"
button .lowlevel.iload -text Load -bg gray70 -width 6 -command "speckleload input"
place .lowlevel.isave -x 220  -y 460
place .lowlevel.iload -x 310 -y 460

button .lowlevel.bsave -text Save -bg gray70 -width 6 -command "specklesave blue"
button .lowlevel.bload -text Load -bg gray70 -width 6 -command "speckleload blue"
place .lowlevel.bsave -x 120  -y 460
place .lowlevel.bload -x 115 -y 460

button .main.video -width 5 -height 2 -text "Video" -relief raised -bg gray -command startfastvideo
place .main.video  -x 100 -y 167

place .main.abort   -x 180 -y 167
text .main.comment -height 14 -width 50 
label .main.lcomment -text "Comments :" -bg gray
checkbutton .main.clrcomment -bg gray -variable SCOPE(autoclrcmt) -text "Auto-clear"  -highlightthickness 0
place .main.comment -x 560 -y 50
place .main.lcomment -x 560 -y 23
place .main.clrcomment -x 640 -y 23

ttk::progressbar .lowlevel.p -orient horizontal -length 900  -mode determinate
place .lowlevel.p -x 20 -y 130
label .lowlevel.progress -text "Observation status : Idle" -fg NavyBlue -bg gray
place .lowlevel.progress -x 20 -y 154
label .lowlevel.datarate -text "Data Rate : ??? Mbps" -fg NavyBlue -bg gray
place .lowlevel.datarate -x 500 -y 154

#set INSTRUMENT(red) 1
#set INSTRUMENT(blue) 1
set SCOPE(exposure) 0.04
set LASTACQ fullframe
specklemode wide

catch {
  source $SPECKLE_DIR/gui-scripts/mimic.tcl 
  mimicMode red close
  mimicMode blue close
}

showstatus "Initializing Zabers"
source $SPECKLE_DIR/zaber/zaber.tcl 


showstatus "Initializing Filter Wheeels"
source $SPECKLE_DIR/oriel/filterWheel.tcl

.lowlevel.bfilter.m add command -label "$FWHEELS(blue,1)" -command "specklefilter blue $FWHEELS(blue,1)"
.lowlevel.bfilter.m add command -label "$FWHEELS(blue,2)" -command "specklefilter blue $FWHEELS(blue,2)"
.lowlevel.bfilter.m add command -label "$FWHEELS(blue,3)" -command "specklefilter blue $FWHEELS(blue,3)"
.lowlevel.bfilter.m add command -label "$FWHEELS(blue,4)" -command "specklefilter blue $FWHEELS(blue,4)"
.lowlevel.bfilter.m add command -label "$FWHEELS(blue,5)" -command "specklefilter blue $FWHEELS(blue,5)"
.lowlevel.bfilter.m add command -label "$FWHEELS(blue,6)" -command "specklefilter blue $FWHEELS(blue,6)"

.lowlevel.rfilter.m add command -label "$FWHEELS(red,1)" -command "specklefilter red $FWHEELS(red,1)"
.lowlevel.rfilter.m add command -label "$FWHEELS(red,2)" -command "specklefilter red $FWHEELS(red,2)"
.lowlevel.rfilter.m add command -label "$FWHEELS(red,3)" -command "specklefilter red $FWHEELS(red,3)"
.lowlevel.rfilter.m add command -label "$FWHEELS(red,4)" -command "specklefilter red $FWHEELS(red,4)"
.lowlevel.rfilter.m add command -label "$FWHEELS(red,5)" -command "specklefilter red $FWHEELS(red,5)"
.lowlevel.rfilter.m add command -label "$FWHEELS(red,6)" -command "specklefilter red $FWHEELS(red,6)"
  
.mbar.tools.m add command -label "HOME all stages" -command homeZabers
.mbar.tools.m add command -label "zabers to wide mode" -command "positionZabers fullframe"
.mbar.tools.m add command -label "zabers to speckle mode" -command "positionZabers roi"
if { $ZABERS(A,arm) == "red" } {
  .mbar.tools.m add command -label "zaber red wide" -command "zaberGoto A wide"
  .mbar.tools.m add command -label "zaber red speckle" -command "zaberGoto A speckle"
  .mbar.tools.m add command -label "zaber blue wide" -command "zaberGoto B wide"
  .mbar.tools.m add command -label "zaber blue speckle" -command "zaberGoto B speckle"
} else {
  .mbar.tools.m add command -label "zaber red wide" -command "zaberGoto B wide"
  .mbar.tools.m add command -label "zaber red speckle" -command "zaberGoto B speckle"
  .mbar.tools.m add command -label "zaber blue wide" -command "zaberGoto A wide"
  .mbar.tools.m add command -label "zaber blue speckle" -command "zaberGoto A speckle"
}
.mbar.tools.m add command -label "zaber input wide" -command "zaberGoto input wide"
.mbar.tools.m add command -label "zaber input speckle" -command "zaberGoto input speckle"

if { $SCOPE(telescope) == "GEMINI" } {
  .mbar.tools.m add command -label "zaber focus extend" -command "zaberGoto focus extend"
  .mbar.tools.m add command -label "zaber focus stow" -command "zaberGoto focus stow"
  .mbar.tools.m add command -label "zaber pickoff in" -command "zaberGoto pickoff in "
  .mbar.tools.m add command -label "zaber pickoff out" -command "zaberGoto pickpoff out"
}


set SPECKLE(observingGui) 936x540
wm geometry .mimicSpeckle +660+30

if { $SCOPE(telescope) == "WIYN" } {
   .lowlevel configure -height 520 -width 936
   wm geometry . 936x900
   set SPECKLE(engineeringGui) 936x900
   source $SPECKLE_DIR/gui-scripts/redisquery.tcl
   redisConnect
   redisUpdate


} else {

proc redisUpdate { } { }

set SPECKLE(engineeringGui) 936x1100
wm geometry . 936x1100
.lowlevel configure -height 700 -width 936

label .lowlevel.pickoff -text "PICK-OFF" -bg white
place .lowlevel.pickoff -x 735 -y 276
button .lowlevel.zpgoto -bg gray -text "Move to" -width 8 -command "zaberEngpos pickoff"
entry .lowlevel.vzpgoto -bg white -textvariable ZABERS(pickoff,target) -width 10  -justify right -validate all -vcmd {validInteger %W %V %P %s 0 999999}
place .lowlevel.zpgoto -x 670 -y 305
place .lowlevel.vzpgoto -x 780 -y 307
button .lowlevel.zpin -bg gray -text "Set IN to current" -width 20 -command "zaberConfigurePos pickoff in "
place .lowlevel.zpin -x 670 -y 350
button .lowlevel.zpout -bg gray -text "Set OUT to current" -width 20 -command "zaberConfigurePos pickoff out"
place .lowlevel.zpout -x 670 -y 392
button .lowlevel.pksave -text Save -bg gray70 -width 6 -command "specklesave pickoff"
button .lowlevel.pkload -text Load -bg gray70 -width 6 -command "speckleload pickoff"
place .lowlevel.pksave -x 668  -y 430
place .lowlevel.pkload -x 768 -y 430


label .lowlevel.focus -text "FOCUS" -bg white
place .lowlevel.focus -x 735 -y 506
button .lowlevel.zfgoto -bg gray -text "Move to" -width 8 -command "zaberEngpos focus"
entry .lowlevel.vzfgoto -bg white -textvariable ZABERS(focus,target) -width 10  -justify right -validate all -vcmd {validInteger %W %V %P %s 0 999999}
place .lowlevel.zfgoto -x 670 -y 535
place .lowlevel.vzfgoto -x 780 -y 537
button .lowlevel.zfin -bg gray -text "Set EXTEND to current" -width 20 -command "zaberConfigurePos focus extend "
place .lowlevel.zfin -x 670 -y 580
button .lowlevel.zfout -bg gray -text "Set STOW to current" -width 20 -command "zaberConfigurePos focus stow"
place .lowlevel.zfout -x 670 -y 622
button .lowlevel.fksave -text Save -bg gray70 -width 6 -command "specklesave focus"
button .lowlevel.fkload -text Load -bg gray70 -width 6 -command "speckleload focus"
place .lowlevel.fksave -x 668  -y 660
place .lowlevel.fkload -x 768 -y 660


label .lowlevel.rpico -text "Pico position" -bg gray
place .lowlevel.rpico -x 20 -y 565
button .lowlevel.rpicomm -width 3 -text "<<" -command "jogPico X --" -bg gray
button .lowlevel.rpicom  -width 3 -text "<" -command "jogPico X -" -bg gray
button .lowlevel.rpicop  -width 3 -text ">" -command "jogPico X +" -bg gray
button .lowlevel.rpicopp  -width 3 -text ">>" -command "jogPico X ++" -bg gray
place .lowlevel.rpicomm -x 120 -y 565
place .lowlevel.rpicom -x 200 -y 565
place .lowlevel.rpicop -x 350 -y 565
place .lowlevel.rpicopp -x 430 -y 565

button .lowlevel.rvpicomm -width 3 -text "--" -command "jogPico Y --" -bg gray
button .lowlevel.rvpicom  -width 3 -text "-" -command "jogPico Y -" -bg gray
button .lowlevel.rvpicop  -width 3 -text "+" -command "jogPico Y +" -bg gray
button .lowlevel.rvpicopp  -width 3 -text "++" -command "jogPico Y ++" -bg gray
place .lowlevel.rvpicomm -x 278 -y 625
place .lowlevel.rvpicom -x 278 -y 585
place .lowlevel.rvpicop -x 278 -y 545
place .lowlevel.rvpicopp -x 278 -y 505

button .lowlevel.psave -text Save -bg gray70 -width 12 -command "savePicosConfig"
button .lowlevel.pload -text Load -bg gray70 -width 12 -command "loadPicosConfig"
place .lowlevel.psave -x 420  -y 660
place .lowlevel.pload -x 60 -y 660

entry .lowlevel.vxpico -width 8 -bg white -textvariable PICOS(X,current)  -justify right -validate all -vcmd {validInteger %W %V %P %s 0 999999}
place .lowlevel.vxpico -x 510 -y 570
entry .lowlevel.vypico -width 8 -bg white -textvariable PICOS(Y,current)  -justify right -validate all -vcmd {validInteger %W %V %P %s 0 999999}
place .lowlevel.vypico -x 272 -y 665

showstatus "Initializing PICOs"
source $SPECKLE_DIR/picomotor/picomotor.tcl

if { $SCOPE(telescope) == "GEMINI" } {
 showstatus "Connecting to Gemini Telemetry service"
 source $SPECKLE_DIR/gui-scripts/gemini_telemetry.tcl

 set SPKTELEM(sim) 0
 if { [info exists env(SPECKLE_SIM)] } {
   set simdev [split $env(SPECKLE_SIM) ,]
   if { [lsearch $simdev geminitlm] > -1 } {
       set SPKTELEM(sim) 1
       debuglog "Gemini telemetry in SIMULATION mode"
       simGeminiTelemetry
  }
 }
}

if { $SPKTELEM(sim) == 0 } {
  geminiConnect north
}


}

if { [file exists $env(HOME)/.specklegui] } {
   source $env(HOME)/.specklegui
}


set SCOPE(imagename) "N[exec date +%Y%m%d]"
catch {
    set all [lsort [glob $SCOPE(datadir)/N*.fits]]
    set last [split [lindex $all end] _]
    set SCOPE(seqnum) [expr [string trimleft [lindex $last 2] 0] +1]
}




