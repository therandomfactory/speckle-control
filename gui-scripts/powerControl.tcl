## \file powercontrol.tcl
# \brief This contains the code to control the WTI power strip
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2021 The Random Factory (www.randomfactory.com) \n
#\n
#
#  This code switches WTI power strip ports on/off
#
#\code
## Documented proc \c powerPortSwitch .
# \param[in] port  (1,2,3,4)
# \param[in] state (on/off)
#
#  Globals    :
#		POWER - Array of power strip configuration parameters
#               SCOPE - Array of telescope parameters
#		SIMPOWER - 1 if we are simulation power strip control
#	
proc powerPortSwitch { port state } {
global POWER SIMPOWER env
  set user [string tolower $env(INSTRUMENT)]
  set pw speckle
  set ip $POWER($user,ip)
  debuglog "Power cycling plug $port : new state = $state"
  if  { $SIMPOWER == 0 } {
    exec wget http://$ip/api/v2/config/powerplug --user=$user --password=$pw --post-data='\{"plug":$port, "state": "$state"\}'
  }
}

## Documented proc \c powerCycleHardware .
# \param[in] what (filterWheels, cameras, all)
#
#  Globals    :
#		POWER - Array of power strip configuration parameters
#
proc powerCycleHardware { what } {
global POWER
  switch $what {
         all     { powerCycleHardware cameras ; powerCycleHardware filterWheels } 
         cameras {
                    powerPortSwitch $POWER(blueCamera) off
                    powerPortSwitch $POWER(redCamera) off
                    after 2000
                    powerPortSwitch $POWER(blueCamera) on
                    powerPortSwitch $POWER(redCamera) on
                    after 2000
                 }
         filterWheels {
                    powerPortSwitch $POWER(filterWheels) off
                    after 2000
                    powerPortSwitch $POWER(filterWheels) on
                    after 10000
                 }
  }
}

set SIMPOWER 0
if { [info exists env(SPECKLE_SIM)] } {
  set simdev [split $env(SPECKLE_SIM) ,]
  if { [lsearch $simdev power] > -1 } {
    set SIMPOWER 1
    proc debuglog { msg } { puts stdout $msg } 
  }
}

source $env(SPECKLE_DIR)/powerSwitchConfiguration
if { $argv == "cleanRestart" } {
   puts stdout "Clean restart in progress"
   powerCycleHardware all
}






