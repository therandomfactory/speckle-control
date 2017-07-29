
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
#include "atmcdLXd.h"

int tcl_andorInitCmds (Tcl_Interp *interp);

int tcl_andorFilter_GetAveragingFactor(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_GetAveragingFrameCount(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_GetDataAveragingMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_GetMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_GetThreshold(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetAvailableCameras(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetBaselineClamp(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetCameraSerialNumber(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetCurrentCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetEMAdvanced(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetEMCCDGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetExternalTriggerTermination(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetFIFOUsage(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetFKExposureTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetFilterMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetFrontEndStatus(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetGateMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetHVflag(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetIRQ(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetImageRotate(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetKeepCleanTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetMaximumExposure(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetMaximumNumberRingExposureTimes(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetMinimumImageLength(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetMinimumNumberInSeries(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberADChannels(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberAmp(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberDevices(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberFKVShiftSpeeds(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberHorizontalSpeeds(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberIO(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberPreAmpGains(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberRingExposureTimes(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberVSAmplitudes(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberVSSpeeds(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetNumberVerticalSpeeds(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetReadOutTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetStartUpTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetStatus(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetTECStatus(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetTotalNumberImagesAcquired(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorIsCoolerOn(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorIsInternalMechanicalShutter(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_SetAveragingFactor(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_SetAveragingFrameCount(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_SetDataAveragingMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_SetMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorFilter_SetThreshold(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetADChannel(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetAccumulationCycleTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetAcquisitionMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetAcquisitionType(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetAdvancedTriggerModeState(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetBaselineClamp(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetBaselineOffset(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetCameraLinkMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetCameraStatusEnable(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetCoolerMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetCountConvertMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetCountConvertWavelength(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetCurrentCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetCustomTrackHBin(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetDACOutputScale(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetDataType(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetDualExposureMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetEMAdvanced(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetEMCCDGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetEMClockCompensation(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetEMGainMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetExposureTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetExternalTriggerTermination(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetFKVShiftSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetFPDP(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetFVBHBin(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetFanMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetFastExtTrigger(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetFastKineticsStorageMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetFilterMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetFrameTransferMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetGateMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetHighCapacity(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetHorizontalSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetImageRotate(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetKineticCycleTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetMCPGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetMCPGating(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetMessageWindow(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetMetaData(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetMultiTrackHBin(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetNumberAccumulations(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetNumberKinetics(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetNumberPrescans(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetOutputAmplifier(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetOverlapMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetPhotonCounting(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetPreAmpGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetReadMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetReadoutRegisterPacking(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetRegisterDump(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetSensorPortMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetSingleTrackHBin(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetSpoolThreadCount(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetStorageMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetTemperature(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetTriggerInvert(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetTriggerLevel(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetTriggerMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetVSAmplitude(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetVSSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetVerticalRowBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetVerticalSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetVirtualChip(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
