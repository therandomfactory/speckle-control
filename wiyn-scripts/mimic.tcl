#
#  This code manages the mimic diagram to provide at-a-glance instrument status
#
#

proc createMimicDiagram { baseimg } {
global MOFF XO YO NESSI_DIR
  catch {destroy .mimicNessi}
  set XO [lindex $MOFF($baseimg) 0]
  set YO [lindex $MOFF($baseimg) 1]
  toplevel .mimicNessi -width 850 -height 640
  canvas .mimicNessi.myCanvas  -width 849 -height 640 
  pack .mimicNessi.myCanvas
  set mimic [image create photo]
  $mimic read $NESSI_DIR/wiyn-scripts/[set baseimg].gif
  .mimicNessi.myCanvas create image 0 0 -anchor nw -image $mimic
  set oredwide   [.mimicNessi.myCanvas create oval 50 50 80 100 -fill yellow]
  set obluewide  [.mimicNessi.myCanvas create oval 50 50 100 80 -fill yellow]
  set oredspck   [.mimicNessi.myCanvas create oval 50 50 40 60 -fill yellow]
  set obluespck  [.mimicNessi.myCanvas create oval 50 50 60 40 -fill yellow]
  set oinpwide   [.mimicNessi.myCanvas create oval 50 50 80 140 -fill yellow]
  set oinpspck   [.mimicNessi.myCanvas create oval 50 50 80 100 -fill yellow]
  set oredshut   [.mimicNessi.myCanvas create oval 50 50 40 80 -fill white]
  set oblueshut  [.mimicNessi.myCanvas create oval 50 50 80 40 -fill white]
  label .mimicNessi.myCanvas.redfilt -width 10  -text "clear" 
  place .mimicNessi.myCanvas.redfilt -x [expr $XO+410] -y  [expr $YO+80]
  label .mimicNessi.myCanvas.bluefilt  -width 10  -text "clear" 
  place .mimicNessi.myCanvas.bluefilt -x [expr $XO+306] -y  [expr $YO+220]
  label .mimicNessi.myCanvas.redroi  -width 10  -text "1024x1024" 
  place .mimicNessi.myCanvas.redroi -x [expr $XO+716] -y  [expr $YO+120]
  label .mimicNessi.myCanvas.blueroi  -width 10  -text "1024x1024" 
  place .mimicNessi.myCanvas.blueroi -x [expr $XO+266] -y [expr $YO+540]
  label .mimicNessi.myCanvas.redtemp  -width 10  -text "0.0 deg" 
  place .mimicNessi.myCanvas.redtemp -x [expr $XO+716] -y  [expr $YO+140]
  label .mimicNessi.myCanvas.bluetemp  -width 10  -text "0.0 deg" 
  place .mimicNessi.myCanvas.bluetemp -x [expr $XO+266] -y  [expr $YO+560]
}


proc mimicMode { arm mode {value ""} } {
global oredwide obluewide  oredspck obluespck oinpwide oinpspck oredshut oblueshut XO YO MIMIC
   set MIMIC($arm,$mode) "$value"
   if { $arm == "red" } {
     if { $mode == "wide" } {
       .mimicNessi.myCanvas moveto $oredwide [expr $XO+450] [expr $YO+115]
       .mimicNessi.myCanvas moveto $oredspck [expr $XO+460 ] [expr $YO+180]
     }
     if { $mode == "speckle" } {
       .mimicNessi.myCanvas moveto $oredwide [expr $XO+450 ] [expr $YO+60]
       .mimicNessi.myCanvas moveto $oredspck [expr $XO+460 ] [expr $YO+135]
     }
     if { $mode == "open" } {
       .mimicNessi.myCanvas moveto $oredshut [expr $XO+670 ] [expr $YO+124]
     }
     if { $mode == "close" } {
       .mimicNessi.myCanvas moveto $oredshut [expr $XO+1000 ] [expr $YO+124]
     }
     if { $mode == "filter" } {
       .mimicNessi.myCanvas.redfilt configure -text $value
     }
     if { $mode == "roi" } {
       .mimicNessi.myCanvas.redroi configure -text $value
     }
     if { $mode == "temp" } {
       .mimicNessi.myCanvas.redtemp configure -text $value
     }
   }
   if { $arm == "blue" } {
     if { $mode == "wide" } {
       .mimicNessi.myCanvas moveto $obluewide [expr $XO+276 ] [expr $YO+260]
       .mimicNessi.myCanvas moveto $obluespck [expr $XO+341 ] [expr $YO+268]
     }
     if { $mode == "speckle" } {
       .mimicNessi.myCanvas moveto $obluewide [expr $XO+221 ] [expr $YO+260]
       .mimicNessi.myCanvas moveto $obluespck [expr $XO+297 ] [expr $YO+268]
     }
     if { $mode == "open" } {
       .mimicNessi.myCanvas moveto $oblueshut [expr $XO+286 ] [expr $YO+468]
     }
     if { $mode == "close" } {
       .mimicNessi.myCanvas moveto $oblueshut [expr $XO+286 ] [expr $YO+1000]
     }
     if { $mode == "filter" } {
       .mimicNessi.myCanvas.bluefilt configure -text $value
     }
     if { $mode == "roi" } {
       .mimicNessi.myCanvas.blueroi configure -text $value
     }
      if { $mode == "temp" } {
       .mimicNessi.myCanvas.bluetemp configure -text $value
     }
  }
   if { $arm == "input" } {
     if { $mode == "wide" } {
       .mimicNessi.myCanvas moveto $oinpwide [expr $XO+200 ] [expr $YO+95]
       .mimicNessi.myCanvas moveto $oinpspck [expr $XO+200 ] [expr $YO+35]
     }
     if { $mode == "speckle" } {
       .mimicNessi.myCanvas moveto $oinpwide [expr $XO+200 ] [expr $YO+180]
       .mimicNessi.myCanvas moveto $oinpspck [expr $XO+200 ] [expr $YO+115]
     }
   }
}

proc mimicOffset { x y } {
global oredwide obluewide  oredspck obluespck oinpwide oinpspck oredshut oblueshut
   foreach w "oredwide obluewide  oredspck obluespck oinpwide oinpspck oredshut oblueshut" {
       .mimicNessi.myCanvas move [set [set w]] $x $y
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


