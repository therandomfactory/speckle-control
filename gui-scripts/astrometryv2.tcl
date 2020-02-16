## \file astrometry.tcl
# \brief This contains procedures for updating WCS in the headers and ds9
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
## Documented proc \c updateds9wcs .
# \param[in] ra RA coordinate
# \param[in] dec DEC coordinate
#
#  Update the DS9 World Coordinate system based upon current RA,DEC
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue
#		ACQREGION - Region of interest parameters\n
#		SCOPE - Array of telescope information
#		CAMSTATUS - Camera parameters
#		PI - pi
#		DS9 - Name of a ds9 executable , ds9red or ds9blue
#
proc updateds9wcs { ra dec } {
global SCOPE ACQREGION PSCALES ANDOR_CFG PI DS9 ANDOR_ARM env TELEMETRY WCSPARS
  readWCSpars $ANDOR_ARM $TELEMETRY(speckle.andor.inputzaber)
  set radeg [expr ([hms_to_radians $ra]+[hms_to_radians 00:00:$WCSPAR(DELTARA)/15.])*180/$PI]
  set decdeg [expr ([dms_to_radians $dec]+[dms_to_radians 00:00:$WCSPAR(DELTADEC)])*180/$PI]
  set fout [open /tmp/[set ANDOR_ARM]wcs.wcs w]
  if { $WCSPARS(CRVAL1) == "RA" } {
    puts $fout "CRVAL1 $radeg"
    puts $fout "CRVAL2 $decdeg"
    puts $fout "CTYPE1 'RA--TAN'"
    puts $fout "CTYPE2 'DEC--TAN'" 
  } else {
    puts $fout "CRVAL1 $decdeg"
    puts $fout "CRVAL2 $radeg"
    puts $fout "CTYPE1 'DEC--TAN'"
    puts $fout "CTYPE2 'RA--TAN'" 
  }
  puts $fout "CDELT1 $WCSPARS(CDELT1)"
  puts $fout "CDELT2 $WCSPARS(CDELT2)"
  puts $fout "CROTA2 $WCSPARS(CROTA2)"
  puts $fout "CRPIX1 [expr $ACQREGION(geom)/$ANDOR_CFG(binning)/2]"
  puts $fout "CRPIX2 [expr $ACQREGION(geom)/$ANDOR_CFG(binning)/2]"
  puts $fout "CD1_1  [expr $WCSPARS(CDELT1) * [cosd $WCSPARS(CROTA2)]]"
  puts $fout "CD1_2  [expr -1.0*$WCSPARS(CDELT2) * [sind $WCSPARS(CROTA2)]]"
  puts $fout "CD2_1  [expr $WCSPARS(CDELT1) * [sind $WCSPARS(CROTA2)]]"
  puts $fout "CD2_2  [expr $WCSPARS(CDELT2) * [cosd $WCSPARS(CROTA2)]]"
  puts $fout "WCSNAME 'FK5'"
  puts $fout "RADECSYS 'FK5'"
  puts $fout "EQUINOX 2000."
  close $fout
  exec xpaset -p $DS9  wcs replace /tmp/[set ANDOR_ARM]wcs.wcs
}


## Documented proc \c headerAstrometry .
# \param[in] tclFits file handle for opened FITS file
# \param[in] ra RA coordinate
# \param[in] dec DEC coordinate
#
#  Update the FITS header  World Coordinate system based upon current RA,DEC
#
#
# Globals :\n
#		ANDOR_CFG - Andor camera properties\n
#		ANDOR_ARM - Instrument arm this camera is installed in red/blue
#		ACQREGION - Region of interest parameters\n
#		SCOPE - Array of telescope information
#		CAMSTATUS - Camera parameters
#		PI - pi
#		DS9 - Name of a ds9 executable , ds9red or ds9blue
#
proc headerAstrometry { fid ra dec } {
global ACQREGION SCOPE PSCALES ANDOR_CFG PI ANDOR_ARM env TELEMETRY WCSPARS
  readWCSpars $ANDOR_ARM $TELEMETRY(speckle.andor.inputzaber)
  set radeg [expr ([hms_to_radians $ra]+[hms_to_radians 00:00:$WCSPAR(DELTARA)/15.])*180/$PI]
  set decdeg [expr ([dms_to_radians $dec]+[dms_to_radians 00:00:$WCSPAR(DELTADEC)])*180/$PI]
  if { $WCSPARS(CRVAL1) == "RA" } {
    set r [fitshdrrecord  CRVAL2	 double "$decdeg"	"Declination of reference pixel \[deg\]"]
    $fid put keyword $r
    set r [fitshdrrecord  CRVAL1	 double "$radeg"	"RA of reference pixel \[deg\]"]
    $fid put keyword $r
    set r [fitshdrrecord  CTYPE2	 string "DEC--TAN"	"Coordinate type"]
    $fid put keyword $r
    set r [fitshdrrecord  CTYPE1	 string  "RA--TAN"	"Coordinate type"]
    $fid put keyword $r
  } else {
    set r [fitshdrrecord  CRVAL1	 double "$decdeg"	"Declination of reference pixel \[deg\]"]
    $fid put keyword $r
    set r [fitshdrrecord  CRVAL2	 double "$radeg"	"RA of reference pixel \[deg\]"]
    $fid put keyword $r
    set r [fitshdrrecord  CTYPE1	 string "DEC--TAN"	"Coordinate type"]
    $fid put keyword $r
    set r [fitshdrrecord  CTYPE2	 string  "RA--TAN"	"Coordinate type"]
    $fid put keyword $r
  }
  set r [fitshdrrecord  CRPIX1	 	integer [expr $ACQREGION(geom)/$ANDOR_CFG(binning)/2]	"Coordinate reference pixel in X"]
  $fid put keyword $r
  set r [fitshdrrecord  CRPIX2	 	integer [expr $ACQREGION(geom)/$ANDOR_CFG(binning)/2]	"Coordinate reference pixel in Y"]
  $fid put keyword $r
  set r [fitshdrrecord  CDELT1	 	double  $WCSPARS(CDELT1)	"Coordinate pixel scale in X"]
  $fid put keyword $r
  set r [fitshdrrecord  CDELT2	 	double  $WCSPARS(CDELT2)	"Coordinate pixel scale in Y"]
  $fid put keyword $r
  set r [fitshdrrecord  CDELT1	 	double  $WCSPARS(CROTA2)	"Rotation angle"]
  $fid put keyword $r
  set r [fitshdrrecord  CD1_1 		double 	[expr $WCSPARS(CDELT1) * [cosd $WCSPARS(CROTA2)]] ""]
  $fid put keyword $r
  set r [fitshdrrecord  CD1_2 		double  [expr -1.0*$WCSPARS(CDELT2) * [sind $WCSPARS(CROTA2)]] ""]
  $fid put keyword $r
  set r [fitshdrrecord  CD2_1 		double  [expr $WCSPARS(CDELT1) * [sind $WCSPARS(CROTA2)]] ""]
  $fid put keyword $r
  set r [fitshdrrecord  CD2_2 		double  [expr $WCSPARS(CDELT2) * [cosd $WCSPARS(CROTA2)]] ""]
  $fid put keyword $r
  set r [fitshdrrecord  WCSNAME  string "FK5"	"World coordinate system type"]
  $fid put keyword $r
  set r [fitshdrrecord  RADECSYS string "FK5"	"Default coordinate system type"]
  $fid put keyword $r
}

## Documented proc \c dms_to_radians .
# \param[in] dms dd:mm:ss for conversion
#
# Convert ddd:mm:ss to radians
#
#
# Globals :
#		PI - pi
#
proc dms_to_radians { dms } {
global PI
   set t [string trim $dms "+ "]
   set s 1
   if { [string range $t 0 0] == "-" } {
      set s -1
      set dms [string trim $dms "-"]
   }
   set f [split $dms ":"]
   set r [expr $s * ([scan [lindex $f 0] %d] + [scan [lindex $f 1] %d]/60.0 + [scan [lindex $f 2] %d]/3600.0 )/180. * $PI]
}

## Documented proc \c hms_to_radians .
# \param[in] hms hh:mm:ss for conversion
#
# Convert hh:mm:ss to radians
#
#
# Globals :
#		PI - pi
#
proc hms_to_radians { hms } {
global PI
   set f [split $hms ":"]
   set r [expr ([scan [lindex $f 0] %d] + [scan [lindex $f 1] %d]/60.0 + [scan [lindex $f 2] %d]/3600.0 )/12. * $PI]
}

proc sind { ang } {
global PI
  return [expr sin($ang/180.*$PI)]
}

proc cosd { ang } {
global PI
  return [expr cos($ang/180.*$PI)]
}

## Documented proc \c readWCSpars .
#
#
# Convert hh:mm:ss to radians
#
#
# Globals :
#		WCSPARS - User tunable WCS parameters from file
#
proc readWCSpars { arm mode } {
global env WCSPARS
  switch $env(TELESCOPE)_$env(GEMINISITE)_$mode {
      GEMINI_north_speckle   { set wcspars $env(SPECKLE_DIR)/wcsPars.$arm.speckle.geminiN }
      GEMINI_south_speckle   { set wcspars $env(SPECKLE_DIR)/wcsPars.$arm.speckle.geminiS }
      WIYN_NA_speckle        { set wcspars $env(SPECKLE_DIR)/wcsPars.$arm.speckle.wiyn }
      GEMINI_north_wide      { set wcspars $env(SPECKLE_DIR)/wcsPars.$arm.wide.geminiN }
      GEMINI_south_wide      { set wcspars $env(SPECKLE_DIR)/wcsPars.$arm.wide.geminiS }
      WIYN_NA_fullframe      { set wcspars $env(SPECKLE_DIR)/wcsPars.$arm.wide.wiyn }
  }
  set fin [open $wcspars r]
  while { [gets $fin rec] > -1 } {
     set par [string trim [lindex [split $rec =] 0]]
     set val [string trim [lindex [split $rec =] 1]]
     set WCSPARS($par) $val
  }
  close $fin
}



# \endcode

set PI 3.141592653589
set ACQREGION(geom) 1024
set ANDOR_CFG(binning) 1
set ANDOR_CFG(frame) fullframe



