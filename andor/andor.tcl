## \file andor.tcl
# \brief This contains procedures shared between the GUI and camera servers and which facilitate communication between them
#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2 If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2017 The Random Factory (www.randomfactory.com) 
#
#
# \mainpage Introduction
# This project provides controller software (server and GUI) for the instrument described below.\n
# It has been undertaken by "The Random Factory" (www.randomfactory.com) located in Tucson AZ.\n
#\n
# This effort is funded under NASA Grant and Cooperative agreement #NNX14AR61A\n
#\n
# Principal Investigator : Steve B. Howell, NASA Ames Research Center, Senior Research Scientist\n
#\n
# The NN-EXPLORE program provides about 50 percent of the observing time on the Kitt Peak WIYN\n
# (Wisconsin-Indiana-Yale-NOAO) 3.5-meter \n
# telescope to the exoplanet community. \n
# WIYN’s suite of instruments include HYDRA, a multi-fiber medium to high-resolution bench #spectrograph, \n
# WHIRC, a near-IR imager, ODI, an optical wide-field optical imager, and for over a decade, \n
# a visiting speckle camera #called DSSI (Horch et al. 2009). \n
#\n
# The telescope’s instruments also include several integral field units, bundles of optical fiber that \n
# feed light from the telescope to an instrument, in this case a spectrograph, that lives in an environmentally \n
# controlled room in the WIYN telescope basement. \n
#\n
# Beginning in 2017, thanks to funding support from the NASA Exoplanet program, DSSI has been replaced by a \n
# modern, more functional, community available observatory instrument named NESSI.\n
#\n
# NESSI, the NN-EXPLORE Exoplanet & Stellar Speckle Imager, was commissioned during the fall of 2016 \n
# and is now available for community #use. Speckle imaging allows telescopes to achieve diffraction limited\n
# imaging performance—that is, collecting images with resolutions equal to that which would be possible if the atmosphere were removed.\n 
# The technique employs digital cameras capable of reading out frames at a very fast rate, effectively “freezing out” \n
# atmospheric seeing. The resulting speckles are correlated and combined in Fourier space to produce reconstructed \n
# images with resolutions at the diffraction limit of the telescope (see Howell et al., 2011). \n
# Achievable spatial resolutions at WIYN are 39 milliarcseconds (550 nanometers) and 64 milliarcseconds (880 nanometers).\n
#

#\code
## Documented proc \c initCameraConfig .
# \param[in] id Camera Id reference for Andor Library calls
#
# Globals : 
#		ANDOR_CFG - Array of camera configuration items
#
# This function initializes all the items of the ANDOR_CFG global array to a default value
# of ? to ensure that we can easily see when they are assigned actual values via the Andor library
# wrapped calls.
#
proc initCameraConfig { id } {
global ANDOR_CFG
  foreach c "exposure_time temperature cam_frames_per_second missed_frames__second usb_frames_per_second preamp_gain vertical_speed horizontal_speeds hbin vbin hstart hend vstart vend read_mode acquisition_mode width height shutter amplifier npixx npixy minimum_temperature maximum_temperature target_temperature temperature_status running usb_running camlink_running num_preamp_gains preamp_gain_index em_advanced minimum_em_gain maximum_em_gain em_gain num_vertical_speeds vertical_speed_index num_horizontal_speeds horizontal_speed_index"  {
    set ANDOR_CFG($id,$c) "?"
  }
}


## Documented proc \c printCapabilities .
# \param[in] fid Open file id to output to
#
# Globals : 
#		ANDOR_CFG - Array of camera configuration items
#
proc printCapabilities { fid } {
global ANDOR_CAP
set ANDOR_CAP [AndorCapabilities]
  set s [GetCapabilities $ANDOR_CAP]
  foreach c "ulSize ulAcqModes  ulReadModes ulTriggerModes ulCameraType ulPixelMode ulSetFunctions ulGetFunctions  ulFeatures ulPCICard ulEMGainCapability  ulFTReadModes" {
      puts $fid "$c	= [AndorCapabilities_[set c]_get $ANDOR_CAP]"
  }
}

## Documented proc \c printCameraConfig .
# \param[in] id Camera Id reference for Andor Library calls
# \param[in] fid Open file id to output to
#
# Globals : 
#		ANDOR_CFG - Array of camera configuration items
#
proc printCameraConfig { fid id } {
global ANDOR_CFG
  foreach c "exposure_time temperature cam_frames_per_second missed_frames__second usb_frames_per_second preamp_gain vertical_speed horizontal_speeds hbin vbin hstart hend vstart vend read_mode acquisition_mode width height shutter amplifier npixx npixy minimum_temperature maximum_temperature target_temperature temperature_status running usb_running camlink_running num_preamp_gains preamp_gain_index em_advanced minimum_em_gain maximum_em_gain em_gain num_vertical_speeds vertical_speed_index num_horizontal_speeds horizontal_speed_index"  {
      puts $fid "$c	= $ANDOR_CFG($id,$c)"
  }
}

## Documented proc \c initds9 .
# \param[in] shmid Shared memory address
# \param[in] width Width of image
# \param[in] height Height of image
#
# Globals : 
#		SPECKLE_DIR - Directory path to speckle software installation
#
proc initds9 { shmid width height } {
global SPECKLE_DIR
  debuglog "Configuring ds9"
  exec xpaset -p ds9 source $SPECKLE_DIR/andor/ds9refresher.tcl
  exec xpaset -p ds9 shm array shmid $shmid \\\[xdim=$width,ydim=$height,bitpix=32\\\]
}

## Documented proc \c refreshds9 .
# \param[in] delta Period between refreshes
# \param[in] count Number of refreshes
#
#  This function uses XPA to start a refresh cycle in ds9
#
proc refreshds9 { delta count } {
  exec xpaset -p ds9 tcl \{refinit $delta $count\}
  exec xpaset -p ds9 tcl refresher
}

## Documented proc \c initads9 .
# \param[in] shmid Shared memory address
# \param[in] width Width of image
# \param[in] height Height of image
#
# Globals :\n
#		SPECKLE_DIR - Directory path to speckle software installation\n
#		DS9 - Name of a ds9 executable for XPA control (ds9red or ds9blue)
#
proc initads9 { shmid width height } {
global SPECKLE_DIR DS9
  debuglog "Configuring ds9"
  exec xpaset -p $DS9 source $SPECKLE_DIR/andor/ds9refresher.tcl
  exec xpaset -p $DS9 shm array shmid $shmid \\\[xdim=$width,ydim=$height,bitpix=32\\\]
}

## Documented proc \c refreshads9 .
# \param[in] delta Period between refreshes
# \param[in] count Number of refreshes
#
#  This function uses XPA to start a refresh cycle in a ds9
#
#
#
# Globals : 
#		DS9 - Name of a ds9 executable for XPA control (ds9red or ds9blue)
#
proc refreshads9 { delta count } {
global DS9
  exec xpaset -p $DS9 tcl \{refinit $delta $count\}
  exec xpaset -p $DS9 tcl refresher
}


## Documented proc \c connectToAndors .
#
# Connect to the 2 Andor camera server processes using sockets (2001 and 2002)
#
#
# Globals :\n 
#		ANDOR_SOCKET - Array of (2) socket file handles\n
#		INSTRUMENT - Array of instrument settings
#
proc connectToAndors { } {
global ANDOR_SOCKET INSTRUMENT
   set ANDOR_SOCKET(red) 0
   set ANDOR_SOCKET(blue) 0
   catch {
     set s2001 [socket localhost 2001]
     fconfigure $s2001 -buffering line
     puts $s2001 "whicharm"
     gets $s2001 rec
     debuglog "Server at socket 2001 is $rec arm"
     set INSTRUMENT($rec) 1
   }
   catch {
     set ANDOR_SOCKET($rec) $s2001
     set s2002 [socket localhost 2002]
     fconfigure $s2002 -buffering line
     puts $s2002 "whicharm"
     gets $s2002 rec
     debuglog "Server at socket 2002 is $rec arm"
     set ANDOR_SOCKET($rec) $s2002
     set INSTRUMENT($rec) 1
   }
   if { $ANDOR_SOCKET(red) == 0 } {
      debuglog "No connecton to Red arm camera"
   }
   if { $ANDOR_SOCKET(blue) == 0 } {
      debuglog "No connecton to Blue arm camera"
   }
}

## Documented proc \c commandAndor .
# \param[in] arm Name of intrument arm red/blue
# \param[in] cmd Command and parameters
# \param[in] echk Optional existence check for "grab" command
#
#  Send a command to an Andor camera server via socket
#
#
# Globals :\n
#		ANDOR_SOCKET - Array of (2) socket file handles\n
#		SCOPE - Array of telescope settings
#
proc commandAndor { arm cmd {echk 1} } {
global ANDOR_SOCKET SCOPE
   if { $ANDOR_SOCKET($arm) == 0 } {
     debuglog "WARNING : $arm arm camera not connected"
     return 0
   } else {
     if { [string range $cmd 0 3] == "grab" } {
        if { $echk } {
           set nrchk "$SCOPE(datadir)/$SCOPE(imagename)[set SCOPE(seqnum)]r.fits"
           if { [file exists $nrchk] } {
              set it [ tk_dialog .d "File exists" "The file named\n $nrchk\n already exists" {} -1 OK]
              debuglog "Cannot overwrite file $nrchk"
              return 0
            }
           set nbchk "$SCOPE(datadir)/$SCOPE(imagename)[set SCOPE(seqnum)]b.fits"
           if { [file exists $nbchk] } {
              set it [ tk_dialog .d "File exists" "The file named\n $nbchk\n already exists" {} -1 OK]
              debuglog "Cannot overwrite file $nbchk"
              return 0
            }
        }
     }
     debuglog "Commanding Andor $arm : $cmd"
     puts $ANDOR_SOCKET($arm) $cmd
     gets $ANDOR_SOCKET($arm) result
   }
   return $result
} 

## Documented proc \c commandAndor .
# Flush the Andor communication sockets
#
#
# Globals : 
#		ANDOR_SOCKET - Array of (2) socket file handles
#
proc flushAndors { } {
global ANDOR_SOCKET
   if { $ANDOR_SOCKET(red) > 0 } {
      while { [gets $ANDOR_SOCKET(red) result] > -1 } {set x 1}
   }
   if { $ANDOR_SOCKET(blue) > 0 } {
      while { [gets $ANDOR_SOCKET(blue) result] > -1 } {set x 1}
   }
}


## Documented proc \c commandCameras .
# \param[in] cmd Command and parameters
# \param[in] echk Optional existence check for "grab" command
#
# Send command to both cameras if clone setting is selected
#
#
# Globals : 
#		INSTRUMENT - Array of instrument settings
#
proc commandCameras { cmd {echk 1} } {
global INSTRUMENT
   commandAndor red $cmd $echk
   if { $INSTRUMENT(clone) } {
      commandAndor blue $cmd $echk
   }
}


## Documented proc \c videomode .
#
#  Process (slow) frame by frame video mode
#
#
# Globals : \n
#		LASTACQ - Type of last acquisition fulframe/roi\n
#		SCOPE - Array of telescope settings\n
#		STATUS - Array of exposure statuses\n
#		ACQREGION - ROI properties xs,xe,ys,ye
#
proc videomode { } {
global LASTACQ STATUS SCOPE ACQREGION INSTRUMENT
   set ANDOR_CFG(videomode) 1
   commandAndor red "imagename videomode 1"
   commandAndor blue "imagename videomode 1"
   exec rm -f $SCOPE(datadir)/videomode_red.fits
   exec rm -f $SCOPE(datadir)/videomode_blue.fits
   set redtemp  [lindex [commandAndor red gettemp] 0]
   set bluetemp  [lindex [commandAndor blue gettemp] 0]
   commandAndor red "autofitds9 $INSTRUMENT(red,fitds9)"
   commandAndor blue "autofitds9 $INSTRUMENT(blue,fitds9)"
   mimicMode red temp "[format %5.1f [lindex $redtemp 0]] degC"
   mimicMode blue temp "[format %5.1f [lindex $bluetemp 0]] degC"
   .main.rcamtemp configure -text "[format %5.1f [lindex $redtemp 0]] degC"
   .main.bcamtemp configure -text "[format %5.1f [lindex $bluetemp 0]] degC"
   if { $LASTACQ == "fullframe" } {
      commandAndor red "grabframe $SCOPE(exposure)"
      commandAndor blue "grabframe $SCOPE(exposure)"
   } else {
      commandAndor red "grabroi $SCOPE(exposure) $ACQREGION(rxs) $ACQREGION(rys) $ACQREGION(geom)"
      commandAndor blue "grabroi $SCOPE(exposure) $ACQREGION(bxs) $ACQREGION(bys) $ACQREGION(geom)"
   }
   if { $STATUS(abort) == 0 } {
      if { $SCOPE(exposure) > 0.0 } {
          mimicMode red open
          mimicMode blue open
      }
      .main.video configure -relief sunken -fg yellow
      .main.observe configure -fg LightGray -relief sunken -command ""
      .main.abort configure -fg black -relief raised
      after [expr int($SCOPE(exposure)*1000)+100] videomode
   } else {
      .main.video configure -relief raised -fg black
      .main.observe configure -fg black -relief raised -command startsequence
      .main.abort configure -fg gray -relief sunken
      set ANDOR_CFG(videomode) 0
   }
}
  

## Documented proc \c startfastvideo .
#
#  Initiate fast video mode
# Globals : 
#		STATUS - Array of exposure statuses
#
proc startfastvideo { } {
global STATUS ANDOR_CFG
   set STATUS(abort) 0
   set ANDOR_CFG(waskinetic) $ANDOR_CFG(kineticMode)
   set ANDOR_CFG(kineticMode) 1
   setKineticMode
   .lowlevel.datarate configure -text ""
#   andorset vspeed red VSSpeed 0
#   andorset emhs red EMHSSpeed 0
#   andorset vspeed blue VSSpeed 0
#   andorset emhs blue EMHSSpeed 0
   speckleshutter red open
   speckleshutter blue open
   fastvideomode
}

## Documented proc \c fastvideomode .
#
#  Fast video mode processing
#
#
# Globals :\n
#		SCOPE - Array of telescope settings\n
#		STATUS - Array of exposure statuses\n
#		ACQREGION - ROI properties xs,xe,ys,ye\n
#		CAMSTATUS - Array of camera current settings retrieved from Andor servers\n
#		ANDOR_CFG - Andor camera properties
#
proc fastvideomode { } {
global STATUS SCOPE ACQREGION CAMSTATUS ANDOR_CFG INSTRUMENT
global ANDOR_CCD ANDOR_EMCCD
#   commandAndor red "imagename videomode 1" 0
#   commandAndor blue "imagename videomode 1" 0
#   exec rm -f $SCOPE(datadir)/videomode_red.fits
#   exec rm -f $SCOPE(datadir)/videomode_blue.fits
   if { $STATUS(abort) == 0 } {
     set redtemp  [lindex [commandAndor red gettemp] 0]
     set bluetemp  [lindex [commandAndor blue gettemp] 0]
     mimicMode red temp "[format %5.1f [lindex $redtemp 0]] degC"
     mimicMode blue temp "[format %5.1f [lindex $bluetemp 0]] degC"
     .main.rcamtemp configure -text "[format %5.1f [lindex $redtemp 0]] degC"
     .main.bcamtemp configure -text "[format %5.1f [lindex $bluetemp 0]] degC"
     set perrun [expr int(100 / ($CAMSTATUS(blue,TKinetics) / $SCOPE(exposure)))]
     if { $perrun > 100 } {set perrun 100}
     if { $perrun < 20 } {set perrun 20}
     commandAndor red "numberkinetics $perrun"
     commandAndor blue "numberkinetics $perrun"
     commandAndor red  "numberaccumulations $SCOPE(numaccum)"
     commandAndor blue "numberaccumulations $SCOPE(numaccum)"
     commandAndor red  "vsspeed $ANDOR_CFG(red,VSSpeed)"
     commandAndor blue "vsspeed $ANDOR_CFG(blue,VSSpeed)"
     commandAndor red  "preampgain $CAMSTATUS(red,PreAmpGain)"
     commandAndor blue "preampgain $CAMSTATUS(blue,PreAmpGain)"
     if { $INSTRUMENT(red,emccd) } {
       commandAndor red "outputamp $ANDOR_EMCCD"
       commandAndor red "emadvanced $INSTRUMENT(red,highgain)"
       commandAndor red "emccdgain $INSTRUMENT(red,emgain)"
       commandAndor red "hsspeed 0 $ANDOR_CFG(red,EMHSSpeed)"
     } else {
       commandAndor red "outputamp $ANDOR_CCD"
       commandAndor red "hsspeed 1 $ANDOR_CFG(red,HSSpeed)"
     }
     if { $INSTRUMENT(blue,emccd) } {
       commandAndor blue "outputamp $ANDOR_EMCCD"
       commandAndor blue "emadvanced $INSTRUMENT(blue,highgain)"
       commandAndor blue "emccdgain $INSTRUMENT(blue,emgain)"
       commandAndor blue "hsspeed 0 $ANDOR_CFG(blue,EMHSSpeed)"
     } else {
       commandAndor blue "outputamp $ANDOR_CCD"
       commandAndor blue "hsspeed 1 $ANDOR_CFG(blue,HSSpeed)"
     }
     commandAndor red "fastVideo $SCOPE(exposure) $ACQREGION(rxs) $ACQREGION(rys) [expr $ACQREGION(geom)/$ANDOR_CFG(binning)] $perrun"
     commandAndor blue "fastVideo $SCOPE(exposure) $ACQREGION(bxs) $ACQREGION(bys) [expr $ACQREGION(geom)/$ANDOR_CFG(binning)]  $perrun"
      if { $SCOPE(exposure) > 0.0 } {
          mimicMode red open
          mimicMode blue open
      }
      .main.video configure -relief sunken -fg yellow
      .main.observe configure -fg LightGray -relief sunken -command ""
      .main.abort configure -fg black -relief raised
      after [expr int($SCOPE(exposure)*1000)+1000] fastvideomode
   } else {
       andorSetControl 0 abort 1
      .main.video configure -relief raised -fg black
      .main.observe configure -fg black -relief raised -command startsequence
      .main.abort configure -fg gray -relief sunken
      if { $ANDOR_CFG(waskinetic) == 0 } {
        set ANDOR_CFG(kineticMode) 0
        setKineticMode
      }
      speckleshutter red during
      speckleshutter blue during
  }
}


set CAMSTATUS(blue,TKinetics) .30
set CAMSTATUS(red,TKinetics)  .30

## Documented proc \c startvideomode .
#
#  Setup (slow) frame by frame video mode
#
# Globals :\n
#		SCOPE - Array of telescope settings\n
#		STATUS - Array of exposure statuses
#
proc startvideomode { } {
global STATUS SCOPE
   set STATUS(abort) 0
   speckleshutter red open
   speckleshutter blue open
   commandAndor red "datadir $SCOPE(datadir)"
   commandAndor blue "datadir $SCOPE(datadir)"
   videomode
}


## Documented proc \c showControl .
#
#  Print contents of SharedMem2 shared memory area which is used
#  for high speed data sharing with the Andor camera servers
#
proc showControl { } {
   foreach i "0 1" {
     foreach p "min peak frame lucky luckythresh" {
        puts stdout  "Camera $i : $p = [andorGetControl $i $p]"
     }
   }
   puts stdout  "Global : showfft = [andorGetControl $i showfft]"
   puts stdout  "Global : savelucky = [andorGetControl $i savelucky]"
   puts stdout  "Global : showlucky = [andorGetControl $i showlucky]"
   puts stdout  "Global : abort = [andorGetControl $i abort]"
}


## Documented proc \c testControl .
#
#  Test setting values in the SharedMem2 shared memory area which is used
#  for high speed data sharing with the Andor camera servers
#
proc testControl { } {
   andorSetControl 0 luckythresh 99
   andorSetControl 1 luckythresh 123
   andorSetControl 0 showfft 0
   andorSetControl 0 savelucky 0
   andorSetControl 0 showlucky 0
   andorSetControl 0 abort 0
}

## Documented proc \c initControl .
#
#  Set inital default values in the SharedMem2 shared memory area which is used
#  for high speed data sharing with the Andor camera servers
#
proc initControl { } {
   andorSetControl 0 luckythresh 99
   andorSetControl 1 luckythresh 99
   andorSetControl 0 frame 0
   andorSetControl 1 frame 0
   andorSetControl 0 showfft 0
   andorSetControl 0 savelucky 0
   andorSetControl 0 showlucky 0
   andorSetControl 0 abort 0
}


## Documented proc \c acquireCubes .
#
#  Setup and start a data acqusition run of a data cube
#
#
# Globals :\n
#		INSTRUMENT - Array of instrument settings\n
#		LASTACQ - Type of last acquisition fulframe/roi\n
#		SCOPE - Array of telescope settings\n
#		STATUS - Array of exposure statuses\n
#		ACQREGION - ROI properties xs,xe,ys,ye\n
#		ANDOR_CFG - Andor camera properties
#
proc acquireCubes { } {
global INSTRUMENT SCOPE LASTACQ ACQREGION ANDOR_CFG
   set n [expr $ACQREGION(xe) - $ACQREGION(xs) +1]
   if { $INSTRUMENT(red) } {
#      commandAndor red "setframe roi"
      commandAndor red "grabcube $SCOPE(exposure) $ACQREGION(rxs) $ACQREGION(rys) [expr $ACQREGION(geom)/$ANDOR_CFG(binning)] $SCOPE(numframes)"
      set LASTACQ roi
   }
   if { $INSTRUMENT(blue) } {
#      commandAndor blue "setframe roi"
      commandAndor blue "grabcube $SCOPE(exposure) $ACQREGION(bxs) $ACQREGION(bys) [expr $ACQREGION(geom)/$ANDOR_CFG(binning)] $SCOPE(numframes)"
      set LASTACQ roi
   }
}

## Documented proc \c acquireFrames .
#
#  Setup and start a data acqusition run of an individual frame#
#
# Globals :\n
#		INSTRUMENT - Array of instrument settings\n
#		LASTACQ - Type of last acquisition fulframe/roi\n
#		SCOPE - Array of telescope settings\n
#		STATUS - Array of exposure statuses
#
proc acquireFrames { } {
global INSTRUMENT SCOPE LASTACQ
   if { $INSTRUMENT(red) } {
      commandAndor red "setframe fullframe"
      commandAndor red "grabframe $SCOPE(exposure)"
      set LASTACQ fullframe
   }
   if { $INSTRUMENT(blue) } {
      commandAndor blue "setframe fullframe"
      commandAndor blue "grabframe $SCOPE(exposure)"
      set LASTACQ fullframe
   }
}
   
## Documented proc \c resetAndors .
#
#  Shutdown any existing Andor camera servers, and restart them - DEPRECATED
#
#
# Globals :\n
#		SPECKLE_DIR - Directory path to speckle software installation\n
#		LASTACQ - Type of last acquisition fulframe/roi\n
#		ANDOR_SOCKET - Array of (2) socket file handles\n
#		SCOPE - Array of telescope settings\n
#		ACQREGION - ROI properties xs,xe,ys,ye\n
#
proc resetAndors { mode } {
global SPECKLE_DIR ANDOR_SOCKET ACQREGION LASTACQ
   debuglog "Resetting Andors for $mode" 
   catch {commandAndor red shutdown; close $ANDOR_SOCKET(red)}
   catch {commandAndor blue shutdown; close $ANDOR_SOCKET(blue)}
   if { $mode == "fullframe" } {
     exec xterm -e "$SPECKLE_DIR/andor/andorServer.tcl 1 1 1024 1 1024" &
     after 1000
     exec xterm -e "$SPECKLE_DIR/andor/andorServer.tcl 2 1 1024 1 1024" &
     set LASTACQ fullframe
   } else {
     exec xterm -e "$SPECKLE_DIR/andor/andorServer.tcl 1 $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)" &
     exec xterm -e "$SPECKLE_DIR/andor/andorServer.tcl 2 $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)" &
     set LASTACQ roi
     set SCOPE(numframes) 1000
   }
   after 40000
   connectToAndors
   debuglog "Andor reset complete"
}


## Documented proc \c resetSingleAndors .
#
#  Shutdown any existing Andor camera servers, and restart them
#  This uses the two dedicated (per arm) ds9's for display, and is the currently
#  preferred mode of operation
#
#
# Globals :\n
#		SPECKLE_DIR - Directory path to speckle software installation\n
#		LASTACQ - Type of last acquisition fulframe/roi\n
#		ANDOR_SOCKET - Array of (2) socket file handles\n
#		ACQREGION - ROI properties xs,xe,ys,ye
#
proc resetSingleAndors { mode } {
global SPECKLE_DIR ANDOR_SOCKET ACQREGION LASTACQ env
   debuglog "Resetting Andors for $mode" 
   catch {commandAndor red shutdown; close $ANDOR_SOCKET(red)}
   catch {commandAndor blue shutdown; close $ANDOR_SOCKET(blue)}
   set geom1 "+20+800" ; set geom2 "+1100+800"
   if { $env(TELESCOPE) == "WIYN"} {
     set geom2 "+20+800" ; set geom1 "+1100+800"
   }
   if { $mode == "fullframe" } {
     exec xterm -geometry $geom1 -e "$SPECKLE_DIR/andor/andorCameraServer.tcl 1 1 1024 1 1024" &
     exec xterm -geometry $geom2 -e "$SPECKLE_DIR/andor/andorCameraServer.tcl 2 1 1024 1 1024" &
     set LASTACQ fullframe
   } else {
     exec xterm -geometry $geom1 -e "$SPECKLE_DIR/andor/andorCameraServer.tcl 1 $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)" &
     exec xterm -geometry $geom2 -e "$SPECKLE_DIR/andor/andorCameraServer.tcl 2 $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)" &
     set LASTACQ roi
     set SCOPE(numframes) 1000
   }
   after 25000
   connectToAndors
   after 5000 updateTemps
   debuglog "Andor reset complete"
}
#\endcode

set ANDOR_CFG(videomode) 0

set ANDOR_MODES(readout) 		"full_vertical_binning multi_track random_track single_track image"
set ANDOR_MODES(acquisition)		"single_scan accumulate kinetics fast_kinetics run_till_abort"
set ANDOR_MODES(shutter) 		"auto open close"
set ANDOR_MODES(amplifier) 		"emccd ccd"
set ANDOR_MODES(temperature) 		"off stablized not_reached drift not_stabilized"

set ANDOR_SHUTTER(auto)                        0
set ANDOR_SHUTTER(open)                        1
set ANDOR_SHUTTER(close)                       2

set ANDOR_READMODE(FULL_VERTICAL_BINNING)      0
set ANDOR_READMODE(MULTI_TRACK)                1
set ANDOR_READMODE(RANDOM_TRACK)               2
set ANDOR_READMODE(SINGLE_TRACK)               3
set ANDOR_READMODE(IMAGE)                      4

set ANDOR_ACQMODE(SINGLE_SCAN)                 1
set ANDOR_ACQMODE(ACCUMULATE)                  2
set ANDOR_ACQMODE(KINETICS)                    3
set ANDOR_ACQMODE(FAST_KINETICS)               4
set ANDOR_ACQMODE(RUN_TILL_ABORT)              5

set ANDOR_EMCCD                                0
set ANDOR_CCD                                  1

set ANDOR_TEMPERATURE(OFF)                     0
set ANDOR_TEMPERATURE(STABILIZED)              1
set ANDOR_TEMPERATURE(NOT_REACHED)             2
set ANDOR_TEMPERATURE(DRIFT)                   3
set ANDOR_TEMPERATURE(NOT_STABILIZED)          4

set ANDOR_DEF(exposure_time)		0.04
set ANDOR_DEF(shutter)	 		$ANDOR_SHUTTER(close)
set ANDOR_DEF(hbin)			1
set ANDOR_DEF(vbin)			1
set ANDOR_DEF(hstart)			1
set ANDOR_DEF(hend)			1024
set ANDOR_DEF(vstart)			1
set ANDOR_DEF(vend)			1024
set ANDOR_DEF(amplifier)		$ANDOR_CCD
set ANDOR_DEF(ccd_horizontal_speed	0
set ANDOR_DEF(emccd_horizontal_speed)   1
set ANDOR_DEF(em_advanced)		0
set ANDOR_DEF(camera_link)		0
set ANDOR_DEF(head)                 "DU888_BV"
set ANDOR_DEF(acquisition_mode)     "single_scan"
set ANDOR_DEF(int_time)             0.04
set ANDOR_DEF(kinetic_time)         0.0
set ANDOR_DEF(num_exposures)        1
set ANDOR_DEF(exposure_total)       1
set ANDOR_DEF(read_mode)            "Image"
set ANDOR_DEF(fullframe)            "1,1024,1,1024"
set ANDOR_DEF(roi)                  "200, 456, 200, 456"
set ANDOR_DEF(datatype)             "Counts"
set ANDOR_DEF(calibration_type)     "Pixel number"
set ANDOR_DEF(calibration_units)    0
set ANDOR_DEF(trigger)              "Internal"
set ANDOR_DEF(calibration)          "0,1,0,0"
set ANDOR_DEF(sw_version)           "4.27.30001.0"
set ANDOR_DEF(total_exposure)       0.04
set ANDOR_DEF(temperature)          -60.
set ANDOR_DEF(readout_time)         5.0E-08
set ANDOR_DEF(system_type)          0
set ANDOR_DEF(gain)                 0
set ANDOR_DEF(em_gain)              0
set ANDOR_DEF(vclock_amp)           0
set ANDOR_DEF(vertical_speed)       4.33E-06     
set ANDOR_DEF(amplifier)            "CCD"
set ANDOR_DEF(preamp_gain)          2.
set ANDOR_DEF(target_temperature)   -60.
set ANDOR_DEF(base_clamp)           1  
set ANDOR_DEF(prescans)             0
set ANDOR_DEF(flipx)                0
set ANDOR_DEF(flipy)                0
set ANDOR_DEF(convert_mode)         0
set ANDOR_DEF(conversion)           1    
set ANDOR_DEF(sensitivity)          4.17358
set ANDOR_DEF(frame_count)          1       


set ANDOR_CFG(vertical_speeds)	    "4.33,2.2,1.13,0.6"
set ANDOR_CFG(readoutrate,ccd)      "1.0,0.1"
set ANDOR_CFG(readoutrate,emccd)    "30,20,10,1"
set ANDOR_CFG(preampgains)          "1,2"
set ANDOR_CFG(minexposure,ccd)       1.1
set ANDOR_CFG(minexposure,emccd)     0.015
	
set ANDORCODE(DRV_ERROR_CODES) 20001
set ANDORCODE(DRV_SUCCESS) 20002
set ANDORCODE(DRV_VXDNOTINSTALLED) 20003
set ANDORCODE(DRV_ERROR_SCAN) 20004
set ANDORCODE(DRV_ERROR_CHECK_SUM) 20005
set ANDORCODE(DRV_ERROR_FILELOAD) 20006
set ANDORCODE(DRV_UNKNOWN_FUNCTION) 20007
set ANDORCODE(DRV_ERROR_VXD_INIT) 20008
set ANDORCODE(DRV_ERROR_ADDRESS) 20009
set ANDORCODE(DRV_ERROR_PAGELOCK) 20010
set ANDORCODE(DRV_ERROR_PAGEUNLOCK) 20011
set ANDORCODE(DRV_ERROR_BOARDTEST) 20012
set ANDORCODE(DRV_ERROR_ACK) 20013
set ANDORCODE(DRV_ERROR_UP_FIFO) 20014
set ANDORCODE(DRV_ERROR_PATTERN) 20015

set ANDORCODE(DRV_ACQUISITION_ERRORS) 20017
set ANDORCODE(DRV_ACQ_BUFFER) 20018
set ANDORCODE(DRV_ACQ_DOWNFIFO_FULL) 20019
set ANDORCODE(DRV_PROC_UNKONWN_INSTRUCTION) 20020
set ANDORCODE(DRV_ILLEGAL_OP_CODE) 20021
set ANDORCODE(DRV_KINETIC_TIME_NOT_MET) 20022
set ANDORCODE(DRV_ACCUM_TIME_NOT_MET) 20023
set ANDORCODE(DRV_NO_NEW_DATA) 20024
set ANDORCODE(KERN_MEM_ERROR) 20025
set ANDORCODE(DRV_SPOOLERROR) 20026
set ANDORCODE(DRV_SPOOLSETUPERROR) 20027
set ANDORCODE(DRV_FILESIZELIMITERROR) 20028
set ANDORCODE(DRV_ERROR_FILESAVE) 20029

set ANDORCODE(DRV_TEMPERATURE_CODES) 20033
set ANDORCODE(DRV_TEMPERATURE_OFF) 20034
set ANDORCODE(DRV_TEMPERATURE_NOT_STABILIZED) 20035
set ANDORCODE(DRV_TEMPERATURE_STABILIZED) 20036
set ANDORCODE(DRV_TEMPERATURE_NOT_REACHED) 20037
set ANDORCODE(DRV_TEMPERATURE_OUT_RANGE) 20038
set ANDORCODE(DRV_TEMPERATURE_NOT_SUPPORTED) 20039
set ANDORCODE(DRV_TEMPERATURE_DRIFT) 20040

set ANDORCODE(DRV_TEMP_CODES) 20033
set ANDORCODE(DRV_TEMP_OFF) 20034
set ANDORCODE(DRV_TEMP_NOT_STABILIZED) 20035
set ANDORCODE(DRV_TEMP_STABILIZED) 20036
set ANDORCODE(DRV_TEMP_NOT_REACHED) 20037
set ANDORCODE(DRV_TEMP_OUT_RANGE) 20038
set ANDORCODE(DRV_TEMP_NOT_SUPPORTED) 20039
set ANDORCODE(DRV_TEMP_DRIFT) 20040

set ANDORCODE(DRV_GENERAL_ERRORS) 20049
set ANDORCODE(DRV_INVALID_AUX) 20050
set ANDORCODE(DRV_COF_NOTLOADED) 20051
set ANDORCODE(DRV_FPGAPROG) 20052
set ANDORCODE(DRV_FLEXERROR) 20053
set ANDORCODE(DRV_GPIBERROR) 20054
set ANDORCODE(DRV_EEPROMVERSIONERROR) 20055

set ANDORCODE(DRV_DATATYPE) 20064
set ANDORCODE(DRV_DRIVER_ERRORS) 20065
set ANDORCODE(DRV_P1INVALID) 20066
set ANDORCODE(DRV_P2INVALID) 20067
set ANDORCODE(DRV_P3INVALID) 20068
set ANDORCODE(DRV_P4INVALID) 20069
set ANDORCODE(DRV_INIERROR) 20070
set ANDORCODE(DRV_COFERROR) 20071
set ANDORCODE(DRV_ACQUIRING) 20072
set ANDORCODE(DRV_IDLE) 20073
set ANDORCODE(DRV_TEMPCYCLE) 20074
set ANDORCODE(DRV_NOT_INITIALIZED) 20075
set ANDORCODE(DRV_P5INVALID) 20076
set ANDORCODE(DRV_P6INVALID) 20077
set ANDORCODE(DRV_INVALID_MODE) 20078
set ANDORCODE(DRV_INVALID_FILTER) 20079

set ANDORCODE(DRV_I2CERRORS) 20080
set ANDORCODE(DRV_I2CDEVNOTFOUND) 20081
set ANDORCODE(DRV_I2CTIMEOUT) 20082
set ANDORCODE(DRV_P7INVALID) 20083
set ANDORCODE(DRV_P8INVALID) 20084
set ANDORCODE(DRV_P9INVALID) 20085
set ANDORCODE(DRV_P10INVALID) 20086
set ANDORCODE(DRV_P11INVALID) 20087

set ANDORCODE(DRV_USBERROR) 20089
set ANDORCODE(DRV_IOCERROR) 20090
set ANDORCODE(DRV_VRMVERSIONERROR) 20091
set ANDORCODE(DRV_GATESTEPERROR) 20092
set ANDORCODE(DRV_USB_INTERRUPT_ENDPOINT_ERROR) 20093
set ANDORCODE(DRV_RANDOM_TRACK_ERROR) 20094
set ANDORCODE(DRV_INVALID_TRIGGER_MODE) 20095
set ANDORCODE(DRV_LOAD_FIRMWARE_ERROR) 20096
set ANDORCODE(DRV_DIVIDE_BY_ZERO_ERROR) 20097
set ANDORCODE(DRV_INVALID_RINGEXPOSURES) 20098
set ANDORCODE(DRV_BINNING_ERROR) 20099
set ANDORCODE(DRV_INVALID_AMPLIFIER) 20100
set ANDORCODE(DRV_INVALID_COUNTCONVERT_MODE) 20101

set ANDORCODE(DRV_ERROR_NOCAMERA) 20990
set ANDORCODE(DRV_NOT_SUPPORTED) 20991
set ANDORCODE(DRV_NOT_AVAILABLE) 20992

set ANDORCODE(DRV_ERROR_MAP) 20115
set ANDORCODE(DRV_ERROR_UNMAP) 20116
set ANDORCODE(DRV_ERROR_MDL) 20117
set ANDORCODE(DRV_ERROR_UNMDL) 20118
set ANDORCODE(DRV_ERROR_BUFFSIZE) 20119
set ANDORCODE(DRV_ERROR_NOHANDLE) 20121

set ANDORCODE(DRV_GATING_NOT_AVAILABLE) 20130
set ANDORCODE(DRV_FPGA_VOLTAGE_ERROR) 20131

set ANDORCODE(DRV_OW_CMD_FAIL) 20150
set ANDORCODE(DRV_OWMEMORY_BAD_ADDR) 20151
set ANDORCODE(DRV_OWCMD_NOT_AVAILABLE) 20152
set ANDORCODE(DRV_OW_NO_SLAVES) 20153
set ANDORCODE(DRV_OW_NOT_INITIALIZED) 20154
set ANDORCODE(DRV_OW_ERROR_SLAVE_NUM) 20155
set ANDORCODE(DRV_MSTIMINGS_ERROR) 20156

set ANDORCODE(DRV_OA_NULL_ERROR) 20173
set ANDORCODE(DRV_OA_PARSE_DTD_ERROR) 20174
set ANDORCODE(DRV_OA_DTD_VALIDATE_ERROR) 20175
set ANDORCODE(DRV_OA_FILE_ACCESS_ERROR) 20176
set ANDORCODE(DRV_OA_FILE_DOES_NOT_EXIST) 20177
set ANDORCODE(DRV_OA_XML_INVALID_OR_NOT_FOUND_ERROR) 20178
set ANDORCODE(DRV_OA_PRESET_FILE_NOT_LOADED) 20179
set ANDORCODE(DRV_OA_USER_FILE_NOT_LOADED) 20180
set ANDORCODE(DRV_OA_PRESET_AND_USER_FILE_NOT_LOADED) 20181
set ANDORCODE(DRV_OA_INVALID_FILE) 20182
set ANDORCODE(DRV_OA_FILE_HAS_BEEN_MODIFIED) 20183
set ANDORCODE(DRV_OA_BUFFER_FULL) 20184
set ANDORCODE(DRV_OA_INVALID_STRING_LENGTH) 20185
set ANDORCODE(DRV_OA_INVALID_CHARS_IN_NAME) 20186
set ANDORCODE(DRV_OA_INVALID_NAMING) 20187
set ANDORCODE(DRV_OA_GET_CAMERA_ERROR) 20188
set ANDORCODE(DRV_OA_MODE_ALREADY_EXISTS) 20189
set ANDORCODE(DRV_OA_STRINGS_NOT_EQUAL) 20190
set ANDORCODE(DRV_OA_NO_USER_DATA) 20191
set ANDORCODE(DRV_OA_VALUE_NOT_SUPPORTED) 20192
set ANDORCODE(DRV_OA_MODE_DOES_NOT_EXIST) 20193
set ANDORCODE(DRV_OA_CAMERA_NOT_SUPPORTED) 20194
set ANDORCODE(DRV_OA_FAILED_TO_GET_MODE) 20195

set ANDORCODE(DRV_PROCESSING_FAILED) 20211

set ANDORCODE(AC_ACQMODE_SINGLE) 1
set ANDORCODE(AC_ACQMODE_VIDEO) 2
set ANDORCODE(AC_ACQMODE_ACCUMULATE) 4
set ANDORCODE(AC_ACQMODE_KINETIC 8)
set ANDORCODE(AC_ACQMODE_FRAMETRANSFER) 16
set ANDORCODE(AC_ACQMODE_FASTKINETICS) 32
set ANDORCODE(AC_ACQMODE_OVERLAP) 64

set ANDORCODE(AC_READMODE_FULLIMAGE) 1
set ANDORCODE(AC_READMODE_SUBIMAGE) 2
set ANDORCODE(AC_READMODE_SINGLETRACK) 4
set ANDORCODE(AC_READMODE_FVB) 8
set ANDORCODE(AC_READMODE_MULTITRACK) 16
set ANDORCODE(AC_READMODE_RANDOMTRACK) 32
set ANDORCODE(AC_READMODE_MULTITRACKSCAN) 64

set ANDORCODE(AC_TRIGGERMODE_INTERNAL) 1
set ANDORCODE(AC_TRIGGERMODE_EXTERNAL) 2
set ANDORCODE(AC_TRIGGERMODE_EXTERNAL_FVB_EM) 4
set ANDORCODE(AC_TRIGGERMODE_CONTINUOUS) 8
set ANDORCODE(AC_TRIGGERMODE_EXTERNALSTART) 16
set ANDORCODE(AC_TRIGGERMODE_EXTERNALEXPOSURE) 32
set ANDORCODE(AC_TRIGGERMODE_INVERTED) 0x40
set ANDORCODE(AC_TRIGGERMODE_EXTERNAL_CHARGESHIFTING) 0x80

# Deprecated for AC_TRIGGERMODE_EXTERNALEXPOSURE
set ANDORCODE(AC_TRIGGERMODE_BULB) 32

set ANDORCODE(AC_CAMERATYPE_PDA) 0
set ANDORCODE(AC_CAMERATYPE_IXON) 1
set ANDORCODE(AC_CAMERATYPE_ICCD) 2
set ANDORCODE(AC_CAMERATYPE_EMCCD) 3
set ANDORCODE(AC_CAMERATYPE_CCD) 4
set ANDORCODE(AC_CAMERATYPE_ISTAR) 5
set ANDORCODE(AC_CAMERATYPE_VIDEO) 6
set ANDORCODE(AC_CAMERATYPE_IDUS) 7
set ANDORCODE(AC_CAMERATYPE_NEWTON) 8
set ANDORCODE(AC_CAMERATYPE_SURCAM) 9
set ANDORCODE(AC_CAMERATYPE_USBICCD) 10
set ANDORCODE(AC_CAMERATYPE_LUCA)  11
set ANDORCODE(AC_CAMERATYPE_RESERVED)  12
set ANDORCODE(AC_CAMERATYPE_IKON)  13
set ANDORCODE(AC_CAMERATYPE_INGAAS)  14
set ANDORCODE(AC_CAMERATYPE_IVAC)  15
set ANDORCODE(AC_CAMERATYPE_UNPROGRAMMED)  16
set ANDORCODE(AC_CAMERATYPE_CLARA)  17
set ANDORCODE(AC_CAMERATYPE_USBISTAR)  18
set ANDORCODE(AC_CAMERATYPE_SIMCAM)  19
set ANDORCODE(AC_CAMERATYPE_NEO) 20
set ANDORCODE(AC_CAMERATYPE_IXONULTRA) 21
set ANDORCODE(AC_CAMERATYPE_VOLMOS) 22
set ANDORCODE(AC_CAMERATYPE_IVAC_CCD) 23
set ANDORCODE(AC_CAMERATYPE_ASPEN) 24
set ANDORCODE(AC_CAMERATYPE_ASCENT) 25
set ANDORCODE(AC_CAMERATYPE_ALTA) 26
set ANDORCODE(AC_CAMERATYPE_ALTAF) 27
set ANDORCODE(AC_CAMERATYPE_IKONXL) 28
set ANDORCODE(AC_CAMERATYPE_RES1) 29

set ANDORCODE(AC_PIXELMODE_8BIT)  1
set ANDORCODE(AC_PIXELMODE_14BIT) 2
set ANDORCODE(AC_PIXELMODE_16BIT)  4
set ANDORCODE(AC_PIXELMODE_32BIT)  8

set ANDORCODE(AC_PIXELMODE_MONO)  0x000000
set ANDORCODE(AC_PIXELMODE_RGB)  0x010000
set ANDORCODE(AC_PIXELMODE_CMY)  0x020000

set ANDORCODE(AC_SETFUNCTION_VREADOUT)  0x01
set ANDORCODE(AC_SETFUNCTION_HREADOUT)  0x02
set ANDORCODE(AC_SETFUNCTION_TEMPERATURE)  0x04
set ANDORCODE(AC_SETFUNCTION_MCPGAIN)  0x08
set ANDORCODE(AC_SETFUNCTION_EMCCDGAIN)  0x10
set ANDORCODE(AC_SETFUNCTION_BASELINECLAMP)  0x20
set ANDORCODE(AC_SETFUNCTION_VSAMPLITUDE)  0x40
set ANDORCODE(AC_SETFUNCTION_HIGHCAPACITY)  0x80
set ANDORCODE(AC_SETFUNCTION_BASELINEOFFSET)  0x0100
set ANDORCODE(AC_SETFUNCTION_PREAMPGAIN)  0x0200
set ANDORCODE(AC_SETFUNCTION_CROPMODE)  0x0400
set ANDORCODE(AC_SETFUNCTION_DMAPARAMETERS)  0x0800
set ANDORCODE(AC_SETFUNCTION_HORIZONTALBIN)  0x1000
set ANDORCODE(AC_SETFUNCTION_MULTITRACKHRANGE)  0x2000
set ANDORCODE(AC_SETFUNCTION_RANDOMTRACKNOGAPS)  0x4000
set ANDORCODE(AC_SETFUNCTION_EMADVANCED)  0x8000
set ANDORCODE(AC_SETFUNCTION_GATEMODE)  0x010000
set ANDORCODE(AC_SETFUNCTION_DDGTIMES)  0x020000
set ANDORCODE(AC_SETFUNCTION_IOC)  0x040000
set ANDORCODE(AC_SETFUNCTION_INTELLIGATE)  0x080000
set ANDORCODE(AC_SETFUNCTION_INSERTION_DELAY)  0x100000
set ANDORCODE(AC_SETFUNCTION_GATESTEP)  0x200000
set ANDORCODE(AC_SETFUNCTION_GATEDELAYSTEP)  0x200000
set ANDORCODE(AC_SETFUNCTION_TRIGGERTERMINATION)  0x400000
set ANDORCODE(AC_SETFUNCTION_EXTENDEDNIR)  0x800000
set ANDORCODE(AC_SETFUNCTION_SPOOLTHREADCOUNT)  0x1000000
set ANDORCODE(AC_SETFUNCTION_REGISTERPACK)  0x2000000
set ANDORCODE(AC_SETFUNCTION_PRESCANS)  0x4000000
set ANDORCODE(AC_SETFUNCTION_GATEWIDTHSTEP)  0x8000000
set ANDORCODE(AC_SETFUNCTION_EXTENDED_CROP_MODE)  0x10000000
set ANDORCODE(AC_SETFUNCTION_SUPERKINETICS)  0x20000000
set ANDORCODE(AC_SETFUNCTION_TIMESCAN) 0x40000000

# Deprecated for AC_SETFUNCTION_MCPGAIN
set ANDORCODE(AC_SETFUNCTION_GAIN)  8
set ANDORCODE(AC_SETFUNCTION_ICCDGAIN)  8

set ANDORCODE(AC_GETFUNCTION_TEMPERATURE)  0x01
set ANDORCODE(AC_GETFUNCTION_TARGETTEMPERATURE)  0x02
set ANDORCODE(AC_GETFUNCTION_TEMPERATURERANGE)  0x04
set ANDORCODE(AC_GETFUNCTION_DETECTORSIZE)  0x08
set ANDORCODE(AC_GETFUNCTION_MCPGAIN)  0x10
set ANDORCODE(AC_GETFUNCTION_EMCCDGAIN)  0x20
set ANDORCODE(AC_GETFUNCTION_HVFLAG)  0x40
set ANDORCODE(AC_GETFUNCTION_GATEMODE)  0x80
set ANDORCODE(AC_GETFUNCTION_DDGTIMES)  0x0100
set ANDORCODE(AC_GETFUNCTION_IOC)  0x0200
set ANDORCODE(AC_GETFUNCTION_INTELLIGATE)  0x0400
set ANDORCODE(AC_GETFUNCTION_INSERTION_DELAY)  0x0800
set ANDORCODE(AC_GETFUNCTION_GATESTEP)  0x1000
set ANDORCODE(AC_GETFUNCTION_GATEDELAYSTEP)  0x1000
set ANDORCODE(AC_GETFUNCTION_PHOSPHORSTATUS)  0x2000
set ANDORCODE(AC_GETFUNCTION_MCPGAINTABLE)  0x4000
set ANDORCODE(AC_GETFUNCTION_BASELINECLAMP)  0x8000
set ANDORCODE(AC_GETFUNCTION_GATEWIDTHSTEP)  0x10000

set ANDORCODE(AC_GETFUNCTION_GAIN) 0x10
set ANDORCODE(AC_GETFUNCTION_ICCDGAIN) 0x10

set ANDORCODE(AC_FEATURES_POLLING)  1
set ANDORCODE(AC_FEATURES_EVENTS) 2
set ANDORCODE(AC_FEATURES_SPOOLING)  4
set ANDORCODE(AC_FEATURES_SHUTTER) 8
set ANDORCODE(AC_FEATURES_SHUTTEREX)  16
set ANDORCODE(AC_FEATURES_EXTERNAL_I2C)  32
set ANDORCODE(AC_FEATURES_SATURATIONEVENT)  64
set ANDORCODE(AC_FEATURES_FANCONTROL)  128
set ANDORCODE(AC_FEATURES_MIDFANCONTROL) 256
set ANDORCODE(AC_FEATURES_TEMPERATUREDURINGACQUISITION)  512
set ANDORCODE(AC_FEATURES_KEEPCLEANCONTROL)  1024
set ANDORCODE(AC_FEATURES_DDGLITE)  0x0800
set ANDORCODE(AC_FEATURES_FTEXTERNALEXPOSURE)  0x1000
set ANDORCODE(AC_FEATURES_KINETICEXTERNALEXPOSURE)  0x2000
set ANDORCODE(AC_FEATURES_DACCONTROL) 0x4000
set ANDORCODE(AC_FEATURES_METADATA)  0x8000
set ANDORCODE(AC_FEATURES_IOCONTROL)  0x10000
set ANDORCODE(AC_FEATURES_PHOTONCOUNTING)  0x20000
set ANDORCODE(AC_FEATURES_COUNTCONVERT)  0x40000
set ANDORCODE(AC_FEATURES_DUALMODE)  0x80000
set ANDORCODE(AC_FEATURES_OPTACQUIRE)  0x100000
set ANDORCODE(AC_FEATURES_REALTIMESPURIOUSNOISEFILTER)  0x200000
set ANDORCODE(AC_FEATURES_POSTPROCESSSPURIOUSNOISEFILTER)  0x400000
set ANDORCODE(AC_FEATURES_DUALPREAMPGAIN)  0x800000
set ANDORCODE(AC_FEATURES_DEFECT_CORRECTION)  0x1000000
set ANDORCODE(AC_FEATURES_STARTOFEXPOSURE_EVENT)  0x2000000
set ANDORCODE(AC_FEATURES_ENDOFEXPOSURE_EVENT)  0x4000000
set ANDORCODE(AC_FEATURES_CAMERALINK)  0x8000000
set ANDORCODE(AC_FEATURES_FIFOFULL_EVENT)  0x10000000
set ANDORCODE(AC_FEATURES_SENSOR_PORT_CONFIGURATION)  0x20000000
set ANDORCODE(AC_FEATURES_SENSOR_COMPENSATION)  0x40000000
set ANDORCODE(AC_FEATURES_IRIG_SUPPORT)  0x80000000

set ANDORCODE(AC_EMGAIN_8BIT)  1
set ANDORCODE(AC_EMGAIN_12BIT) 2
set ANDORCODE(AC_EMGAIN_LINEAR12)  4
set ANDORCODE(AC_EMGAIN_REAL12)  8

foreach i [array names ANDORCODE] { 
   if { [string range $i 0 3] == "DRV_" } {
      set ANDOR_RET($ANDORCODE($i)) [string range $i 4 end]
   }
}



