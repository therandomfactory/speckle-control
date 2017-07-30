


#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : getDSS
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (djm@randomfactory.com)
#  Version    : 0.9
#  Date       : Aug-04-2003
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure provides access to the Digital Sky Survey (100x compressed)
#  dataset. These can be purchased from "The Astronomical Society of the Pacific"
#  The cdroms provide 1arcsec resolution coverage of the entire sky. 
#  The location of the DSS files is specified by the configuration in
#  /opt/apogee/scripts/dss.env
#
#  Arguments  :
#
#               name	-	Image file name
#               ra	-	RA in the form hh:mm:ss.ss
#               dec	-	DEC in the form +ddd:mm:ss.ss
#               xsize	-	X dimension in arcmin
#               ysize	-	Y dimension in arcmin
 
proc getDSS {name ra dec xsize ysize } {
 
#
#  Globals    :		n/a
#  
   set fout [open /tmp/dsscmd w]
   puts $fout "$name [split $ra :] [split $dec :] $xsize $ysize"
   close $fout
   dss -i /tmp/dsscmd
   set f [glob $name*.fits]
   checkDisplay
   exec xpaset -p ds9 file $f
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : checkDisplay
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (djm@randomfactory.com)
#  Version    : 0.9
#  Date       : Aug-04-2003
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure checks if the image display tool DS9 is up and running.
#  If not we start a copy. The xpans server is used to communicate with DS9
#  it should always be running, as a copy is started by the /opt/apogee/scripts/setup.env
#
#  Arguments  :
#
 
proc checkDisplay { } {
 
#
#  Globals    :		n/a
#  
   set x ""
   catch {set x [exec xpaget ds9]}
   if { $x == "" } {
      exec /opt/apogee/bin/ds9 &
   }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : getGSC
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (djm@randomfactory.com)
#  Version    : 0.9
#  Date       : Aug-04-2003
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This proceduure provides access to the Compressed version of the Hubble
#  Guide Star Catalog. This catalog contains the same set of objects, but 
#  occupies only ~300Mb of disk space, rather than 2 full cdroms.
#
#  The obtained set of positions are overlaid on the current image displayed
#  in the DS9 image display tool. For other purposes, simply use the 
#  cmdGFind call to return the list of objects for further processing.
#
#  Arguments  :
#
#               ra	-	RA in the form hh:mm:ss.ss
#               dec	-	DEC in the form +ddd:mm:ss.ss
#               xsize	-	X dimension in arcmin
#               ysize	-	Y dimension in arcmin
 
proc getGSC { ra dec xsize ysize } {
 
#
#  Globals    :		n/a
#  
   if { $xsize < 0 } {
      set results [exec cat testgsc.dat]
   } else {
      set results [cmdGFind $ra $dec $xsize $ysize]
   }
   set byline [lrange [split $results "\n"] 1 end]
   exec xpaset -p ds9 regions deleteall                                                
   foreach l $byline {
      set lra  [join [lrange $l 1 3] :]
      set ldec [join [lrange $l 4 6] :]
      exec xpaset -p ds9 regions circle $lra $ldec 5.
   }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : locateObjs
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (djm@randomfactory.com)
#  Version    : 0.9
#  Date       : Aug-04-2003
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  Test routine, will eventually be part of automatic image coordinate
#  system calibration
#
#  Arguments  :
#
 
proc locateObjs { } {
 
#
#  Globals    :		n/a
#  
   set fin [open test.cat r]
   exec xpaset -p ds9 regions coordformat xy
   exec xpaset -p ds9 regions deleteall                                                
   set i 7
   while { $i > 0 } {gets $fin rec ;  incr i -1}
   while { [gets $fin rec] > -1 } {
      exec xpaset -p ds9 regions circle [lindex $rec 4] [lindex $rec 5] 5.
   }
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : getRegion
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (djm@randomfactory.com)
#  Version    : 0.9
#  Date       : Aug-04-2003
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  This procedure will eventaully be part of automatic coordinate determination
#
#  Arguments  :
#
 
proc getRegion { } {
 
#
#  Globals    :		n/a
#  
   set res [exec xpaget  ds9 regions]
   set i [lsearch $res "image\;box"]
   if { $i < 0 } {
      exec  xpaset -p ds9 regions deleteall  
      tk_dialog
   }
   set lx [lindex $res [expr $i+1]]
   set ly [lindex $res [expr $i+2]]
   set nx [lindex $res [expr $i+3]]
   set ny [lindex $res [expr $i+4]]
#  test command for sextractor
# /opt/apogee/bin/sextractor -DETECT_MINAREA 10 -DETECT_THRESH 30 test207vo.fits        
}




#---------------------------------------------------------------------------
#---------------------------------------------------------------------------
#
#  Procedure  : autoIdentify
#
#---------------------------------------------------------------------------
#  Author     : Dave Mills (djm@randomfactory.com)
#  Version    : 0.9
#  Date       : Aug-04-2003
#  Copyright  : The Random Factory, Tucson AZ
#  License    : GNU GPL
#  Changes    :
#
#  Experimental - This procedure attempts to autocorrelate image coordinate
#  lists between GSC and an  sextractor run
#
#
#  Arguments  :
#
#               imax	-	Maximum number of candidates (optional, default is 20)
#               type	-	Calibration type (flat,dark,sky,zero) (optional, default is raw)
#               aspp	-	Threshold (optional, default is 1.7)
 
proc autoIdentify { {imax 20} {type raw} {aspp 1.7} } {
 
#
#  Globals    :
#  
#               X	-	X data for temperature plot
#               Y	-	Y data for temperature plot
#               F	-	 
global X Y F
    exec sort -r +2 test.cat > stest.dat
    if { $type == "raw" } {
     set fin [open stest.dat r]
     set i 1
     while { $i < $imax } {
        gets $fin rec
        if { [string range $rec 0 0] != "#" } {   
          set X($i) [lindex $rec 4]
          set Y($i) [lindex $rec 5]
          set F($i) [lindex $rec 2]
          incr i 1
        }
     }
     close $fin
    } 
    if { $type == "gsc" } {
     set fin [open testgsc.dat r]
     set i 1
     set DEC 50
     while { $i < $imax } {
        gets $fin rec
        set dec [expr ([lindex $rec 4]*3600+[lindex $rec 5]*60+[lindex $rec 6])  / $aspp]
        set ra [expr ([lindex $rec 1]*3600+[lindex $rec 2]*60+[lindex $rec 3]) *15. / $aspp]
        set ra [expr $ra*cos($DEC/180.*3.14159)]
        set X($i) $ra
        set Y($i) $dec
        set F($i) [lindex $rec 7]
        incr i 1
     }
     close $fin
    } 
    set i 1
    while { $i < $imax } {
       set mind 9999999999.
       set maxd 0.
       set j 1
       while { $j < $imax  } {
         if { $i != $j } {
           set d [expr sqrt( ($X($i)-$X($j))*($X($i)-$X($j)) + ($Y($i)-$Y($j))*($Y($i)-$Y($j)) )]
           if { $d > $maxd } {set maxd $d}
           if { $d < $mind && $d > 50.} {
              set mind $d
              set minj($i) $j
           }
         }
         incr j 1
       }
       set M($i) [expr $maxd / $mind]
       puts stdout "$i $mind $minj($i)"
       incr i 1
    }
}





