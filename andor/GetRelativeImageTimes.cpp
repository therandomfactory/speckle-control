#include <stdio.h>
#include <time.h>
#include "atmcd32d.h"

int main(int, char**)
{
  DWORD error = Initialize("");
  printf("Initialize returned %d\n", error);
  if (error == DRV_SUCCESS) {
    int index, xpixels, ypixels;
    float expTime, cycTime, kinTime, speed;
    long nImages = 10;

    GetDetector(&xpixels, &ypixels);
    SetShutter(1, 1, 0, 0); // shutter fully open
    SetPreAmpGain(0);
    SetTriggerMode(0); // internal trigger
    GetFastestRecommendedVSSpeed(&index, &speed);
    SetVSSpeed(index); // recommended vertical shift speed
    SetADChannel(0); // only one channel so not strictly necessary for the ultra
    SetHSSpeed(0, 0); // EM amplifier, fastest horizontal shift speed
    SetFrameTransferMode(1); // frame transfer on

    SetExposureTime(0.010f);

    SetReadMode(4); // imaging mode
    SetImage(1, 1, 1, xpixels, 1, ypixels);
    SetAcquisitionMode(3); // kinetic series
    SetNumberKinetics(nImages);

    GetAcquisitionTimings(&expTime, &cycTime, &kinTime);
    printf("Cycle Time %f seconds (%fHz)\n", cycTime, 1. / cycTime);

    error = StartAcquisition();
    printf("StartAcquisition() returns %d\n", error);
    printf("Attempting to acquire...\n");
    if (error == DRV_SUCCESS) {
      long first = 0, last = 0, validfirst, validlast;
      at_u64 timeFromStart[100];
      while (last < nImages) {
        WaitForAcquisition();
        GetNumberNewImages(&first, &last);
        
        long numFrames = last - first + 1;
        long frameSize = xpixels * ypixels;
        GetRelativeImageTimes(first, last, timeFromStart, numFrames);

        unsigned long size = numFrames * frameSize;
        long* arr = new long[size];

        error = GetImages(first, last, arr, size, &validfirst, &validlast);
        printf("GetImages() returns %d\n", error);

        long count = 0;
        for (long i = first; i <= last; i++) {
          int index = (int)((count + 0.5) * frameSize);
          printf("%d:  %llu nanoseconds, %d counts\n", i, timeFromStart[count], arr[index]);
          count++;
        }

        delete[] arr;
      }
    }

    SYSTEMTIME st;
    float f_timeFromStart;
    error = GetMetaDataInfo(&st, &f_timeFromStart, 0);
    if (error == DRV_SUCCESS) {
      printf("Start time: %d/%d/%d %d:%d:%d.%d\n", st.wDay, st.wMonth, st.wYear, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);
    }

    printf("ShutDown() returned %d\n", ShutDown());
  }

  printf("End\n");
  getc(stdin);

  return 0;
}