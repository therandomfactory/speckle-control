/*Andor example program showing the use of the SDK to
perform a single full image acquisition from
the CCD. The image is saved in file image.bmp*/
#include <stdio.h>

#ifdef __GNUC__
#  if(__GNUC__ > 3 || __GNUC__ ==3)
#	define _GNUC3_
#  endif
#endif

#ifdef _GNUC3_
#  include <iostream>
#  include <fstream>
   using namespace std;
#else
#  include <iostream.h>
#  include <fstream.h>
#endif
#include <unistd.h>
#include <time.h>
#include <signal.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "vips/vips.h"

//#include "atmcdLXd.h"
#include <atmcdLXd.h>
unsigned short *SharedMem;
struct shmid_ds Shmem_buf;
int Shmem_size = 512*256*4;
int Shmem_id = 0;
void dofft(int width, int height, int *imageData, int* outputData);
void addavg(at_32 *im, at_32 *avg, int n);
void calcavg(at_32 *avg, int n, int numexp);

int CameraSelect (int iNumArgs, char* szArgList[]);

int main(int argc, char* argv[])
{
        int num;

        if (CameraSelect (argc, argv) < 0) {
          cout << "*** CAMERA SELECTION ERROR" << endl;
          return -1;
        }
  
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
        if (argc > 2) { 
           sscanf(argv[2],"%f",&exposure);
        }
        if (argc > 3) { 
           sscanf(argv[3],"%d",&numexp);
        }
	//Initialize CCD
	error = Initialize("/usr/local/etc/andor");
	if(error!=DRV_SUCCESS){
		cout << "Initialisation error...exiting" << endl;
		return(1);
	}

	sleep(2); //sleep to allow initialization to complete

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

	at_32* imageData = new at_32[width*height];
        Shmem_size = 2*width*height*4;
	at_32* outputData = new at_32[width*height];

	at_32* outputAvg = new at_32[width*height];
      Shmem_id = shmget(7772, Shmem_size, IPC_CREAT|0666);
      if (Shmem_id < 0) {
        Shmem_id = shmget(7772, Shmem_size, IPC_CREAT|0666);
      }
	printf("CameraSetup: Shared memory shmid = %d.\n",Shmem_id);
//      Shmem_size = Shmem_buf.shm_segsz; 
      SharedMem  = (unsigned short *) shmat(Shmem_id, NULL, 0);
      SharedMem2 = SharedMem + width*height*2;
  	printf("CameraSetup: Attached shared memory @%lx, using %d bytes\n",SharedMem, Shmem_size);
  	printf("CameraSetup: Attached shared memory2 @%lx, using %d bytes\n",SharedMem2, Shmem_size/2);
	quit = false;

	while (count < numexp) {
			StartAcquisition();

			int status;


			//Loop until acquisition finished
			GetStatus(&status);
			while(status==DRV_ACQUIRING) {
                              GetTotalNumberImagesAcquired(&num);
                              GetStatus(&status);
                       }
//                        GetOldestImage16();
			GetAcquiredData(imageData, width*height);
                        dofft(width,height,imageData,outputData);
                        memcpy(SharedMem,outputData,Shmem_size/2);
                        memcpy(SharedMem2,imageData,Shmem_size/2);
                        addavg(outputData,outputAvg,width*height);
                         count  = count+1;
                         printf(".");
                         fflush(stdout);

	}
        calcavg(outputAvg,width*height,numexp);
        memcpy(SharedMem,outputAvg,Shmem_size/2);

	//Shut down CCD
	AbortAcquisition();
        sleep(2);
	ShutDown();	

	return 0;
}

void addavg(at_32 *im, at_32 *avg, int n) 
{
  for(int i=0;i<n;i++) {
     avg[i] = avg[i]+ im[i];
  }
}

void calcavg(at_32 *avg, int n, int numexp) 
{
  for(int i=0;i<n;i++) {
     avg[i] = avg[i]/numexp;
  }
}


int CameraSelect (int iNumArgs, char* szArgList[])
{
  if (iNumArgs == 2) {
 
    at_32 lNumCameras;
    GetAvailableCameras(&lNumCameras);
    int iSelectedCamera = atoi(szArgList[1]);
 
    if (iSelectedCamera < lNumCameras && iSelectedCamera >= 0) {
      at_32 lCameraHandle;
      GetCameraHandle(iSelectedCamera, &lCameraHandle);
      SetCurrentCamera(lCameraHandle);
      return iSelectedCamera;
    }
    else
      return -1;
  }
  return 0;
}
