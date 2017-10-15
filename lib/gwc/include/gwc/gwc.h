
/* Generic WIYN Client: gwc.h
 
 
 *  Header name:
        gwc.h
 
 *  Function:
        This file is the public API for the GWC - Generic Wiyn Client
	programming library.  Only the functions in this interface
	are supported for application use.
 
 *  Description:
        This file is the public programmer interface to GWC.
 
 *  Language:
      C
 
 *  Support: Kim Gillies, NOAO
 
 *
 
 *  History:
      12 Dec 94: Version 2 - goes into CVS
 
 */
#ifndef _GWC_H
#define _GWC_H

#ifndef _TCL
#include <tcl.h>
#endif

#ifndef _SITE_H
#include "site.h"
#endif

#include <stdint.h>

/* ----- Connection Information and functions acting on connections ----- */
typedef struct _gwcConnectInfo *gwcConnectInfo;

/* Connect to the router */
int gwcRouterConnect (gwcConnectInfo info);

/* Return the client socket */
int gwcGetClientSocket (gwcConnectInfo info);

/* Set the client socket */
void gwcSetClientSocket (gwcConnectInfo info, int sock);

/* Get host name */
char *gwcGetClientHost (gwcConnectInfo info);

/* Get router host name */
char *gwcGetRouterHost (gwcConnectInfo info);

/* Get connection interpreter */
Tcl_Interp *gwcGetInterp (gwcConnectInfo info);

/* Get/Set client data */
ClientData gwcGetClientData (gwcConnectInfo info);

void gwcSetClientData (gwcConnectInfo info, ClientData clientdata);

/* Get/Set connection status  - state 1 for connected - for not connected */
void gwcSetConnected (gwcConnectInfo info, int state);

int gwcGetConnected (gwcConnectInfo info);

/* -------- Data types used within GWC stream functions ---------- */

/* These are the valid data types */
#ifndef GWC_PRIVATE
enum valueType
{
    ENG_INT = 0,
    ENG_SHORT = 1,
    ENG_FLOAT = 2,
    ENG_ENUM = 3,
    ENG_CHAR = 4,
    ENG_LONG = 5,
    ENG_DOUBLE = 6,
    ENG_STRING = 7
};
typedef enum valueType valueType;

enum alarmType
{
    AL_OK = 0,
    AL_WARNING = 1,
    AL_FAILURE = 2,
    AL_HIHI = 3,
    AL_HI = 4,
    AL_LO = 5,
    AL_LOLO = 6,
    AL_LOST_CONNECTION,
    AL_UNKNOWN
};
typedef enum alarmType alarmType;

enum actionType
{
    COMMAND = 0,
    STATUS_ITEM = 1,
    REPLY_ACK = 2,
    REPLY_BUSY = 3,
    REPLY_FAILURE = 4,
    REPLY_TRIGGER = 5,
    REPLY_ERROR = 6,
    REPLY_DONE = 7
};
typedef enum actionType actionType;

/* Must be the same as values in edm.h */
#define	MAX_ATTR_SIZE 24

typedef char *attribute;

#define	MAX_VALUE_SIZE 64

typedef char *sdata;

#endif /* GWC_PRIVATE */

/* Public strucutres for variable callbacks */

/* When should event be triggered? */
typedef enum eventType
{
    EV_CHANGED = 1,
    EV_ALWAYS,
    EV_STREAM_FOREACH
}
eventType;

/* Event callback argument */
typedef struct gwcEventArgs
{
    Tcl_Interp *interp;
    ClientData clientData;
    char *attribute;
    char *keyword;
    char *action;
    int inHeader;
    alarmType alarm;
    char *alarmmsg;
    valueType type;
    int valuecount;
    void *value;
}
gwcEventArgs;

/* The event callback function type */
typedef int (gwcInfoFunc) (gwcEventArgs args);

/* --------------- Create variables and set values ------------------ */

typedef enum scopeType
{
    SCOPE_PRIVATE,
    SCOPE_PUBLIC
}
scopeType;

typedef struct _gwcVid *gwcVid;

/* Create status variables and set values */
gwcVid gwcNewLocalVariable (gwcConnectInfo info, char *varname,
                            valueType type, attribute keyword, int headerFlag,
                            scopeType scope);

/* Set the static data for an attribute through its vid  */
int gwcSetVarData (gwcVid vid, attribute name, valueType type,
                   attribute keyword, int headerFlag);

/* Set the variable data value by name */
int gwcSetVarStringValue (gwcVid vid, int num, char *value[]);
int gwcSetVarIntValue (gwcVid vid, int num, int value[]);
int gwcSetVarShortValue (gwcVid vid, int num, short value[]);
int gwcSetVarFloatValue (gwcVid vid, int num, float value[]);
int gwcSetVarEnumValue (gwcVid vid, int num, short value[]);
int gwcSetVarCharValue (gwcVid vid, int num, char value[]);
int gwcSetVarLongValue (gwcVid vid, int num, int32_t value[]);
int gwcSetVarDoubleValue (gwcVid vid, int num, double value[]);
int gwcSetVarNullValue (gwcVid vid);

/* Set item to any kind of data */
int gwcSetValue (gwcVid vid, valueType etype, int cnt, void *data);

/* Set an items alarm and alarm message */
int gwcSetVarAlarm (gwcVid vid, alarmType alarm, char *alarm_msg);

/* Fetch a single item by name */
int gwcGetAttrValue (gwcConnectInfo info, char *name,
                     valueType * etype, int *num, void **value);

/* Print a local variable */
void gwcPrintVar (gwcVid vid);

/* ------------------ Put a stream - changed or all --------------- */
typedef enum putType
{
    STREAM_ALL,
    STREAM_CHANGED
}
putType;
int gwcPutStream (gwcConnectInfo info, char *streamname, putType stype);

/* Send a command stream */
int gwcPutCommandStream (gwcConnectInfo info, char *streamname);

/* ---------------------- Stream status --------------------------- */

typedef enum streamType
{
    STREAM_SEND,
    STREAM_COMMAND_SEND,
    STREAM_ACTION_SEND,
    STREAM_RECEIVE,
    STREAM_COMMAND_RECEIVE,
    STREAM_ACTION_RECEIVE
}
streamType;
int gwcGetStreamCount (gwcConnectInfo info, char *streamname,
                       streamType skind);

typedef enum enableType
{
    STREAM_ENABLE,
    STREAM_DISABLE
}
enableType;
enableType gwcGetStreamEnable (gwcConnectInfo info, char *streamname,
                               streamType skind);

int gwcSetStreamEnable (gwcConnectInfo info, char *streamname,
                        enableType etype, streamType skind);

/* ---------------  Streams/items Events ------------------- */

/* Add a callback to an attribute or stream */
int gwcAddEvent (gwcConnectInfo info, char *stream, eventType etype,
                 gwcInfoFunc * callback, char *tclproc, ClientData client);

/* Receive a command functon */
int gwcAddCommandEvent (gwcConnectInfo info, char *stream,
                        gwcInfoFunc * callback, char *tclproc,
                        ClientData client);

/* Respond to an action */
int gwcAddActionEvent (gwcConnectInfo info, char *streamname,
                       gwcInfoFunc * callback, char *tclproc,
                       ClientData client);

/* --------------- Subscription to streams/items ------------------- */

/* -- Subscribe to a status stream -- */
int gwcStreamSubscribe (gwcConnectInfo info, char *streamname);

/* Subscribe to a stream by name */
int gwcCommandStreamSubscribe (gwcConnectInfo info, char *streamname);

/* Subscribe to an action stream */
int gwcActionStreamSubscribe (gwcConnectInfo info, char *streamname);

/* ------------ Command Streams ---------------------------------- */

gwcVid gwcNewCommandVariable (gwcConnectInfo info, char *varname,
                              char *command, valueType type);

/* Set a variable command */
int gwcSetVarCommand (gwcVid vid, char *command);

int gwcSendVarCommand (gwcVid vid, char *command,
                       valueType etype, int num, void *value,
                       int immediateFlag);

/* ------------ Action Streams ---------------------------------- */

/* Send an action message */
int gwcSendDeviceAction (gwcConnectInfo info, char *varname,
                         actionType action, valueType etype, int num,
                         void *value);

/*--- Register a function that will be used to post GWC library messages --*/

typedef void (gwcStatusFunc) (gwcConnectInfo info, char *message);

int gwcSetStatusFunc (gwcConnectInfo info, gwcStatusFunc * func);

/* Print a status message */
void gwcPrintStatus (gwcConnectInfo info, char *fmt, ...);

/* ------------ Miscellaneous Functioality ------------------------------ */

/* Step through a status stream list of attributes */
gwcEventArgs *gwcForEachAttr (gwcConnectInfo info,
                              char *streamname, Tcl_HashSearch * search);
gwcEventArgs *gwcNextAttr (Tcl_HashSearch * search);

/* Send a TCS/Wis command */
int gwcSendTcsCommand (gwcConnectInfo info, char *clistring);

/* Convert an action string to an action type */
actionType gwcConvertStringToActionType (char *actiontext);

/* --------------- Initialize and Connect a Client --------------------- */

typedef enum connectType
{
    CONNECT_YES,
    CONNECT_NO
}
connectType;

/* The event callback function type --
 * The connectType parameter is set to CONNECT_YES if the final
 * connection succeeded, else it's set to CONNECT_NO for failure
 */
typedef void (gwcConnectFunc) (gwcConnectInfo, connectType);

int gwcInit (Tcl_Interp * interp, char *site, char *appname,
             gwcConnectFunc * restartFunc, char *tclRestartProc,
             gwcConnectInfo * cInfo, connectType ctype);

void gwcSetRestartFunc (gwcConnectInfo info, gwcConnectFunc * restartFunc);
void gwcSetRestartParameters (int delay, int attempts);

/* -------------------- Initialize TCL commands ------------------------ */

int gwcTclInit (Tcl_Interp * interp);

/* Type conversions */
int gwcConvertStringToType (char *s);
char *gwcConvertTypeToString (valueType s);
char *gwcConvertAlarmTypeToString (alarmType s);
alarmType gwcConvertStringToAlarmType (char *s);

/* Function to change stream strings to streamType values */
streamType gwcConvertStringToStreamType (char *s);

/* Convert a string to an event type */
eventType gwcConvertStringToEventType (char *s);

/* Function to change enentTypes to strings */
char *gwcConvertEventTypeToString (eventType s);

/* Function to change alarm types to string values */
int gwcConvertActionTypeToId (actionType s);

#endif /* _GWC_H */
