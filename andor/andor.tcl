#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2 If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2017 The Random Factory (www.randomfactopry.com) 
#
#


proc initCameraConfig { id } {
global ANDOR_CFG
  foreach c "exposure_time temperature cam_frames_per_second missed_frames__second usb_frames_per_second preamp_gain vertical_speed horizontal_speeds hbin vbin hstart hend vstart vend read_mode acquisition_mode width height shutter amplifier npixx npixy minimum_temperature maximum_temperature target_temperature temperature_status running usb_running camlink_running num_preamp_gains preamp_gain_index em_advanced minimum_em_gain maximum_em_gain em_gain num_vertical_speeds vertical_speed_index num_horizontal_speeds horizontal_speed_index"  {
    set ANDOR_CFG($id,$c) "?"
  }
}



proc printCapabilities { fid } {
global ANDOR_CAP
set ANDOR_CAP [AndorCapabilities]
  set s [GetCapabilities $ANDOR_CAP]
  foreach c "ulSize ulAcqModes  ulReadModes ulTriggerModes ulCameraType ulPixelMode ulSetFunctions ulGetFunctions  ulFeatures ulPCICard ulEMGainCapability  ulFTReadModes" {
      puts $fid "$c	= [AndorCapabilities_[set c]_get $ANDOR_CAP]"
  }
}

proc printCameraConfig { fid id } {
global ANDOR_CFG
  foreach c "exposure_time temperature cam_frames_per_second missed_frames__second usb_frames_per_second preamp_gain vertical_speed horizontal_speeds hbin vbin hstart hend vstart vend read_mode acquisition_mode width height shutter amplifier npixx npixy minimum_temperature maximum_temperature target_temperature temperature_status running usb_running camlink_running num_preamp_gains preamp_gain_index em_advanced minimum_em_gain maximum_em_gain em_gain num_vertical_speeds vertical_speed_index num_horizontal_speeds horizontal_speed_index"  {
      puts $fid "$c	= $ANDOR_CFG($id,$c)"
  }
}

proc initds9 { shmid width height } {
global SPECKLE_DIR
  debuglog "Configuring ds9"
  exec xpaset -p ds9 source $SPECKLE_DIR/andor/ds9refresher.tcl
  exec xpaset -p ds9 shm array shmid $shmid \\\[xdim=$width,ydim=$height,bitpix=32\\\]
}

proc refreshds9 { delta count } {
  exec xpaset -p ds9 tcl \{refinit $delta $count\}
  exec xpaset -p ds9 tcl refresher
}

proc initads9 { shmid width height } {
global SPECKLE_DIR DS9
  debuglog "Configuring ds9"
  exec xpaset -p $DS9 source $SPECKLE_DIR/andor/ds9refresher.tcl
  exec xpaset -p $DS9 shm array shmid $shmid \\\[xdim=$width,ydim=$height,bitpix=32\\\]
}

proc refreshads9 { delta count } {
global DS9
  exec xpaset -p $DS9 tcl \{refinit $delta $count\}
  exec xpaset -p $DS9 tcl refresher
}


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

proc commandAndor { arm cmd {echk 1} } {
global ANDOR_SOCKET SCOPE
   if { $ANDOR_SOCKET($arm) == 0 } {
     debuglog "WARNING : $arm arm camera not connected"
     return 0
   } else {
     if { [string range $cmd 0 3] == "grab" } {
        if { $echk } {
           set nrchk "$SCOPE(datadir)/$SCOPE(imagename)_[set SCOPE(seqnum)]_red.fits"
           if { [file exists $nrchk] } {
              set it [ tk_dialog .d "File exists" "The file named\n $nrchk\n already exists" {} -1 OK]
              debuglog "Cannot overwrite file $nrchk"
              return 0
            }
           set nbchk "$SCOPE(datadir)/$SCOPE(imagename)_[set SCOPE(seqnum)]_blue.fits"
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

proc flushAndors { } {
global ANDOR_SOCKET
   if { $ANDOR_SOCKET(red) > 0 } {
      while { [gets $ANDOR_SOCKET(red) result] > -1 } {set x 1}
   }
   if { $ANDOR_SOCKET(blue) > 0 } {
      while { [gets $ANDOR_SOCKET(blue) result] > -1 } {set x 1}
   }
}


proc commandCameras { cmd {echk 1} } {
global INSTRUMENT
   commandAndor red $cmd $echk
   if { $INSTRUMENT(clone) } {
      commandAndor blue $cmd $echk
   }
}


proc videomode { } {
global LASTACQ STATUS SCOPE ACQREGION
   commandAndor red "imagename videomode 1" 0
   commandAndor blue "imagename videomode 1" 0
   exec rm -f $SCOPE(datadir)/videomode_red.fits
   exec rm -f $SCOPE(datadir)/videomode_blue.fits
   if { $LASTACQ == "fullframe" } {
      commandAndor red "grabframe $SCOPE(exposure)" 0
      commandAndor blue "grabframe $SCOPE(exposure)" 0
   } else {
      commandAndor red "grabroi $SCOPE(exposure) $ACQREGION(xs) $ACQREGION(ys) $ACQREGION(geom)" 0
      commandAndor blue "grabroi $SCOPE(exposure) $ACQREGION(xs) $ACQREGION(ys) $ACQREGION(geom)" 0
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
      after 1000 speckleshutter red close
      after 1000 speckleshutter blue close
   }
}
  
proc startvideomode { } {
global STATUS SCOPE
   set STATUS(abort) 0
   speckleshutter red open
   speckleshutter blue open
   commandAndor red "datadir $SCOPE(datadir)"
   commandAndor blue "datadir $SCOPE(datadir)"
   videomode
}




proc acquireCubes { } {
global INSTRUMENT SCOPE LASTACQ ACQREGION
   set n [expr $ACQREGION(xe) - $ACQREGION(xs) +1]
   if { $INSTRUMENT(red) } {
      commandAndor red "setframe roi"
      commandAndor red "grabcube $SCOPE(exposure) $ACQREGION(rxs) $ACQREGION(rys) $ACQREGION(geom) $SCOPE(numframes)"
      set LASTACQ roi
   }
   if { $INSTRUMENT(blue) } {
      commandAndor blue "setframe roi"
      commandAndor blue "grabcube $SCOPE(exposure) $ACQREGION(bxs) $ACQREGION(bys) $ACQREGION(geom) $SCOPE(numframes)"
      set LASTACQ roi
   }
}

proc acquireFrames { } {
global INSTRUMENT SCOPE
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
   
proc resetAndors { mode } {
global INSTRUMENT SPECKLE_DIR ANDOR_SOCKET ACQREGION LASTACQ SCOPE
   debuglog "Resetting Andors for $mode" 
   catch {commandAndor red shutdown; close $ANDOR_SOCKET(red)}
   catch {commandAndor blue shutdown; close $ANDOR_SOCKET(blue)}
   if { $mode == "fullframe" } {
     exec xterm -e "$SPECKLE_DIR/andor/andorServer.tcl 1 1 1024 1 1024" &
     exec xterm -e "$SPECKLE_DIR/andor/andorServer.tcl 2 1 1024 1 1024" &
     set LASTACQ fullframe
   } else {
     exec xterm -e "$SPECKLE_DIR/andor/andorServer.tcl 1 $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)" &
     exec xterm -e "$SPECKLE_DIR/andor/andorServer.tcl 2 $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)" &
     set LASTACQ roi
     set SCOPE(numframes) 1000
   }
   after 15000
   connectToAndors
   debuglog "Andor reset complete"
}


proc resetSingleAndors { mode } {
global INSTRUMENT SPECKLE_DIR ANDOR_SOCKET ACQREGION LASTACQ SCOPE
   debuglog "Resetting Andors for $mode" 
   catch {commandAndor red shutdown; close $ANDOR_SOCKET(red)}
   catch {commandAndor blue shutdown; close $ANDOR_SOCKET(blue)}
   if { $mode == "fullframe" } {
     exec xterm -geometry +20+800 -e "$SPECKLE_DIR/andor/andorCameraServer.tcl 1 1 1024 1 1024" &
     exec xterm -geometry +540+800 -e "$SPECKLE_DIR/andor/andorCameraServer.tcl 2 1 1024 1 1024" &
     set LASTACQ fullframe
   } else {
     exec xterm -geometry +20+800 -e "$SPECKLE_DIR/andor/andorCameraServer.tcl 1 $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)" &
     exec xterm -geometry +540+800 -e "$SPECKLE_DIR/andor/andorCameraServer.tcl 2 $ACQREGION(xs) $ACQREGION(xe) $ACQREGION(ys) $ACQREGION(ye)" &
     set LASTACQ roi
     set SCOPE(numframes) 1000
   }
   after 15000
   connectToAndors
   debuglog "Andor reset complete"
}


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



