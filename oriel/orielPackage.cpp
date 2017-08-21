
/*
 * orielPackage.c
 */

extern "C"
{
 
#include <tcl.h>

int orielAppInit(Tcl_Interp *interp);

static char export_script[]={ " \
	namespace eval ::oriel:: { \
		namespace export help setup test1 \
	} " };


static int doTest1(void)
{
  fprintf(stderr, "doTest1\n");

  /*  'x' is temporary check of library load  */

  fprintf(stderr, "oriel Version 1.0\n");

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
int Oriel_Init(Tcl_Interp *interp)
{

  printf("oriel_Init\n");

  Tcl_PkgProvide(interp, "oriel", "1.0");

  /*  export namespace  */


  Tcl_Eval(interp, export_script);

  Tcl_CreateObjCommand(interp, "oriel::test1", (Tcl_ObjCmdProc *)cmdTest1,
                       (ClientData)NULL, (Tcl_CmdDeleteProc *)NULL);

  orielAppInit(interp);

  return TCL_OK;
}

/*  dummy  */

int _eprintf()
{
return TCL_OK;
}

}

