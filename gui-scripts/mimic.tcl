#
#  This code manages the mimic diagram to provide at-a-glance instrument status
#
#

proc createMimicDiagram { baseimg } {
global MOFF XO YO SPECKLE_DIR SCOPE
global oredwide obluewide  oredspck obluespck oinpwide oinpspck oredshut oblueshut XO YO MIMIC
  catch {destroy .mimicSpeckle}
  set XO [lindex $MOFF($baseimg) 0]
  set YO [lindex $MOFF($baseimg) 1]
  toplevel .mimicSpeckle -width 850 -height 640 
  wm title .mimicSpeckle "Speckle Instrument Configuration"
  canvas .mimicSpeckle.myCanvas  -width 849 -height 640 
  pack .mimicSpeckle.myCanvas
  set mimic [image create photo]
  $mimic read $SPECKLE_DIR/gui-scripts/[set baseimg].gif
  .mimicSpeckle.myCanvas create image 0 0 -anchor nw -image $mimic
  set oredwide   [.mimicSpeckle.myCanvas create oval 50 50 80 100 -fill yellow]
  set obluewide  [.mimicSpeckle.myCanvas create oval 50 50 100 80 -fill yellow]
  set oredspck   [.mimicSpeckle.myCanvas create oval 50 50 40 60 -fill yellow]
  set obluespck  [.mimicSpeckle.myCanvas create oval 50 50 60 40 -fill yellow]
  set oinpwide   [.mimicSpeckle.myCanvas create oval 50 50 80 140 -fill yellow]
  set oinpspck   [.mimicSpeckle.myCanvas create oval 50 50 80 100 -fill yellow]
  set oredshut   [.mimicSpeckle.myCanvas create oval 50 50 40 80 -fill white]
  set oblueshut  [.mimicSpeckle.myCanvas create oval 50 50 80 40 -fill white]
  label .mimicSpeckle.myCanvas.redfilt -width 10  -text "clear" 
  place .mimicSpeckle.myCanvas.redfilt -x [expr $XO+410] -y  [expr $YO+80]
  label .mimicSpeckle.myCanvas.bluefilt  -width 10  -text "clear" 
  place .mimicSpeckle.myCanvas.bluefilt -x [expr $XO+306] -y  [expr $YO+220]
  label .mimicSpeckle.myCanvas.redroi  -width 10  -text "1024x1024" 
  place .mimicSpeckle.myCanvas.redroi -x [expr $XO+716] -y  [expr $YO+120]
  label .mimicSpeckle.myCanvas.blueroi  -width 10  -text "1024x1024" 
  place .mimicSpeckle.myCanvas.blueroi -x [expr $XO+266] -y [expr $YO+540]
  label .mimicSpeckle.myCanvas.redtemp  -width 10  -text "0.0 deg" 
  place .mimicSpeckle.myCanvas.redtemp -x [expr $XO+716] -y  [expr $YO+140]
  label .mimicSpeckle.myCanvas.bluetemp  -width 10  -text "0.0 deg" 
  place .mimicSpeckle.myCanvas.bluetemp -x [expr $XO+266] -y  [expr $YO+560]
  label .mimicSpeckle.zaberA -text "Zaber A @ ???? : ????"
  label .mimicSpeckle.zaberB -text "Zaber B @ ???? : ????"
  label .mimicSpeckle.zaberInput -text "Zaber Input @ ???? : ????"
  if { $SCOPE(telescope) == "GEMINI" } {
    label .mimicSpeckle.zaberFocus -text "Zaber Focus @ ???? : ????"
    label .mimicSpeckle.zaberPickoff -text "Zaber Pickoff @ ???? : ????"
    place .mimicSpeckle.zaberFocus -x 640 -y 590
    place .mimicSpeckle.zaberPickoff -x 640 -y 620
  }
  place .mimicSpeckle.zaberA -x 640 -y 500
  place .mimicSpeckle.zaberB -x 640 -y 530
  place .mimicSpeckle.zaberInput -x 640 -y 560
  updateMimic
  wm geometry .mimicSpeckle +960+30
}


proc mimicMode { arm mode {value ""} } {
global oredwide obluewide  oredspck obluespck oinpwide oinpspck oredshut oblueshut XO YO MIMIC
   set MIMIC($arm,$mode) "$value"
   if { $arm == "red" } {
     if { $mode == "wide" } {
       .mimicSpeckle.myCanvas moveto $oredwide [expr $XO+450] [expr $YO+115]
       .mimicSpeckle.myCanvas moveto $oredspck [expr $XO+460 ] [expr $YO+180]
     }
     if { $mode == "speckle" } {
       .mimicSpeckle.myCanvas moveto $oredwide [expr $XO+450 ] [expr $YO+60]
       .mimicSpeckle.myCanvas moveto $oredspck [expr $XO+460 ] [expr $YO+135]
     }
     if { $mode == "open" } {
       .mimicSpeckle.myCanvas moveto $oredshut [expr $XO+670 ] [expr $YO+124]
     }
     if { $mode == "close" } {
       .mimicSpeckle.myCanvas moveto $oredshut [expr $XO+1000 ] [expr $YO+124]
     }
     if { $mode == "filter" } {
       .mimicSpeckle.myCanvas.redfilt configure -text $value
     }
     if { $mode == "roi" } {
       .mimicSpeckle.myCanvas.redroi configure -text $value
     }
     if { $mode == "temp" } {
       .mimicSpeckle.myCanvas.redtemp configure -text $value
     }
   }
   if { $arm == "blue" } {
     if { $mode == "wide" } {
       .mimicSpeckle.myCanvas moveto $obluewide [expr $XO+276 ] [expr $YO+260]
       .mimicSpeckle.myCanvas moveto $obluespck [expr $XO+341 ] [expr $YO+268]
     }
     if { $mode == "speckle" } {
       .mimicSpeckle.myCanvas moveto $obluewide [expr $XO+221 ] [expr $YO+260]
       .mimicSpeckle.myCanvas moveto $obluespck [expr $XO+297 ] [expr $YO+268]
     }
     if { $mode == "open" } {
       .mimicSpeckle.myCanvas moveto $oblueshut [expr $XO+286 ] [expr $YO+468]
     }
     if { $mode == "close" } {
       .mimicSpeckle.myCanvas moveto $oblueshut [expr $XO+286 ] [expr $YO+1000]
     }
     if { $mode == "filter" } {
       .mimicSpeckle.myCanvas.bluefilt configure -text $value
     }
     if { $mode == "roi" } {
       .mimicSpeckle.myCanvas.blueroi configure -text $value
     }
      if { $mode == "temp" } {
       .mimicSpeckle.myCanvas.bluetemp configure -text $value
     }
  }
   if { $arm == "input" } {
     if { $mode == "wide" } {
       .mimicSpeckle.myCanvas moveto $oinpwide [expr $XO+200 ] [expr $YO+95]
       .mimicSpeckle.myCanvas moveto $oinpspck [expr $XO+200 ] [expr $YO+35]
     }
     if { $mode == "speckle" } {
       .mimicSpeckle.myCanvas moveto $oinpwide [expr $XO+200 ] [expr $YO+180]
       .mimicSpeckle.myCanvas moveto $oinpspck [expr $XO+200 ] [expr $YO+115]
     }
   }
}

proc mimicOffset { x y } {
global oredwide obluewide  oredspck obluespck oinpwide oinpspck oredshut oblueshut
   foreach w "oredwide obluewide  oredspck obluespck oinpwide oinpspck oredshut oblueshut" {
       .mimicSpeckle.myCanvas move [set [set w]] $x $y
   }
}

proc updateMimic { } {
global MIMIC
  foreach w [array names MIMIC] {
     set arm [lindex [split $w ,] 0]
     set mode [lindex [split $w ,] 1]
     set value $MIMIC($arm,$mode)
     mimicMode $arm $mode $value
  }
}


set MOFF(mimic-picoin) "-29 7"
set MOFF(mimic) 	"0 0"
set MOFF(mimic-picoout) "-46 19"
createMimicDiagram mimic


mimicMode red wide
mimicMode blue wide
mimicMode input wide
mimicMode red open
mimicMode blue open


