/* 
   This file contains the tcl interface routine to high level API for Nessi Zaber Linear stage control

   Author : Dave Mills (The Random Factory)
   Date   : July 7th 2017
 
   This Source Code Form is subject to the terms of the GNU Public
   License, v. 2.1. If a copy of the GPL was not distributed with this file,
   You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
 
  Copyright(c) 2017 The Random Factory (www.randomfactopry.com)  
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
#include "za_serial.h"
#include "zb_serial.h"

int tcl_za_connect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_za_setbaud(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_za_send(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_za_receive(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_za_disconnect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_za_drain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_zb_receive(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_zb_send(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_zb_connect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_zb_disconnect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_zb_drain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);

char *result;

int tcl_za_connect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;

  result = malloc(256);

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  name\"", (char *)NULL);
     return TCL_ERROR;
  }

  status = za_connect(&handle, argv[1]);
  if (status != 0) {
     sprintf(result,"Failed to open port - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  sprintf(result,"%d",handle);
  Tcl_SetResult(interp,result,TCL_STATIC);

  return TCL_OK;
}


int tcl_za_setbaud(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  int baudrate;
  
  result = malloc(256);

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 3) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle rate\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&handle);
  sscanf(argv[1],"%d",&baudrate);
  status = za_setbaud(handle, baudrate);
  if (status != 0) {
     sprintf(result,"Failed to set baud rate- %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}

int tcl_za_send(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  char command[128];
  

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 3) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle command\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  sscanf(argv[2], "%s", &command);
  status = za_send(handle, command);
  if (status < 0) {
     sprintf(result,"Failed to send command - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}

int tcl_za_receive(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  char reply[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  status = za_receive(handle, &reply, 255);
  if (status < 0) {
     sprintf(result,"Failed to get reply - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  Tcl_AppendResult(interp, reply, (char *)NULL);
  return TCL_OK;
}

int tcl_zb_receive(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  uint8_t reply[128];
  int rdata;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  status = zb_receive(handle, &reply);
  if (status != 6) {
     sprintf(result,"Failed to get reply - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }
  status = zb_decode(&rdata, reply);
  sprintf(result,"%d %d %d",reply[0],reply[1],rdata);
  Tcl_SetResult(interp,result,TCL_STATIC);
  return TCL_OK;
}

int tcl_zb_send(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  int command;
  
  uint8_t cbuffer[6];
  uint8_t cmdid, devid;

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 5) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle devid cmdid command\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  sscanf(argv[2], "%d", &devid);
  sscanf(argv[3], "%d", &cmdid);
  sscanf(argv[4], "%d", &command);
  status = zb_encode(&cbuffer,devid,cmdid,command);
  status = zb_send(handle, cbuffer);
  if (status != 6) {
     sprintf(result,"Failed to send command - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}


int tcl_za_disconnect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  status = za_disconnect(handle);
  if (status != 0) {
     sprintf(result,"Failed to close port - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}


int tcl_zb_connect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  name\"", (char *)NULL);
     return TCL_ERROR;
  }

  status = zb_connect(&handle, argv[1]);
  if (status != 0) {
     sprintf(result,"Failed to open port - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  sprintf(result,"%d",handle);
  Tcl_SetResult(interp,result,TCL_STATIC);

  return TCL_OK;
}

int tcl_zb_disconnect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  status = zb_disconnect(handle);
  if (status != 0) {
     sprintf(result,"Failed to close port - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}

int tcl_za_drain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  
 
  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  status = za_drain(handle);
  if (status != 0) {
     sprintf(result,"Failed to flush - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}

int tcl_zb_drain(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  z_port handle;
  

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  handle\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  status = zb_drain(handle);
  if (status != 0) {
     sprintf(result,"Failed to flush - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}

/* Routine : zaberAppInit
   Purpose : This routine is called from tclAppInit and initializes all the zaber
             tcl interface routines
 */
int zaberAppInit(Tcl_Interp *interp)
{

/* Initialize the new commands */
   Tcl_CreateCommand(interp, "za_connect", (Tcl_CmdProc *) tcl_za_connect, NULL, NULL);
   Tcl_CreateCommand(interp, "za_disconnect", (Tcl_CmdProc *) tcl_za_disconnect, NULL, NULL);
   Tcl_CreateCommand(interp, "za_setbaud", (Tcl_CmdProc *) tcl_za_setbaud, NULL, NULL);
   Tcl_CreateCommand(interp, "za_send", (Tcl_CmdProc *) tcl_za_send, NULL, NULL);
   Tcl_CreateCommand(interp, "za_receive", (Tcl_CmdProc *) tcl_za_receive, NULL, NULL);
   Tcl_CreateCommand(interp, "za_connect", (Tcl_CmdProc *) tcl_za_connect, NULL, NULL);
   Tcl_CreateCommand(interp, "zb_drain", (Tcl_CmdProc *) tcl_zb_drain, NULL, NULL);
   Tcl_CreateCommand(interp, "za_disconnect", (Tcl_CmdProc *) tcl_za_disconnect, NULL, NULL);
   Tcl_CreateCommand(interp, "zb_send", (Tcl_CmdProc *) tcl_zb_send, NULL, NULL);
   Tcl_CreateCommand(interp, "zb_receive", (Tcl_CmdProc *) tcl_za_send, NULL, NULL);
   Tcl_CreateCommand(interp, "zb_drain", (Tcl_CmdProc *) tcl_zb_drain, NULL, NULL);
   return TCL_OK;
}


