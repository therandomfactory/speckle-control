#
#  This file contains support for observation scripting.
#  The "Execution Engine" allows a limited set of telescope
#  and guider related commands. Scripts may be loaded at
#  runtime by the observer. Facilities to run, pause, 
#  and single-step are provided.
#

proc observingEngine { op {sname ""} } {
global SPECKLE_EEDIR SPECKLE_EECMDS SPECKLE_EEFILE  SPECKLE_EEINDEX SPECKLE_EE
   set result 0
   switch $op {
           load {
                  if { $sname == "" } {
                  set fsel [tk_getOpenFile -initialdir $SPECKLE_EEDIR -filetypes {{{Observing-scripts} {.obs}}}]
                  } else {
                     set fsel $sname
                  }
                  if { [file exists $fsel] } {
                     set SPECKLE_EEFILE $fsel
                     set SPECKLE_EE idle
                     set SPECKLE_EECMDS [split [exec cat $SPECKLE_EEFILE] \n]
                     set SPECKLE_EEINDEX 0
                     set result [obsEngValidate $SPECKLE_EECMDS]
                     if { $result } {
                        obsEngControls show
                     }
                   }
                }
            cancel {
                     obsEngControls hide
                     set SPECKLE_EE halt
                     set SPECKLE_EECMDS ""
                     set SPECKLE_EEFILE ""
                }
            pause {
                    set SPECKLE_EE pause
                    obsEngControls pause
                 }
            resume - 
            run {
                   set SPECKLE_EE running
                   obsEngControls resume
                   obsEngRun
                }
            step {
                   set SPECKLE_EE step
                   obsEngControls resume
                   obsEngRun
                 }
   }
   return $result
}

proc obsEngRun { } {
global SPECKLE_EE SPECKLE_EECMDS SPECKLE_EEINDEX SPECKLE_EECUR
  set curcmd [obsEngNext]
  if { $curcmd == -1 } {
       set SPECKLE_EE idle
       set SPECKLE_EEINDEX 0
       obsEngControls show
       .main.obsengcurcmd configure -text "Executing : Finished - click \"Run Script\" again to repeat" -fg NavyBlue
       .main.observe      configure -relief raised -fg black
       return
  }
  .main.obsengcurcmd configure -text "Executing : $curcmd" -fg NavyBlue
  set nxtcmd [obsEngNext 1]
  if { $nxtcmd == -1 } {
    .main.obsengnxtcmd configure -text "Next command : None" -fg white
  } else {
    .main.obsengnxtcmd configure -text "Next command : $nxtcmd" -fg yellow
    incr SPECKLE_EEINDEX -1
  }
  set SPECKLE_EECUR $curcmd
  update
  obsEngExecute
}

proc obsEngExecute { } {
global SPECKLE_EE SPECKLE_EECMDS SPECKLE_EEINDEX SPECKLE_EECUR
  puts stdout "Executing : $SPECKLE_EECUR"
  obsEngControls resume
# do the command here
  catch {eval $SPECKLE_EECUR} result
  update
  obsEngCheck $result
  if { $SPECKLE_EE == "pause" } {
     .main.obsengcurcmd configure -text "Executing : ----Paused----"
  }
  if { $SPECKLE_EE == "running" } {after 10 obsEngRun}
  if { $SPECKLE_EE == "step" } {
     .main.obsengcurcmd configure -text "Executing : " -fg white
      obsEngControls pause
      set SPECKLE_EE idle
  }
}


proc obsEngCheck { result } {
global SPECKLE_EE SPECKLE_EECMDS SPECKLE_EEINDEX SPECKLE_EECUR
# nothing yet, parse results here and pause scripts if necessary
}

proc obsEngNext { {lookahead 0} } {
global SPECKLE_EEINDEX SPECKLE_EECMDS SPECKLE_EEDURATION
  if { $SPECKLE_EEINDEX > [llength $SPECKLE_EECMDS] } {return -1}
  set gotnext 0
  while { $gotnext == 0 } {
    set nxtcmd [lindex $SPECKLE_EECMDS $SPECKLE_EEINDEX]
    if { [lindex $nxtcmd 0] == "durationEstimate" && $lookahead == 0} {
       set nothanks [obsEngDuration [lindex $nxtcmd 1]]
       if { $nothanks } {obsEngControls show; return -1}
    } else {
      if { [string trim $nxtcmd] != "" } {
        if { [string range $nxtcmd 0 0] != "#" } {
          set gotnext 1
          incr SPECKLE_EEINDEX 1
        }
      }
    }
    if { $gotnext == 0 } {incr SPECKLE_EEINDEX 1}
    if { $SPECKLE_EEINDEX > [llength $SPECKLE_EECMDS] } {
       return -1
    }
  }
  return $nxtcmd
}

proc obsEngDuration { t } {
   set SPECKLE_EEDURATION $t
   set it [ tk_dialog .d "Estimated duration" "This sequence is expected\nto take $t seconds\nProceed ?" {} -1 Yes No]
   return $it
}



proc obsEngControls { op } {
global SPECKLE_EEDIR SPECKLE_EEFILE
  if { $op == "show" } {
     wm title . "Monsoon Camera Control - Script loaded"
     .main.obsengname configure -text "Observing script : $SPECKLE_EEFILE" -fg NavyBlue
     .main.observe configure -text "Run\nScript" -command "observingEngine run"
     place .main.obsengpause  -x 280
     place .main.obsengresume  -x 343
     place .main.obsengsingle  -x 406
     .main.obsengpause configure -relief sunken -fg LightGray
     .main.obsengresume configure -relief sunken -fg LightGray
     .main.obsengsingle configure -relief raised -fg black
     .main.obsengcurcmd configure -text "Executing : Loaded - click \"Run Script\" to start" -fg NavyBlue
     .main.observe      configure -relief raised -fg black
  }
  if { $op == "hide" } {
     wm title . "Monsoon Camera Control"
     .main.obsengname configure  -text "Observing script : None" -fg white -bg gray
     .main.observe configure -text "Observe" -command startsequence
     place .main.obsengpause  -x -1000
     place .main.obsengresume  -x -1000
     place .main.obsengsingle  -x -1000
     .main.obsengcurcmd configure -text ""
     .main.obsengnxtcmd configure -text ""
 }
 if { $op == "pause" } {
     .main.obsengcurcmd configure -fg yellow
     .main.obsengnxtcmd configure -fg yellow
     .main.obsengpause configure -relief sunken -fg LightGray
     .main.obsengresume configure -relief raised -fg black
     .main.obsengsingle configure -relief raised -fg black
     .main.observe configure -text "Observe" -command startsequence -relief raised -fg black
 }
 if { $op == "resume" } {
     .main.obsengcurcmd configure -fg NavyBlue
     .main.obsengnxtcmd configure -fg yellow
     .main.obsengpause configure -relief raised -fg black
     .main.obsengresume configure -relief sunken -fg LightGray
     .main.obsengsingle configure -relief sunken -fg LightGray
     .main.observe      configure -relief sunken -fg LightGray
     .main.observe configure -text "Run\nScript" -command "observingEngine run"
 }
}



proc obsEngValidate { obscmds } {
global CLI_SCRIPTCMDS DEBUG
   set valid 1
   set reason ""
   foreach cmd $obscmds {
     if { [string trim $cmd] != "" } {
        if { [string range $cmd 0 0] != "#" } {
            if {$DEBUG} {puts stdout "obsEngValidate Syntax check $cmd"}
            set chk [string trim $cmd]
            if { [lsearch $CLI_SCRIPTCMDS [lindex $chk 0]] < 0 } {
               set valid 0
               set reason "${reason}Invalid command - [lindex $chk 0]\n"
            }
        }
     }
   }
   if { $valid == 0 } {
       set it [tk_dialog .d "Syntax error" "Bad .obs file\n$reason" {} -1 "OK"]
   }
   return $valid
}


proc wiyncmd { cmd } {
  debuglog "Sending $cmd"
  wiyn tcs "$cmd"
}


proc ffLamps { bank op {bright 0} } {
  set bn $bank
  if { [string range $bank 0 1] == "lo" } {set bn 1}
  if { [string range $bank 0 1] == "hi" } {set bn 2}
  switch $op {
            on  { wiyncmd "oss flatfield$bn power on" }
            off { wiyncmd "oss flatfield$bn power off" }
            set { wiyncmd "oss flatfield$bn brightness set $bright" }
  }
}


proc waitforFocus { target timeleft } {
  while { $timeleft > 0 } {
    set posa [lindex [wiyn info oss.secondary.posa] 0]
    set posb [lindex [wiyn info oss.secondary.posb] 0]
    set posc [lindex [wiyn info oss.secondary.posc] 0]
    set current -99990.
    catch {set  current [expr  ($posa+$posc)/2.0/8.0 ]}
    if { [expr abs($target-$current)] < 10 } {
       return 0
    }
    after 1000
    incr timeleft -1
    update
  }
}

proc getFocus { } {
    set posa [lindex [wiyn info oss.secondary.posa] 0]
    set posb [lindex [wiyn info oss.secondary.posb] 0]
    set posc [lindex [wiyn info oss.secondary.posc] 0]
    set current -99990.
    catch {set  current [expr  ($posa+$posc)/2.0/8.0 ]}
    return $current
}


proc finalsetFocus { newf } {
   set cur [getFocus]
   if { [expr abs($cur-$newf)] > 1000 } {
      puts stdout "Max focus adjust is 1000"
      return
   } else {
      set delta [expr int($newf-$cur)]
      wiyncmd "oss secondary focus_matrix set 1,3,$delta"
      waitforFocus $newf 30
   }
}

proc setFocus { newf } {
   set cur [getFocus]
   if { [expr abs($cur-$newf)] > 1000 } {
      puts stdout "Max focus adjust is 1000"
      return
   } else {
      set delta [expr int($newf-$cur)]
      adjustFocus $delta
      waitforFocus $newf 30
   }
}


proc adjustFocus { distance } {
 
# some constants
#       scale value to convert to secondary stesp
        set scale 1
 
        wiyncmd "oss secondary stepper power on"
        wiyncmd "oss secondary lvdt power on"
 
puts stdout "Moving secondary $distance microns"
 
        set steps [expr $distance*$scale]
        wiyncmd "oss secondary focus adjust $steps"
 
# calculate secondary tilt to restore it to true
#       set tilt [expr $steps*-3/100]
# changed 3/2000  cc
#       set tilt [expr $steps*-28/100]
 
#       wiyncmd "oss secondary position adjust 2, $tilt"
 
# turn stepper and lvdt power off
#       wiyncmd "oss secondary lvdt power off"
}
 
proc focusFrame { param value } {
   switch $param {
          Focus_First -
          Focus_Last  -
          Focus_Shift -
          expVector   { setAVP $param $value }
   }
}



.mbar.file.m add command -label "Load Observing script" -command "observingEngine load"
.mbar.file.m add command -label "Unload current script" -command "observingEngine cancel"
label .main.obsengname  -text "Observing script : None" -fg white -bg gray
place .main.obsengname -x 20 -y 270
label .main.obsengcurcmd  -text "Executing : None" -fg white -bg gray
place .main.obsengcurcmd -x 20 -y 290
label .main.obsengnxtcmd  -text "Next command : None" -fg white -bg gray
place .main.obsengnxtcmd -x 20 -y 310

button .main.obsengpause -width 5 -height 2 -text "Pause\nScript" -relief sunken -bg gray -command "observingEngine pause"
place .main.obsengpause  -x 280 -y 170
.main.obsengpause configure -relief sunken -fg LightGray
button .main.obsengresume -width 5 -height 2 -text "Resume\nScript" -relief sunken -bg gray -command "observingEngine resume"
place .main.obsengresume  -x 343 -y 170
.main.obsengresume configure -relief sunken -fg LightGray
button .main.obsengsingle -width 5 -height 2 -text "Step\nScript" -relief sunken -bg gray -command "observingEngine step"
place .main.obsengsingle  -x 406 -y 170
.main.obsengsingle configure -relief sunken -fg LightGray
#.main configure -height 340

set CLI_SCRIPTCMDS "durationEstimate observe newTarget offsetScope autoGstar guideprobe waitFor setFilter hdrComment informUser ffLamps setFocus focusFrame"

# Default location for observing scripts
set SPECKLE_EEDIR $env(SPECKLE_EEDIR)
set SPECKLE_EE halt
set SPECKLE_EECMDS ""
set SPECKLE_EEDURATION unknown

source $SPECKLE_DIR/focusSequence.tcl




