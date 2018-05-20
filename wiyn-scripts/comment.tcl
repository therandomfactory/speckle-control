#
#  Observing gui dimensions need changing
#
text .main.comment -height 16 -width 50 
label .main.lcomment -text "Comments :" -bg gray
checkbutton .main.clrcomment -bg gray -variable SCOPE(autoclrcmt) -text "Auto-clear"

place .main.comment -x 560 -y 50
place .main.lcomment -x 560 -y 25
place .main.clrcomment -x 640 -y 25
