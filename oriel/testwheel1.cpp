//
//  g++ -c -g -I../include GenOneLinuxUSB.cpp -fpermissive
//  g++ -g -o test1 testwheel1.cpp GenOneLinuxUSB.o -L../lib -I. -I../include ../lib/libusb-1.0.so.0 -lstdc++ -fpermissive
//

#include "string.h"
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

#include "GenOneLinuxUSB.h"

int main(int argc, char **argv)
{
  char *result=(char *)malloc(128);
  char *cmd=(char *)malloc(32);

  int status;
  unsigned int count=80;

  GenOneLinuxUSB wheelA = GenOneLinuxUSB(1);
  printf("Connected to wheel 1\n");
 
  wheelA.write_cmd("STB?\n");
  status=wheelA.read_result(result,count);
  printf("result of STB? is %d, %s\n",status,result);
  wheelA.write_cmd("IDN?\n");
  status=wheelA.read_result(result,count);
  printf("result of IDN? is %d, %s\n",status,result);
  wheelA.write_cmd("NEXT\n");
  status=wheelA.read_result(result,count);
  printf("result of NEXT is %d, %s\n",status,result);
  wheelA.write_cmd("FILT?\n");
  status=wheelA.read_result(result,count);
  printf("result of FILT? is %d, %s\n",status,result);
  delete (GenOneLinuxUSB *)&wheelA;

  sleep(100);

}


