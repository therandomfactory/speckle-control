



#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : get_temp
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure retrieves the current ccd temperature, it is included so that
#  future versions can transparently support other makes of camera.
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc get_temp { {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
global CAMERAS
   set t -99
   set t [$CAMERAS($id) read_Temperature]
   return $t
}





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : setpoint
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure controls the operation of the cooling circuit. 
#  The cooler can be swithed off, ramped to ambient, or ramped to 
#  a required target temperature.
#
#  Arguments  :
#
#               op	-	Operation specifier
#               t	-	Temperature (degrees c) (optional, default is 10.0)
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc setpoint { op {t 10.0} {id 0} } {
 
#
#  Globals    :
#  
#               CCD_TMP	-	 
#               SETPOINTS	-	Cooler setpoints
#               CAMERAS	-	Camera id's
global CCD_TMP SETPOINTS CAMERAS ALTA CONFIG
    set op [string toupper $op]
    set camera $CAMERAS($id)
    if { $ALTA } {
       set cooler SetCooler
    } else {
       set cooler write_CoolerMode
    }
    switch $op {
       SET { 
             $camera $cooler 1 
             $camera SetCoolerSetPoint $t
             set  CONFIG(temperature.Target) $t
           }
       AMB { if { $ALTA } {
#                $camera $cooler 0
                set hst [$camera GetTempHeatsink]
                set tamb [expr $hst-15.0]
                if { $tamb < 20.0 } {set tamb 20.0}
                if { $tamb > 30.0 } {set tamb 30.0}
		$camera SetCoolerSetPoint $tamb
                $camera $cooler 1
                set t $tamb
                waitforwarmup $tamb
             } else {
                $camera $cooler 2
             } 
           }
       OFF { $camera $cooler 0
           }
       ON  { 
#             $camera $cooler 0
             $camera $cooler 1
             $camera SetCoolerSetPoint $SETPOINTS
             set t $SETPOINTS
           }
    }
    if { $op == "SET" || $op == "ON" || $op == "AMB" } {
       set SETPOINTS $t
    } else {
       set SETPOINTS $CONFIG(temperature.Target)
    }
}
   
proc waitforwarmup { t {n 200} {id 0} } {
global CAMERAS DEBUG
  set now [get_temp]
  if { [expr abs($t-$now)] < 0.5 || $n == 0} {
    set camera $CAMERAS($id)
    $camera SetCooler 0
    if { $DEBUG } {debuglog "Warmed up - cooler off - ramp to ambient"}
  } else {
    if { $DEBUG } {debuglog "Warming up to $t"}
    after 10000 waitforwarmup $t [expr $n-1]
  }
}

     


proc getpoint { { id 0 } } {
global CAMERAS
    set camera $CAMERAS($id)
    set sp [$camera GetCoolerSetPoint]
    return $sp
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : monitortemp
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure monitors the ccd temperature, and periodically calls 
#  plottemp to update the graphical display. The temperature as plotted is
#  based on an average of the last 10 values, this is done because the 
#  least significant bit of the temperature ADC represents ~0.5degrees
#  and averaging produces a more representative display.
#
#  Arguments  :
#
#               id	-	Camera id (for multi-camera use) (optional, default is 0)
 
proc monitortemp { {id 0} } {
 
#
#  Globals    :
#  
#               TEMPS	-	Raw temperatures
#               AVGTEMPS	-	Average temps for plotting
#               STATUS	-	Exposure status
global TEMPS AVGTEMPS STATUS RAWTEMP CAMSTATUS ALTA NOBLT
  if { $STATUS(tempgraph) }  {
   set t [lindex [get_temp $id] 0]
   if { $t != -99 } {
    if { $RAWTEMP } {
      set AVGTEMPS $t
    } else {
     if { $TEMPS == "" } {
         set TEMPS "$t $t $t $t $t $t $t $t $t $t"
     } else {
         set TEMPS [lrange "$t $TEMPS" 0 9]
     }
     set i 0
     set temp 0
     while { $i < 10 } {set temp [expr $temp+[lindex $TEMPS $i]] ; incr i 1}
     set AVGTEMPS [expr $temp/10.0]
    }
    plottemp
   }
   set interval 5000
   after $interval monitortemp
  }
}

 



#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : plottemp
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure updates the graphical display of temperature.
#  It uses the  BLT graph widget to do all the hard work.
#
#  Arguments  :
#
 
proc plottemp { } {
 
#
#  Globals    :
#  
#               ydata	-	temp plot array - temp
#               ysetp	-	temp plot array - setpoint
#               TEMPWIDGET	-	BLT temperature graph widget name
#               AVGTEMPS	-	Average temps for plotting
#               SETPOINTS	-	Cooler setpoints
global ydata ysetp TEMPWIDGET AVGTEMPS SETPOINTS TEMPCNTR
   set ydata "[lrange [split $ydata] 1 59] $AVGTEMPS"
   if { $SETPOINTS == -50 }  {
      set ysetp "[lrange [split $ysetp] 1 59] $AVGTEMPS"
   } else {
      set ysetp "[lrange [split $ysetp] 1 59] $SETPOINTS"
   }
   setminmax
   $TEMPWIDGET plot setpoint $TEMPCNTR [lindex $ysetp end]
   $TEMPWIDGET plot ccd $TEMPCNTR [lindex $ydata end]
   incr TEMPCNTR 1
}

set TEMPCNTR 1




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : setminmax
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure resets the display parameters for the temperature
#  graphic in an attempt to autoscale it to the recent range.
#
#  Arguments  :
#
 
proc setminmax { } {
 
#
#  Globals    :
#  
#               ydata	-	temp plot array - temp
#               ysetp	-	temp plot array - setpoint
#               TEMPWIDGET	-	BLT temperature graph widget name
global ydata ysetp TEMPWIDGET
  set min  9999999
  set max -9999999 
  foreach i $ydata { 
     if { $i < $min } { set min $i } 
     if { $i > $max } { set max $i } 
  }
  foreach i $ysetp { 
     if { $i < $min } { set min $i } 
     if { $i > $max } { set max $i } 
  }
  set r [expr ($max-$min)/5.+1.]
###  $TEMPWIDGET yaxis configure -min [expr $min-$r] -max [expr $max+$r]
}






set PI 3.14159265359




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : tlabel
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure takes an input time in radians and converts it to hh:mm:ss form
#
#  Arguments  :
#
#               atime	-	Time in radians
 
proc tlabel { atime } {
 
#
#  Globals    :
#  
#               PI	-	 
global PI
    if { $atime < 0 } {
       set asign "-"
       set atime [expr -$atime]
    } else {
       set asign ""
    }
    set atime [expr $atime/$PI*12.0]
    set ahrs [expr int($atime)]
    set amins [expr int(60*($atime-$ahrs))]
    set asecs [expr int(($atime-$ahrs-$amins/60.0)*3600.0)]
    set out ""
    if { $ahrs < 10 } {
      set ahrs "0$ahrs"
    }
    if { $amins < 10 } {
      set amins "0$amins"
    }
    if { $asecs < 10 } {
      set asecs "0$asecs"
    }
    return "$asign$ahrs:$amins:$asecs"
}
                                                                                





#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : waitfortemp
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (randomfactory@gmail.com)
#  Version    : 0.9
#  Date       : Aug-01-2017
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure is used to wait until the required temperature is 
#  reached (within 1 degree). At that point it calls the routine
#  specified. It is used by the calibration library generation routines.
#
#  Arguments  :
#
#               t	-	Temperature (degrees c)
#               cmd	-	Command to execute after timed wait (optional, default is bell)
 
proc waitfortemp { t {cmd bell} } {
 
#
#  Globals    :
#  
#               AVGTEMPS	-	Average temps for plotting
#               WAITCMD	-	Command to execute after a wait
global AVGTEMPS WAITCMD 
   if { $cmd != "wait" } {set  WAITCMD "$cmd"}
   if { [expr abs($t-$AVGTEMPS)] < 1.0 } {
       eval $WAITCMD
   } else {
       after 5000 waitfortemp $t wait
   }
}







