/*                      zaberVersion.c

 *  Module name:
      zaberVersion

 *  Function:
      Return the current zaber version which is set in the Makefiles.

 *  Description:
      Supports the TCL and C version functions.

 *  Language:
      C

 *  Support: Dave Mills - The Random Factory

 *

 *  History:
    

 */
#include <stdio.h>
#include <stdarg.h>
#include <signal.h>
#include <string.h>

static char *version = VER;

char *zaberGetVersion(void)
{
  return version;
}
