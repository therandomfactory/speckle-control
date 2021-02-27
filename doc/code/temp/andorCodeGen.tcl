#!/usr/bin/tclsh
## \file andorCodeGen.tcl
# \brief This script  builds tcl wrappers for the main Andor Get/Set library calls
#
#  Parse simple andor interface functions and generate tcl/C access code\n
#  for inclusion in andorTclInit.so shared library
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

set setterFuncs "
SetAccumulationCycleTime float time
SetAcquisitionMode int mode
SetAcquisitionType int typ
SetADChannel int channel
SetAdvancedTriggerModeState int iState
SetBaselineClamp int state
SetBaselineOffset int offset
SetCameraLinkMode int mode
SetCameraStatusEnable int Enable
SetCoolerMode int mode
SetCountConvertMode int Mode
SetCountConvertWavelength float wavelength
SetCurrentCamera int cameraHandle
SetCustomTrackHBin int bin
SetDACOutputScale int iScale
SetDataType int typ
SetDualExposureMode int mode
SetEMAdvanced int state
SetEMCCDGain int gain
SetEMClockCompensation int EMClockCompensationFlag
SetEMGainMode int mode
SetExposureTime float time
SetExternalTriggerTermination int uiTermination
SetFanMode int mode
SetFastExtTrigger int mode
SetFastKineticsStorageMode int mode
SetFilterMode int mode
SetFKVShiftSpeed int index
SetFPDP int state
SetFrameTransferMode int mode
SetFVBHBin int bin
SetGain int gain
SetGateMode int gatemode
SetHighCapacity int state
SetHorizontalSpeed int index
SetImageRotate int iRotate
SetKineticCycleTime float time
SetMCPGain int gain
SetMCPGating int gating
SetMessageWindow int wnd
SetMetaData int state
SetMultiTrackHBin int bin
SetNumberAccumulations int number
SetNumberKinetics int number
SetNumberPrescans int iNumber
SetOutputAmplifier int typ
SetOverlapMode int mode
SetPhotonCounting int state
SetPreAmpGain int index
SetReadMode int mode
SetReadoutRegisterPacking int mode
SetRegisterDump int mode
SetSensorPortMode int mode
SetSingleTrackHBin int bin
SetSpoolThreadCount int count
SetStorageMode int mode
SetTemperature int temperature
SetTriggerInvert int mode
SetTriggerLevel float f_level
SetTriggerMode int mode
SetVerticalRowBuffer int rows
SetVerticalSpeed int index
SetVirtualChip int state
SetVSAmplitude int index
SetVSSpeed int index
Filter_SetAveragingFactor int averagingFactor
Filter_SetAveragingFrameCount int frames
Filter_SetDataAveragingMode int mode
Filter_SetMode    unsigned int mode
Filter_SetThreshold float threshold"

set all [lsort [split $simpleFuncs \n]]
set fout [open andorGenTclInterfaces.c w]
puts $fout "
/** 
 * \\file andorGenTclInterfaces.c
 * \\brief Tcl wrapper for Andor Set/Get routines, autogenerated by andorCodeGen.tcl
 * 
 */
#include \"andorGenTclInterfaces.h\"
"

set fo2  [open andorCreateTclCmds.c w]
set fhdr [open andorGenTclInterfaces.h w]
puts $fhdr "
/** 
 * \\file andorGenTclInterfaces.h
 * \\brief Tcl wrapper for Andor Set/Get routines, autogenerated by andorCodeGen.tcl
 * 
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <tcl.h>
#include <tk.h>
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdint.h>
#include \"atmcdLXd.h\"
/** 
 * \\brief Initialize the wrapper commands
 * \\param Tcl_Interp interpreter pointer
 *
 */
int tcl_andorInitCmds (Tcl_Interp *interp);
"
puts $fo2 "
/** 
 * \\file andorCreateTclCmds.c
 * \\brief Tcl wrapper for Andor Set/Get routines, autogenerated by andorCodeGen.tcl
 * 
 */
#include \"andorGenTclInterfaces.h\"
int tcl_andorInitCmds (Tcl_Interp *interp) \{
"

foreach f $all {
  if { $f != "" } {
     puts stdout "Processing $f"
     set fname [lindex $f 0]
     set typ [lindex $f 1]
     set par [lindex $f 2]
     puts $fout "
int tcl_andor[set fname](ClientData clientData, Tcl_Interp *interp, int argc, char **argv) \{
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result\[128\];
  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) \{
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
     sprintf(result,\"%f\",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  \}
  return TCL_ERROR;
\}
"
    }
    puts $fhdr "
/** 
 * \\brief ClientData Tcl handle
 * \\param Tcl_Interp interpreter pointer
 * \\param argc Argument count
 * \\param arcv Arguments
 *
 */
int tcl_andor[set fname](ClientData clientData, Tcl_Interp *interp, int argc, char **argv);"
    puts $fo2 "   Tcl_CreateCommand(interp, \"[set fname]\", (Tcl_CmdProc *) tcl_andor[set fname], NULL, NULL);"

  }
}


set all [lsort [split $setterFuncs \n]]
foreach f $all {
  if { $f != "" } {
     puts stdout "Processing $f"
     set fname [lindex $f 0]
     set typ [lindex $f 1]
     set par [lindex $f 2]
     puts $fout "
int tcl_andor[set fname](ClientData clientData, Tcl_Interp *interp, int argc, char **argv) \{
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result\[128\];
  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) \{
     Tcl_AppendResult(interp, \"wrong # args: should be $par\", (char *)NULL);
     return TCL_ERROR;
  \}
"
    if { $typ == "int" } {
        puts $fout "
  sscanf(argv\[1\],\"%d\", &ivalue);
  status = [set fname](ivalue);
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
  sscanf(argv\[1\],\"%f\", &fvalue);
  status = [set fname](fvalue);
  if (status == DRV_SUCCESS) \{
     sprintf(result,\"%f\",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  \}
  return TCL_ERROR;
\}
"
    }
    puts $fhdr "
/** 
 * \\brief ClientData Tcl handle
 * \\param Tcl_Interp interpreter pointer
 * \\param argc Argument count
 * \\param arcv Arguments
 *
 */
int tcl_andor[set fname](ClientData clientData, Tcl_Interp *interp, int argc, char **argv);"
    puts $fo2 "   Tcl_CreateCommand(interp, \"[set fname]\", (Tcl_CmdProc *) tcl_andor[set fname], NULL, NULL);"

  }
}





puts $fo2 "   return TCL_OK;
\}
"
close $fout
close $fo2
close $fhdr


# \endcode

