#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2 If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2017 The Random Factory (www.randomfactopry.com) 
#
#
#
#
#

proc pxlSetup { cam exp bin x y roixs roiys } {
  set usec [expr int($exp*1000000)]
  pxlSetItem $cam  hbin $bin
  pxlSetItem $cam  vbin $bin
  pxlSetItem $cam  exposure_time $usec
  pxlSetItem $cam  npixx $x
  pxlSetItem $cam  npixy $y
  pxlSetItem $cam  PixelFormat Mono16
  pxlSetItem $cam  hstart $roixs
  pxlSetItem $cam  vstart $roiys
}

proc pxlBinning { {cam 1} {bin 4} } {
global PXS_STATUS PXS_LEAKRATE PXS_CONFIG
  pxlStream $cam stop
  pxlSetItem $cam  hbin $bin
  pxlSetItem $cam  vbin $bin
  pxlSetItem $cam  npixx [expr $PXS_STATUS($cam,SensorWidth)/$bin]
  pxlSetItem $cam  npixy [expr $PXS_STATUS($cam,SensorHeight)/$bin]
  pxlStream $cam start $PXS_CONFIG($cam,leak)
  pxlShmemDisp $PXS_CONFIG($cam,shmid) [expr $PXS_STATUS($cam,SensorWidth)/$bin] [expr $PXS_STATUS($cam,SensorHeight)/$bin]
  set PXS_STATUS($cam,scale) [expr $PXS_STATUS($cam,BinningX) * 0.0515]
  .cam$cam.lscl configure -text "Image scale : $PXS_STATUS($cam,scale) arcsecs per pixel"
}

proc pxlSetItem { cam item value {tries 5} } {
global ANDOR_CFG
  set dogeom 0
  setCurrentCamera $ANDOR_CFG($cam,handle)
  switch $item {
     exposure_time { setExposureTime $value }
     vstart -
     hstart -
     npixx  -
     npixy  -
     vbin   -
     hbin   { set ANDOR_CFG($item) $value
              set dogeom 1
            }
  }
  if { $dogeom } {
     SetImage $ANDOR_CFG(hbin) $ANDOR_CFG(vbin) $ANDOR_CFG(hstart) $ANDOR_CFG(hend) $ANDOR_CFG(vstart) $ANDOR_CFG(vend
  }
}


proc pxlSetROI { {cam 1} } {
global PXS_CONFIG
    exec xpaset -p ds9 regions deleteall
    exec xpaset -p ds9 regions -coord image
    exec echo "box 300 300 128 128 0" | xpaset  ds9 regions
    set it [tk_dialog .d "Edit region" "Resize/Move the region in the\n image display tool then click OK" {} -1 "OK"]
    set reg [split [exec xpaget ds9 regions] \n]
    foreach i $reg {
     if { [string range $i 0 2] == "box" } {
        set r [lrange [split $i ",()"] 1 4]
        set PXS_CONFIG($cam,xs) [expr int([lindex $r 0] - [lindex $r 2]/2)]
        set PXS_CONFIG($cam,xe) [expr int([lindex $r 0] + [lindex $r 2]/2)]
        set PXS_CONFIG($cam,ys) [expr int([lindex $r 1] - [lindex $r 3]/2)]
        set PXS_CONFIG($cam,ye) [expr int([lindex $r 1] + [lindex $r 3]/2)]
        set PXS_CONFIG($cam,xdata) [expr int([lindex $r 2])]
        set PXS_CONFIG($cam,ydata) [expr int([lindex $r 3])]
        addhistory  "selected region $r"
     }
    }
    pxlStream $cam stop
    pxlSetup $cam $PXS_CONFIG($cam,exposure) $PXS_CONFIG($cam,binning) $PXS_CONFIG($cam,xdata) $PXS_CONFIG($cam,ydata) $PXS_CONFIG($cam,xs) $PXS_CONFIG($cam,ys)
    pxlStream $cam start $PXS_CONFIG($cam,leak)
    pxlStart $cam [expr $PXS_CONFIG($cam,exposure)+10] $PXS_CONFIG($cam,xdata) $PXS_CONFIG($cam,ydata) 
}

proc pxlFullFrame { {cam 1} } {
global PXS_CONFIG PXS_STATUS
    set PXS_CONFIG($cam,xs) 0
    set PXS_CONFIG($cam,xe) $PXS_STATUS($cam,SensorWidth)
    set PXS_CONFIG($cam,ys) 0
    set PXS_CONFIG($cam,ye) $PXS_STATUS($cam,SensorHeight)
    set PXS_CONFIG($cam,xdata) [expr $PXS_STATUS($cam,SensorWidth)/$PXS_CONFIG($cam,binning)]
    set PXS_CONFIG($cam,ydata) [expr $PXS_STATUS($cam,SensorHeight)/$PXS_CONFIG($cam,binning)]
    pxlStream $cam stop
    set neww [expr $PXS_STATUS($cam,SensorWidth)/$PXS_CONFIG($cam,binning)]
    set newh [expr $PXS_STATUS($cam,SensorHeight)/$PXS_CONFIG($cam,binning)]
    pxlSetup $cam $PXS_CONFIG($cam,exposure) $PXS_CONFIG($cam,binning) $neww $newh $PXS_CONFIG($cam,xs) $PXS_CONFIG($cam,ys)
    pxlStream $cam start $PXS_CONFIG($cam,leak)
    pxlStart $cam [expr $PXS_CONFIG($cam,exposure)+10] $PXS_CONFIG($cam,xdata) $PXS_CONFIG($cam,ydata) 
}



proc pxlConfigure { cam property {val ""} } {
global PXS_CONFIG PXS_STATUS PXS_SNAPSHOT
   pxlStream $cam stop
   switch $property {
       binning  { pxlBinning $cam $val }
       exposure { 
                  pxlSetItem $cam  ExposureValue $val
                  addhistory "Setting ExposureValue to $nexp"
                  }
                  set PXS_SNAPSHOT($cam,interval) [format %7.3f [expr $PXS_CONFIG($cam,exposure)*1.1]]
                  if { $PXS_SNAPSHOT($cam,interval) < 0.1 } {set PXS_SNAPSHOT($cam,interval) 0.1}
                  pxlStream $cam start $PXS_CONFIG($cam,leak)
                }
       leak     {
                  pxlStream $cam start $PXS_CONFIG($cam,leak)
                }

   }
}

proc pxlROIGrid { {cam 1} } {
global PXS_CONFIG PXS_SNAPSHOT
    pxlStream $cam stop
    pxlStream $cam roi $PXS_SNAPSHOT($cam,number)
    pxlShmemDisp $PXS_CONFIG($cam,shmid) 1024 1024
    set PXS_CONFIG($cam,stream) 1
    pxlStreamds9
}

proc pxlUpdate { } {
   exec xpaset -p ds9 frame refresh
}

proc pxlStreamds9 { {cam 1} } {
global PXS_CONFIG PXS_SNAPSHOT
  if { $PXS_CONFIG($cam,stream) } {
    pxlUpdate
  }
  set t [expr int($PXS_SNAPSHOT($cam,interval)*1000)+10]
  after $t pxlStreamds9
}

proc pxlShmemDisp { shmid x y } {
  set size [expr $x*$y*2]
  exec xpaset -p ds9 shm array shmid $shmid \\\[xdim=$x,ydim=$y,bitpix=16\\\]
}

proc pxlShmemSnap { cam name {n 1} {t 100} } {
  if { $n > 1 } {
     set nid 1
     while { $nid <= $n } {
        exec xpaset -p ds9 savefits [set name]_[format %4.4d $nid].fits
        addhistory "Snapped image [set name]_[format %4.4d $nid].fits" $cam
        after 1000 "xpak_header [set name]_[format %4.4d $nid].fits"
        incr nid 1
        after $t
     }
  } else {
     exec xpaset -p ds9 savefits $name.fits
     addhistory "Snapped image [set name].fits" $cam
     after 1000 "xpak_header $name.fits"
  }
}

proc pxlSnapshot { cam } {
global PXS_SNAPSHOT
   set n $PXS_SNAPSHOT($cam,number)
   set i [expr int($PXS_SNAPSHOT($cam,interval)*1000*1.1)]
   set name $PXS_SNAPSHOT($cam,dir)/$PXS_SNAPSHOT($cam,name)
   pxlShmemSnap $cam $name $n $i
}


proc pxlInit { cam exp {bin 1} {x 1024} {y 1024} {roixs 0} {roiys 0} } {
global PXS_EXEC
   set running [llength [split [exec ps axw | grep Stream] \n]]
   if { $running > 1 } {
      exec pkill -INT Stream
      addhistory "Stopping image streaming"
      after 2000
   }
   pxlSetup $cam $exp $bin $x $y $roix $roiy
   addhistory "Starting image streaming $ip $exp $bin $x $y $roixs $roiys" $cam
   exec $PXS_EXEC/Stream -i $PXS_CONFIG($cam,shmid) &
}

proc pxlStream { cam op {leak 1} } {
global PXS_CONFIG PXS_EXEC PXS_SNAPSHOT
   set cmd "Stream"
   switch $op {
      start {
               set PXS_CONFIG($cam,stream) 1
               exec xterm -e $PXS_EXEC/$cmd -l $leak -i $PXS_CONFIG($cam,shmid) &
               addhistory "Restarted streaming for camera $cam" $cam
               exec xpaset -p ds9 scale zscale
             }
      roi    { 
               set bname $PXS_SNAPSHOT($cam,dir)/$PXS_SNAPSHOT($cam,name)
               exec xterm -e $PXS_EXEC/Stream2Fits -o $bname -c $leak -i $PXS_CONFIG($cam,shmid) &
               addhistory "Started ROI capture for camera $cam" $cam
               set PXS_CONFIG($cam,stream) 1
               exec xpaset -p ds9 scale zscale
             }
      stop   {
               set PXS_CONFIG($cam,stream) 0
               set running [llength [split [exec ps axw | grep $cmd] \n]]
               if { $running > 1 } {
                  exec pkill -INT $cmd
                  after 2000
                  addhistory "Stopped streaming for camera $cam" $cam
               }
             }
   }
}


proc pxlFind { } {
global ANDOR_DEF PXS_STATUS
   foreach cam "1 2" {
       addhistory "Initializing camera $cam"
       set PSX_STATUS($cam,xs) $ANDOR_DEF(hstart)
       set PSX_STATUS($cam,ys) $ANDOR_DEF(vstart)
       set PSX_STATUS($cam,xe) $ANDOR_DEF(hend)
       set PSX_STATUS($cam,ye) $ANDOR_DEF(vend)
       set PSX_STATUS($cam,xdata) $ANDOR_DEF(npixx)
       set PSX_STATUS($cam,ydata) $ANDOR_DEF(npixy)
       set PSX_STATUS($cam,exposure) $ANDOR_DEF(exposure_time)
       set PSX_STATUS($cam,binning) $ANDOR_DEF(hbin)
   }
}

proc pxlStart { {cam 1} {refresh 1100} {nx 1024} {ny 1024} } {
global PXS_CONFIG
  if { [info exists PXS_CONFIG($cam,shmid)] } {
    pxlShmemDisp $PXS_CONFIG($cam,shmid) $nx $ny
    set PXS_CONFIG($cam,stream) 1
    pxlStreamds9
    after 2000
    exec xpaset -p ds9 scale zscale
    return 1
  }
  return 0
}

proc choosedir { cam } {
global PXS_SNAPSHOT FLOG
   set cfg [tk_chooseDirectory -initialdir $PXS_SNAPSHOT($cam,dir)]
   if { [string length $cfg] > 0 } {
     if { [file exists $cfg] == 0 } {
        addhistory "Attempting to creat directory - $cfg"
        set res [catch {exec mkdir -p $cfg}]
        if { $res } {return}
        addhistory "Sucessfully created directory - $cfg"
     }
     set PXS_SNAPSHOT($cam,dir) $cfg
     .cam$cam.vdir configure -text "$cfg"
     addhistory "Output directory set to $cfg"
   }
}

proc addpakwcs { ra dec } {
global PXS_STATUS
  set fout [open /tmp/pakwcs.wcs w]
  set rad  [expr [hms_to_radians $ra]*180./3.1415926]
  set decd [expr [dms_to_radians $dec]*180./3.1415926]
  puts $fout "CRVAL1 00:00:00"
  puts $fout "CRVAL2 00:00:00"
  puts $fout "CRPIX1 [expr $PXS_STATUS($cam,SensorWidth)/$PXS_STATUS($cam,BinningX)/2]"
  puts $fout "CRPIX2 [expr $PXS_STATUS($cam,SensorHeight)/$PXS_STATUS($cam,BinningY)/2]"
  puts $fout "CD1_1 [expr 1.49826e-5*$PXS_STATUS($cam,BinningX)]"                   
  puts $fout "CD1_2 0.0"
  puts $fout "CD2_1 0.0"
  puts $fout "CD2_2 [expr 1.49826e-5*$PXS_STATUS($cam,BinningY)]"
  puts $fout "CTYPE1 'RA--TAN'"
  puts $fout "CTYPE2 'DEC--TAN'" 
  puts $fout "WCSNAME 'FK5'"
  puts $fout "RADECSYS 'FK5'"
  puts $fout "EQUINOX 2000."
  close $fout
  exec xpaset -p ds9 wcs replace /tmp/pakwcs.wcs
}

proc markusno { r d maglim } {
global PARENT gXLIM gYLIM gSCL gMAX gMIN gROT gRAD
    set uRES [usnofind 4 6.6 12.0 $maglim $r $d 2000.0]  
    exec xpaset -p ds9 regions coordformat hms &                                    
    exec xpaset -p ds9 regions coord fk5
    set fout [open /tmp/usno.reg w]
    foreach o [lrange [split $uRES "\n"] 1 end] {
       set ra  [join [lrange $o 4 6] :]
       set dec [join [lrange $o 7 9] :]
#       exec xpaset -p ds9 regions circle $ra $dec 15\" \# color=blue &
       set r [expr 3 + 20-[lindex $o 11]]
       puts $fout "circle($ra,$dec,$r) #color=\"blue\",text=\"[lindex $o 11]\""
    }
    close $fout
    exec xpaset -p ds9 regions load /tmp/usno.reg
}

proc updatewcs { } {
   set ra [lindex [kpno_wiyn info tcs.target.ra] 0]
   set dec [lindex [kpno_wiyn info tcs.target.dec] 0]
   addpakwcs $ra $dec
#   markusno $ra $dec 17.
}


# imsum option=average  pixtype=real calctype=real


proc addhistory { msg { cam ""} } {
global FLOG
   puts $FLOG $msg
   if { $cam != "" } {
      .cam$cam.lmsg configure -text "$msg"
   }
}

source $env(NESSI_DIR)/andorsConfiguration

set PXS_SNAPSHOT(nd) 0
set PXS_EXEC $env(NESSI_DIR)/bin
set PXS_ATTR "BinningX BinningY ExposureValue Height PixelFormat RegionX RegionY Width"
set PXS_GEOMETRY(IXon)    "1024 1024 13.0 13.0"
set PXS_GEOMETRY(IXonROI) " 256 256 13.0 13.0"
set PXS_CONFIG(1,shmid) [string trim $ANDORS(blue,serialnum) "X-"]
set PXS_CONFIG(2,shmid) [string trim $ANDORS(red,serialnum) "X-"]

set FLOG stdout
catch {exec pkill -9 Stream}
pxlFind

#create gui windows
foreach cam "1 2" {

  set PXS_CONFIG($cam,exposure) 0.04
  set PXS_CONFIG($cam,binning) 1
  set PXS_CONFIG($cam,leak) 1
  set PXS_CONFIG($cam,stream) 1
  set PXS_SNAPSHOT($cam,dir) /home/rfactory
  set PXS_SNAPSHOT($cam,number) 1
  set PXS_SNAPSHOT($cam,name) test
  set PXS_SNAPSHOT($cam,interval) 0.04
  set PXS_STATUS($cam,scale) [expr $PXS_CONFIG($cam,binning) * 0.01797]

#
#  Define a default sub-region
#  
  set PXS_CONFIG($cam,xs) 0
  set PXS_CONFIG($cam,xe) 1024
  set PXS_CONFIG($cam,ys) 0
  set PXS_CONFIG($cam,ye) 1024


  wm withdraw .
  toplevel .cam$cam
  wm geometry .cam$cam 430x350+30+30
  wm title .cam$cam "NESSI Camera Control - $PXS_CONFIG($cam,shmid)"

  label .cam$cam.lnam -text "Camera type : Andor IXon"
  label .cam$cam.luid -text "Camera Id : $PXS_CONFIG($cam,shmid) "
  label .cam$cam.lxpx -text "Sensor width : 1024"
  label .cam$cam.lypx -text "Sensor height : 1024"
  place  .cam$cam.lnam -x 20 -y 10
  place  .cam$cam.luid -x 170 -y 10
  place  .cam$cam.lxpx -x 20 -y 30
  place  .cam$cam.lypx -x 170 -y 30
  label .cam$cam.lscl -text "Image scale : $PXS_STATUS($cam,scale) arcsecs per pixel"
  place .cam$cam.lscl -x 20 -y 50

  label .cam$cam.lexp -text "Exposure (secs) :"
  label .cam$cam.lbin -text "Binning :"
  label .cam$cam.leak -text "Leaky memory (frames) :"
  label .cam$cam.lroi -text "ROI :"
  label .cam$cam.lxs  -text "xs"
  label .cam$cam.lxe  -text "xe"
  label .cam$cam.lys  -text "ys"
  label .cam$cam.lye  -text "ye"
  entry .cam$cam.vxs -width 5 -bg LightBlue -textvariable PXS_CONFIG($cam,xs)
  entry .cam$cam.vxe -width 5 -bg LightBlue -textvariable PXS_CONFIG($cam,xe)
  entry .cam$cam.vys -width 5 -bg LightBlue -textvariable PXS_CONFIG($cam,ys)
  entry .cam$cam.vye -width 5 -bg LightBlue -textvariable PXS_CONFIG($cam,ye)
  button .cam$cam.sroi -width 4 -text "Set" -command "pxlSetROI $cam"
  button .cam$cam.sall -width 4 -text "Full" -command "pxlFullFrame $cam"
  button .cam$cam.swcs -width 12 -text "Update WCS" -command "updatewcs"
  label .cam$cam.ldir -text "Snapshot directory :"
  label .cam$cam.limg -text "Snapshot filename :"
  label .cam$cam.lnum -text "Number of images :"
  label .cam$cam.lint -text "Interval (sec) :"
  entry .cam$cam.vimg -width 27 -bg LightBlue -textvariable PXS_SNAPSHOT($cam,name)
  entry .cam$cam.vnum -width 8 -bg LightBlue -textvariable PXS_SNAPSHOT($cam,number)
  entry .cam$cam.vint -width 8 -bg LightBlue -textvariable PXS_SNAPSHOT($cam,interval)
  button .cam$cam.vdir -width 24 -text "Configure data directory" -command "choosedir $cam"
  entry .cam$cam.vexp -width 8 -bg LightBlue -textvariable PXS_CONFIG($cam,exposure)
  entry .cam$cam.vlek -width 8 -bg LightBlue -textvariable PXS_CONFIG($cam,leak)
  foreach i "1 2 4 5 6" {
    radiobutton .cam$cam.vbin$i  -variable PXS_CONFIG($cam,binning) -text $i -value $i -command "pxlConfigure $cam binning $i"
  }
  button .cam$cam.snap -text "Take image(s)" -command "pxlSnapshot $cam" -width 46
  label .cam$cam.lmsg -text "Notifications appear here" -fg NavyBlue
  bind .cam$cam.vexp <Return> "pxlConfigure $cam exposure" 
  bind .cam$cam.vlek <Return> "pxlConfigure $cam leak" 
  button .cam$cam.go   -text "GO" -command "pxlConfigure $cam exposure"
  button .cam$cam.stop -text "STOP" -command "catch {exec pkill -9 Stream}"
  place .cam$cam.go   -x 204 -y 75
  place .cam$cam.stop -x 244 -y 75
  place .cam$cam.lexp -x 20 -y 80
  place .cam$cam.vexp -x 140 -y 80
  place .cam$cam.swcs -x 290 -y 75
  place .cam$cam.lbin -x 20 -y 110
  place .cam$cam.vbin1 -x 85 -y 110
  place .cam$cam.vbin2 -x 130 -y 110
  place .cam$cam.vbin4 -x 220 -y 110
  place .cam$cam.vbin5 -x 265 -y 110
  place .cam$cam.vbin6 -x 310 -y 110
  place .cam$cam.leak -x 20 -y 140
  place .cam$cam.vlek -x 170 -y 140
  place .cam$cam.lroi -x 20 -y 170
  place .cam$cam.lxs  -x 60 -y 170
  place .cam$cam.vxs  -x 80 -y 170
  place .cam$cam.lxe  -x 120 -y 170
  place .cam$cam.vxe  -x 140 -y 170
  place .cam$cam.lys  -x 180 -y 170
  place .cam$cam.vys  -x 200 -y 170
  place .cam$cam.lye  -x 240 -y 170
  place .cam$cam.vye  -x 260 -y 170
  place .cam$cam.sroi -x 310 -y 150
  place .cam$cam.sall -x 310 -y 175
  place .cam$cam.ldir -x 20 -y 200
  place .cam$cam.vdir -x 170 -y 200
  place .cam$cam.limg -x 20 -y 230
  place .cam$cam.vimg -x 170 -y 230
  place .cam$cam.lnum -x 20 -y 260
  place .cam$cam.vnum -x 140 -y 260
  place .cam$cam.lint -x 213 -y 260
  place .cam$cam.vint -x 303 -y 260
  place .cam$cam.snap -x 20 -y 290
  place .cam$cam.lmsg -x 20 -y 325 
}

foreach cam "1 2" {
#set standard acq defaults
  pxlSetItem $cam  PixelFormat Mono16
  pxlSetItem $cam  ExposureValue 0.04
  pxlSetItem $cam  BinningX 1
  pxlSetItem $cam  BinningY 1
}

set imred [image create photo -height 64 -width 64]
$imred read $env(NESSI_DIR)/andor/andor-red -format gif
label .cam2.im -image $imred
place .cam2.im -x 335 -y 2

set imblue [image create photo -height 64 -width 64]
$imblue read $env(NESSI_DIR)/andor/andor-blue -format gif
label .cam1.im -image $imblue
place .cam1.im -x 335 -y 2


####load /usr/local/gui/lib/shared/libxtcs.so
####source /usr/local/gui/tclsrc/scripts/gstar/xgsc_usno.tk
source $env(NESSI_DIR)/wiyn-scripts/xpak_header.tcl
puts stdout "Configuring camera - please wait"

if { [pxlFullFrame 1] == 0 } {
   addhistory "Andor Blue arm camera streaming not active."
}

if { [pxlFullFrame 2] == 0 } {
   addhistory "Andor Red arm camera streaming not active."
}

