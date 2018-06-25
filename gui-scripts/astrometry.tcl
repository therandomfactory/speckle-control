set PI 3.141592653589

proc updateds9wcs { ra dec } {
global SCOPE ACQREGION PSCALES ANDOR_CFG PI
  set radeg [expr [hms_to_radians $ra]*180/$PI]
  set decdeg [expr [dms_to_radians $dec]*180/$PI]
  set fout [open /tmp/pakwcs.wcs w]
  puts $fout "CRVAL1 $radeg"
  puts $fout "CRVAL2 $decdeg"
  puts $fout "CRPIX1 [expr $ACQREGION(geom)/$ACQREGION(bin)/2]"
  puts $fout "CRPIX2 [expr $ACQREGION(geom)/$ACQREGION(bin)/2]"
  puts $fout "CD1_1 [expr $PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ACQREGION(bin)]"              
     
  puts $fout "CD1_2 0.0"
  puts $fout "CD2_1 0.0"
  puts $fout "CD2_2 [expr $PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ACQREGION(bin)]"
  puts $fout "CTYPE1 'RA--TAN'"
  puts $fout "CTYPE2 'DEC--TAN'" 
  puts $fout "WCSNAME 'FK5'"
  puts $fout "RADECSYS 'FK5'"
  puts $fout "EQUINOX 2000."
  close $fout
  exec xpaset -p ds9red wcs replace /tmp/pakwcs.wcs
  exec xpaset -p ds9blue wcs replace /tmp/pakwcs.wcs
}

proc headerAstrometry { fid ra dec } {
global ACQREGION SCOPE PSCALES ANDOR_CFG PI
  set radeg [expr [hms_to_radians $ra]*180/$PI]
  set decdeg [expr [dms_to_radians $dec]*180/$PI]
  set r [fitshdrrecord  CRVAL1	 string "$radeg"	"R.A. of reference pixel \[deg\]"]
  $fid put keyword $r
  set r [fitshdrrecord  CRVAL2	 string "$decdeg"	"Declination of reference pixel \[deg\]"]
  $fid put keyword $r
  set r [fitshdrrecord  CRPIX1	 integer [expr $ACQREGION(geom)/$ACQREGION(bin)/2]	"Coordinate reference pixel in X"]
  $fid put keyword $r
  set r [fitshdrrecord  CRPIX2	 integer [expr $ACQREGION(geom)/$ACQREGION(bin)/2]	"Coordinate reference pixel in Y"]
  $fid put keyword $r
  set r [fitshdrrecord  CD1_1	 double [expr $PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ACQREGION(bin)]  "Coordinate scale matrix \[degrees / pixel\]"]           
  $fid put keyword $r
  set r [fitshdrrecord  CD1_2	 double  0.0	"Coordinate scale matrix \[degrees / pixel\]"]
  $fid put keyword $r
  set r [fitshdrrecord  CD2_1	 double  0.0	"Coordinate scale matrix \[degrees / pixel\]"]
  $fid put keyword $r
  set r [fitshdrrecord  CD2_2	 double  [expr $PSCALES($SCOPE(telescope),$ANDOR_CFG(frame))*$ACQREGION(bin)]	"Coordinate scale matrix \[degrees / pixel\]"]
  $fid put keyword $r
  set r [fitshdrrecord  CTYPE1	 string 'RA--TAN'	"Coordinate type"]
  $fid put keyword $r
  set r [fitshdrrecord  CTYPE2	 string  'DEC--TAN'	"Coordinate type"]
  $fid put keyword $r
  set r [fitshdrrecord  WCSNAME  string 'FK5'	"World coordinate system type"]
  $fid put keyword $r
  set r [fitshdrrecord  RADECSYS string 'FK5'	"Default coordinate system type"]
  $fid put keyword $r
  set r [fitshdrrecord  EQUINOX	 float 2000.	"Default coordinate system Equinox"]
  $fid put keyword $r
}

proc dms_to_radians { dms } {
global PI
   set t [string trim $dms "+ "]
   set s 1
   if { [string range $t 0 0] == "-" } {
      set s -1
      set dms [string trim $dms "-"]
   }
   set f [split $dms ":"]
   set r [expr $s * ([lindex $f 0] + [lindex $f 1]/60.0 + [lindex $f 2]/3600.0 )/180. * $PI]
}

proc hms_to_radians { hms } {
global PI
   set f [split $hms ":"]
   set r [expr ([lindex $f 0] + [lindex $f 1]/60.0 + [lindex $f 2]/3600.0 )/12. * $PI]
}



set PSCALES(WIYN,fullframe) 	[expr 0.0813/3600./180.*$PI]
set PSCALES(WIYN,speckle) 	[expr 0.0182/3600./180.*$PI]
set PSCALES(GEMINI,fullframe) 	[expr 0.0725/3600./180.*$PI]
set PSCALES(GEMINI,speckle)	[expr 0.0096/3600./180.*$PI]
set ACQREGION(geom) 1024
set ACQREGION(bin) 1
set ANDOR_CFG(frame) fullframe



