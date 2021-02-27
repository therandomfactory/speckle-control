/** 
 * \file oriel_tcl.cpp
 * \brief Tcl wrapper for Oriel filter wheel control
 * 
 */

/* 
   This file contains the tcl interface routine to high level API for Nessi Oriel filter wheel

   Author : Dave Mills (The Random Factory)
   Date   : July 7th 2017
 
   This Source Code Form is subject to the terms of the GNU Public
   License, v. 2.1. If a copy of the GPL was not distributed with this file,
   You can obtain one at https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html
 
  Copyright(c) 2017 The Random Factory (www.randomfactory.com)  
 */

 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tcl.h"
#include "tk.h"
#include <math.h>
#include <time.h>
#include <stdlib.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <stdint.h>
#include "GenOneLinuxUSB.h" 

extern "C" {

/** 
 * \brief ClientData Tcl handle
 * \param Tcl_Interp interpreter pointer
 * \param argc Argument count
 * \param arcv Arguments
 *
 */
int tcl_oriel_connect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
/** 
 * \brief ClientData Tcl handle
 * \param Tcl_Interp interpreter pointer
 * \param argc Argument count
 * \param arcv Arguments
 *
 */

int tcl_oriel_write_cmd(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
/** 
 * \brief ClientData Tcl handle
 * \param Tcl_Interp interpreter pointer
 * \param argc Argument count
 * \param arcv Arguments
 *
 */

int tcl_oriel_read_result(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
/** 
 * \brief ClientData Tcl handle
 * \param Tcl_Interp interpreter pointer
 * \param argc Argument count
 * \param arcv Arguments
 *
 */

int tcl_oriel_disconnect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
/** 
 * \brief Initialize the wrapper commands
 * \param Tcl_Interp interpreter pointer
 *
 */
int orielAppInit(Tcl_Interp *interp);


char *result;
GenOneLinuxUSB *filterWheel[3];
//GenOneLinuxUSB filterWheelA = GenOneLinuxUSB(1);
//GenOneLinuxUSB filterWheelB = GenOneLinuxUSB(2);

int tcl_oriel_connect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  int id=0;
  int ubus,uaddr;

  result = malloc(256);

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0]," id\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1],"%d",&id);
  filterWheel[id] = (GenOneLinuxUSB *) new GenOneLinuxUSB(id);

  if (filterWheel[id]->m_Device == 0) {
     sprintf(result,"USB Error: Failed to open wheel - %d",id);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  ubus = filterWheel[id]->GetBus();
  uaddr = filterWheel[id]->GetAddress();

  sprintf(result,"%d %3.3d:%3.3d",filterWheel[id]->m_Device,ubus,uaddr);
  Tcl_SetResult(interp,result,TCL_STATIC);

  return TCL_OK;
}


int tcl_oriel_write_cmd(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  int handle;
  char command[128];
  

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 3) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  id command\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  sscanf(argv[2], "%s", &command);
  filterWheel[handle]->write_cmd(command);
  if (status < 0) {
     sprintf(result,"Failed to send command - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  return TCL_OK;
}

int tcl_oriel_read_result(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  int handle;
  char reply[128];

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  id\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  status = filterWheel[handle]->read_result(reply,128);
  if (status <= 0) {
     sprintf(result,"Failed to get reply - %d",status);
     Tcl_SetResult(interp,result,TCL_STATIC);
     return TCL_ERROR;
  }

  Tcl_AppendResult(interp, reply, (char *)NULL);
  return TCL_OK;
}

int tcl_oriel_disconnect(ClientData clientData, Tcl_Interp *interp, int argc, char **argv)
{
  int status=0;
  int handle;
  

  /* Check number of arguments provided and return an error if necessary */
  if (argc < 2) {
     Tcl_AppendResult(interp, "wrong # args: should be \"",argv[0],"  id\"", (char *)NULL);
     return TCL_ERROR;
  }

  sscanf(argv[1], "%d", &handle);
  delete &filterWheel[handle];

  return TCL_OK;
}

/* Routine : orielAppInit
   Purpose : This routine is called from tclAppInit and initializes all the oriel
             tcl interface routines
 */

int orielAppInit(Tcl_Interp *interp)
{

/* Initialize the new commands */
   Tcl_CreateCommand(interp, "oriel_connect", (Tcl_CmdProc *) tcl_oriel_connect, NULL, NULL);
   Tcl_CreateCommand(interp, "oriel_disconnect", (Tcl_CmdProc *) tcl_oriel_disconnect, NULL, NULL);
   Tcl_CreateCommand(interp, "oriel_write_cmd", (Tcl_CmdProc *) tcl_oriel_write_cmd, NULL, NULL);
   Tcl_CreateCommand(interp, "oriel_read_result", (Tcl_CmdProc *) tcl_oriel_read_result, NULL, NULL);
   return TCL_OK;
}


}


