wm title . "NESSI Control"
place .main -x 0 -y 30
place .mbar -x 0
.main configure -width 620
.mbar configure -width 620
place .mbar.help -x 550
set iy 50
foreach item "target propid ra dec equinox observer telescope instrument site latitude longitude" {
   place .main.l$item -x 360 -y $iy
   place .main.v$item -x 440 -y $iy

   incr iy 24 
}


menubutton .mbar.config -text "Configurations" -fg black -bg gray -menu .mbar.config.m
menu .mbar.config.m
set cfg [glob $env(NESSI_DIR)/config-scripts/*]
foreach i $$cfg { 
   set id [file tail $i]
   .mbar.config.m add command -label "$id" -command "loadconfig $id"
}
.mbar.config.m add command -label "User selected" -command "loadconfig user"
.mbar.config.m add command -label "Save current as" -command "saveconfig"
place .mbar.config -x 380 -y 0



checkbutton .main.bred -bg gray50 -text "RED ARM" -variable INSTRUMENT(red)
place .main.bred -x 350 -y 22
checkbutton .main.bblue -bg gray50 -text "BLUE ARM" -variable INSTRUMENT(blue)
place .main.bblue -x 450 -y 22
.main configure -height 370 -width 620

label .main.astatus -text test -fg black -bg LightBlue
place .main.astatus -x 20 -y 315
.main.astatus configure -text "Run:YES   Shut:OPEN   FPS:32/32   Mode:CCD     Temp:ON:-50  Frame:256x256   PGain:10   NumPix:??????"
 
label .main.bstatus -text test -bg Orange -fg black
place .main.bstatus -x 20 -y 340
.main.bstatus configure -text "Run:YES   Shut:OPEN   FPS:32/32   Mode:CCD     Temp:ON:-50  Frame:256x256   PGain:10   NumPix:??????"

###TBD
place .main.astatus -x 1000
place .main.bstatus -x 1000

frame .lowlevel -bg gray50 -width 620 -height 710
place .lowlevel -x 0 -y 400
label .lowlevel.red -text "RED ARM" -bg red -fg black -width 25
place .lowlevel.red -x 20 -y 0
label .lowlevel.blue -text "BLUE ARM" -bg LightBlue -fg black -width 25
place .lowlevel.blue -x 420 -y 0
checkbutton .lowlevel.clone -bg gray50 -text "Clone settings" -variable INSTRUMENT(clone)
place .lowlevel.clone -x 220 -y 0


label .lowlevel.input -text "INPUT" -bg white
place .lowlevel.input -x 280 -y 270
set INSTRUMENT(clone) 0

button .lowlevel.rtempset -bg gray50 -text "Temp Set" -width 6 -command "andorsetpoint red"
entry .lowlevel.vrtempset -bg white -textvariable ANDOR_CFG(red,setpoint) -width 6
place .lowlevel.rtempset -x 116 -y 30
place .lowlevel.vrtempset -x 210 -y 33
label .lowlevel.rcamtemp -bg gray -fg blue -text "???.??" -bg gray50
place .lowlevel.rcamtemp -x 265 -y 33

button .lowlevel.btempset -bg gray50 -text "Temp Set" -width 6 -command "andorsetpoint blue"
entry .lowlevel.vbtempset -bg white -textvariable ANDOR_CFG(blue,setpoint) -width 6
place .lowlevel.btempset -x 446 -y 30
place .lowlevel.vbtempset -x 527 -y 33
label .lowlevel.bcamtemp -bg gray -fg blue -text "???.??" -bg gray50
place .lowlevel.bcamtemp -x 578 -y 33
set ANDOR_CFG(red,setpoint) -60
set ANDOR_CFG(blue,setpoint) -60

menubutton .lowlevel.rshut -text Shutter  -width 10 -bg gray80 -menu .lowlevel.rshut.m
menu .lowlevel.rshut.m
place .lowlevel.rshut -x 20 -y 30
.lowlevel.rshut.m add command -label "Shutter=During" -command "nessishutter red during"
.lowlevel.rshut.m add command -label "Shutter=Close" -command "nessishutter red close"
.lowlevel.rshut.m add command -label "Shutter=Open" -command "nessishutter red open"

menubutton .lowlevel.bshut -text Shutter  -width 10 -bg gray80 -menu .lowlevel.bshut.m
menu .lowlevel.bshut.m
place .lowlevel.bshut -x 355 -y 30
.lowlevel.bshut.m add command -label "Shutter=During" -command "nessishutter blue during"
.lowlevel.bshut.m add command -label "Shutter=Close" -command "nessishutter blue close"
.lowlevel.bshut.m add command -label "Shutter=Open" -command "nessishutter blue open"


set ZABERS(A,target) 0
set ZABERS(B,target) 0
set ZABERS(input,target) 0

button .lowlevel.zagoto -bg gray50 -text "Move to" -width 8 -command "zaberEngpos A"
entry .lowlevel.vzagoto -bg white -textvariable ZABERS(A,target) -width 10
place .lowlevel.zagoto -x 20 -y 300
place .lowlevel.vzagoto -x 130 -y 302
button .lowlevel.zawide -bg gray50 -text "Set WIDE to current" -width 20 -command "zaberConfigurePos A wide"
place .lowlevel.zawide -x 20 -y 340
button .lowlevel.zaspec -bg gray50 -text "Set SPECKLE to current" -width 20 -command "zaberConfigurePos A speckle"
place .lowlevel.zaspec -x 20 -y 380
button .lowlevel.zahome -bg gray50 -text "Set HOME to current" -width 20 -command "zaberConfigurePos A home"
place .lowlevel.zahome -x 20 -y 420

button .lowlevel.zigoto -bg gray50 -text "Move to" -width 8 -command "zaberEngpos input"
entry .lowlevel.vzigoto -bg white -textvariable ZABERS(B,target) -width 10
place .lowlevel.zigoto -x 220 -y 300
place .lowlevel.vzigoto -x 330 -y 302
button .lowlevel.ziwide -bg gray50 -text "Set WIDE to current" -width 20 -command "zaberConfigurePos input wide"
place .lowlevel.ziwide -x 220 -y 340
button .lowlevel.zispec -bg gray50 -text "Set SPECKLE to current" -width 20 -command "zaberConfigurePos input speckle"
place .lowlevel.zispec -x 220 -y 380
button .lowlevel.zihome -bg gray50 -text "Set HOME to current" -width 20 -command "zaberConfigurePos input home"
place .lowlevel.zihome -x 220 -y 420

button .lowlevel.zbgoto -bg gray50 -text "Move to" -width 8 -command "zaberEngpos B"
entry .lowlevel.vzbgoto -bg white -textvariable ZABERS(B,target) -width 10
place .lowlevel.zbgoto -x 420 -y 300
place .lowlevel.vzbgoto -x 530 -y 302
button .lowlevel.zbwide -bg gray50 -text "Set WIDE to current" -width 20 -command "zaberConfigurePos B wide"
place .lowlevel.zbwide -x 420 -y 340
button .lowlevel.zbspec -bg gray50 -text "Set SPECKLE to current" -width 20 -command "zaberConfigurePos B speckle"
place .lowlevel.zbspec -x 420 -y 380
button .lowlevel.zbhome -bg gray50 -text "Set HOME to current" -width 20 -command "zaberConfigurePos B home"
place .lowlevel.zbhome -x 420 -y 420

menubutton .lowlevel.rmode -text Mode  -width 10 -bg gray80 -menu .lowlevel.rmode.m
menu .lowlevel.rmode.m
place .lowlevel.rmode -x 20 -y 70
.lowlevel.rmode.m add command -label "Wide Field" -command "nessimode red wide"
.lowlevel.rmode.m add command -label "Speckle" -command "nessimode red speckle"
.lowlevel.rmode.m add command -label "Custom" -command "nessimode red custom"

menubutton .lowlevel.bmode -text Mode -width 10 -bg gray80 -menu .lowlevel.bmode.m
menu .lowlevel.bmode.m
place .lowlevel.bmode -x 420 -y 70
.lowlevel.bmode.m add command -label "Wide Field" -command "nessimode blue wide"
.lowlevel.bmode.m add command -label "Speckle" -command "nessimode blue speckle"
.lowlevel.bmode.m add command -label "Custom" -command "nessimode blue custom"

menubutton .lowlevel.rfilter -text "Filter = clear"  -width 10 -bg gray80 -menu .lowlevel.rfilter.m
menu .lowlevel.rfilter.m
place .lowlevel.rfilter -x 118 -y 70
.lowlevel.rfilter.m add command -label "i" -command "nessifilter red Red-I"
.lowlevel.rfilter.m add command -label "z" -command "nessifilter red Red-Z"
.lowlevel.rfilter.m add command -label "716" -command "nessifilter red Red-716"
.lowlevel.rfilter.m add command -label "832" -command "nessifilter red Red-832"
.lowlevel.rfilter.m add command -label "clear" -command "nessifilter red clear"
.lowlevel.rfilter.m add command -label "block" -command "nessifilter red block"

menubutton .lowlevel.bfilter -text "Filter = clear"  -width 10 -bg gray80 -menu .lowlevel.bfilter.m
menu .lowlevel.bfilter.m
place .lowlevel.bfilter -x 518 -y 70
.lowlevel.bfilter.m add command -label "u" -command "nessifilter blue Blue-U"
.lowlevel.bfilter.m add command -label "g" -command "nessifilter blue Blue-G"
.lowlevel.bfilter.m add command -label "r" -command "nessifilter blue Blue-R"
.lowlevel.bfilter.m add command -label "467" -command "nessifilter blue Blue-467"
.lowlevel.bfilter.m add command -label "562" -command "nessifilter blue Blue-562"
.lowlevel.bfilter.m add command -label "clear" -command "nessifilter blue clear"

proc nessifilter { arm name } {
global FWHEELS NESSI_FILTER
  if { $arm == "red" } {
    .lowlevel.rfilter configure -text "Filter = $name"
  } else {
    .lowlevel.bfilter configure -text "Filter = $name"
  }
  if { $NESSI_FILTER($arm,current) != $name } {
    set id [findfilter $arm $name]
    if { $id > 0 } {
       debuglog "Arm $arm select filter $name"
       selectfilter $arm $id
    }
  }
}

set NESSI_FILTER(red,current) clear
set NESSI_FILTER(blue,current) clear
set NESSI_FILTER(red,wheel) 1
set NESSI_FILTER(blue,wheel) 2

set d  [split $SCOPE(obsdate) "-"]
set SCOPE(equinox) [format %7.2f [expr [lindex $d 0]+[lindex $d 1]./12.]]

#
#  Do the actual setup of the GUI, to sync it with the camera status
#


proc findfilter { arm name  } {
global FWHEELS
   foreach i "1 2 3 4 5 6"  {
     if { $FWHEELS($arm,$i) == $name } {return $i}
   }
   return 0
}


proc loadconfig { fname } {
global NESSI_DIR
   if { $fname == "user" } {
      set it [tk_getOpenFile -initialdir $NESSI_DIR/config-scripts]
      if { $it == "" } {return}
      debuglog "Loading configration from $it"
      source $it
   } else {
      debuglog "Loading configration from $NESSI_DIR/config-scripts/$fname"
      source $NESSI_DIR/config-scripts/$fname
   }
}


proc initFilter { arm } {
global NESSI_FILTER FWHEELS
   debuglog "Initializing filter wheels ..."
   resetFilterWheel $FWHEELS($arm,handle)
   selectfilter $arm $FWHEELS($arm,clear)
   debuglog "Initialized filter wheels"
}

proc nessisave { device } {
global NESSI_DIR
   saveZaberConfig zabersConfiguration
   debuglog "Saved zabers configuration"
}

proc nessiload { device } {
global NESSI_DIR
   source $NESSI_DIR/zabersConfiguration
   debuglog "Loaded zabers configuration"
}

proc nessimode { arm name } {
global ANDOR_MODE LASTACQ
    .lowlevel.rmode configure -text "Mode=$name"
    .lowlevel.bmode configure -text "Mode=$name"
    debuglog "Setting arm $arm up for $name"
    if { $name == "wide" && $LASTACQ != "fullframe" } {
       commandAndor $arm "setframe fullframe"
       positionSpeckle $arm fullframe
    }
    if { $name == "speckle" && $LASTACQ != "roi" } {
       commandAndor arm "setframe roi"
       positionSpeckle $arm roi
     }
    debuglog "$arm setup for $name"
}


proc nessishutter { arm name } {
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

proc andorsetpoint { arm } {
global ANDOR_CFG
   debuglog "Set $arm camera temperature setpoint to $ANDOR_CFG($arm,setpoint)"
   commandAndor $arm "setTemperature $ANDOR_CFG($arm,setpoint)"
}


proc checkemccdgain { arm } {
global INSTRUMENT
   debuglog "Set $arm camera EMCCD gain to $INSTRUMENT($arm,emccd)"
   commandAndor $arm "setEMCCDGain $INSTRUMENT($arm,emccd)"
   if { $INSTRUMENT($arm,highgain) == 0 || $INSTRUMENT($arm,emccd) == 0 } {
      if { $INSTRUMENT($arm,emgain) > 300 } {set INSTRUMENT($arm,emgain) 300}
      .mbar configure -bg gray50
   }
   if { $INSTRUMENT($arm,highgain) && $INSTRUMENT($arm,emccd) } {
      if { $INSTRUMENT($arm,emgain) > 300 } {
         debuglog "$arm camera EMCCD gain >300 WARNING"
         .mbar configure -bg orange
      } else {
         .mbar configure -bg gray50
      }
   }
}

checkbutton .lowlevel.emccd  -bg gray50 -text "EMCCD" -variable INSTRUMENT(red,emccd) -command "checkemccdgain red"
checkbutton .lowlevel.hgain  -bg gray50 -text "High Gain" -command "checkemccdgain red" -variable INSTRUMENT(red,highgain)
label .lowlevel.lemgain  -bg gray50 -text "EM Gain"
SpinBox .lowlevel.emgain -width 4  -bg gray50  -range "0 1000 1" -textvariable INSTRUMENT(red,emgain) -command "checkemccdgain red" 
label .lowlevel.lvspeed  -bg gray50 -text "VSpeed"
SpinBox .lowlevel.vspeed -width 4  -bg gray50   -range "0 1000 1" -textvariable INSTRUMENT(red,vspeed)
label .lowlevel.lemhs  -bg gray50 -text "EMCCD HS" 
SpinBox .lowlevel.emhs -width 4  -bg gray50   -range "0 30 1" -textvariable INSTRUMENT(red,emhs)
label .lowlevel.lccdhs  -bg gray50 -text "CCD HS" 
SpinBox .lowlevel.ccdhs -width 4  -bg gray50  -range "0 30 1" -textvariable INSTRUMENT(red,ccdhs)
place .lowlevel.emccd -x 20 -y 100
place .lowlevel.hgain -x 120 -y 100

place .lowlevel.lemgain -x 20 -y 170
place .lowlevel.emgain -x 120 -y 170

place .lowlevel.lvspeed -x 20 -y 200
place .lowlevel.vspeed -x 120 -y 200

place .lowlevel.lemhs -x 20 -y 230
place .lowlevel.emhs -x 120 -y 230

place .lowlevel.lccdhs -x 20 -y 260
place .lowlevel.ccdhs -x 120 -y 260


checkbutton .lowlevel.bemccd  -bg gray50 -text "EMCCD" -variable INSTRUMENT(blue,emccd) -command "checkemccdgain blue"
checkbutton .lowlevel.bhgain  -bg gray50 -text "High Gain" -variable INSTRUMENT(blue,highgain) -command "checkemccdgain blue"
label .lowlevel.lbemgain  -bg gray50 -text "EM Gain"
SpinBox .lowlevel.bemgain -width 4  -bg gray50  -range "0 1000 1" -textvariable INSTRUMENT(blue,emgain) -command "checkemccdgain blue"
label .lowlevel.lbvspeed  -bg gray50 -text "Vspeed"
SpinBox .lowlevel.bvspeed -width 4  -bg gray50   -range "0 1000 1" -textvariable INSTRUMENT(blue,vspeed)
label .lowlevel.lbemhs  -bg gray50 -text "EMCCD HS" 
SpinBox .lowlevel.bemhs -width 4  -bg gray50  -range "0 30 1" -textvariable INSTRUMENT(blue,emhs)
label .lowlevel.lbccdhs  -bg gray50 -text "CCD HS" 
SpinBox .lowlevel.bccdhs -width 4  -bg gray50  -range "0 30 1" -textvariable INSTRUMENT(blue,ccdhs)
place .lowlevel.bemccd -x 420 -y 100
place .lowlevel.bhgain -x 520 -y 100

place .lowlevel.lbemgain -x 420 -y 170
place .lowlevel.bemgain -x 520 -y 170

place .lowlevel.lbvspeed -x 420 -y 200
place .lowlevel.bvspeed -x 520 -y 200

place .lowlevel.lbemhs -x 420 -y 230
place .lowlevel.bemhs -x 520 -y 230

place .lowlevel.lbccdhs -x 420 -y 260
place .lowlevel.bccdhs -x 520 -y 260

button .lowlevel.rsave -text Save -bg gray70 -width 6 -command "nessisave red"
button .lowlevel.rload -text Load -bg gray70 -width 6 -command "nessiload red"
place .lowlevel.rsave -x 20  -y 460
place .lowlevel.rload -x 115 -y 460


button .lowlevel.isave -text Save -bg gray70 -width 6 -command "nessisave input"
button .lowlevel.iload -text Load -bg gray70 -width 6 -command "nessiload input"
place .lowlevel.isave -x 220  -y 460
place .lowlevel.iload -x 310 -y 460


button .lowlevel.bsave -text Save -bg gray70 -width 6 -command "nessisave blue"
button .lowlevel.bload -text Load -bg gray70 -width 6 -command "nessiload blue"
place .lowlevel.bsave -x 420  -y 460
place .lowlevel.bload -x 515 -y 460

button .main.video -width 5 -height 2 -text "Video" -relief sunken -bg gray -command startvideomode
place .main.video  -x 100 -y 167

place .main.abort   -x 180 -y 167

#set INSTRUMENT(red) 1
#set INSTRUMENT(blue) 1
set SCOPE(exposure) 0.04
set LASTACQ fullframe
nessimode red wide
nessimode blue wide

source $NESSI_DIR/wiyn-scripts/mimic.tcl 
mimicMode red close
mimicMode blue close

showstatus "Initializing Zabers"
source $NESSI_DIR/zaber/zaber.tcl 

showstatus "Initializing Filter Wheeels"
source $NESSI_DIR/oriel/filterWheel.tcl
  
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
  .mbar.tools.m add command -label "picos to in " -command "picosInPosition"
  .mbar.tools.m add command -label "picos to out" -command "picsoOutPosition"
}

set NESSI(observingGui) 620x540
wm geometry .mimicNessi +660+30

if { $SCOPE(telescope) == "WIYN" } {
   .lowlevel configure -height 520 -width 620
   wm geometry . 620x900
   set NESSI(engineeringGui) 620x900
} else {

set NESSI(engineeringGui) 900x1100
wm geometry . 900x1100
.lowlevel configure -height 700 -width 900
.main configure -width 900
.mbar  configure -width 900

label .lowlevel.pickoff -text "PICK-OFF" -bg white
place .lowlevel.pickoff -x 735 -y 276
button .lowlevel.zpgoto -bg gray50 -text "Move to" -width 8 -command "zaberEngpos pickoff"
entry .lowlevel.vzpgoto -bg white -textvariable ZABERS(pickoff,target) -width 10
place .lowlevel.zpgoto -x 670 -y 305
place .lowlevel.vzpgoto -x 780 -y 307
button .lowlevel.zpin -bg gray50 -text "Set IN to current" -width 20 -command "zaberConfigurePos pickoff in "
place .lowlevel.zpin -x 670 -y 350
button .lowlevel.zpout -bg gray50 -text "Set OUT to current" -width 20 -command "zaberConfigurePos pickoff out"
place .lowlevel.zpout -x 670 -y 392
button .lowlevel.pksave -text Save -bg gray70 -width 6 -command "nessisave pickoff"
button .lowlevel.pkload -text Load -bg gray70 -width 6 -command "nessiload pickoff"
place .lowlevel.pksave -x 668  -y 430
place .lowlevel.pkload -x 768 -y 430


label .lowlevel.focus -text "FOCUS" -bg white
place .lowlevel.focus -x 735 -y 506
button .lowlevel.zfgoto -bg gray50 -text "Move to" -width 8 -command "zaberEngpos focus"
entry .lowlevel.vzfgoto -bg white -textvariable ZABERS(focus,target) -width 10
place .lowlevel.zfgoto -x 670 -y 535
place .lowlevel.vzfgoto -x 780 -y 537
button .lowlevel.zfin -bg gray50 -text "Set EXTEND to current" -width 20 -command "zaberConfigurePos focus extend "
place .lowlevel.zfin -x 670 -y 580
button .lowlevel.zfout -bg gray50 -text "Set STOW to current" -width 20 -command "zaberConfigurePos focus stow"
place .lowlevel.zfout -x 670 -y 622
button .lowlevel.fksave -text Save -bg gray70 -width 6 -command "nessisave focus"
button .lowlevel.fkload -text Load -bg gray70 -width 6 -command "nessiload focus"
place .lowlevel.fksave -x 668  -y 660
place .lowlevel.fkload -x 768 -y 660


label .lowlevel.rpico -text "Pico position" -bg gray50
place .lowlevel.rpico -x 20 -y 565
button .lowlevel.rpicomm -width 3 -text "<<" -command "jogPico X --" -bg gray50
button .lowlevel.rpicom  -width 3 -text "<" -command "jogPico X -" -bg gray50
button .lowlevel.rpicop  -width 3 -text ">" -command "jogPico X +" -bg gray50
button .lowlevel.rpicopp  -width 3 -text ">>" -command "jogPico X ++" -bg gray50
place .lowlevel.rpicomm -x 120 -y 565
place .lowlevel.rpicom -x 200 -y 565
place .lowlevel.rpicop -x 350 -y 565
place .lowlevel.rpicopp -x 430 -y 565

button .lowlevel.rvpicomm -width 3 -text "--" -command "jogPico Y --" -bg gray50
button .lowlevel.rvpicom  -width 3 -text "-" -command "jogPico Y -" -bg gray50
button .lowlevel.rvpicop  -width 3 -text "+" -command "jogPico Y +" -bg gray50
button .lowlevel.rvpicopp  -width 3 -text "++" -command "jogPico Y ++" -bg gray50
place .lowlevel.rvpicomm -x 278 -y 625
place .lowlevel.rvpicom -x 278 -y 585
place .lowlevel.rvpicop -x 278 -y 545
place .lowlevel.rvpicopp -x 278 -y 505

button .lowlevel.psave -text Save -bg gray70 -width 12 -command "savePicosConfig"
button .lowlevel.pload -text Load -bg gray70 -width 12 -command "loadPicosConfig"
place .lowlevel.psave -x 420  -y 660
place .lowlevel.pload -x 60 -y 660

entry .lowlevel.vxpico -width 8 -bg white -textvariable PICOS(X,current)
place .lowlevel.vxpico -x 510 -y 570
entry .lowlevel.vypico -width 8 -bg white -textvariable PICOS(Y,current)
place .lowlevel.vypico -x 272 -y 665

button .lowlevel.movein -text "Move to IN" -bg gray70 -width 12 -command "picosInPosition"
button .lowlevel.moveout -text "Move to OUT" -bg gray70 -width 12 -command "picosInitialize"
place .lowlevel.movein -x 2  -y 620
place .lowlevel.moveout -x 130  -y 620


button .lowlevel.usein -text "IN = Current" -bg gray70 -width 12 -command "picoUseCurrentPos in"
button .lowlevel.useout -text "OUT = Current" -bg gray70 -width 12 -command "picoUseCurrentPos out"
place .lowlevel.usein -x 360  -y 620
place .lowlevel.useout -x 490  -y 620
showstatus "Initializing PICOs"
source $NESSI_DIR/picomotor/picomotor.tcl

if { 0 } {
showstatus "Connecting to Gemini Telemetry service"
source $NESSI_DIR/wiyn-scripts/gemini_telemetry.tcl

set GEMINITLM(sim) 0
if { [info exists env(NESSI_SIM)] } {
   set simdev [split $env(NESSI_SIM) ,]
   if { [lsearch $simdev geminitlm] > -1 } {
       set GEMINITLM(sim) 1
       debuglog "Gemini telemetry in SIMULATION mode"
       simGeminiTelemetry
  }
} else {
  geminiConnect north
}
}


}



