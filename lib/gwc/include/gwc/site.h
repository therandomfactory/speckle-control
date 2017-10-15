
/* Generic WIYN Client: site.h

 *  Module name:
        site.h

 *  Function:
        This file contains GWC environment defines/defaults.

 *  Description:
        This file contains definitions that are used for system
        specification.

 *  Language:
      C

 *  Support: Kim Gillies, NOAO

 *

 *  History:
      12 Dec 94: Version 2 - goes into CVS

 */
#ifndef _SITE_H
#define _SITE_H

#define ALL 0                   /* Used to subscribe to all devices */

#define DEFAULT_GWCHOME         "/usr/local/gwc"

/* for socket connections */
#define DEFAULT_GWC_ROUTER      "bone.kpno.noao.edu"

/* One more than the standard WIYN router port */
#ifndef WIYN_ROUTER_PORT
#define WIYN_ROUTER_PORT	(2345)
#endif
#define DEFAULT_GWC_ROUTER_PORT (WIYN_ROUTER_PORT+1)

#endif /* _SITE_H */
