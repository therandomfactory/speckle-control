#
#  export XPA_METHOD=local before starting xpans and ds9
#  then 
#
#  xpaset -p ds9 source ds9refresher.tcl
#
#  then e.g for 100 freshes at 500msec intervals
#
#  xpaset -p ds9 \{refinit 500 100\}
#  xpaset -p ds9 refresher
#

proc refinit { delta rmax } {
global REFRESHING REFDELTA REFMAX
  set REFRESHING 1
  set REFDELTA $delta
  set REFMAX $rmax
}

proc refresher { } {
global REFRESHING REFDELTA REFMAX
  if { $REFRESHING < $REFMAX } {
    UpdateAllFrame
    after $REFDELTA refresher
    incr REFRESHING 1
  }
}


