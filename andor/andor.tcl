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

set ANDOR_MODES(readout) 		"full_vertical_binning multi_track random_track single_track image"
set ANDOR_MODES(acquisition)		"single_scan accumulate kinetics fast_kinetics run_till_abort"
set ANDOR_MODES(shutter) 		"auto open close"
set ANDOR_MODES(amplifier) 		"emccd ccd"
set ANDOR_MODES(temperature) 		"off stablized not_reached drift not_stabilized"



load $NESSI_DIR/lib/andorWrap.so
set ANDOR_DEF(exposure_time)		0.001
set ANDOR_DEF(shutter)	 		$ANDOR_SHUTTER_CLOSE
set ANDOR_DEF(hbin)			1
set ANDOR_DEF(vbin)			1
set ANDOR_DEF(hstart)			1
set ANDOR_DEF(hend)			90
set ANDOR_DEF(vstart)			1
set ANDOR_DEF(vend)			90
set ANDOR_DEF(amplifier)		$ANDOR_CCD
set ANDOR_DEF(ccd_horizontal_speed	0
set ANDOR_DEF(emccd_horizontal_speed)   0
set ANDOR_DEF(em_advanced)		0
set ANDOR_DEF(camera_link)		0
set ANDOR_DEF(head)                 "DU888_BV"
set ANDOR_DEF(acquisition_mode)     "Kinetics"
set ANDOR_DEF(int_time)             0.07059
set ANDOR_DEF(kinetic_time)         0.07059
set ANDOR_DEF(num_exposures)        1
set ANDOR_DEF(exposure_total)       1
set ANDOR_DEF(read_mode)            "Image"
set ANDOR_DEF(fullframe)            "1, 1024, 1024, 1"
set ANDOR_DEF(roi)                  "385, 640, 640, 385"
set ANDOR_DEF(datatype)             "Counts"
set ANDOR_DEF(calibration_type)     "Pixel number"
set ANDOR_DEF(calibration_units)    0
set ANDOR_DEF(rayleigh_wave)        422.
set ANDOR_DEF(wave_calibration)     1
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
set ANDOR_DEF(amplifier)            "Electron Multiplying"
set ANDOR_DEF(preamp_gain)          2.
set ANDOR_DEF(serial_number)        10244   
set ANDOR_DEF(target_temperature)   -999.
set ANDOR_DEF(base_clamp)           T    
set ANDOR_DEF(prescans)             0
set ANDOR_DEF(flipx)                0
set ANDOR_DEF(flipy)                0
set ANDOR_DEF(convert_mode)         0
set ANDOR_DEF(conversion)           1    
set ANDOR_DEF(detection_wave)       550.
set ANDOR_DEF(sensitivity)          4.17358
set ANDOR_DEF(spurious_filter)      0
set ANDOR_DEF(threshold)            0.
set ANDOR_DEF(photon_counting)      0  
set ANDOR_DEF(nphoton_thresh)       0
set ANDOR_DEF(pc_thresh1)           0.
set ANDOR_DEF(pc_thresh2)           0.
set ANDOR_DEF(pc_thresh3)           0.
set ANDOR_DEF(pc_thresh4)           0.
set ANDOR_DEF(avg_filter_mode)      0 
set ANDOR_DEF(avg_factor)           1
set ANDOR_DEF(frame_count)          1       
set ANDOR_DEF(port_readout)         -1            
set ANDOR_DEF(exp_window_height)    0    
set ANDOR_DEF(linescan_speed)       0.           
set ANDOR_DEF(alternate_readout)    0
set ANDOR_DEF(scanspeed_control)    0            
set ANDOR_DEF(readout_direction)    -1                      
set ANDOR_DEF(user_text1)           ""                             
set ANDOR_DEF(user_text2)           ""
set ANDOR_DEF(user_text3)           ""
set ANDOR_DEF(user_text4)           ""
set ANDOR_DEF(eshutter_mode)        -1



set ANDOR_RET($DRV_SUCCESS) 		"OK"
set ANDOR_RET($DRV_NOT_SUPPORTED) 	"Camera Link Not Supported."
set ANDOR_RET($DRV_P1INVALID) 		"Invalid camera index."
set ANDOR_RET($DRV_VXDNOTINSTALLED) 	"VxD not loaded."
set ANDOR_RET($DRV_INIERROR) 		"Unable to load DETECTOR.INI."
set ANDOR_RET($DRV_COFERROR) 		"Unable to load *.COF."
set ANDOR_RET($DRV_FLEXERROR) 		"Unable to load *.RBF."
set ANDOR_RET($DRV_ERROR_ACK) 		"Unable to communicate with card."
set ANDOR_RET($DRV_ERROR_FILELOAD) 	"Unable to load COF or RBF files."
set ANDOR_RET($DRV_ERROR_PAGELOCK) 	"Unable to acquire lock on memory."
set ANDOR_RET($DRV_USBERROR) 		"Unable to detect USB device."
set ANDOR_RET($DRV_ERROR_NOCAMERA) 	"No camera found."
set ANDOR_RET($DRV_NOT_INITIALIZED) 	"Not initialized."
set ANDOR_RET($DRV_P1INVALID) 		"Invalid CAPS parameter."
set ANDOR_RET($DRV_ACQUIRING) 		"Acquisition in progress."
	

