## \file ds9refresher.tcl
# \brief This script is loaded into ds9 to support continous refresh update the shared memory buffered images
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2017 The Random Factory (www.randomfactory.com)\n 
#\n
#  export XPA_METHOD=local before starting xpans and ds9\n
#  then \n
#\n
#  xpaset -p ds9 source ds9refresher.tcln\n
#\n
#  then e.g for 100 freshes at 500msec intervals\n
#\n
#  xpaset -p ds9 \{refinit 500 100\}\n
#  xpaset -p ds9 refresher\n
#
# \code
## Documented proc \c refinit .
# \param[in] delta Refresh interval in millseconds
# \param[in] rmax Number of refresh cycles\
#
#  Initialize a refresh loop in ds9
#
# Globals : \n
#		REFRESHING - 1 if still refreshing\n
#		REFDELTA - Save refresh period\n
#		REFMAX - Save refresh count
#
proc refinit { delta rmax } {
global REFRESHING REFDELTA REFMAX
  set REFRESHING 1
  set REFDELTA $delta
  set REFMAX $rmax
}

## Documented proc \c refresher .
# \param[in] delta Refresh interval in millseconds
# \param[in] rmax Number of refresh cycles\
#
#  Refresh all image buffers and schedule next run
#
# Globals : \n
#		REFRESHING - 1 if still refreshing\n
#		REFDELTA - Save refresh period\n
#		REFMAX - Save refresh count
#
proc refresher { } {
global REFRESHING REFDELTA REFMAX
  if { $REFRESHING < $REFMAX } {
    UpdateAllFrame
    after $REFDELTA refresher
    incr REFRESHING 1
  }
}

# \endcode



