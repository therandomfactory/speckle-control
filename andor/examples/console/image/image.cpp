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
#include <string.h>
#include <stdlib.h>

//#include "atmcdLXd.h"
#include <atmcdLXd.h>
unsigned short *SharedMem;
struct shmid_ds Shmem_buf;
int Shmem_size = 1024*1024*4;
int Shmem_id = 0;

int CameraSelect (int iNumArgs, char* szArgList[]);

int main(int argc, char* argv[])
{
        int num;

        if (CameraSelect (argc, argv) < 0) {
          cout << "*** CAMERA SELECTION ERROR" << endl;
          return -1;
        }
  
	unsigned long error;
	bool quit;
	char choice;
        int count=0;
	float fChoice;
	int width, height;
        
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
	SetExposureTime(0.04);

	//Get Detector dimensions
	GetDetector(&width, &height);

	//Initialize Shutter
	SetShutter(1,1,50,50);
        SetFrameTransferMode(1);
        
        //Setup Image dimensions
        SetImage(1,1,1,width,1,height);

	at_32* imageData = new at_32[width*height];
        Shmem_size = width*height*4;

      Shmem_id = shmget(7771, Shmem_size, IPC_CREAT|0666);
      if (Shmem_id < 0) {
        Shmem_id = shmget(7771, Shmem_size, IPC_CREAT|0666);
      }
	printf("CameraSetup: Shared memory shmid = %d.\n",Shmem_id);
//      Shmem_size = Shmem_buf.shm_segsz; 
      SharedMem  = (unsigned short *) shmat(Shmem_id, NULL, 0);
  	printf("CameraSetup: Attached shared memory @%lx, using %d bytes\n",SharedMem, Shmem_size);
	quit = false;
	while (count < 1000) {
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
                        memcpy(SharedMem,imageData,Shmem_size);
                         count  = count+1;
                         printf(".");

	}

	//Shut down CCD
       sleep(2);
	ShutDown();	

	return 0;
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
