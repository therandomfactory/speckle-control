/*                      ccdVersion.c

 *  Module name:
      ccdVersion

 *  Function:
      Return the current ccd version which is set in the Makefiles.

 *  Description:
      Supports the TCL and C version functions.

 *  Language:
      C

 *  Support: Dave Mills - The Random Factory

 *

 *  History:
    

 *  Rcs Id:  $Id: ccdVersion.c,v 1.1 1995/06/10 00:30:51 rfactory Exp $

 */
#include <stdio.h>
#include <stdarg.h>
#include <signal.h>
#include <string.h>

static char *version = VER;

char *ccdGetVersion(void)
{
  return version;
}
