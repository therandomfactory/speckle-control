## \file convert.tcl
# \brief This file contains common instrument independent functions
#
#	<p>Ulyxes - an open source project to drive total stations and
#			publish observation results</p>
#	<p>GPL v2.0 license</p>
#	<p>Copyright (C) 2010-2012 Zoltan Siki <siki@agt.bme.hu></p>
#	@author Zoltan Siki 
#	@author Daniel Moka (TclDoc comments)
#	@version 1.0
#//#
set PI 3.141592653589
# \code
# Conversion function:
#
## Documented proc \c Deg2Rad .
# Convert sexagesimal angle to radian
# \param[in] deg angle in pseudo dms format (ddd.mmss)
# 	@return angle in radians
proc Deg2Rad {deg} {
	global PI
	set d [expr {int(floor($deg))}]
	set m [expr {int(floor(($deg - $d) * 100))}]
	set s [expr {($deg - $d - $m / 100.0) * 10000.0}]
	return [expr {($d + $m / 60.0 + $s / 3600.0) / 180.0 * $PI}]
}

# Conversion function:
#
## Documented proc \c Rad2Deg .
# Convert radian to sexagesimal into pseudo dms (ddd.mmss) format
# \param[in] angle value in radian
#	@return angle in pseudo DMS
proc Rad2Deg {angle} {
	global PI
	set d [expr {$angle * 180.0 / $PI}]	;# decimal degrees
	set dd [expr {int(floor($d))}]
	set m [expr {($d -$dd) * 60.0}]
	set mm [expr {int(floor($m))}]
	set ss [expr {int(($m -$mm) * 60.0)}]
	return "$dd.$mm$ss"
}



# Conversion function:
#
## Documented proc \c Deg2Rad .
#	Convert angle from radian to seconds (ss)
#	\param[in] angle angle value in radian
#	@return angle in second
proc Rad2Sec {rad} {
	global RO
	return [expr {$rad * $RO}]
}

# Conversion function:
#
## Documented proc \c DMS2Rad .
# Convert angle from DMS (sexagesimal) to radian
#	\param[in] angle in DMS (deg-min-sec) to convert into radian
#	@return angle in radian or empty string if invalid value got
proc DMS2Rad {dms} {
	global PI
        set sign 1
        if { [string range $dms 0 0] == "-" } {
           set dms [string trim $dms "-"]
           set sign -1
        }
        set dms [join [split $dms :] -]
	set m 0
	set s 0
	regsub -- "^(\[0-9\]+).*" $dms "\\1" d			;# degree
#	remove leading zeros
	regsub -- "^0+(.*)" $d "\\1" d
	if {$d == ""} {set d 0}
	if {[regexp "^\[0-9\]+-\[0-9\]+" $dms]} {
		regsub -- "^\[0-9\]+-(\[0-9\]+).*" $dms "\\1" m	;# minute
	}
#	remove leading zeros
	regsub -- "^0+(.*)" $m "\\1" m
	if {$m == ""} {set m 0}
	if {[regexp "^\[0-9\]+-\[0-9\]+-\[0-9\]+" $dms]} {
		regsub -- "^\[0-9\]+-\[0-9\]+-(\[0-9\]+.*)" $dms "\\1" s	;# second
	}
#	remove leading zeros
	regsub -- "^0+(.*)" $s "\\1" s
	if {$s == ""} {set s 0}
	# check limits for degree, minute & second
	if {$d > 359 || $m > 60 || $s > 60} {
		return ""
	} else {
		return [expr { $sign * ($d + $m / 60.0 + $s / 3600.0) / 180.0 * $PI}]
	}
}
# Conversion function:
#
## Documented proc \c HMSRad .
# Convert angle from DMS (sexagesimal) to radian
#	\param[in] angle in DMS (deg-min-sec) to convert into radian
#	@return angle in radian or empty string if invalid value got
proc HMS2Rad {dms} {
	global PI
        set sign 1
        if { [string range $dms 0 0] == "-" } {
           set dms [string trim $dms "-"]
           set sign -1
        }
        set dms [join [split $dms :] -]
	set m 0
	set s 0
	regsub -- "^(\[0-9\]+).*" $dms "\\1" d			;# degree
#	remove leading zeros
	regsub -- "^0+(.*)" $d "\\1" d
	if {$d == ""} {set d 0}
	if {[regexp "^\[0-9\]+-\[0-9\]+" $dms]} {
		regsub -- "^\[0-9\]+-(\[0-9\]+).*" $dms "\\1" m	;# minute
	}
#	remove leading zeros
	regsub -- "^0+(.*)" $m "\\1" m
	if {$m == ""} {set m 0}
	if {[regexp "^\[0-9\]+-\[0-9\]+-\[0-9\]+" $dms]} {
		regsub -- "^\[0-9\]+-\[0-9\]+-(\[0-9\]+.*)" $dms "\\1" s	;# second
	}
#	remove leading zeros
	regsub -- "^0+(.*)" $s "\\1" s
	if {$s == ""} {set s 0}
	# check limits for degree, minute & second
	if {$d > 359 || $m > 60 || $s > 60} {
		return ""
	} else {
		return [expr {$sign * ($d + $m / 60.0 + $s / 3600.0) / 12.0 * $PI}]
	}
}


# Conversion function:
#
## Documented proc \c DM2Rad .
# Convert angle from DM (NMEA format) to radian
#	\param[in] angle in DM (degmin.nnnn) to convert into radian
#	@return angle in radian
proc DM2Rad {dm} {
	global PI
	set sign 1
	set w [expr {$dm / 100.0}]
	if {$w < 0} {
		set sign -1
		set w [expr {abs($w)}]
	}
	set d [expr {floor($w)}]
	return [expr {$sign * ($d + ($w - $d) * 100. / 60.0) / 180.0 * $PI}]
}
# Conversion function:
#
## Documented proc \c DMS .
# Convert radian to DMS (sexagesimal)
#	\param[in] val angle in radian
#	@return angle in ddd-mm-ss format
proc DMS {val} {
	global PI
        set sign ""
        if { [string range $val 0 0] == "-" } {
           set val [string trim $val "-"]
           set sign "-"
        }
	set seconds [expr {$val * 180.0 / $PI * 3600}]
	set ss [expr {int($seconds)}]
	set d [expr {$ss / 3600}]
	set m [expr {($ss % 3600) / 60}]
	set s [expr {$ss % 60 + $seconds - $ss}]
	set wstr [format "[set sign]%3d:%02d:%02d" $d $m [expr {round($s)}]]
	return $wstr
}
# Conversion function:
#
## Documented proc \c HMS .
# Convert radian to HMS (sexagesimal)
#	\param[in] val angle in radian
#	@return angle in hh-mm-ss format
proc HMS {val} {
	global PI
        set sign ""
        if { [string range $val 0 0] == "-" } {
           set val [string trim $val "-"]
           set sign "-"
        }
        set val [expr $val/15.]
	set seconds [expr {$val * 180.0 / $PI * 3600}]
	set ss [expr {int($seconds)}]
	set d [expr {$ss / 3600}]
	set m [expr {($ss % 3600) / 60}]
	set s [expr {$ss % 60 + $seconds - $ss}]
	set wstr [format "[set sign]%2d:%02d:%02d" $d $m [expr {round($s)}]]
	return $wstr
}
# Conversion function:
#
## Documented proc \c ChangeAngle .
# Universal angle conversion function
#	\param[in] angle the angle to convert
#	\param[in] in actual unit of angle (DMS/DEG/RAD/GON)
#	\param[in] out target unit for result (DMS/DEG/RAD/GON)
#	@return angle in out unit
proc ChangeAngle {angle {in "DMS"} {out "RAD"}} {
	# convert angle to radians
	switch -exact $in {
		"RAD" { set r $angle }
		"DMS" { set r [DMS2Rad $angle] }
		"DEG" { set r [Deg2Rad $angle] }
		"GON" { set r [Gon2Rad $angle] }
	}
	switch -exact $out {
		"RAD" { set o $r }
		"DMS" { set o [DMS $r] }
		"DEG" { set o [Rad2Gon $r] }
		"GON" { set o [Rad2Gon $r] }
	}
	return $o
}

# \endcode

