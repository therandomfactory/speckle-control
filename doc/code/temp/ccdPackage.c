
/*
 * ccdPackage.c
 */

#ifndef lint
static char *rcsId="$Id$";
#endif

#include <tcl.h>


static char export_script[]={ " \
	namespace eval ::ccd:: { \
		namespace export help setup test1 \
	} " };


static int doTest1(void)
{
  fprintf(stderr, "doTest1\n");

  /*  'x' is temporary check of library load  */

  fprintf(stderr, "Ccd Version %s x2\n", ccdGetVersion());

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
int Ccd_Init(Tcl_Interp *interp)
{
  Tcl_Namespace *namesp_ptr;

  printf("Ccd_Init\n");

  Tcl_PkgProvide(interp, "ccd", "2.0");

  /*  export namespace  */


  Tcl_Eval(interp, export_script);

  Tcl_CreateObjCommand(interp, "ccd::test1", (Tcl_ObjCmdProc *)cmdTest1,
                       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

  ccdAppInit(interp);

  return TCL_OK;
}

/*  dummy  */

int _eprintf()
{
return TCL_OK;
}

