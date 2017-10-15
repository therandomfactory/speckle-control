
/* Generic WIYN Client: names.h

 *  Module name:
        names.h

 *  Function:
       This file defines the public API for the names library.

 *  Description:
       The public interface to the names library for WIYN.
       The names dictionary is a single instance of a nameDict structure.

 *  Language:
      C

 *  Author: Kim Gillies
 *  Support: Kim Gillies, NOAO

 *

 *  History:
      12 Dec 94: Version - goes into CVS

 *  Rcs Id:  $Id: names.h,v 1.2 2004/11/30 21:30:54 behzad Exp $

 */
#ifndef _NAMES_H
#define _NAMES_H

typedef struct _nameData *nameDataPtr;

/* Initialize the names */
int ndNamesInit (Tcl_Interp * interp, char *file);

/* Fetch and create */
int ndFetchCreateSubsystem (char *s, int *newid);

int ndFetchCreateDevice (char *s, int *newid);

/* Create a new subsystem */
int ndNewSubsystem (char *s, int *newid);

/* Create a new device */
int ndNewDevice (char *s, int *newid);

/* Return a name */
char *ndGetName (nameDataPtr);

/* Return an id */
int ndGetId (nameDataPtr);

/* Return both */
int ndGetBoth (nameDataPtr d, int *id, char **name);

/* Get systems */
nameDataPtr ndGetSystemByName (char *name);
nameDataPtr ndGetSystemById (int id);

/* Get actions */
nameDataPtr ndGetActionById (int id);
nameDataPtr ndGetActionByName (char *name);

/* Get devices */
nameDataPtr ndGetDeviceById (int id);
nameDataPtr ndGetDeviceByName (char *name);

/* Get device actions */
nameDataPtr ndGetDevActionById (int id);
nameDataPtr ndGetDevActionByName (char *name);

/* Attributes */
nameDataPtr ndGetAttributeById (int id);
nameDataPtr ndGetAttributeByName (char *name);

/* Subsystems */
nameDataPtr ndGetSubsystemById (int id);
nameDataPtr ndGetSubsystemByName (char *name);

/* Units */
nameDataPtr ndGetUnitById (int id);
nameDataPtr ndGetUnitByName (char *name);

/* WIYN Protability functions */

/* Get systems */
int system_code (char *name);
char *system_name (int id);
int system_hits (char *name);

/* Get actions */
char *action_name (int id);
int action_code (char *name);
int action_hits (char *name);

/* Get devices */
char *device_name (int id);
int device_code (char *name);
int device_hits (char *name);

/* Attributes */
char *attribute_name (int id);
int attribute_code (char *name);
int attribute_hits (char *name);

/* Subsystems */
char *subsystem_name (int id);
int subsystem_code (char *name);
int subsystem_hits (char *name);

/* Units */
char *unit_name (int id);
int unit_code (char *name);
int unit_hits (char *name);

#endif /* _NAMES_H */
