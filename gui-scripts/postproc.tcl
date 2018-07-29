## \file postproc.tcl
# \brief This contains procedures for initiating post processing of the images
#
# This Source Code Form is subject to the terms of the GNU Public\n
# License, v. 2 If a copy of the GPL was not distributed with this file,\n
# You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html\n
#\n
# Copyright(c) 2018 The Random Factory (www.randomfactory.com) \n
#\n
#
#
#\code
## Documented proc \c postProcess .
# \param[in] fname Name of FITS data file
#
# Generic hook for post processing
#
proc postProcess { fname } {
  sendToArchive $fname
}


## Documented proc \c sendToArchive .
# \param[in] fname Name of FITS data file
#
# Queue a FITS file for archiving with Save-the-bits or similar
#
proc sendToArchive { fname } {
  if { [file exists $fname] } {
     if { [file exists /bits/bin/postproc] } {
        if { [file executable /bits/bin/postproc] } {
            debuglog "Queueing $fname for archiving"
            catch {exec /bits/bin/postproc $fname} result
        } else {
            set result "ERROR /bits/bin/postproc not executable"
        }
     } else {
        set result "ERROR /bits/bin/postproc not found"
     }
  } else {
     set result "ERROR Image not found : $fname"
  }
  debuglog "postProcess: $result"
  return $result
}

# \endcode


