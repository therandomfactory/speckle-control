wm title . "NESSI Control"
place .main -x 0 -y 30
place .mbar -x 0
.main configure -width 600
.mbar configure -width 600
place .mbar.help -x 550
set iy 50
foreach item "target ra dec equinox observer telescope instrument site latitude longitude" {
   place .main.l$item -x 360 -y $iy
   place .main.v$item -x 440 -y $iy
   incr iy 24 
}
place .main.ssite -x 530 -y 218


checkbutton .main.bred -bg gray50 -text "RED ARM" -variable INSTRUMENT(red)
place .main.bred -x 240 -y 70
checkbutton .main.bblue -bg gray50 -text "BLUE ARM" -variable INSTRUMENT(blue)
place .main.bblue -x 240 -y 97
.main configure -height 360

label .main.status -text test -fg NavyBlue
place .main.status -x 20 -y 330

.main.status configure -text "Run:YES   Shut:OPEN   FPS:32/32   Mode:CCD   Temp:ON:-50  Frame:200x200   PGain:10   NumPix:??"
 
frame .lowlevel -bg gray50 -width 600 -height 500
place .lowlevel -x 0 -y 380
label .lowlevel.red -text "RED ARM" -bg gray50
place .lowlevel.red -x 20 -y 20
label .lowlevel.blue -text "BLUE ARM" -bg gray50
place .lowlevel.blue -x 320 -y 20
checkbutton .lowlevel.clone -bg gray50 -text "Clone settings" -variable INSTRUMENT(clone)
place .lowlevel.clone -x 150 -y 20

set iy 300
foreach item "ZaberSpeckle ZaberWide ZaberHome ZaberOffset ZaberGoto" {
  label .lowlevel.r$item -bg gray50 -text $item
  place .lowlevel.r$item -x 20 -y $iy
  entry .lowlevel.er$item -bg white -textvariable INSTRUMENT(red,$item) -width 7
  place .lowlevel.er$item -x 120 -y $iy
  label .lowlevel.vr$item -bg gray50 -text "????"
  place .lowlevel.vr$item -x 200 -y $iy
  incr iy 24
}

set iy 300
foreach item "ZaberSpeckle ZaberWide ZaberHome ZaberOffset ZaberGoto" {
  label .lowlevel.b$item -bg gray50 -text $item
  place .lowlevel.b$item -x 320 -y $iy
  entry .lowlevel.eb$item -bg white -textvariable INSTRUMENT(blue,$item) -width 7
  place .lowlevel.eb$item -x 420 -y $iy
  label .lowlevel.vb$item -bg gray50 -text "????"
  place .lowlevel.vb$item -x 500 -y $iy
  incr iy 24
}

menubutton .lowlevel.rmode -text Mode  -width 10 -bg gray80 -menu .lowlevel.rmode.m
menu .lowlevel.rmode.m
place .lowlevel.rmode -x 20 -y 45
.lowlevel.rmode.m add command -label "Wide Field" -command "nessimode red wide"
.lowlevel.rmode.m add command -label "Speckle" -command "nessimode red speckle"
.lowlevel.rmode.m add command -label "Custom" -command "nessimode red custom"

menubutton .lowlevel.bmode -text Mode -width 10 -bg gray80 -menu .lowlevel.bmode.m
menu .lowlevel.bmode.m
place .lowlevel.bmode -x 320 -y 45
.lowlevel.bmode.m add command -label "Wide Field" -command "nessimode blue wide"
.lowlevel.bmode.m add command -label "Speckle" -command "nessimode blue speckle"
.lowlevel.bmode.m add command -label "Custom" -command "nessimode blue custom"

menubutton .lowlevel.rfilter -text Filter  -width 10 -bg gray80 -menu .lowlevel.rfilter.m
menu .lowlevel.rfilter.m
place .lowlevel.rfilter -x 20 -y 75
.lowlevel.rfilter.m add command -label "i" -command "nessifilter red i"
.lowlevel.rfilter.m add command -label "z" -command "nessifilter red z"
.lowlevel.rfilter.m add command -label "716" -command "nessifilter red 716"
.lowlevel.rfilter.m add command -label "832" -command "nessifilter red 832"

menubutton .lowlevel.bfilter -text Filter  -width 10 -bg gray80 -menu .lowlevel.bfilter.m
menu .lowlevel.bfilter.m
place .lowlevel.bfilter -x 320 -y 75
.lowlevel.bfilter.m add command -label "u" -command "nessifilter blue u"
.lowlevel.bfilter.m add command -label "g" -command "nessifilter blue g"
.lowlevel.bfilter.m add command -label "r" -command "nessifilter blue r"
.lowlevel.bfilter.m add command -label "467" -command "nessifilter blue 467"
.lowlevel.bfilter.m add command -label "562" -command "nessifilter blue 562"

proc nessifilter { arm name } {
  if { $arm == "red" } {
    .lowlevel.rfilter configure -text "Filter = $name"
  } else {
    .lowlevel.bfilter configure -text "Filter = $name"
  }
}

proc nessimode { arm name } {
  if { $arm == "red" } {
    .lowlevel.rmode configure -text "Mode=$name"
  } else {
    .lowlevel.bmode configure -text "Mode=$name"
  }
}

checkbutton .lowlevel.emccd  -bg gray50 -text "EMCCD" -variable INSTRUMENT(red,emccd)
checkbutton .lowlevel.hgain  -bg gray50 -text "High Gain" -variable INSTRUMENT(red,emccd)
label .lowlevel.lemgain  -bg gray50 -text "EM Gain"
SpinBox .lowlevel.emgain -width 4  -bg gray50  -range "0 1000 1" -textvariable INSTRUMENT(red,emgain)
label .lowlevel.lvspeed  -bg gray50 -text "VSpeed"
SpinBox .lowlevel.vspeed -width 4  -bg gray50   -range "0 1000 1" -textvariable INSTRUMENT(red,vspeed)
label .lowlevel.lemhs  -bg gray50 -text "EMCCD HS" 
SpinBox .lowlevel.emhs -width 4  -bg gray50   -range "0 30 1" -textvariable INSTRUMENT(red,emhs)
label .lowlevel.lccdhs  -bg gray50 -text "CCD HS" 
SpinBox .lowlevel.ccdhs -width 4  -bg gray50  -range "0 30 1" -textvariable INSTRUMENT(red,ccdhs)
place .lowlevel.emccd -x 20 -y 110
place .lowlevel.hgain -x 20 -y 140

place .lowlevel.lemgain -x 20 -y 170
place .lowlevel.emgain -x 120 -y 170

place .lowlevel.lvspeed -x 20 -y 200
place .lowlevel.vspeed -x 120 -y 200

place .lowlevel.lemhs -x 20 -y 230
place .lowlevel.emhs -x 120 -y 230

place .lowlevel.lccdhs -x 20 -y 260
place .lowlevel.ccdhs -x 120 -y 260


checkbutton .lowlevel.bemccd  -bg gray50 -text "EMCCD" -variable INSTRUMENT(blue,emccd)
checkbutton .lowlevel.bhgain  -bg gray50 -text "High Gain" -variable INSTRUMENT(blue,emccd)
label .lowlevel.lbemgain  -bg gray50 -text "EM Gain"
SpinBox .lowlevel.bemgain -width 4  -bg gray50  -range "0 1000 1" -textvariable INSTRUMENT(blue,emgain)
label .lowlevel.lbvspeed  -bg gray50 -text "Vspeed"
SpinBox .lowlevel.bvspeed -width 4  -bg gray50   -range "0 1000 1" -textvariable INSTRUMENT(blue,vspeed)
label .lowlevel.lbemhs  -bg gray50 -text "EMCCD HS" 
SpinBox .lowlevel.bemhs -width 4  -bg gray50  -range "0 30 1" -textvariable INSTRUMENT(blue,emhs)
label .lowlevel.lbccdhs  -bg gray50 -text "CCD HS" 
SpinBox .lowlevel.bccdhs -width 4  -bg gray50  -range "0 30 1" -textvariable INSTRUMENT(blue,ccdhs)
place .lowlevel.bemccd -x 320 -y 110
place .lowlevel.bhgain -x 320 -y 140

place .lowlevel.lbemgain -x 320 -y 170
place .lowlevel.bemgain -x 420 -y 170

place .lowlevel.lbvspeed -x 320 -y 200
place .lowlevel.bvspeed -x 420 -y 200

place .lowlevel.lbemhs -x 320 -y 230
place .lowlevel.bemhs -x 420 -y 230

place .lowlevel.lbccdhs -x 320 -y 260
place .lowlevel.bccdhs -x 420 -y 260

label .lowlevel.lrxbin -text Xbin -bg gray50
SpinBox .lowlevel.rxbin -width 4  -bg gray50 -range "1 32 1" -textvariable INSTRUMENT(red,xbin)
label .lowlevel.lrybin -text Ybin -bg gray50
SpinBox .lowlevel.rybin -width 4  -bg gray50 -range "1 32 1" -textvariable INSTRUMENT(red,ybin)
label .lowlevel.lrxmin -text Xmin -bg gray50
SpinBox .lowlevel.rxmin -width 4  -bg gray50 -range "0 1024 1" -textvariable INSTRUMENT(red,xmin)
label .lowlevel.lrxmax -text Xmax -bg gray50
SpinBox .lowlevel.rxmax -width 4  -bg gray50 -range "0 1024 1024" -textvariable INSTRUMENT(red,xmax)
label .lowlevel.lrymin -text Ymin -bg gray50
SpinBox .lowlevel.rymin -width 4  -bg gray50 -range "0 1024 1" -textvariable INSTRUMENT(red,ymin)
label .lowlevel.lrymax -text Ymax -bg gray50
SpinBox .lowlevel.rymax -width 4  -bg gray50 -range "0 1024 1024" -textvariable INSTRUMENT(red,ymax)
place .lowlevel.lrxbin -x 130 -y 70
place .lowlevel.rxbin -x 165 -y 70
place .lowlevel.lrybin -x 212 -y 70
place .lowlevel.rybin -x 245 -y 70
place .lowlevel.lrxmin -x 130 -y 95
place .lowlevel.rxmin -x 165 -y 95
place .lowlevel.lrxmax -x 212 -y 95
place .lowlevel.rxmax -x 245 -y 95
place .lowlevel.lrymin -x 130 -y 120
place .lowlevel.rymin -x 165 -y 120
place .lowlevel.lrymax -x 212 -y 120
place .lowlevel.rymax -x 245 -y 120

label .lowlevel.lbxbin -text Xbin -bg gray50
SpinBox .lowlevel.bxbin -width 4  -bg gray50 -range "1 32 1" -textvariable INSTRUMENT(blue,xbin)
label .lowlevel.lbybin -text Ybin -bg gray50
SpinBox .lowlevel.bybin -width 4  -bg gray50 -range "1 32 1" -textvariable INSTRUMENT(blue,ybin)
label .lowlevel.lbxmin -text Xmin -bg gray50
SpinBox .lowlevel.bxmin -width 4  -bg gray50 -range "0 1024 1" -textvariable INSTRUMENT(blue,xmin)
label .lowlevel.lbxmax -text Xmax -bg gray50
SpinBox .lowlevel.bxmax -width 4  -bg gray50 -range "0 1024 1024" -textvariable INSTRUMENT(blue,xmax)
label .lowlevel.lbymin -text Ymin -bg gray50
SpinBox .lowlevel.bymin -width 4  -bg gray50 -range "0 1024 1" -textvariable INSTRUMENT(blue,ymin)
label .lowlevel.lbymax -text Ymax -bg gray50
SpinBox .lowlevel.bymax -width 4  -bg gray50 -range "0 1024 1024" -textvariable INSTRUMENT(blue,ymax)
place .lowlevel.lbxbin -x 430 -y 70
place .lowlevel.bxbin -x 465 -y 70
place .lowlevel.lbybin -x 512 -y 70
place .lowlevel.bybin -x 545 -y 70
place .lowlevel.lbxmin -x 430 -y 95
place .lowlevel.bxmin -x 465 -y 95
place .lowlevel.lbxmax -x 512 -y 95
place .lowlevel.bxmax -x 545 -y 95
place .lowlevel.lbymin -x 430 -y 120
place .lowlevel.bymin -x 465 -y 120
place .lowlevel.lbymax -x 512 -y 120
place .lowlevel.bymax -x 545 -y 120

label .lowlevel.rpico -text "Pico position" -bg gray50
place .lowlevel.rpico -x 20 -y 425
button .lowlevel.rpicomm -width 3 -text "<<" -command "nessipico red --" -bg gray50
button .lowlevel.rpicom  -width 3 -text "<" -command "nessipico red -" -bg gray50
entry .lowlevel.vrpico -width 6 -bg white -textvariable INSTRUMENT(red,picopos)
button .lowlevel.rpicop  -width 3 -text ">" -command "nessipico red +" -bg gray50
button .lowlevel.rpicopp  -width 3 -text ">>" -command "nessipico red ++" -bg gray50
place .lowlevel.rpicomm -x 100 -y 425
place .lowlevel.rpicom -x 139 -y 425
place .lowlevel.vrpico -x 185 -y 428
place .lowlevel.rpicop -x 235 -y 425
place .lowlevel.rpicopp -x 270 -y 425


label .lowlevel.bpico -text "Pico position" -bg gray50
place .lowlevel.bpico -x 320 -y 425
button .lowlevel.bpicomm -width 3 -text "<<" -command "nessipico blue --" -bg gray50
button .lowlevel.bpicom  -width 3 -text "<" -command "nessipico blue -" -bg gray50
entry .lowlevel.vbpico -width 6 -bg white -textvariable INSTRUMENT(blue,picopos)
button .lowlevel.bpicop  -width 3 -text ">" -command "nessipico blue +" -bg gray50
button .lowlevel.bpicopp  -width 3 -text ">>" -command "nessipico blue ++" -bg gray50
place .lowlevel.bpicomm -x 400 -y 425
place .lowlevel.bpicom -x 439 -y 425
place .lowlevel.vbpico -x 485 -y 428
place .lowlevel.bpicop -x 535 -y 425
place .lowlevel.bpicopp -x 570 -y 425

 
button .lowlevel.rsave -text Save -bg gray70 -width 14 -command "nessisave red"
button .lowlevel.rload -text Load -bg gray70 -width 14 -command "nessiload red"
place .lowlevel.rsave -x 20  -y 460
place .lowlevel.rload -x 160 -y 460

button .lowlevel.bsave -text Save -bg gray70 -width 14 -command "nessisave blue"
button .lowlevel.bload -text Load -bg gray70 -width 14 -command "nessiload blue"
place .lowlevel.bsave -x 320  -y 460
place .lowlevel.bload -x 460 -y 460


