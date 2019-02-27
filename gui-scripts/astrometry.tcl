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
global SCOPE ACQREGION PSCALES ANDOR_CFG PI DS9 ANDOR_ARM env TELEMETRY
  set radeg [expr [hms_to_radians $ra]*180/$PI]
  set decdeg [expr [dms_to_radians $dec]*180/$PI]
  set fout [open /tmp/[set ANDOR_ARM]wcs.wcs w]
  puts $fout "CRVAL1 $decdeg"
  puts $fout "CRVAL2 $radeg"
  puts $fout "CRPIX1 [expr $ACQREGION(geom)/$ANDOR_CFG(binning)/2]"
  puts $fout "CRPIX2 [expr $ACQREGION(geom)/$ANDOR_CFG(binning)/2]"
  set fac 1.0
  if { $ANDOR_ARM == "blue" } {set fac -1.0}
  if { $env(TELESCOPE) == "GEMINI" } {
    set fac11 [expr -1.0*sin($TELEMETRY(tcs.telescope.instrpa)*180./$PI)]
    set fac12 [expr cos($TELEMETRY(tcs.telescope.instrpa)*180./$PI)]
    set fac21 [expr cos($TELEMETRY(tcs.telescope.instrpa)*180./$PI)]
    set fac22 [expr sin($TELEMETRY(tcs.telescope.instrpa)*180./$PI)]
    puts $fout "CD1_1 [expr $fac11*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)]"        
    puts $fout "CD1_2 [expr $fac12*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)]"
    puts $fout "CD2_1 [expr $fac21*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)]"
    puts $fout "CD2_2 [expr $fac22*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)]"
  } else {
    puts $fout "CD1_1 [expr $fac*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)]"                   
    puts $fout "CD1_2 0.0"
    puts $fout "CD2_1 0.0"
    puts $fout "CD2_2 [expr -1.0*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)]"
  }
  puts $fout "CTYPE1 'DEC--TAN'"
  puts $fout "CTYPE2 'RA--TAN'" 
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
global ACQREGION SCOPE PSCALES ANDOR_CFG PI ANDOR_ARM env TELEMETRY
  set radeg [expr [hms_to_radians $ra]*180/$PI]
  set decdeg [expr [dms_to_radians $dec]*180/$PI]
  set r [fitshdrrecord  CRVAL1	 string "$decdeg"	"Declination of reference pixel \[deg\]"]
  $fid put keyword $r
  set r [fitshdrrecord  CRVAL2	 string "$radeg"	"RA of reference pixel \[deg\]"]
  $fid put keyword $r
  set r [fitshdrrecord  CRPIX1	 integer [expr $ACQREGION(geom)/$ANDOR_CFG(binning)/2]	"Coordinate reference pixel in X"]
  $fid put keyword $r
  set r [fitshdrrecord  CRPIX2	 integer [expr $ACQREGION(geom)/$ANDOR_CFG(binning)/2]	"Coordinate reference pixel in Y"]
  $fid put keyword $r
  set fac 1.0
  if { $ANDOR_ARM == "blue" } {set fac -1.0}
  if { $env(TELESCOPE) == "WIYN" } {
    set r [fitshdrrecord  CD1_1	 double [expr $fac*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)] "Coordinate scale matrix \[degrees / pixel\]"]           
    $fid put keyword $r
    set r [fitshdrrecord  CD1_2	 double  0.0	"Coordinate scale matrix \[degrees / pixel\]"]
    $fid put keyword $r
    set r [fitshdrrecord  CD2_1	 double  0.0	"Coordinate scale matrix \[degrees / pixel\]"]
    $fid put keyword $r
    set r [fitshdrrecord  CD2_2	 double  [expr $PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)] "Coordinate scale matrix \[degrees / pixel\]"]
    $fid put keyword $r
  } else {
    set fac11 [expr -1.0*sin($TELEMETRY(tcs.telescope.instrpa)*180./$PI)]
    set fac12 [expr cos($TELEMETRY(tcs.telescope.instrpa)*180./$PI)]
    set fac21 [expr cos($TELEMETRY(tcs.telescope.instrpa)*180./$PI)]
    set fac22 [expr sin($TELEMETRY(tcs.telescope.instrpa)*180./$PI)]
    set r [fitshdrrecord  CD1_1	 double [expr $fac11*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)] "Coordinate scale matrix \[degrees / pixel\]"]           
    $fid put keyword $r
    set r [fitshdrrecord  CD1_2	 double  [expr $fac12*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)] "Coordinate scale matrix \[degrees / pixel\]"]
    $fid put keyword $r
    set r [fitshdrrecord  CD2_1	 double  [expr $fac21*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)] "Coordinate scale matrix \[degrees / pixel\]"]
    $fid put keyword $r
    set r [fitshdrrecord  CD2_2	 double  [expr $fac22*$PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ANDOR_CFG(binning)] "Coordinate scale matrix \[degrees / pixel\]"]
    $fid put keyword $r
  }
  set r [fitshdrrecord  CTYPE1	 string "DEC--TAN"	"Coordinate type"]
  $fid put keyword $r
  set r [fitshdrrecord  CTYPE2	 string  "RA--TAN"	"Coordinate type"]
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


# \endcode

set PI $PI2653589
set PSCALES(Gemini-North,fullframe) 	2.0138889E-05
set PSCALES(Gemini-North,speckle)	2.6666666E-06
set PSCALES(Gemini-South,fullframe) 	2.0138889E-05
set PSCALES(Gemini-South,speckle)	2.6666666E-06
set PSCALES(WIYN,fullframe) 	[expr 0.0813/3600./180.*$PI]
set PSCALES(WIYN,speckle) 	[expr 0.0182/3600./180.*$PI]
set PSCALES(GEMINI,fullframe) 	[expr 0.0725/3600./180.*$PI]
set PSCALES(GEMINI,speckle)	[expr 0.0096/3600./180.*$PI]
set ACQREGION(geom) 1024
set ANDOR_CFG(binning) 1
set ANDOR_CFG(frame) fullframe



