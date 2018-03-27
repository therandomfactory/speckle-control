
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
#include "vips/vips.h"
#include "fitsio.h"

#define OBS_SIZE 256
#define LOC_SIZE 1024
#define MINBORDER 16

 
unsigned int *SharedMemA;
struct shmid_ds Shmem_buf;
unsigned int *SharedMemAPro;
unsigned int *SharedMemB;
unsigned int *SharedMemBPro;
int imageDataA[1024*1024];
int imageDataB[1024*1024];
int outputData[1024*1024];
int outputAvgA[1024*1024];
int outputAvgB[1024*1024];
float imageFrame[1024*1024];
float fitsROI[512*512];
unsigned int imageFrameI4[1024*1024];
unsigned int fitsROI4[512*512];
unsigned short imageFrameI2[1024*1024];
unsigned short fitsROI2[512*512];
char *result=NULL;
static at_32 cameraA;
static at_32 cameraB;
static at_32 numCameras;
andor_setup andorSetup[2];
fitsfile *fptr;       /* pointer to the FITS file, defined in fitsio.h */

int Shmem_id = 0;
void dofft(int width, int height, int *imageData, int* outputData);
void addavg(at_32 *im, at_32 *avg, int n);
void calcavg(at_32 *avg, int n, int numexp);
void copyline (int *tobuf, int *frombuf, int count, int offset);
void create_fits_header(Tcl_Interp *interp, fitsfile *fptr);

int tcl_andorInit(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorConfigure(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetupCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorConnectShmem(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorIdle(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorStartAcquisition(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSelectCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorDisplayFrame(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorAbortAcquisition(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorStoreFrame(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorStoreFrameI2(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorDisplayAvgFFT(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorStoreFrameI4(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetAcquiredData(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetOldestFrame(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetROI(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorSetCropMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorWaitForData(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorWaitForIdle(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorLocateStar(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorPrepDataCube(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorPrepDataFrame(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorShutDown(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorGetDataCube(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
#ifdef TCL_USB_THREAD
int tcl_andorStartUsbThread(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorStopUsbThread(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorStartUsb(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorStopUsb(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
/*void *andor_usb_thread(void *arg); */
int tcl_andorLockUsbMutex(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_andorUnlockUsbMutex(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
#endif


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

  Tcl_CreateCommand(interp, "andorConnectCamera", (Tcl_CmdProc *) tcl_andorInit, NULL, NULL);
  Tcl_CreateCommand(interp, "andorConfigure", (Tcl_CmdProc *) tcl_andorConfigure, NULL, NULL);
  Tcl_CreateCommand(interp, "andorSetupCamera", (Tcl_CmdProc *) tcl_andorSetupCamera, NULL, NULL);
  Tcl_CreateCommand(interp, "andorIdle", (Tcl_CmdProc *) tcl_andorIdle, NULL, NULL);
/*
  Tcl_CreateCommand(interp, "andorSetTemperature", (Tcl_CmdProc *) tcl_andorSetTemperature, NULL, NULL);
  Tcl_CreateCommand(interp, "andorCooler", (Tcl_CmdProc *) tcl_andorCooler, NULL, NULL);
 */
  Tcl_CreateCommand(interp, "andorConnectShmem", (Tcl_CmdProc *) tcl_andorConnectShmem, NULL, NULL);
  Tcl_CreateCommand(interp, "andorDisplayFrame", (Tcl_CmdProc *) tcl_andorDisplayFrame, NULL, NULL);
  Tcl_CreateCommand(interp, "andorShutDown", (Tcl_CmdProc *) tcl_andorShutDown, NULL, NULL);
  Tcl_CreateCommand(interp, "andorDisplayAvgFFT", (Tcl_CmdProc *) tcl_andorDisplayAvgFFT, NULL, NULL);
  Tcl_CreateCommand(interp, "andorStoreFrame", (Tcl_CmdProc *) tcl_andorStoreFrame, NULL, NULL);
  Tcl_CreateCommand(interp, "andorStoreFrameI2", (Tcl_CmdProc *) tcl_andorStoreFrameI2, NULL, NULL);
  Tcl_CreateCommand(interp, "andorGetProperty", (Tcl_CmdProc *) tcl_andorGetProperty, NULL, NULL);
  Tcl_CreateCommand(interp, "andorStoreFrameI4", (Tcl_CmdProc *) tcl_andorStoreFrameI4, NULL, NULL);
  Tcl_CreateCommand(interp, "andorSetProperty", (Tcl_CmdProc *) tcl_andorSetProperty, NULL, NULL);
  Tcl_CreateCommand(interp, "andorSelectCamera", (Tcl_CmdProc *) tcl_andorSelectCamera, NULL, NULL);
  Tcl_CreateCommand(interp, "andorStartAcq", (Tcl_CmdProc *) tcl_andorStartAcquisition, NULL, NULL);
  Tcl_CreateCommand(interp, "andorAbortAcq", (Tcl_CmdProc *) tcl_andorAbortAcquisition, NULL, NULL);
  Tcl_CreateCommand(interp, "andorGetData", (Tcl_CmdProc *) tcl_andorGetAcquiredData, NULL, NULL);
  Tcl_CreateCommand(interp, "andorGetFrame", (Tcl_CmdProc *) tcl_andorGetOldestFrame, NULL, NULL);
  Tcl_CreateCommand(interp, "andorSetROI", (Tcl_CmdProc *) tcl_andorSetROI, NULL, NULL);
  Tcl_CreateCommand(interp, "andorPrepDataCube", (Tcl_CmdProc *) tcl_andorPrepDataCube, NULL, NULL);
  Tcl_CreateCommand(interp, "andorLocateStar", (Tcl_CmdProc *) tcl_andorLocateStar, NULL, NULL);
  Tcl_CreateCommand(interp, "andorSetCropMode", (Tcl_CmdProc *) tcl_andorSetCropMode, NULL, NULL);
  Tcl_CreateCommand(interp, "andorPrepDataFrame", (Tcl_CmdProc *) tcl_andorPrepDataFrame, NULL, NULL);
  Tcl_CreateCommand(interp, "andorGetDataCube", (Tcl_CmdProc *) tcl_andorGetDataCube, NULL, NULL);
  Tcl_CreateCommand(interp, "andorWaitForData", (Tcl_CmdProc *) tcl_andorWaitForData, NULL, NULL);
  Tcl_CreateCommand(interp, "andorWaitForIdle", (Tcl_CmdProc *) tcl_andorWaitForIdle, NULL, NULL);
#ifdef TCL_USB_THREAD
  Tcl_CreateCommand(interp, "andorStartUsbThread", (Tcl_CmdProc *) tcl_andorStartUsbThread, NULL, NULL);
  Tcl_CreateCommand(interp, "andorStopUsbThread", (Tcl_CmdProc *) tcl_andorStopUsbThread, NULL, NULL);
  Tcl_CreateCommand(interp, "andorStartUsb", (Tcl_CmdProc *) tcl_andorStartUsb, NULL, NULL);
  Tcl_CreateCommand(interp, "andorStopUsb", (Tcl_CmdProc *) tcl_andorStopUsb, NULL, NULL);
  Tcl_CreateCommand(interp, "andorLockUsbMutex", (Tcl_CmdProc *) tcl_andorLockUsbMutex, NULL, NULL);
  Tcl_CreateCommand(interp, "andorUnlockUsbMutex", (Tcl_CmdProc *) tcl_andorUnlockUsbMutex, NULL, NULL);
#endif
  tcl_andorInitCmds(interp);

  return TCL_OK;
}

/*  dummy  */

int _eprintf()
{
return TCL_OK;
}


int tcl_andorShutDown(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
    AbortAcquisition();
    sleep(2);
    ShutDown();
    return TCL_OK;
}


int tcl_andorConnectShmem(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int width,height;
  int Shmem_size;

    if (argc < 3) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  width height\"", (char *)NULL);
     return TCL_ERROR;
    }

    sscanf(argv[1],"%d",&width);
    sscanf(argv[2],"%d",&height);
    Shmem_size = width*height*4;
    Shmem_id = shmget(7772, Shmem_size, IPC_CREAT|0666);
    if (Shmem_id < 0) {
        Shmem_id = shmget(7772, Shmem_size, IPC_CREAT|0666);
    }
    SharedMemA  = (unsigned int *) shmat(Shmem_id, NULL, 0);
    SharedMemAPro = SharedMemA + width*height/2;
    SharedMemB  = SharedMemA + width/2;
    SharedMemBPro = SharedMemAPro + width/2;
    sprintf(result,"%ld %d %ld %ld %ld %ld",Shmem_id, Shmem_size,SharedMemA,SharedMemAPro,SharedMemB,SharedMemBPro);
    Tcl_SetResult(interp,result,TCL_STATIC);
    return TCL_OK;
}

int tcl_andorStoreFrame(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int width,height,numexp,iexp,cameraId;
  int irow,iw,ih,ipix;
  int status;
  int *copyFrom;
  char filename[1024];
  int bitpix   =  FLOAT_IMG; /* 32-bit unsigned int pixel values       */
  long naxes3[3];   
  long naxes[2];
  int fpixel=1;
  int nelements;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 6) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId filename width height iexp numexp\"", (char *)NULL);
     return TCL_ERROR;
  }
  sscanf(argv[1],"%d",&cameraId);
  strcpy(filename,argv[2]);
  sscanf(argv[3],"%d",&width);
  sscanf(argv[4],"%d",&height);
  sscanf(argv[5],"%d",&iexp);
  sscanf(argv[6],"%d",&numexp);
  if ( cameraId == 0 ) {
     copyFrom = &imageDataA;
     if (width < 1024) {
       for (iw=0;iw<width;iw++) {
       for (ih=0;ih<height;ih++) {
         fitsROI[iw+ih*width] = (float)imageDataA[iw+ih*width];
       }
       }
     }
  }
  if ( cameraId == 1 ) {
     copyFrom = &imageDataB;
     if (width < 1024) {
       for (iw=0;iw<width;iw++) {
       for (ih=0;ih<height;ih++) {
         fitsROI[iw+ih*width] = (float)imageDataB[iw+ih*width];
       }
       }
     }
 }

  if ( numexp == 1 ) {
    status = 0;         /* initialize status before calling fitsio routines */ 
    fits_create_file(&fptr, filename, &status); /* create new FITS file */
    if (status != 0) {
         sprintf(result,"fits create file error %d",status);
         Tcl_SetResult(interp,result,TCL_STATIC);
         return TCL_ERROR;
    }
    naxes[0]=width;
    naxes[1]=height;
    fpixel=1;
    nelements = naxes[0] * naxes[1];          /* number of pixels to write */

    fits_create_img(fptr,  bitpix, 2, naxes, &status);
    if (status != 0) {
          sprintf(result,"fits create image error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }
   
    if (width < 1024) {
      fits_write_img(fptr, TFLOAT, fpixel, nelements, &fitsROI, &status);
    } else {
      if ( cameraId == 0 ) {
        for (ipix=0;ipix<1024*1024;ipix++) {
            imageFrame[ipix] = (float)imageDataA[ipix];
        }
      }
      if ( cameraId == 1 ) {
        for (ipix=0;ipix<1024*1024;ipix++) {
            imageFrame[ipix] = (float)imageDataB[ipix];
        }
      }
      fits_write_img(fptr, TFLOAT, fpixel, nelements, &imageFrame, &status);
    }

    if (status != 0) {
          sprintf(result,"fits write error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }

    create_fits_header(interp, fptr);
 
    fits_close_file(fptr, &status);                /* close the file */
    if (status != 0) {
          sprintf(result,"fits close error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }
   } else {
     status=0;
     naxes3[0]=width;
     naxes3[1]=height;
     naxes3[2]=numexp;
     if ( iexp == 1) {
        fits_create_file(&fptr, filename, &status); /* create new FITS file */
        if (status != 0) {
            sprintf(result,"fits create file error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
        fits_create_img(fptr,  bitpix, 3, naxes3, &status);
        if (status != 0) {
            sprintf(result,"fits create img error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
     }
     fpixel=width*height*(iexp-1)+1;
     nelements = naxes3[0] * naxes3[1];          /* number of pixels to write */
     fits_write_img(fptr, TFLOAT, fpixel, nelements, &fitsROI, &status);
     if (status != 0) {
         sprintf(result,"fits write img error %d",status);
         Tcl_SetResult(interp,result,TCL_STATIC);
         return TCL_ERROR;
     }
     if (iexp == numexp) {
        create_fits_header(interp, fptr);
        fits_close_file(fptr, &status);                /* close the file */
        if (status != 0) {
            sprintf(result,"fits close error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
     }
  }  

  return TCL_OK;
}

int tcl_andorStoreFrameI4(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int width,height,numexp,iexp,cameraId;
  int irow,iw,ih,ipix;
  int status;
  int *copyFrom;
  char filename[1024];
  int bitpix   =  ULONG_IMG; /* 32-bit unsigned int pixel values       */
  long naxes3[3];   
  long naxes[2];
  int fpixel=1;
  int nelements;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 6) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId filename width height iexp numexp\"", (char *)NULL);
     return TCL_ERROR;
  }
  sscanf(argv[1],"%d",&cameraId);
  strcpy(filename,argv[2]);
  sscanf(argv[3],"%d",&width);
  sscanf(argv[4],"%d",&height);
  sscanf(argv[5],"%d",&iexp);
  sscanf(argv[6],"%d",&numexp);
  if ( cameraId == 0 ) {
     copyFrom = &imageDataA;
     if (width < 1024) {
       for (iw=0;iw<width;iw++) {
       for (ih=0;ih<height;ih++) {
         fitsROI4[iw+ih*width] = (unsigned int)imageDataA[iw+ih*width];
       }
       }
     }
  }
  if ( cameraId == 1 ) {
     copyFrom = &imageDataB;
     if (width < 1024) {
       for (iw=0;iw<width;iw++) {
       for (ih=0;ih<height;ih++) {
         fitsROI4[iw+ih*width] = (unsigned int)imageDataB[iw+ih*width];
       }
       }
     }
 }

  if ( numexp == 1 ) {
    status = 0;         /* initialize status before calling fitsio routines */ 
    fits_create_file(&fptr, filename, &status); /* create new FITS file */
    if (status != 0) {
         sprintf(result,"fits create file error %d",status);
         Tcl_SetResult(interp,result,TCL_STATIC);
         return TCL_ERROR;
    }
    naxes[0]=width;
    naxes[1]=height;
    fpixel=1;
    nelements = naxes[0] * naxes[1];          /* number of pixels to write */

    fits_create_img(fptr,  bitpix, 2, naxes, &status);
    if (status != 0) {
          sprintf(result,"fits create image error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }
   
    if (width < 1024) {
      fits_write_img(fptr, TULONG, fpixel, nelements, &fitsROI, &status);
    } else {
      if ( cameraId == 0 ) {
        for (ipix=0;ipix<1024*1024;ipix++) {
            imageFrameI4[ipix] = (unsigned int)imageDataA[ipix];
        }
      }
      if ( cameraId == 1 ) {
        for (ipix=0;ipix<1024*1024;ipix++) {
            imageFrameI4[ipix] = (unsigned int)imageDataB[ipix];
        }
      }
      fits_write_img(fptr, TULONG, fpixel, nelements, &imageFrameI4, &status);
    }

    if (status != 0) {
          sprintf(result,"fits write error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }

    create_fits_header(interp, fptr);
 
    fits_close_file(fptr, &status);                /* close the file */
    if (status != 0) {
          sprintf(result,"fits close error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }
   } else {
     status=0;
     naxes3[0]=width;
     naxes3[1]=height;
     naxes3[2]=numexp;
     if ( iexp == 1) {
        fits_create_file(&fptr, filename, &status); /* create new FITS file */
        if (status != 0) {
            sprintf(result,"fits create file error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
        fits_create_img(fptr,  bitpix, 3, naxes3, &status);
        if (status != 0) {
            sprintf(result,"fits create img error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
     }
     fpixel=width*height*(iexp-1)+1;
     nelements = naxes3[0] * naxes3[1];          /* number of pixels to write */
     fits_write_img(fptr, TULONG, fpixel, nelements, &fitsROI4, &status);
     if (status != 0) {
         sprintf(result,"fits write img error %d",status);
         Tcl_SetResult(interp,result,TCL_STATIC);
         return TCL_ERROR;
     }
     if (iexp == numexp) {
        create_fits_header(interp, fptr);
        fits_close_file(fptr, &status);                /* close the file */
        if (status != 0) {
            sprintf(result,"fits close error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
     }
  }  

  return TCL_OK;
}

int tcl_andorStoreFrameI2(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int width,height,numexp,iexp,cameraId;
  int irow,iw,ih,ipix;
  int status;
  int *copyFrom;
  char filename[1024];
  int bitpix   =  USHORT_IMG; /* 32-bit unsigned int pixel values       */
  long naxes3[3];   
  long naxes[2];
  int fpixel=1;
  int nelements;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 6) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId filename width height iexp numexp\"", (char *)NULL);
     return TCL_ERROR;
  }
  sscanf(argv[1],"%d",&cameraId);
  strcpy(filename,argv[2]);
  sscanf(argv[3],"%d",&width);
  sscanf(argv[4],"%d",&height);
  sscanf(argv[5],"%d",&iexp);
  sscanf(argv[6],"%d",&numexp);
  if ( cameraId == 0 ) {
     copyFrom = &imageDataA;
     if (width < 1024) {
       for (iw=0;iw<width;iw++) {
       for (ih=0;ih<height;ih++) {
         fitsROI4[iw+ih*width] = (unsigned int)imageDataA[iw+ih*width];
       }
       }
     }
  }
  if ( cameraId == 1 ) {
     copyFrom = &imageDataB;
     if (width < 1024) {
       for (iw=0;iw<width;iw++) {
       for (ih=0;ih<height;ih++) {
         fitsROI2[iw+ih*width] = (unsigned short)imageDataB[iw+ih*width];
       }
       }
     }
 }

  if ( numexp == 1 ) {
    status = 0;         /* initialize status before calling fitsio routines */ 
    fits_create_file(&fptr, filename, &status); /* create new FITS file */
    if (status != 0) {
         sprintf(result,"fits create file error %d",status);
         Tcl_SetResult(interp,result,TCL_STATIC);
         return TCL_ERROR;
    }
    naxes[0]=width;
    naxes[1]=height;
    fpixel=1;
    nelements = naxes[0] * naxes[1];          /* number of pixels to write */

    fits_create_img(fptr,  bitpix, 2, naxes, &status);
    if (status != 0) {
          sprintf(result,"fits create image error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }
   
    if (width < 1024) {
      fits_write_img(fptr, TUSHORT, fpixel, nelements, &fitsROI2, &status);
    } else {
      if ( cameraId == 0 ) {
        for (ipix=0;ipix<1024*1024;ipix++) {
            imageFrameI2[ipix] = (unsigned short)imageDataA[ipix];
        }
      }
      if ( cameraId == 1 ) {
        for (ipix=0;ipix<1024*1024;ipix++) {
            imageFrameI2[ipix] = (unsigned short)imageDataB[ipix];
        }
      }
      fits_write_img(fptr, TUSHORT, fpixel, nelements, &imageFrameI2, &status);
    }

    if (status != 0) {
          sprintf(result,"fits write error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }

    create_fits_header(interp, fptr);
 
    fits_close_file(fptr, &status);                /* close the file */
    if (status != 0) {
          sprintf(result,"fits close error %d",status);
          Tcl_SetResult(interp,result,TCL_STATIC);
          return TCL_ERROR;
    }
   } else {
     status=0;
     naxes3[0]=width;
     naxes3[1]=height;
     naxes3[2]=numexp;
     if ( iexp == 1) {
        fits_create_file(&fptr, filename, &status); /* create new FITS file */
        if (status != 0) {
            sprintf(result,"fits create file error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
        fits_create_img(fptr,  bitpix, 3, naxes3, &status);
        if (status != 0) {
            sprintf(result,"fits create img error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
     }
     fpixel=width*height*(iexp-1)+1;
     nelements = naxes3[0] * naxes3[1];          /* number of pixels to write */
     fits_write_img(fptr, TUSHORT, fpixel, nelements, &fitsROI2, &status);
     if (status != 0) {
         sprintf(result,"fits write img error %d",status);
         Tcl_SetResult(interp,result,TCL_STATIC);
         return TCL_ERROR;
     }
     if (iexp == numexp) {
        create_fits_header(interp, fptr);
        fits_close_file(fptr, &status);                /* close the file */
        if (status != 0) {
            sprintf(result,"fits close error %d",status);
            Tcl_SetResult(interp,result,TCL_STATIC);
            return TCL_ERROR;
        }
     }
  }  

  return TCL_OK;
}




int tcl_andorLocateStar(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
   int stepsize, smoothing;
   int bnum;
   int ifound;
   int cameraId;
   unsigned int *cframe;
   int line, pixel, ii,jj;
   int xmaxat, ymaxat;
   int image_width,image_height;
   double maxsum, csum;
   char starpos[16];

   xmaxat = 0;
   ymaxat = 0;
   maxsum = 0.0;

   if ( argc < 4 ) {
           Tcl_AppendResult (interp, "wrong # args: should be \"", argv[0],
            " cameraId stepsize smoothing\"", (char *) NULL);
           return TCL_ERROR;
   }
   sscanf (argv[1],"%d", &cameraId);
   sscanf (argv[2],"%d", &stepsize);
   sscanf (argv[3],"%d", &smoothing);

   if ( cameraId == 0 ) {
     cframe = &imageDataA;
    }
   if ( cameraId == 1 ) {
     cframe = &imageDataB;
    }
    image_width = andorSetup[cameraId].image.hend -  andorSetup[cameraId].image.hstart +1;
    image_height = andorSetup[cameraId].image.vend -  andorSetup[cameraId].image.vstart +1;

    xmaxat = 0;
    ymaxat = 0;
    maxsum = 0.0;
    for (line = MINBORDER; line <= image_height-MINBORDER; line=line+stepsize) {
       for (pixel = MINBORDER; pixel <= image_width-MINBORDER; pixel=pixel+stepsize) {
        csum = 0.0;
        for (ii=-1*smoothing;ii<=smoothing;ii++) {
          for (jj=-1*smoothing;jj<=smoothing;jj++) {
             csum = csum + (double)cframe[(line+ii) * image_width + pixel+jj];
          }
        }
        if (csum > maxsum) {
           xmaxat = pixel;
           ymaxat = line;
           maxsum = csum;
        }
      }
    }
    sprintf(starpos,"%d %d ",xmaxat,ymaxat);
    Tcl_AppendResult (interp,starpos,(char *) NULL);
    return TCL_OK;
}


int tcl_andorDisplayFrame(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{

  int width,height,ifft,cameraId;
  int irow;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 5) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId width height dofft\"", (char *)NULL);
     return TCL_ERROR;
  }
  sscanf(argv[1],"%d",&cameraId);
  sscanf(argv[2],"%d",&width);
  sscanf(argv[3],"%d",&height);
  sscanf(argv[4],"%d",&ifft);

  if ( cameraId == 0 ) {
    if ( ifft == 1) {
      dofft(width,height,imageDataA,outputData);
      for ( irow=0;irow<width;irow++) {
        copyline(SharedMemAPro + irow*width*2, outputData + irow*width, width*4, 0);
      }
      for ( irow=0;irow<width;irow++) {
        copyline(SharedMemA + irow*width*2, imageDataA + irow*width, width*4, 0);
      }
      addavg(outputData,outputAvgA,width*height);
    } else {
      for ( irow=0;irow<width;irow++) {
        copyline(SharedMemA + irow*width*2, imageDataA + irow*width, width*4, 0);
      }
    }
  }

  if ( cameraId == 1 ) {
    if ( ifft == 1) {
      dofft(width,height,imageDataB,outputData);
      for ( irow=0;irow<width;irow++) {
        copyline(SharedMemBPro + irow*width*2, outputData + irow*width, width*4, 0);
      }
      for ( irow=0;irow<width;irow++) {
        copyline(SharedMemB + irow*width*2, imageDataB + irow*width, width*4, 0);
      }
      addavg(outputData,outputAvgB,width*height);
    } else {
      for ( irow=0;irow<width;irow++) {
        copyline(SharedMemB + irow*width*2, imageDataB + irow*width, width*4, 0);
      }
    }
  }

    return TCL_OK;
}

void copyline (int *tobuf, int *frombuf, int count, int offset) {
   memcpy(tobuf+offset,frombuf,count);
}

int tcl_andorDisplayAvgFFT(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{

  int width,height,numexp,cameraId;
  int irow;
  float fvalue;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 5) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId width height numexp\"", (char *)NULL);
     return TCL_ERROR;
  }
  sscanf(argv[1],"%d",&cameraId);
  sscanf(argv[2],"%d",&width);
  sscanf(argv[3],"%d",&height);
  sscanf(argv[4],"%d",&numexp);
  if ( cameraId == 0 ) {
      calcavg(outputAvgA,width*height,numexp);
      for ( irow=0;irow<width;irow++) {
        copyline(SharedMemAPro + irow*width*2, outputAvgA + irow*width, width*4, 0);
      }
  }

  if ( cameraId == 1 ) {
      calcavg(outputAvgB,width*height,numexp);
      for ( irow=0;irow<width;irow++) {
        copyline(SharedMemAPro + irow*width*2, outputAvgB + irow*width, width*4, 0);
      }
  }

  return TCL_OK;
}



int tcl_andorSetProperty(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int ivalue = 0;
  int imode = 0;
  int fvalue = 0.0;
  int cameraId;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 4) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  cameraId, property value\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&cameraId);

  if (strcmp(argv[2],"Temperature") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetTemperature(ivalue);
     if (status == DRV_SUCCESS) {
        andorSetup[cameraId].target_temperature = ivalue;
     }
  }
  if (strcmp(argv[2],"Cooler") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     if (ivalue == 0) {
        CoolerOFF();
     } else {
        CoolerON();
     }
  }
  if (strcmp(argv[2],"Shutter") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetShutter(1,ivalue,50,50);
     if (status == DRV_SUCCESS) {
        andorSetup[cameraId].shutter = ivalue;
     }
  }
  if (strcmp(argv[2],"FrameTransferMode") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetFrameTransferMode(ivalue);
     if (status != DRV_SUCCESS) {
        return status;
     }
  }

  if (strcmp(argv[2],"OutputAmplifier") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetOutputAmplifier(ivalue);
     if (status != DRV_SUCCESS) {
        andorSetup[cameraId].amplifier = ivalue;
        return status;
     }
  }


  if (strcmp(argv[2],"EMAdvanced") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetEMAdvanced(ivalue);
     if (status != DRV_SUCCESS) {
        andorSetup[cameraId].em_advanced = ivalue;
        return status;
     }
  }

  if (strcmp(argv[2],"EMCCDGain") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetEMCCDGain(ivalue);
     if (status != DRV_SUCCESS) {
        andorSetup[cameraId].em_gain = ivalue;
        return status;
     }
  }

  if (strcmp(argv[2],"VSSpeed") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetVSSpeed(ivalue);
     if (status != DRV_SUCCESS) {
        andorSetup[cameraId].vertical_speed_index = ivalue;
        return status;
     }
  }

  if (strcmp(argv[2],"PreAmpGain") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetPreAmpGain(ivalue);
     if (status != DRV_SUCCESS) {
        andorSetup[cameraId].preamp_gain_index = ivalue;
        return status;
     }
  }

  if (strcmp(argv[2],"ReadMode") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetReadMode(ivalue);
     if (status != DRV_SUCCESS) {
        return status;
     }
  }

  if (strcmp(argv[2],"AcquisitionMode") == 0) {
     sscanf(argv[3],"%d",&ivalue);
     status = SetAcquisitionMode(ivalue);
     if (status != DRV_SUCCESS) {
        return status;
     }
  }

  if (strcmp(argv[2],"KineticCycleTime") == 0) {
     sscanf(argv[3],"%f",&fvalue);
     status = SetKineticCycleTime(fvalue);
     if (status != DRV_SUCCESS) {
        return status;
     }
  }

  if (strcmp(argv[2],"HSSpeed") == 0) {
     sscanf(argv[3],"%d",&imode);
     sscanf(argv[4],"%d",&ivalue);
     status = SetHSSpeed(imode,ivalue);
     if (status != DRV_SUCCESS) {
        andorSetup[cameraId].horizontal_speed_index[imode] = ivalue;
        return status;
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

  if (strcmp(argv[2],"temperature") == 0) {
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

int tcl_andorSetROI(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int cameraId;
  int xstart, ystart, xend, yend, ibin;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 7) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0]," cameraId xstart xend ystart yend bin\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&cameraId);
  sscanf(argv[2],"%d",&xstart);
  sscanf(argv[3],"%d",&xend);
  sscanf(argv[4],"%d",&ystart);
  sscanf(argv[5],"%d",&yend);
  sscanf(argv[6],"%d",&ibin);
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
  andorSetup[cameraId].image.vbin =   ibin;
  andorSetup[cameraId].image.hbin =   ibin;
  andorSetup[cameraId].image.hstart = xstart;
  andorSetup[cameraId].image.hend =   xend;
  andorSetup[cameraId].image.vstart = ystart;
  andorSetup[cameraId].image.vend =   yend;
  andorSetup[cameraId].npix = (xend-xstart+1)*(yend-ystart+1)/ibin/ibin;

  SetImage(ibin,ibin,xstart,xend-xstart+1,ystart,yend-ystart+1);
  return TCL_OK;

}




int tcl_andorPrepDataCube(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
        int num;
        unsigned short *SharedMem2;
	unsigned long error;
	bool quit;
        int numexp=1000;
	char choice;
        int count=0;
        int i,j;
 	float fChoice;
        float exposure=0.04;
	int width, height;
        vips_init(argv[0]);

	//Set Read Mode to --Image--
	SetReadMode(4);

	//Set Acquisition mode to --Single scan--
	SetAcquisitionMode(1);

	//Set initial exposure time
	SetExposureTime(exposure);

	//Get Detector dimensions
	GetDetector(&width, &height);
        height=256;
        width=256;
	//Initialize Shutter
	SetShutter(1,1,50,50);
        SetFrameTransferMode(1);
        
        //Setup Image dimensions
        SetImage(1,1,1,width,1,height);
        return TCL_OK;
}

int tcl_andorPrepDataFrame(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
        int num;
	unsigned long error;
	bool quit;
        int numexp=1;
	char choice;
        int count=0;
        int i,j;
 	float fChoice;
        float exposure=0.04;
	int width, height;

	//Set Read Mode to --Image--
	SetReadMode(4);

	//Set Acquisition mode to --Single scan--
	SetAcquisitionMode(1);

	//Set initial exposure time
	SetExposureTime(exposure);

	//Get Detector dimensions
	GetDetector(&width, &height);
        height=1024;
        width=1024;
	//Initialize Shutter
	SetShutter(1,1,50,50);
        SetFrameTransferMode(1);
        
        //Setup Image dimensions
        SetImage(1,1,1,width,1,height);
        return TCL_OK;
}


int tcl_andorGetDataCube(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
        int num;
        unsigned short *SharedMem2;
	unsigned long error;
	bool quit;
        int numexp=1000;
	char choice;
        int count=0;
        int i,j;
 	float fChoice;
        float exposure=0.04;
	int width, height;

	while (count < numexp) {
			StartAcquisition();

			int status;


			//Loop until acquisition finished
			GetStatus(&status);
			while(status==DRV_ACQUIRING) {
                              GetTotalNumberImagesAcquired(&num);
                              GetStatus(&status);
                       }
			GetAcquiredData(imageDataA, width*height);
                        dofft(width,height,imageDataA,outputData);
                        memcpy(SharedMemAPro,outputData,width*height*4);
                        memcpy(SharedMemA,imageDataA,width*height*4);
                        addavg(outputData,outputAvgA,width*height);
                         count  = count+1;
                         printf(".");
                         fflush(stdout);

	}
        calcavg(outputAvgA,width*height,numexp);
        memcpy(SharedMemA,outputAvgA,width*height*4);

	//Shut down CCD
	AbortAcquisition();
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
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  numCamera\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&numCamReq);

  status = GetAvailableCameras(&cameraCount);
  if (status != DRV_SUCCESS || cameraCount < numCamReq) {
     sprintf(result,"Camera count invalid - %d",cameraCount);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  if (numCamReq == 1) { 
    status = GetCameraHandle(0, &cameraA);
    if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to connect camera A - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
    }
  }

  if (numCamReq == 2) { 
    status = GetCameraHandle(1, &cameraB);
    if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to connect camera B - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
    }
  }

  if (numCamReq == 1) { 
    SetCurrentCamera(cameraA);
    status = Initialize("/usr/local/etc/andor");
    sleep(2);
    SetReadMode(4);
  //Set Acquisition mode to --Single scan--
    SetAcquisitionMode(1);
    status = SetShutter(1, 1, 50, 50);
    SetFrameTransferMode(1);
    if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to initialize camera A - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
    }
  }

  if (numCamReq == 2) { 
    SetCurrentCamera(cameraB);
    status = Initialize("/usr/local/etc/andor");
    sleep(2);
    SetReadMode(4);
    //Set Acquisition mode to --Single scan--
    SetAcquisitionMode(1);
    status = SetShutter(1, 1, 50, 50);
    SetFrameTransferMode(1);
    if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to initialize camera B - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
    }
  }
  if (numCamReq == 1) { 
     sprintf(result,"%d",cameraA);
     Tcl_SetResult(interp,result,TCL_STATIC);
  }

  if (numCamReq == 2) { 
     sprintf(result,"%d",cameraB);
     Tcl_SetResult(interp,result,TCL_STATIC);
  }

  return TCL_OK;
}

int tcl_andorSelectCamera(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int cameraId;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0]," camnum \"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&cameraId);

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
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0]," camnum hbin vbin hstart hend vstart vend preamp_gain vertical_speed ccd_horizontal_speed em_horizontal_speed \"", (char *)NULL);
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
  andorSetup[cameraId].npix = (hend-hstart+1)*(vend-vstart+1)/hbin/vbin;
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

  status = SetReadMode(4);
  status = SetAcquisitionMode(1);
  status = SetFrameTransferMode(1);  //NJS added
  status = SetImage(andorSetup[cameraId].image.hbin,andorSetup[cameraId].image.vbin,andorSetup[cameraId].image.hstart,andorSetup[cameraId].image.hend,andorSetup[cameraId].image.vstart,andorSetup[cameraId].image.vend);
/*  status = PrepareAcquisition();
  status = StartAcquisition();
  sleep(1);
  status = AbortAcquisition();
 */

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
  sscanf(argv[2],"%d",&ccdMode);

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


int tcl_andorStartAcquisition(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;

  status = PrepareAcquisition();
  status = StartAcquisition();
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to select start acquisition %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}


int tcl_andorAbortAcquisition(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int cameraId=0;
  int status=0;

  sscanf(argv[1],"%d",&cameraId);

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

  status = AbortAcquisition();

  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to select abort acquisition %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}


int tcl_andorGetAcquiredData(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  int cameraId=0;
  int num;

  sscanf(argv[1],"%d",&cameraId);

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

   StartAcquisition();
   GetStatus(&status);
   while(status==DRV_ACQUIRING) {
     GetTotalNumberImagesAcquired(&num);
     GetStatus(&status);
  }

  if ( cameraId == 0 ) {
     status = GetAcquiredData(imageDataA, andorSetup[cameraId].npix);
  } else {
     status = GetAcquiredData(imageDataB, andorSetup[cameraId].npix);
  }
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to get acquired data %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}


int tcl_andorGetOldestFrame(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  int cameraId=0;

  sscanf(argv[1],"%d",&cameraId);

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

  status = GetOldestImage(image_data, andorSetup[cameraId].npix);
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to get oldest frame %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}



int tcl_andorSetCropMode(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int height,width,vbin,hbin;
  int cameraId=0;

  sscanf(argv[1],"%d",&cameraId);

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

 
  /* Check number of arguments provided and return an error if necessary */
  if (argc < 5) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0]," camnum height width vbin hbin\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[2],"%d",&height);
  sscanf(argv[3],"%d",&width);
  sscanf(argv[4],"%d",&vbin);
  sscanf(argv[5],"%d",&hbin);
  status = SetIsolatedCropMode(1, height, width, vbin, hbin);
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to set crop mode %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;

}



int tcl_andorWaitForData(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int timeout;
  time_t start;

 
  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  timeout\"", (char *)NULL);
     return TCL_ERROR;
  }
  sscanf(argv[1],"%d",&timeout);
 
  start = time(NULL);
  do {
     GetStatus(&status);
     if (time(NULL) > start + timeout)
       return TCL_ERROR;
  } while (status == DRV_ACQUIRING);

  return TCL_OK;

}



int tcl_andorWaitForIdle(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=-1;
  int timeout;
  time_t start;

 
  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  timeout\"", (char *)NULL);
     return TCL_ERROR;
  }
  sscanf(argv[1],"%d",&timeout);
  start = time(NULL);
  do {
     GetStatus(&status);
     if (time(NULL) > start + timeout)
       return TCL_ERROR;
  } while (status == DRV_IDLE);

  return TCL_OK;
}


void addavg(at_32 *im, at_32 *avg, int n) 
{
  int i;
  for(i=0;i<n;i++) {
     avg[i] = avg[i]+ im[i];
  }
}

void calcavg(at_32 *avg, int n, int numexp) 
{
  int i;
  for(i=0;i<n;i++) {
     avg[i] = avg[i]/numexp;
  }
}



#ifdef TCL_USB_THREAD

int tcl_andorStartUsbThread(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;

  status = andor_start_usb_thread();
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to start usb thread %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}


int tcl_andorStopUsbThread(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;

  status = andor_stop_usb_thread();
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to stop usb thread %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}


int tcl_andorStartUsb(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;

  status = andor_start_usb();
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to start usb %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}


int tcl_andorStopUsb(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;

  status = andor_stop_usb();
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to stop usb %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}



int tcl_LockUsbMutex(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;

  status = andor_lock_usb_mutex();
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to lock usb mutex %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}


int tcl_UnlockUsbMutex(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;

  status = andor_unlock_usb_mutex();
  if (status != DRV_SUCCESS) {
     sprintf(result,"Failed to unlock usb mutex %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  return TCL_OK;
}

#endif


void create_fits_header(Tcl_Interp *interp, fitsfile *fptr)
{
    char *text;
    int status;
    float fvar;
    int ivar;
    int utcmon, utcyear;
    double utcday;
    double jdobs, mjdobs;
    struct tm *gmt;
    time_t t;

    status = 0;
    fits_write_key(fptr, TSTRING, "CREATOR", "Linux ANDOR CCD control", "NESSI Data-taking program", &status);
/*
    text = Tcl_GetVar2(interp, "SCOPE", "site", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "OBSERVAT", text, "Observatory Site", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "name", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "TELESCOP", text, "Telescope Name",&status);
    text = Tcl_GetVar2(interp, "SCOPE", "latitude", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "LATITUDE", text, "[deg] Observatory Latitude", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "longitude", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "LONGITUD", text, "[deg west] Observatory Longtiude", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "camera", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "INSTRUME", text, "Instrument", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "detector", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "DETECTOR", text, "CCD Detector ID", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "instrument", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "INSTID", text, "Instrument ID Code", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "observer", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "OBSERVER", text, "Observer(s)", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "target", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "OBJECT", text, "Target Name",&status);
    text = Tcl_GetVar2(interp, "SCOPE", "imagetype", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "OBSTYPE", text, "Image type code", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "exposure", TCL_GLOBAL_ONLY); 
    sscanf(text,"%f", &fvar);
    fits_write_key_fixflt(fptr, "EXPTIME", fvar, 2, "[sec] Exposure time", &status);
    fits_write_key(fptr, TSTRING, "TIMESYS", "UTC", "Time System is UTC", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "obsdate", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "DATE-OBS", text, "Date of start of observation", &status);
    text = Tcl_GetVar2(interp, "SCOPE", "obstime", TCL_GLOBAL_ONLY); 
    fits_write_key(fptr, TSTRING, "TIME-OBS", text, "Time of start of observation", &status);
 */
    t = time(NULL);
    gmt = gmtime(&t);

    utcday = (double)(gmt->tm_mday) + ((double)(gmt->tm_hour) + (double)(gmt->tm_min)/60.0
                                   + (double)(gmt->tm_sec)/3600.0) / 24.0 ;

    utcmon = gmt->tm_mon + 1;

    utcyear = gmt->tm_year + 1900;

    cal_mjd(utcmon, utcday, utcyear, &mjdobs);

    jdobs = mjdobs + 2415020.0;

    mjdobs = jdobs - 2400000.5;

    fits_write_key_fixdbl( fptr, "MJD-OBS", mjdobs, 6, "MJD at start of obs", &status);
    fits_write_key_fixdbl( fptr, "JD", jdobs, 5, "Julian Date at start of obs", &status);

/*
    text = Tcl_GetVar2(interp, "CAMSTATUS", "Temperature", TCL_GLOBAL_ONLY); 
    sscanf(text,"%f", &fvar);
    fits_write_key_fixflt(fptr, "CCDTEMP", fvar, 1, "[C] CCD temperature at readout", &status);
    text = Tcl_GetVar2(interp, "CAMSTATUS", "BinX", TCL_GLOBAL_ONLY); 
    sscanf(text,"%d", &ivar);
    fits_write_key(fptr, TSHORT, "CCDXBIN", &ivar, "Column Binning on detector", &status);
    text = Tcl_GetVar2(interp, "CAMSTATUS", "BinY", TCL_GLOBAL_ONLY); 
    sscanf(text,"%d", &ivar);
    fits_write_key(fptr, TSHORT, "CCDYBIN", &ivar, "Row Binning on detector", &status);
 */

}





