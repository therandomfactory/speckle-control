#
# This Source Code Form is subject to the terms of the GNU Public
# License, v. 2 If a copy of the GPL was not distributed with this file,
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
#
# Copyright(c) 2017 The Random Factory (www.randomfactory.com) 
#
#

#
# Command set for rotator
#
#  Open, Initialize, Close, Home, Stop, Vel+, Vel-, Led, MoveTo, MoveRel, SetPos, GetPos, Update
#


proc rotatorCommand { cmd {p1 ""} {p2 ""} {p3 ""} } {
global ZABERS
{
   switch $cmd {
       open    { set ZABERS(rotator) [za_connect $ZABERS(rotatorName)] }
       stop    { za_send estop $ZABERS(rotator) }
       close   { za_disconnect $ZABERS(rotator) }
       velinc  { incr ZABERS(rotator,speed) 1 ; za_send $ZABERS(rotator) "set maxspeed ZABERS(rotator,speed) }
       veldec  { incr ZABERS(rotator,speed) -1 ; za_send $ZABERS(rotator) "set maxspeed ZABERS(rotator,speed) }
       led     { zaberLed $ZABERS(rotator) $p1 }
       moveto  { za_send "move $p1 abs $p2" }
       moverel { za_send "move $p1 rel $p2" }
       setpos  { za_send "set $p1 pos $p2" }
       getpos  { }
   }
}

load $env(NESSI_DIR)/lib/libzaber.so
set ZABERS(rotator,speed) 10
set ZABERS(rotator,unit) 3
set ZABERS(rotatorName) "rotator"


