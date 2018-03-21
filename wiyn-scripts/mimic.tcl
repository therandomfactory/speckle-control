#
#  This code manages the mimic diagram to provide at-a-glance instrument status
#
#

toplevel .mimicNessi -width 850 -height 640

canvas .mimicNessi.myCanvas  -width 849 -height 640 
pack .mimicNessi.myCanvas
set mimic [image create photo]
$mimic read $NESSI_DIR/wiyn-scripts/mimic.gif
.mimicNessi.myCanvas create image 0 0 -anchor nw -image $mimic

set oredwide   [.mimicNessi.myCanvas create oval 50 50 80 100 -fill yellow]
set obluewide  [.mimicNessi.myCanvas create oval 50 50 100 80 -fill yellow]

set oredspck   [.mimicNessi.myCanvas create oval 50 50 40 60 -fill yellow]
set obluespck  [.mimicNessi.myCanvas create oval 50 50 60 40 -fill yellow]

set oinpwide  [.mimicNessi.myCanvas create oval 50 50 80 140 -fill yellow]
set oinpspck  [.mimicNessi.myCanvas create oval 50 50 80 100 -fill yellow]

set oredshut  [.mimicNessi.myCanvas create oval 50 50 40 80 -fill white]
set oblueshut [.mimicNessi.myCanvas create oval 50 50 80 40 -fill white]

label .mimicNessi.myCanvas.redfilt -width 10  -text "Red-???" 
place .mimicNessi.myCanvas.redfilt -x 410 -y 80

label .mimicNessi.myCanvas.bluefilt  -width 10  -text "Blue-???" 
place .mimicNessi.myCanvas.bluefilt -x 230 -y 220

label .mimicNessi.myCanvas.redroi  -width 10  -text "1024x1024" 
place .mimicNessi.myCanvas.redroi -x 716 -y 120
label .mimicNessi.myCanvas.blueroi  -width 10  -text "1024x1024" 
place .mimicNessi.myCanvas.blueroi -x 266 -y 540

label .mimicNessi.myCanvas.redtemp  -width 10  -text "0.0 deg" 
place .mimicNessi.myCanvas.redtemp -x 716 -y 140
label .mimicNessi.myCanvas.bluetemp  -width 10  -text "0.0 deg" 
place .mimicNessi.myCanvas.bluetemp -x 266 -y 560

proc mimicMode { arm mode {value ""} } {
global oredwide obluewide  oredspck obluespck oinpwide oinpspck oredshut oblueshut
   if { $arm == "red" } {
     if { $mode == "wide" } {
       .mimicNessi.myCanvas move $oredwide 450 115
       .mimicNessi.myCanvas move $oredspck 460 180
     }
     if { $mode == "speckle" } {
       .mimicNessi.myCanvas move $oredwide 450 60
       .mimicNessi.myCanvas move $oredspck 460 135
     }
     if { $mode == "open" } {
       .mimicNessi.myCanvas move $oredshut 670 124
     }
     if { $mode == "close" } {
       .mimicNessi.myCanvas move $oredshut 1000 124
     }
     if { $mode == "filter" } {
       .mimicNessi.myCanvas.redfilt configure -text $value
     }
     if { $mode == "roi" } {
       .mimicNessi.myCanvas.redroi configure -text $value
     }
   }
   if { $arm == "blue" } {
     if { $mode == "wide" } {
       .mimicNessi.myCanvas move $obluewide 276 260
       .mimicNessi.myCanvas move $obluespck 341 268 
     }
     if { $mode == "speckle" } {
       .mimicNessi.myCanvas move $obluewide 221 260
       .mimicNessi.myCanvas move $obluespck 297 268
     }
     if { $mode == "open" } {
       .mimicNessi.myCanvas move $oblueshut 286 468
     }
     if { $mode == "close" } {
       .mimicNessi.myCanvas move $oblueshut 286 1000
     }
     if { $mode == "filter" } {
       .mimicNessi.myCanvas.bluefilt configure -text $value
     }
     if { $mode == "roi" } {
       .mimicNessi.myCanvas.blueroi configure -text $value
     }
   }
   if { $arm == "input" } {
     if { $mode == "wide" } {
       .mimicNessi.myCanvas move $oinpwide 200 95
       .mimicNessi.myCanvas move $oinpspck 200 35
     }
     if { $mode == "speckle" } {
       .mimicNessi.myCanvas move $oinpwide 200 180
       .mimicNessi.myCanvas move $oinpspck 200 115
     }
   }
}

mimicMode red wide
mimicMode blue wide
mimicMode input wide
mimicMode red open
mimicMode blue open


