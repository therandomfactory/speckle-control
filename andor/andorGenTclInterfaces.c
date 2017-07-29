
#include "andorGenTclInterfaces.h"


int tcl_andorFilter_GetAveragingFactor(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = Filter_GetAveragingFactor(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_GetAveragingFrameCount(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = Filter_GetAveragingFrameCount(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_GetDataAveragingMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = Filter_GetDataAveragingMode(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_GetMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = Filter_GetMode(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_GetThreshold(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = Filter_GetThreshold(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%f",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetAvailableCameras(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetAvailableCameras(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetBaselineClamp(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetBaselineClamp(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetCameraSerialNumber(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetCameraSerialNumber(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetCurrentCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetCurrentCamera(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetEMAdvanced(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetEMAdvanced(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetEMCCDGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetEMCCDGain(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetExternalTriggerTermination(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetExternalTriggerTermination(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetFIFOUsage(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetFIFOUsage(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetFKExposureTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetFKExposureTime(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%f",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetFilterMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetFilterMode(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetFrontEndStatus(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetFrontEndStatus(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetGateMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetGateMode(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetHVflag(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetHVflag(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetIRQ(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetIRQ(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetImageRotate(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetImageRotate(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetKeepCleanTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetKeepCleanTime(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%f",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetMaximumExposure(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetMaximumExposure(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%f",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetMaximumNumberRingExposureTimes(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetMaximumNumberRingExposureTimes(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetMinimumImageLength(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetMinimumImageLength(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetMinimumNumberInSeries(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetMinimumNumberInSeries(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberADChannels(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberADChannels(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberAmp(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberAmp(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberDevices(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberDevices(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberFKVShiftSpeeds(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberFKVShiftSpeeds(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberHorizontalSpeeds(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberHorizontalSpeeds(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberIO(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberIO(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberPreAmpGains(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberPreAmpGains(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberRingExposureTimes(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberRingExposureTimes(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberVSAmplitudes(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberVSAmplitudes(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberVSSpeeds(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberVSSpeeds(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetNumberVerticalSpeeds(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetNumberVerticalSpeeds(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetReadOutTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetReadOutTime(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%f",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetStartUpTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetStartUpTime(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%f",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetStatus(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetStatus(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetTECStatus(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetTECStatus(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetTotalNumberImagesAcquired(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetTotalNumberImagesAcquired(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorIsCoolerOn(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = IsCoolerOn(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorIsInternalMechanicalShutter(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = IsInternalMechanicalShutter(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_SetAveragingFactor(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be averagingFactor", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = Filter_SetAveragingFactor(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_SetAveragingFrameCount(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be frames", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = Filter_SetAveragingFrameCount(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_SetDataAveragingMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = Filter_SetDataAveragingMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_SetMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be int", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%f", &fvalue);
  status = Filter_SetMode(fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorFilter_SetThreshold(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be threshold", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%f", &fvalue);
  status = Filter_SetThreshold(fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetADChannel(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be channel", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetADChannel(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetAccumulationCycleTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be time", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%f", &fvalue);
  status = SetAccumulationCycleTime(fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetAcquisitionMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetAcquisitionMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetAcquisitionType(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be typ", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetAcquisitionType(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetAdvancedTriggerModeState(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be iState", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetAdvancedTriggerModeState(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetBaselineClamp(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be state", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetBaselineClamp(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetBaselineOffset(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be offset", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetBaselineOffset(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetCameraLinkMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetCameraLinkMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetCameraStatusEnable(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be Enable", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetCameraStatusEnable(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetCoolerMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetCoolerMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetCountConvertMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be Mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetCountConvertMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetCountConvertWavelength(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be wavelength", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%f", &fvalue);
  status = SetCountConvertWavelength(fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetCurrentCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be cameraHandle", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetCurrentCamera(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetCustomTrackHBin(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be bin", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetCustomTrackHBin(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetDACOutputScale(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be iScale", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetDACOutputScale(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetDataType(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be typ", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetDataType(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetDualExposureMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetDualExposureMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetEMAdvanced(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be state", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetEMAdvanced(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetEMCCDGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be gain", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetEMCCDGain(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetEMClockCompensation(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be EMClockCompensationFlag", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetEMClockCompensation(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetEMGainMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetEMGainMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetExposureTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be time", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%f", &fvalue);
  status = SetExposureTime(fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetExternalTriggerTermination(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be uiTermination", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetExternalTriggerTermination(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetFKVShiftSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be index", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetFKVShiftSpeed(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetFPDP(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be state", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetFPDP(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetFVBHBin(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be bin", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetFVBHBin(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetFanMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetFanMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetFastExtTrigger(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetFastExtTrigger(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetFastKineticsStorageMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetFastKineticsStorageMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetFilterMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetFilterMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetFrameTransferMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetFrameTransferMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be gain", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetGain(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetGateMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be gatemode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetGateMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetHighCapacity(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be state", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetHighCapacity(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetHorizontalSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be index", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetHorizontalSpeed(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetImageRotate(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be iRotate", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetImageRotate(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetKineticCycleTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be time", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%f", &fvalue);
  status = SetKineticCycleTime(fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetMCPGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be gain", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetMCPGain(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetMCPGating(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be gating", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetMCPGating(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetMessageWindow(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be wnd", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetMessageWindow(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetMetaData(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be state", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetMetaData(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetMultiTrackHBin(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be bin", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetMultiTrackHBin(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetNumberAccumulations(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be number", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetNumberAccumulations(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetNumberKinetics(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be number", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetNumberKinetics(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetNumberPrescans(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be iNumber", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetNumberPrescans(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetOutputAmplifier(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be typ", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetOutputAmplifier(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetOverlapMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetOverlapMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetPhotonCounting(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be state", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetPhotonCounting(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetPreAmpGain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be index", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetPreAmpGain(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetReadMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetReadMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetReadoutRegisterPacking(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetReadoutRegisterPacking(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetRegisterDump(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetRegisterDump(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetSensorPortMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetSensorPortMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetSingleTrackHBin(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be bin", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetSingleTrackHBin(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetSpoolThreadCount(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be count", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetSpoolThreadCount(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetStorageMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetStorageMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetTemperature(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be temperature", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetTemperature(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetTriggerInvert(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetTriggerInvert(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetTriggerLevel(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be f_level", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%f", &fvalue);
  status = SetTriggerLevel(fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetTriggerMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be mode", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetTriggerMode(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetVSAmplitude(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be index", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetVSAmplitude(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetVSSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be index", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetVSSpeed(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetVerticalRowBuffer(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be rows", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetVerticalRowBuffer(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetVerticalSpeed(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be index", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetVerticalSpeed(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorSetVirtualChip(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
 int status=-1;
 int ivalue = 0;
 float fvalue = 0.0;
 char result[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 2) {
     Tcl_AppendResult(interp, "wrong # args: should be state", (char *)NULL);
     return TCL_ERROR;
  }


  sscanf(argv[1],"%d", &ivalue);
  status = SetVirtualChip(ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}

