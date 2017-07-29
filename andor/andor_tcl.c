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
#include "andor_tcl.h"

int tcl_andorInit(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorConfigure(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetupCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorIdle(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);


/*
int tcl_andorSetTemperature(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorCooler(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
 */

int tcl_andorSetProperty(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetProperty(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);

static char export_script[]={ " \
	namespace eval ::andor:: { \
		namespace export help setup test1 \
	} " };

static int doTest1(void)
{
  fprintf(stderr, "doTest1\n");

  /*  'x' is temporary check of library load  */

  fprintf(stderr, "andor Version 1.0\n");

  return TCL_OK;
}

/*ARGSUSED*/
static int cmdTest1(ClientData data, Tcl_Interp *interp,
               int argc, char *argv[])
{
  (void) data;
  (void) interp;
  (void) argc;
  (void) argv;

  return doTest1();
}

/*  package code  */
int Andortclinit_Init(Tcl_Interp *interp)
{

  printf("andor_Init\n");

  Tcl_PkgProvide(interp, "andor", "1.0");

  /*  export namespace  */

  Tcl_Eval(interp, export_script);

  Tcl_CreateObjCommand(interp, "andor::test1", (Tcl_ObjCmdProc *)cmdTest1,
                       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

  Tcl_CreateCommand(interp, "andorConnect", (Tcl_CmdProc *) tcl_andorInit, NULL, NULL);
  Tcl_CreateCommand(interp, "andorConfigure", (Tcl_CmdProc *) tcl_andorConfigure, NULL, NULL);
  Tcl_CreateCommand(interp, "andorSetupCamera", (Tcl_CmdProc *) tcl_andorSetupCamera, NULL, NULL);
  Tcl_CreateCommand(interp, "andorIdle", (Tcl_CmdProc *) tcl_andorIdle, NULL, NULL);
/*
  Tcl_CreateCommand(interp, "andorSetTemperature", (Tcl_CmdProc *) tcl_andorSetTemperature, NULL, NULL);
  Tcl_CreateCommand(interp, "andorCooler", (Tcl_CmdProc *) tcl_andorCooler, NULL, NULL);
 */
  Tcl_CreateCommand(interp, "andorSetProperty", (Tcl_CmdProc *) tcl_andorSetProperty, NULL, NULL);
  Tcl_CreateCommand(interp, "andorGetProperty", (Tcl_CmdProc *) tcl_andorGetProperty, NULL, NULL);
  tcl_andorInitCmds(interp);

  return TCL_OK;
}

/*  dummy  */

int _eprintf()
{
return TCL_OK;
}

char *result=NULL;
static at_32 cameraA;
static at_32 cameraB;
static at_32 numCameras;
andor_setup andorSetup[2];
#define CAMERA_A 0
#define CAMERA_B 1







int tcl_andorSetProperty(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int ivalue = 0;
  int fvalue = 0.0;
  int cameraId;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 4) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId, property value\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&cameraId);

  if (strcmp(argv[1],"temperature") == 0) {
     sscanf(argv[2],"%d",&ivalue);
     status = SetTemperature(ivalue);
     if (status == DRV_SUCCESS) {
        andorSetup[cameraId].target_temperature = ivalue;
     }
  }





  return TCL_OK;
}


int tcl_andorGetProperty(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int ivalue = 0;
  float fvalue = 0.0;
  int cameraId;
  float SensorTemp,TargetTemp,AmbientTemp,CoolerVolts,temperature;
  int precision,mintemp,maxtemp;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 3) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId, property\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&cameraId);

  if (strcmp(argv[1],"temperature") == 0) {
     status = GetTemperatureF(&temperature);
     status = GetTemperatureRange(&mintemp,&maxtemp);
     status = GetTemperaturePrecision(&precision);
     status = GetTemperatureStatus(&SensorTemp,&TargetTemp,&AmbientTemp,&CoolerVolts);
     sprintf(result,"%f %d %d %d %f %f %f %f",temperature,mintemp,maxtemp,precision,SensorTemp,TargetTemp,AmbientTemp,CoolerVolts);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_OK;
  }




  return TCL_OK;
}



int tcl_andorInit(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int cameraCount=0;
  int numCamReq=0;

  if (result==NULL) {result = malloc(256);}

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  numCameras\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&numCamReq);

  status = GetAvailableCameras(&cameraCount);
  if (status != DRV_SUCCESS || cameraCount != numCamReq) {
     sprintf(result,"Camera count invalid - %d",cameraCount);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  status = GetCameraHandle(0, &cameraA);
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to connect camera A - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  status = GetCameraHandle(1, &cameraB);
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to connect camera B - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  SetCurrentCamera(cameraA);
  status = Initialize("/usr/local/etc/andor");
  sleep(2);
/*  andor_set_shutter(ANDOR_SHUTTER_CLOSE); */
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to initialize camera A - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  SetCurrentCamera(cameraB);
  status = Initialize("/usr/local/etc/andor");
  sleep(2);
/*  andor_set_shutter(ANDOR_SHUTTER_CLOSE); */
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to initialize camera B - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}


int tcl_andorConfigure(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int cameraId,i,j,num_hspeeds;
  int hbin,vbin,hstart,hend,vstart,vend,preamp_gain,vertical_speed;
  int ccd_horizontal_speed,em_horizontal_speed,speed,num_ad;
  float fspeed;

  if (result==NULL) {result = malloc(256);}

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 12) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0]," hbin vbin hstart hend vstart vend preamp_gain vertical_speed ccd_horizontal_speed em_horizontal_speed \"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&cameraId);
  sscanf(argv[2],"%d",&hbin);
  sscanf(argv[3],"%d",&vbin);
  sscanf(argv[4],"%d",&hstart);
  sscanf(argv[5],"%d",&hend);
  sscanf(argv[6],"%d",&vstart);
  sscanf(argv[7],"%d",&vend);
  sscanf(argv[8],"%d",&preamp_gain);
  sscanf(argv[9],"%d",&vertical_speed);
  sscanf(argv[10],"%d",&ccd_horizontal_speed);
  sscanf(argv[11],"%d",&em_horizontal_speed);

  if ( cameraId == 0 ) {
     status = SetCurrentCamera(cameraA);
  } else {
     status = SetCurrentCamera(cameraB);
  }
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to select camera - %d",cameraId);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  status = GetDetector(&andorSetup[cameraId].width, &andorSetup[cameraId].height);
  status = GetTemperatureRange(&andorSetup[cameraId].minimum_temperature, &andorSetup[cameraId].maximum_temperature);
  status = GetNumberPreAmpGains(&andorSetup[cameraId].num_preamp_gains);
  status = GetNumberVSSpeeds(&andorSetup[cameraId].num_vertical_speeds);
/*
  for(j = 0; j < ANDOR_NUM_AMPLIFIERS; j++) {
     status = GetNumberHSSpeeds(0, j, &andorSetup[cameraId].num_horizontal_speeds[j]);
     num_hspeeds = andorSetup[cameraId].num_horizontal_speeds[j];
     for (i=0; i<num_hspeeds; i++) {
	andor_get_horizontal_speed(j, i, &fspeed);
     }
  }
 */
  status = GetEMGainRange(&andorSetup[cameraId].minimum_em_gain, &andorSetup[cameraId].maximum_em_gain);
  status = GetNumberADChannels(&num_ad);

  andorSetup[cameraId].amplifier = DFT_ANDOR_AMPLIFIER;
  andorSetup[cameraId].em_gain = DFT_ANDOR_EM_GAIN;
  andorSetup[cameraId].em_advanced = DFT_ANDOR_EM_ADVANCED;
  andorSetup[cameraId].horizontal_speed_index[ANDOR_CCD] = ccd_horizontal_speed;
  andorSetup[cameraId].horizontal_speed_index[ANDOR_EMCCD] = em_horizontal_speed;
  andorSetup[cameraId].vertical_speed_index = vertical_speed;
  andorSetup[cameraId].preamp_gain_index = preamp_gain;
  andorSetup[cameraId].image.vbin =   vbin;
  andorSetup[cameraId].image.hbin =   hbin;
  andorSetup[cameraId].image.hstart = hstart;
  andorSetup[cameraId].image.hend =   hend;
  andorSetup[cameraId].image.vstart = vstart;
  andorSetup[cameraId].image.vend =   vend;


  andorSetup[cameraId].exposure_time = DFT_ANDOR_EXPOSURE_TIME;

//  status = andor_set_temperature(DFT_ANDOR_TEMPERATURE);
//  status = andor_cooler_off();
// andor_setup_camera


  return TCL_OK;
}



int tcl_andorSetupCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int cameraId,index,speed,ccdMode,type;
  float fspeed;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 3) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId ccdMode \"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&cameraId);
  sscanf(argv[2],"%d",&ccdMode);

  if (andorSetup[cameraId].running) {
     Tcl_AppendResult(interp, "Can not change parameters while the camera is running."), (char *)NULL;
     return TCL_ERROR;
  }

  if ( cameraId == 0 ) {
     status = SetCurrentCamera(cameraA);
  } else {
     status = SetCurrentCamera(cameraB);
  }
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to select camera - %d",cameraId);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  status = SetFrameTransferMode(1);
  status = SetOutputAmplifier(andorSetup[cameraId].amplifier);
  status = SetEMAdvanced(andorSetup[cameraId].em_advanced);
  status = SetEMCCDGain(andorSetup[cameraId].em_gain);
  if (ccdMode == ANDOR_EMCCD) {
    status = SetHSSpeed(ANDOR_EMCCD,andorSetup[cameraId].horizontal_speed_index[ANDOR_EMCCD]);
    status = GetHSSpeed(0, ANDOR_EMCCD, index, &fspeed);
    andorSetup[cameraId].horizontal_speed_index[ANDOR_EMCCD] = index;
  } else {
    status = SetHSSpeed(ANDOR_CCD,andorSetup[cameraId].horizontal_speed_index[ANDOR_CCD]);
    status = GetHSSpeed(0, ANDOR_CCD, index, &fspeed);
    andorSetup[cameraId].horizontal_speed_index[ANDOR_CCD] = index;
  }
  andorSetup[cameraId].horizontal_speed[type] = speed;

  status = SetVSSpeed(andorSetup[cameraId].vertical_speed_index);
  GetVSSpeed(andorSetup[cameraId].vertical_speed_index, &andorSetup[cameraId].vertical_speed);
  status = SetPreAmpGain(andorSetup[cameraId].preamp_gain_index);
  GetPreAmpGain(andorSetup[cameraId].preamp_gain_index, &andorSetup[cameraId].preamp_gain);

  status = SetReadMode(ANDOR_READMODE_IMAGE);
  status = SetAcquisitionMode(5);
  status = SetFrameTransferMode(1);  //NJS added
  status = PrepareAcquisition();
  status = StartAcquisition();
  sleep(1);
  status = AbortAcquisition();


  return TCL_OK;
}

int tcl_andorIdle(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int cameraId=0;
  int ccdMode=0;

 
  /* Check number of arguments provided and return an error if necessary */
  if (argc < 3) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId ccdMode\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&cameraId);
  sscanf(argv[1],"%d",&ccdMode);

  if ( cameraId == 0 ) {
     status = SetCurrentCamera(cameraA);
  } else {
     status = SetCurrentCamera(cameraB);
  }
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to select camera - %d",cameraId);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  SetReadMode(ANDOR_READMODE_IMAGE);
  andorSetup[cameraId].acquisition_mode = ANDOR_ACQMODE_RUN_TILL_ABORT;
  SetAcquisitionMode(andorSetup[cameraId].acquisition_mode);
  SetFrameTransferMode(1);  //NJS added
  PrepareAcquisition();
  StartAcquisition();
  sleep(1);
  AbortAcquisition();
  status = GetEMGainRange(&andorSetup[cameraId].minimum_em_gain, &andorSetup[cameraId].maximum_em_gain);
  if (andorSetup[cameraId].amplifier == ANDOR_EMCCD) {
     status = SetIsolatedCropMode(1, andorSetup[cameraId].height, andorSetup[cameraId].width, 
                                     andorSetup[cameraId].image.vbin, andorSetup[cameraId].image.hbin);

  }
  status = SetExposureTime(andorSetup[cameraId].exposure_time);
  status = SetKineticCycleTime(0.0) ;
  andorSetup[cameraId].acquisition_mode = ANDOR_ACQMODE_RUN_TILL_ABORT;
  status = SetAcquisitionMode(andorSetup[cameraId].acquisition_mode);
  status = SetFrameTransferMode(1) ;
 

  return TCL_OK;
}


