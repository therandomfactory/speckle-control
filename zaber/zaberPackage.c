
/*
 * zaberPackage.c
 */


#include <tcl.h>


static char export_script[]={ " \
	namespace eval ::zaber:: { \
		namespace export help setup test1 \
	} " };


static int doTest1(void)
{
  fprintf(stderr, "doTest1\n");

  /*  'x' is temporary check of library load  */

  fprintf(stderr, "zaber Version %s x2\n", zaberGetVersion());

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
int Zaber_Init(Tcl_Interp *interp)
{

  printf("zaber_Init\n");

  Tcl_PkgProvide(interp, "zaber", "1.0");

  /*  export namespace  */


  Tcl_Eval(interp, export_script);

  Tcl_CreateObjCommand(interp, "zaber::test1", (Tcl_ObjCmdProc *)cmdTest1,
                       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

  zaberAppInit(interp);

  return TCL_OK;
}

/*  dummy  */

int _eprintf()
{
return TCL_OK;
}

