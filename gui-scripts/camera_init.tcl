
proc loadconfig { } {
global CONFIG panDetector panStatus
   panQuerySet default
   set CONFIG(system.Interface) NET
   set CONFIG(system.Data_Bits) 16
   set CONFIG(system.Sensor)    $panDetector
   set CONFIG(system.MaxBinX)   65535    
   set CONFIG(system.MaxBinY)   65535
   set CONFIG(geometry.Columns) $panStatus(pxlCols)    
   set CONFIG(geometry.Rows)    $panStatus(pxlRows) 
   set CONFIG(geometry.ImgCols) $panStatus(imageCols)  
   set CONFIG(geometry.ImgRows) $panStatus(imageRows)  
#   set CONFIG(geometry.BIC)     $panStatus(xPreScan) 
   set CONFIG(geometry.BIR)     0 
#   set CONFIG(geometry.SkipC)   $panStatus(colSkip)    
#   set CONFIG(geometry.SkipR)   $panStatus(rowSkip) 
#   set CONFIG(geometry.BinX)    $panStatus(colBin) 
#   set CONFIG(geometry.BinY)    $panStatus(rowBin)  
   set CONFIG(temp.Control)     True    
   set CONFIG(temp.Target)      -100.0    
   set CONFIG(temp.Cal)         1.0   
   set CONFIG(temp.Scale)       1.0   
   set CONFIG(ccd.Sensor)       $panDetector    
   set CONFIG(ccd.Noise)        3.0
   set CONFIG(ccd.Gain)         3.0
   set CONFIG(ccd.PixelXSize)   9.0
   set CONFIG(ccd.PixelYSize)   9.0
}

proc speckleTelemetryUpdate { } {
global SCOPE TELEMETRY FITSKEY IMGMETA
   foreach i [array names SCOPE] {
       set TELEMETRY(speckle.scope.$i) $SCOPE($i)
   }
   foreach i [array names FITSKEY] {
      if { [info exists IMGMETA([lindex [split $i .] end],value)] } {
          set TELEMETRY($i) $IMGMETA([lindex [split $i .] end],value)
      }
   }
   if { $SCOPE(telescope) == "WIYN" } {
      redisUpdate
   }
}

proc shutdown { {id 0} } {
 
#
#  Globals    :
#  
#               CAMERAS	-	Camera id's
global CAMERAS ANDOR ANDOR_SOCKET SCOPE
   set it [tk_dialog .d "Exit" "Confirm exit" {} -1 "Cancel" "EXIT"]
   if { $it } {
#     set camera $CAMERAS($id)
#     $camera $cooler 2
     if { $SCOPE(telescope) == "GEMINI" } {
        debuglog "Moving Gemini mechanisms to stowed positions"
        picosOutPosition
        zaberGoto focus stow
        zaberGoto pickoff stow
     }
     savespecklegui
     catch { commandAndor red shutdown }
     catch { commandAndor blue shutdown }
     catch { exec xpaset -p ds9 exit }
     after 5000
     catch { exec pkill -9 tail }
     exit
   }
}

set CAMSTATUS(Gain) 1.0
set CAMSTATUS(BinX) 1
set CAMSTATUS(BinY) 1
set CAMSTATUS(Temperature) -100.0
set CAMSTATUS(CoolerMode) 1
set SCOPE(latitude) 31:57:11.78
set SCOPE(longitude) 07:26:27.97
set SCOPE(camera) "Andor iXon Ultra"
set SCOPE(observer) ""
set SCOPE(target) test
set SCOPE(exposure) 1.0
set SCOPE(ra) 00:00:00.00
set SCOPE(dec) +00:00:00.00
set SCOPE(equinox) 2000.0
set SCOPE(secz) 0.0
set SCOPE(filterpos) 0
set SCOPE(filtername) none
set SCOPE(shutter) 1
set now [split [exec  date -u +%Y-%m-%d,%T] ,]
set SCOPE(readout-delay) 999
set SCOPE(obsdate) [exec date -u +%Y-%m-%dT%H:%M:%S.0]
set SCOPE(timeobs) [lindex $now 1]

source $SPECKLE_DIR/andor/andor.tcl

####
####For use with internal andor server version
####source $SPECKLE_DIR/andor/andorWrapper.tcl

