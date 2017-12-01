/*                      guiderVersion.c

 *  Module name:
      guiderVersion

 *  Function:
      Return the current guider version which is set in the Makefiles.

 *  Description:
      Supports the TCL and C version functions.

 *  Language:
      C

 *  Support: Dave Mills - The Random Factory

 *

 *  History:
    

 *  Rcs Id:  $Id: guiderVersion.c,v 1.1 1995/06/10 00:30:51 rfactory Exp $

 */
#include <stdio.h>
#include <stdarg.h>
#include <signal.h>
#include <string.h>

static char *version = VER;

char *guiderGetVersion(void)
{
  return version;
}
