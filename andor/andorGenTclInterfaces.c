
int tcl_andorEnableKeepCleans(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = EnableKeepCleans(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}

urn TCL_ERROR;
}


int tcl_andorFilter_GetAveragingFactor(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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


  status = Filter_GetAveragingFactor(&ivalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",ivalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}

rovided and return an error if necessary */
  if (argc > 1) {
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


int tcl_andorFilter_GetThreshold(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = Filter_GetThreshold(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetAvailableCameras(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetFKExposureTime(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetFilterMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetKeepCleanTime(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetMaximumExposure(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetMaximumExposure(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetMaximumNumberRingExposureTimes(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetReadOutTime(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetStartUpTime(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
     Tcl_AppendResult(interp, "wrong # args: should be null", (char *)NULL);
     return TCL_ERROR;
  }


  status = GetStartUpTime(&fvalue);
  if (status == DRV_SUCCESS) {
     sprintf(result,"%d",fvalue);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }
  return TCL_ERROR;
}


int tcl_andorGetStatus(ClientData clientData, Tcl_Interp *interp, int argc, char **argv) {
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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
  int fvalue = 0.0;

  /* Check number of arguments provided and return an error if necessary */
  if (argc > 1) {
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

