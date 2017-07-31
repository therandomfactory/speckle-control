#
#
#

proc pxlSetup { cam exp bin x y roixs roiys } {
global PSIL_EXEC PSIL_STATUS
  set ip $PSIL_STATUS($cam,DeviceIPAddress)
  set usec [expr int($exp*1000000)]
  exec $PSIL_EXEC/CamAttr -i $ip -s BinningX $bin
  exec $PSIL_EXEC/CamAttr -i $ip -s BinningY $bin
  exec $PSIL_EXEC/CamAttr -i $ip -s ExposureValue $usec
  exec $PSIL_EXEC/CamAttr -i $ip -s Width  $x
  exec $PSIL_EXEC/CamAttr -i $ip -s Height $y
  exec $PSIL_EXEC/CamAttr -i $ip -s PixelFormat Mono16
  exec $PSIL_EXEC/CamAttr -i $ip -s RegionX $roixs
  exec $PSIL_EXEC/CamAttr -i $ip -s RegionY $roiys
}

proc pxlBinning { {cam 1} {bin 4} } {
global PSIL_STATUS PSIL_LEAKRATE PSIL_CONFIG PSIL_EXEC
  pxlStream $cam stop
  set ip $PSIL_STATUS($cam,DeviceIPAddress)
  exec $PSIL_EXEC/CamAttr -i $ip -s BinningX $bin
  exec $PSIL_EXEC/CamAttr -i $ip -s BinningY $bin
  exec $PSIL_EXEC/CamAttr -i $ip -s Width [expr $PSIL_STATUS($cam,SensorWidth)/$bin]
  exec $PSIL_EXEC/CamAttr -i $ip -s Height [expr $PSIL_STATUS($cam,SensorHeight)/$bin]
  pxlStream $cam start $PSIL_CONFIG($cam,leak)
  pxlShmemDisp $PSIL_CONFIG($cam,shmid) [expr $PSIL_STATUS($cam,SensorWidth)/$bin] [expr $PSIL_STATUS($cam,SensorHeight)/$bin]
  set PSIL_STATUS($cam,scale) [expr $PSIL_STATUS($cam,BinningX) * 0.0515]
  .cam$cam.lscl configure -text "Image scale : $PSIL_STATUS($cam,scale) arcsecs per pixel"
}

proc pxlSetItem { cam item value {tries 5} } {
   set ip $PSIL_STATUS($cam,DeviceIPAddress)
   catch { 
      set current [exec $PSIL_EXEC/CamAttr -i $ip -g $item]
      while { $value != $current && $tries > 0 } {
         exec $PSIL_EXEC/CamAttr -i $ip -s $item $value
         incr tries -1
         set current [exec $PSIL_EXEC/CamAttr -i $ip -g $item]
      }
   }
   return $current
}


proc pxlSetROI { {cam 1} } {
global PSIL_CONFIG
    exec xpaset -p ds9 regions deleteall
    exec xpaset -p ds9 regions -coord image
    exec echo "box 300 300 128 128 0" | xpaset  ds9 regions
    set it [tk_dialog .d "Edit region" "Resize/Move the region in the\n image display tool then click OK" {} -1 "OK"]
    set reg [split [exec xpaget ds9 regions] \n]
    foreach i $reg {
     if { [string range $i 0 2] == "box" } {
        set r [lrange [split $i ",()"] 1 4]
        set PSIL_CONFIG($cam,xs) [expr int([lindex $r 0] - [lindex $r 2]/2)]
        set PSIL_CONFIG($cam,xe) [expr int([lindex $r 0] + [lindex $r 2]/2)]
        set PSIL_CONFIG($cam,ys) [expr int([lindex $r 1] - [lindex $r 3]/2)]
        set PSIL_CONFIG($cam,ye) [expr int([lindex $r 1] + [lindex $r 3]/2)]
        set PSIL_CONFIG($cam,xdata) [expr int([lindex $r 2])]
        set PSIL_CONFIG($cam,ydata) [expr int([lindex $r 3])]
        addhistory  "selected region $r"
     }
    }
    pxlStream $cam stop
    pxlSetup $cam $PSIL_CONFIG($cam,exposure) $PSIL_CONFIG($cam,binning) $PSIL_CONFIG($cam,xdata) $PSIL_CONFIG($cam,ydata) $PSIL_CONFIG($cam,xs) $PSIL_CONFIG($cam,ys)
    pxlStream $cam start $PSIL_CONFIG($cam,leak)
    pxlStart $cam [expr $PSIL_CONFIG($cam,exposure)+10] $PSIL_CONFIG($cam,xdata) $PSIL_CONFIG($cam,ydata) 
}

proc pxlFullFrame { {cam 1} } {
global PSIL_CONFIG PSIL_STATUS
    set PSIL_CONFIG($cam,xs) 0
    set PSIL_CONFIG($cam,xe) $PSIL_STATUS($cam,SensorWidth)
    set PSIL_CONFIG($cam,ys) 0
    set PSIL_CONFIG($cam,ye) $PSIL_STATUS($cam,SensorHeight)
    set PSIL_CONFIG($cam,xdata) [expr $PSIL_STATUS($cam,SensorWidth)/$PSIL_CONFIG($cam,binning)]
    set PSIL_CONFIG($cam,ydata) [expr $PSIL_STATUS($cam,SensorHeight)/$PSIL_CONFIG($cam,binning)]
    pxlStream $cam stop
    set neww [expr $PSIL_STATUS($cam,SensorWidth)/$PSIL_CONFIG($cam,binning)]
    set newh [expr $PSIL_STATUS($cam,SensorHeight)/$PSIL_CONFIG($cam,binning)]
    pxlSetup $cam $PSIL_CONFIG($cam,exposure) $PSIL_CONFIG($cam,binning) $neww $newh $PSIL_CONFIG($cam,xs) $PSIL_CONFIG($cam,ys)
    pxlStream $cam start $PSIL_CONFIG($cam,leak)
    pxlStart $cam [expr $PSIL_CONFIG($cam,exposure)+10] $PSIL_CONFIG($cam,xdata) $PSIL_CONFIG($cam,ydata) 
}



proc pxlConfigure { cam property {val ""} } {
global PSIL_CONFIG PSIL_STATUS PSIL_EXEC PSIL_SNAPSHOT
   pxlStream $cam stop
   switch $property {
       binning  { pxlBinning $cam $val }
       exposure { 
#if { $PSIL_CONFIG($cam,exposure) < 0.05 } {set PSIL_CONFIG($cam,exposure) 0.05}
                  set nexp [expr $PSIL_CONFIG($cam,exposure)*1000000.]
                  set ip $PSIL_STATUS($cam,DeviceIPAddress)
                  set res [exec $PSIL_EXEC/CamAttr -i $ip -g ExposureValue]
                  while { $res != $nexp } {
                     exec $PSIL_EXEC/CamAttr -i $ip -s ExposureValue $nexp
                     set res [exec $PSIL_EXEC/CamAttr -i $ip -g ExposureValue]
                     addhistory "Setting ExposureValue to $nexp"
                  }
                  set PSIL_SNAPSHOT($cam,interval) [format %7.3f [expr $PSIL_CONFIG($cam,exposure)*1.1]]
                  if { $PSIL_SNAPSHOT($cam,interval) < 0.1 } {set PSIL_SNAPSHOT($cam,interval) 0.1}
                  pxlStream $cam start $PSIL_CONFIG($cam,leak)
                }
       leak     {
                  pxlStream $cam start $PSIL_CONFIG($cam,leak)
                }

   }
}

proc pxlROIGrid { {cam 1} } {
global PSIL_CONFIG PSIL_SNAPSHOT
    pxlStream $cam stop
    pxlStream $cam roi $PSIL_SNAPSHOT($cam,number)
    pxlShmemDisp $PSIL_CONFIG($cam,shmid) 1024 1024
    set PSIL_CONFIG($cam,stream) 1
    pxlStreamds9
}

proc pxlUpdate { } {
   exec xpaset -p ds9 frame refresh
}

proc pxlStreamds9 { {cam 1} } {
global PSIL_CONFIG PSIL_SNAPSHOT
  if { $PSIL_CONFIG($cam,stream) } {
    pxlUpdate
  }
  set t [expr int($PSIL_SNAPSHOT($cam,interval)*1000)+10]
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
global PSIL_SNAPSHOT
   set n $PSIL_SNAPSHOT($cam,number)
   set i [expr int($PSIL_SNAPSHOT($cam,interval)*1000*1.1)]
   set name $PSIL_SNAPSHOT($cam,dir)/$PSIL_SNAPSHOT($cam,name)
   pxlShmemSnap $cam $name $n $i
}


proc pxlInit { cam exp {bin 1} {x 3296} {y 2472} {roixs 0} {roiys 0} } {
global PSIL_EXEC
   set running [llength [split [exec ps axw | grep Stream] \n]]
   if { $running > 1 } {
      exec pkill -INT Stream
      addhistory "Stopping image streaming"
      after 2000
   }
   pxlSetup $cam $exp $bin $x $y $roix $roiy
   addhistory "Starting image streaming $ip $exp $bin $x $y $roixs $roiys" $cam
   exec $PSIL_EXEC/Stream &
}

proc pxlStream { cam op {leak 1} } {
global PSIL_CONFIG PSIL_EXEC PSIL_SNAPSHOT
   set cmd "Stream"
   if { $cam > 1 } { set cmd "Stream$cam" }
   switch $op {
      start {
               set PSIL_CONFIG($cam,stream) 1
               exec xterm -e $PSIL_EXEC/$cmd -l $leak &
               addhistory "Restarted streaming for camera $cam" $cam
               exec xpaset -p ds9 scale zscale
             }
      roi    { 
               set bname $PSIL_SNAPSHOT($cam,dir)/$PSIL_SNAPSHOT($cam,name)
               exec xterm -e $PSIL_EXEC/Stream2Fits -o $bname -c $leak &
               addhistory "Started ROI capture for camera $cam" $cam
               set PSIL_CONFIG($cam,stream) 1
               exec xpaset -p ds9 scale zscale
             }
      stop   {
               set PSIL_CONFIG($cam,stream) 0
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
global PSIL_EXEC PSIL_CAMERA PSIL_STATUS
   set all [split [exec $PSIL_EXEC/CLIpConfig -l] \n]
   set nc 0
   if { [llength $all] > 1 } {
      foreach cam [lrange $all 1 end] {
         addhistory "Found camera $cam"
         incr nc 1
         set id [lindex [split $cam =] 1]
         set PSIL_CAMERA($nc) "[lindex $cam 2] $id"
         set ipaddr [exec $PSIL_EXEC/CamAttr -u $id -g DeviceIPAddress]
         set cattr [split [exec $PSIL_EXEC/ListAttributes $ipaddr] \n]
         foreach item $cattr {
            set id [lindex [split [lindex $item 0] /] end]
            set val [lindex [lindex [split $item "="] 1] 0]
            set PSIL_STATUS($nc,$id) "$val"
         }
      }
   }
}

proc pxlStart { {cam 1} {refresh 1100} {nx 1648} {ny 1236} } {
global PSIL_CONFIG
  set shared [exec ipcs -a]
  set gid [expr [lsearch $shared 16400000] - 3]
  set ic 1
  while { $gid > 0 } {
    set PSIL_CONFIG($ic,shmid) [lindex $shared $gid]
    set shared [lrange $shared [expr $gid +4] end]
    set gid [expr [lsearch $shared 16400000] - 3]
    incr ic 1
  }
  if { [info exists PSIL_CONFIG($cam,shmid)] } {
    pxlShmemDisp $PSIL_CONFIG($cam,shmid) $nx $ny
    set PSIL_CONFIG($cam,stream) 1
    pxlStreamds9
    after 2000
    exec xpaset -p ds9 scale zscale
    return 1
  }
  return 0
}

proc choosedir { cam } {
global PSIL_SNAPSHOT FLOG
   set cfg [tk_chooseDirectory -initialdir $PSIL_SNAPSHOT($cam,dir)]
   if { [string length $cfg] > 0 } {
     if { [file exists $cfg] == 0 } {
        addhistory "Attempting to creat directory - $cfg"
        set res [catch {exec mkdir -p $cfg}]
        if { $res } {return}
        addhistory "Sucessfully created directory - $cfg"
     }
     set PSIL_SNAPSHOT($cam,dir) $cfg
     .cam$cam.vdir configure -text "$cfg"
     addhistory "Output directory set to $cfg"
   }
}

proc addpakwcs { ra dec } {
global PSIL_STATUS
  set fout [open /tmp/pakwcs.wcs w]
  set rad  [expr [hms_to_radians $ra]*180./3.1415926]
  set decd [expr [dms_to_radians $dec]*180./3.1415926]
  puts $fout "CRVAL1 00:00:00"
  puts $fout "CRVAL2 00:00:00"
  puts $fout "CRPIX1 [expr $PSIL_STATUS($cam,SensorWidth)/$PSIL_STATUS($cam,BinningX)/2]"
  puts $fout "CRPIX2 [expr $PSIL_STATUS($cam,SensorHeight)/$PSIL_STATUS($cam,BinningY)/2]"
  puts $fout "CD1_1 [expr 1.49826e-5*$PSIL_STATUS($cam,BinningX)]"                   
  puts $fout "CD1_2 0.0"
  puts $fout "CD2_1 0.0"
  puts $fout "CD2_2 [expr 1.49826e-5*$PSIL_STATUS($cam,BinningY)]"
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

proc adjustnd { cam op } {
global PSIL_SNAPSHOT PSIL_CONFIG
  switch $op {
     plus  { incr PSIL_SNAPSHOT(nd) 1 }
     minus { incr PSIL_SNAPSHOT(nd) -1 }
  }
  .cam$cam.nd configure -text "ND=$PSIL_SNAPSHOT(nd)"
  set newexp [format %7.3f [expr pow(2.51,$PSIL_SNAPSHOT(nd)) ]]
  set PSIL_CONFIG($cam,exposure) $newexp
  pxlConfigure 1 exposure $newexp
###  catch {exec pkill -9 Stream}
}

proc powercamera { op  {cam 1} } {
   if { $op == "on" } {
     exec xterm -e /usr/local/bin/poe-on-3
     .cam$cam.pon configure -relief sunken
     .cam$cam.poff configure -relief raised
   } else {
     exec xterm -e /usr/local/bin/poe-off-3
     .cam$cam.pon configure -relief raised
     .cam$cam.poff configure -relief sunken
   }
}

set PSIL_SNAPSHOT(nd) 0
set PSIL_EXEC /usr/local/gui/tclsrc/guider/AVTSDK/bin-pc/x86
set PSIL_ATTR "BinningX BinningY ExposureValue Height PixelFormat RegionX RegionY Width"
set PSIL_GEOMETRY(GX2750) "2752 2200 4.54 4.54"
set PSIL_GEOMETRY(GT3300) "3296 2472 4.54 4.54"

set FLOG stdout
catch {exec pkill -9 Stream}
pxlFind

#default to first camera
set cam 1
set ip $PSIL_STATUS($cam,DeviceIPAddress)

#set standard acq defaults
exec $PSIL_EXEC/CamAttr -i $ip -s PixelFormat Mono16
exec $PSIL_EXEC/CamAttr -i $ip -s ExposureValue 1000000
exec $PSIL_EXEC/CamAttr -i $ip -s BinningX 5
exec $PSIL_EXEC/CamAttr -i $ip -s BinningY 5
pxlFind

set PSIL_CONFIG($cam,exposure) [expr $PSIL_STATUS($cam,ExposureValue)/1000000.]
set PSIL_CONFIG($cam,binning) $PSIL_STATUS($cam,BinningX)
set PSIL_CONFIG($cam,leak) 1
set PSIL_CONFIG($cam,stream) 1
set PSIL_SNAPSHOT($cam,dir) /home/wiyn
set PSIL_SNAPSHOT($cam,number) 1
set PSIL_SNAPSHOT($cam,name) test
set PSIL_SNAPSHOT($cam,interval) 1.0
set PSIL_STATUS($cam,scale) [expr $PSIL_STATUS($cam,BinningX) * 0.0515]

#
#  Define a default sub-region
#  
set PSIL_CONFIG($cam,xs) $PSIL_STATUS($cam,RegionX)
set PSIL_CONFIG($cam,xe) [expr $PSIL_STATUS($cam,Width) * $PSIL_STATUS($cam,BinningX)]
set PSIL_CONFIG($cam,ys) $PSIL_STATUS($cam,RegionY)
set PSIL_CONFIG($cam,ye) [expr $PSIL_STATUS($cam,Height) * $PSIL_STATUS($cam,BinningY)]

wm withdraw .
toplevel .cam$cam
wm geometry .cam$cam 430x350+30+30
wm title .cam$cam "Camera Control - $PSIL_STATUS($cam,DeviceIPAddress)"

label .cam$cam.lnam -text "Camera type : $PSIL_STATUS($cam,CameraName)"
label .cam$cam.luid -text "Camera ID : $PSIL_STATUS($cam,UniqueId)"
label .cam$cam.lxpx -text "Sensor width : $PSIL_STATUS($cam,SensorWidth)"
label .cam$cam.lypx -text "Sensor height : $PSIL_STATUS($cam,SensorHeight)"
place  .cam$cam.lnam -x 20 -y 10
place  .cam$cam.luid -x 170 -y 10
place  .cam$cam.lxpx -x 20 -y 30
place  .cam$cam.lypx -x 170 -y 30
label .cam$cam.lscl -text "Image scale : $PSIL_STATUS($cam,scale) arcsecs per pixel"
place .cam$cam.lscl -x 20 -y 50
button .cam$cam.pon -width 8 -text "Power ON" -command "powercamera on"
button .cam$cam.poff -width 8 -text "Power OFF" -command "powercamera off"
place .cam$cam.pon  -x 330 -x 0
place .cam$cam.poff -x 330 -x 30

label .cam$cam.lexp -text "Exposure (secs) :"
label .cam$cam.lbin -text "Binning :"
label .cam$cam.leak -text "Leaky memory (frames) :"
label .cam$cam.lroi -text "ROI :"
label .cam$cam.lxs  -text "xs"
label .cam$cam.lxe  -text "xe"
label .cam$cam.lys  -text "ys"
label .cam$cam.lye  -text "ye"
entry .cam$cam.vxs -width 5 -bg LightBlue -textvariable PSIL_CONFIG($cam,xs)
entry .cam$cam.vxe -width 5 -bg LightBlue -textvariable PSIL_CONFIG($cam,xe)
entry .cam$cam.vys -width 5 -bg LightBlue -textvariable PSIL_CONFIG($cam,ys)
entry .cam$cam.vye -width 5 -bg LightBlue -textvariable PSIL_CONFIG($cam,ye)
button .cam$cam.sroi -width 4 -text "Set" -command "pxlSetROI $cam"
button .cam$cam.sall -width 4 -text "Full" -command "pxlFullFrame $cam"
button .cam$cam.swcs -width 12 -text "Update WCS" -command "updatewcs"


label .cam$cam.nd -width 4 -text "ND=0"
place .cam$cam.nd -x 312 -y 80
button .cam$cam.plusnd  -text "+" -width 2 -command "adjustnd 1 plus"
button .cam$cam.minusnd -text "-" -width 2 -command "adjustnd 1 minus"
place .cam$cam.minusnd -x 360 -y 88
place .cam$cam.plusnd  -x 360 -y 61


label .cam$cam.ldir -text "Snapshot directory :"
label .cam$cam.limg -text "Snapshot filename :"
label .cam$cam.lnum -text "Number of images :"
label .cam$cam.lint -text "Interval (sec) :"
entry .cam$cam.vimg -width 27 -bg LightBlue -textvariable PSIL_SNAPSHOT($cam,name)
entry .cam$cam.vnum -width 8 -bg LightBlue -textvariable PSIL_SNAPSHOT($cam,number)
entry .cam$cam.vint -width 8 -bg LightBlue -textvariable PSIL_SNAPSHOT($cam,interval)


button .cam$cam.vdir -width 24 -text "Configure data directory" -command "choosedir $cam"
entry .cam$cam.vexp -width 8 -bg LightBlue -textvariable PSIL_CONFIG($cam,exposure)
entry .cam$cam.vlek -width 8 -bg LightBlue -textvariable PSIL_CONFIG($cam,leak)
foreach i "1 2 4 5 6" {
   radiobutton .cam$cam.vbin$i  -variable PSIL_CONFIG($cam,binning) -text $i -value $i -command "pxlConfigure $cam binning $i"
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
place .cam$cam.swcs -x 250 -y 78
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


load /usr/local/gui/lib/shared/libxtcs.so
source /usr/local/gui/tclsrc/scripts/gstar/xgsc_usno.tk
source xpak_header.tcl
puts stdout "Configuring camera - please wait"

if { [pxlFullFrame] == 0 } {
   addhistory "Prosilica camera streaming not active."
}


