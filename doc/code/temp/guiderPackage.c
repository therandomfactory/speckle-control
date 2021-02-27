
/*
 * guiderPackage.c
 */

#ifndef lint
static char *rcsId="$Id$";
#endif

#include <tcl.h>


static char export_script[]={ " \
	namespace eval ::guider:: { \
		namespace export help setup test1 \
	} " };


static int doTest1(void)
{
  fprintf(stderr, "doTest1\n");

  /*  'x' is temporary check of library load  */

  fprintf(stderr, "Guider Version 1.0\n");

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
int Guider_Init(Tcl_Interp *interp)
{
  Tcl_Namespace *namesp_ptr;

  printf("Guider_Init\n");

  Tcl_PkgProvide(interp, "guider", "1.0");

  /*  export namespace  */


  Tcl_Eval(interp, export_script);

  Tcl_CreateObjCommand(interp, "guider::test1", (Tcl_ObjCmdProc *)cmdTest1,
                       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

  guiderAppInit(interp);

  return TCL_OK;
}

/*  dummy  */

int _eprintf()
{
return TCL_OK;
}

