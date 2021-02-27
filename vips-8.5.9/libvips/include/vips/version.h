/* Macros for the header version.
 */

#ifndef VIPS_VERSION_H
#define VIPS_VERSION_H

#define VIPS_VERSION		"8.8.2"
#define VIPS_VERSION_STRING	"8.8.2-Thu Feb 25 19:07:27 UTC 2021"
#define VIPS_MAJOR_VERSION	(8)
#define VIPS_MINOR_VERSION	(8)
#define VIPS_MICRO_VERSION	(2)

/* The ABI version, as used for library versioning.
 */
#define VIPS_LIBRARY_CURRENT	(53)
#define VIPS_LIBRARY_REVISION	(1)
#define VIPS_LIBRARY_AGE	(11)

/** 
 * VIPS_SONAME:
 *
 * The name of the shared object containing the vips library, for example
 * "libvips.so.42", or "libvips-42.dll".
 */

#include "soname.h"

/* Not really anything to do with versions, but this is a handy place to put
 * it.
 */
#define VIPS_EXEEXT ""
#define VIPS_ENABLE_DEPRECATED 1

#endif /*VIPS_VERSION_H*/
