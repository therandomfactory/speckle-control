
/* Generic WIYN Client: gwcR.h

 *  Header name:
        gwcR.h

 *  Function:
        This file is a public interface for the "special" needs of
        the MPG router.  The functions in this interface
        are used within the library and the MPG router, 
	but are not exported to users.

 *  Description:
        This file is the semi-private GWC router interface.

 *  Language:
      C

 *  Support: Kim Gillies, NOAO

 *

 *  History:
      14 Feb 95 - Created - KG

 *  Rcs Id:  $Id: gwcR.h,v 1.2 2004/11/30 21:30:53 behzad Exp $

 */
#ifndef _GWCR_H
#define _GWCR_H

#ifndef _GWC_H
#include "gwc.h"
#endif

/* An array of these structures is passed by the router to GWC to
 * send data to a set of clients.  success is set to true if the client
 * was written successfully.
 */
typedef struct gwcSocks
{
    int socket;
    int failure;
}
gwcSocks;

#define SOCKSOCKET(s) ((s).socket)
#define SOCKFAILED(s) ((s).failure)

/* Values for failure */
#define GWC_WRITE_SUCCESS 0
#define GWC_WRITE_FAILED 1

/* Special function for router to send message to a set of sockets 
 * This function returns 1 if successful (TCL_OK) or a positive number or 0
 * if some socket write failed.  The number is the number of successful
 * writes and should be equal to ssize if all succeeded.
 * Arguments:
 *  IN: info - the connection info structure
 *      streamname - the stream to put
 *      stype - changed or all
 *      socks[] - an array of size ssize of gwcSock structures
 *      ssize - the size of the socks array
 *  RETURNS:
 *      TCL_OK  if successful
 *      non-zero - the number of successful writes (must be between 0 and
 *                 ssize.
 */
int gwcPutStreamMultiple (gwcConnectInfo info, char *streamname,
                          putType stype, gwcSocks socks[], int ssize);

#endif /* _GWCR_H */
