#!/usr/bin/tclsh
#
#  Parse simple andor interface functions and generate tcl/C access code
#  for inclusion on andor_tcl.c
#


set simpleFuncs "GetAvailableCameras int * numCamera
GetBaselineClamp int * state
GetCameraSerialNumber int * number
GetCurrentCamera int * cameraHandle
GetEMAdvanced int * state
GetEMCCDGain int * gain
GetExternalTriggerTermination int * puiTermination
GetFIFOUsage int * FIFOusage
GetFilterMode int * mode
GetFKExposureTime float * time
GetFrontEndStatus int * piFlag
GetGateMode int * piGatemode
GetHVflag int * bFlag
GetImageRotate int * iRotate
GetIRQ int * IRQ
GetKeepCleanTime float * KeepCleanTime
GetMaximumExposure float * MaxExp
GetMaximumNumberRingExposureTimes int * number
GetMinimumImageLength int * MinImageLength
GetMinimumNumberInSeries int * number
GetNumberADChannels int * channels
GetNumberAmp int * amp
GetNumberDevices int * numDevs
GetNumberFKVShiftSpeeds int * number
GetNumberHorizontalSpeeds int * number
GetNumberPreAmpGains int * noGains
GetNumberRingExposureTimes int * ipnumTimes
GetNumberIO int * iNumber
GetNumberVerticalSpeeds int * number
GetNumberVSAmplitudes int * number
GetNumberVSSpeeds int * speeds
GetReadOutTime float * ReadOutTime
GetStartUpTime float * time
GetStatus int * status
GetTECStatus int * piFlag
GetTotalNumberImagesAcquired int * index
IsCoolerOn int * iCoolerStatus
IsInternalMechanicalShutter int * InternalShutter
Filter_GetMode int * mode
Filter_GetThreshold float * threshold
Filter_GetDataAveragingMode int * mode
Filter_GetAveragingFrameCount int * frames
Filter_GetAveragingFactor int * averagingFactor"

set all [lsort [split $simpleFuncs \n]]
set fout [open andorGenTclInterfaces.c w]
set fo2  [open andorGenTclInterfacesDecl.inc w]
set fhdr [open andorGenTclInterfaces.h w]


foreach f $all {
  if { $f != "" } {
     puts stdout "Processing $f"
     set fname [lindex $f 0]
     set typ [lindex $f 1]
     set par [lindex $f 3]
     puts $fout "
int tcl_andor[set fname](ClientData clientData, Tcl_Interp *interp, int argc, char **argv) \{
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) \{
     Tcl_AppendResult(interp, \"wrong # args: should be null\", (char *)NULL);
     return TCL_ERROR;
  \}
"
    if { $typ == "int" } {
        puts $fout "
  status = [set fname](&ivalue);
  if (status == DRV_SUCCESS) \{
     sprintf(result,\"%d\",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  \}
  return TCL_ERROR;
\}
"
    } else {
        puts $fout "
  status = [set fname](&fvalue);
  if (status == DRV_SUCCESS) \{
     sprintf(result,\"%d\",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  \}
  return TCL_ERROR;
\}
"
    }
    puts $fhdr "int tcl_andor[set fname](ClientData clientData, Tcl_Interp *interp, int argc, char **argv);"
    puts $fo2 "Tcl_CreateCommand(interp, \"[set fname]\", (Tcl_CmdProc *) tcl_andor[set fname], NULL, NULL);"

  }
}

close $fout
close $fo2
close $fhdr






