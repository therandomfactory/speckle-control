
/* file: msg.h
** sccs: @(#)msg.h UW-SAL 1.23 (12/13/94)
** Copyright 1992,1993 University of Wisconsin
** *******************************************************************
** Space Astronomy Laboratory
** University of Wisconsin
** 1150 University Avenue
** Madison, WI 53706 USA
** *******************************************************************
** Do not use this software without permission.
** Do not use this software without attribution.
** Do not remove or alter any of the lines above.
** *******************************************************************
*/

/*
**********************************************************************
** WIYN message protocol header file
**********************************************************************
*/

#ifndef MSG_H
#define MSG_H

#ifndef VXWORKS
#include <inttypes.h>
#endif

#include "std.h"

/* for rcsId */
#define USE(var) static void use_##var(void *x) {if(x) use_##var((void *)var);}

/* the length of the header part, including sync and length */
#define MSG_HDR_LEN	(6)

/* the max length of the data part */
#define MSG_DAT_LEN	(255)

/* the max message length, including sync, length, header, and data */
#define MSG_LEN		((MSG_HDR_LEN)+(MSG_DAT_LEN))

/* define the socket connection possibilities */
#define NOT_CONNECTED	(0)
#define CONNECTED	(0x1)
#define READABLE	(0x2)
#define WRITEABLE	(0x4)

/* callback types */
#define CB_CONNECT	(1)
#define CB_MESSAGE	(2)
#define CB_DISCONNECT	(3)

/* the message data type */
#ifndef VXWORKS
typedef int32_t msg_t;
#else
typedef long msg_t;
#endif


/* the network message */
struct s_msg
{
    msg_t data[MSG_LEN];
};

/* the SYNC pattern */
#define MSG_SYNC_1	(0x4a)
#define MSG_SYNC_2	(0x57)
#define MSG_SYNC_3	(0x50)

/* handle generic SSDA words */
#define SSDA(a,b,c,d) (((a)&0x3f)<<26|((b)&0x7f)<<19|((c)&0xff)<<11|((d)&0x7ff))
#define SSDA2SYS(ssda)	(((ssda)>>26)&0x3f)
#define SSDA2SUB(ssda)	(((ssda)>>19)&0x7f)
#define SSDA2DEV(ssda)	(((ssda)>>11)&0xff)
#define SSDA2ATT(ssda)	((ssda)&0x7ff)

#define msgGetSSDA(p)		((int)(ntohl((p)->data[4])))
#define msgSetSSDA(p, x)	((p)->data[4] = htonl(x))

/* version number for macro layout */
#define VERSION	(2)

/* macros for getting and setting message header fields */

#define msgGetSync(p)		((char *)((p)->data))

#define msgGetVersion(p)	((int)((ntohl((p)->data[1])>>24) & 0xff))
#define msgSetVersion(p, x)	((p)->data[1] |= htonl(((x) & 0xff)<<24))

#define msgGetMilliseconds(p)	((int)((ntohl((p)->data[1])>>8 & 0xffff)))
#define msgSetMilliseconds(p, x)	((p)->data[1] |= htonl(((x) & 0xffff)<<8))

#define msgGetHost(p)		((p)->data[2])
#define msgSetHost(p, x)	((p)->data[2] = (x))

#define msgGetTime(p)		(ntohl((p)->data[3]))
#define msgSetTime(p, x)	((p)->data[3] = htonl(x))

#define msgGetSystemV1(p)	((msgGetSSDA(p) >> 24) & 0xff)
#define msgSetSystemV1(p, x)	((p)->data[4] |= htonl(((x) & 0xff)<<24))
#define msgGetSystem(p)		(SSDA2SYS(msgGetSSDA(p)))
#define msgSetSystem(p, x)	((p)->data[4] |= htonl(((x) & 0x3f)<<26))

#define msgGetSubsystemV1(p)	((msgGetSSDA(p) >> 16) & 0xff)
#define msgSetSubsystemV1(p, x)	((p)->data[4] |= htonl(((x) & 0xff)<<16))
#define msgGetSubsystem(p)	(SSDA2SUB(msgGetSSDA(p)))
#define msgSetSubsystem(p, x)	((p)->data[4] |= htonl(((x) & 0x7f)<<19))

#define msgGetDeviceV1(p)	((msgGetSSDA(p) >> 8) & 0xff)
#define msgSetDeviceV1(p, x)	((p)->data[4] |= htonl(((x) & 0xff)<<8))
#define msgGetDevice(p)		(SSDA2DEV(msgGetSSDA(p)))
#define msgSetDevice(p, x)	((p)->data[4] |= htonl(((x) & 0xff)<<11))

#define msgGetAttributeV1(p)	((msgGetSSDA(p) >> 0) & 0xff)
#define msgSetAttributeV1(p, x)	((p)->data[4] |= htonl(((x) & 0xff)<<0))
#define msgGetAttribute(p)	(SSDA2ATT(msgGetSSDA(p)))
#define msgSetAttribute(p, x)	((p)->data[4] |= htonl(((x) & 0x7ff)<<0))

/* the bit fields */
#define msgClrLAM(p)		((p)->data[5] &= htonl(~(1<<31)))
#define msgClrRed(p)		((p)->data[5] &= htonl(~(1<<30)))
#define msgClrYellow(p)		((p)->data[5] &= htonl(~(1<<29)))
#define msgClrGreen(p)		((p)->data[5] &= htonl(~(1<<28)))
#define msgClrUser1(p)		((p)->data[5] &= htonl(~(1<<27)))
#define msgClrUser2(p)		((p)->data[5] &= htonl(~(1<<26)))
#define msgClrUser3(p)		((p)->data[5] &= htonl(~(1<<25)))
#define msgClrUser4(p)		((p)->data[5] &= htonl(~(1<<24)))
#define msgClrOOB(p)		((p)->data[5] &= htonl(~(1<<23)))
#define msgClrHistory(p)	((p)->data[5] &= htonl(~(1<<22)))
#define msgClrCommand(p)	((p)->data[5] &= htonl(~(1<<21)))
#define msgClrMetaCmd(p)	((p)->data[5] &= htonl(~(1<<20)))
#define msgClrNew(p)		((p)->data[5] &= htonl(~(1<<19)))
#define msgClrCompressed(p)	((p)->data[5] &= htonl(~(1<<18)))
#define msgClrOver(p)		((p)->data[5] &= htonl(~(1<<17)))

#define msgGetLAM(p)		((int)((ntohl((p)->data[5])>>31) & 0x01))
#define msgGetRed(p)		((int)((ntohl((p)->data[5])>>30) & 0x01))
#define msgGetYellow(p)		((int)((ntohl((p)->data[5])>>29) & 0x01))
#define msgGetGreen(p)		((int)((ntohl((p)->data[5])>>28) & 0x01))
#define msgGetUser1(p)		((int)((ntohl((p)->data[5])>>27) & 0x01))
#define msgGetUser2(p)		((int)((ntohl((p)->data[5])>>26) & 0x01))
#define msgGetUser3(p)		((int)((ntohl((p)->data[5])>>25) & 0x01))
#define msgGetUser4(p)		((int)((ntohl((p)->data[5])>>24) & 0x01))
#define msgGetOOB(p)		((int)((ntohl((p)->data[5])>>23) & 0x01))
#define msgGetHistory(p)	((int)((ntohl((p)->data[5])>>22) & 0x01))
#define msgGetCommand(p)	((int)((ntohl((p)->data[5])>>21) & 0x01))
#define msgGetMetaCmd(p)	((int)((ntohl((p)->data[5])>>20) & 0x01))
#define msgGetNew(p)		((int)((ntohl((p)->data[5])>>19) & 0x01))
#define msgGetCompressed(p)	((int)((ntohl((p)->data[5])>>18) & 0x01))
#define msgGetOver(p)		((int)((ntohl((p)->data[5])>>17) & 0x01))

#define msgSetLAM(p)		((p)->data[5] |= htonl(1<<31))
#define msgSetRed(p)		((p)->data[5] |= htonl(1<<30))
#define msgSetYellow(p)		((p)->data[5] |= htonl(1<<29))
#define msgSetGreen(p)		((p)->data[5] |= htonl(1<<28))
#define msgSetUser1(p)		((p)->data[5] |= htonl(1<<27))
#define msgSetUser2(p)		((p)->data[5] |= htonl(1<<26))
#define msgSetUser3(p)		((p)->data[5] |= htonl(1<<25))
#define msgSetUser4(p)		((p)->data[5] |= htonl(1<<24))
#define msgSetOOB(p)		((p)->data[5] |= htonl(1<<23))
#define msgSetHistory(p)	((p)->data[5] |= htonl(1<<22))
#define msgSetCommand(p)	((p)->data[5] |= htonl(1<<21))
#define msgSetMetaCmd(p)	((p)->data[5] |= htonl(1<<20))
#define msgSetNew(p)		((p)->data[5] |= htonl(1<<19))
#define msgSetCompressed(p)	((p)->data[5] |= htonl(1<<18))
#define msgSetOver(p)		((p)->data[5] |= htonl(1<<17))

#define msgGetUnits(p)		((int)((ntohl((p)->data[5])>>8) & 0xff))
#define msgSetUnits(p, x)	((p)->data[5] |= htonl(((x) & 0xff)<<8))

#define msgGetAction(p)		((int)((ntohl((p)->data[5])) & 0xff))
#define msgSetAction(p, x)	((p)->data[5] |= htonl(((x) & 0xff)))

/*
 * now include the generic definitions 
 */
#ifndef GWC_MSG
#include "msg_systems.h"
#include "msg_subsystems.h"
#include "msg_devices.h"
#include "msg_attributes.h"
#include "msg_actions.h"
#include "msg_units.h"
#include "msg_states.h"
#endif

int getDate ();

/* EXTERN_START */
extern char *action_name ();
extern char *attribute_name ();
extern char *device_name ();
extern char *msgFormat ();
extern char *state_name ();
extern char *subsystem_name ();
extern char *system_name ();
extern char *unit_name ();
extern int action_code ();
extern int action_hits ();
extern int attribute_code ();
extern int attribute_hits ();
extern int device_code ();
extern int device_hits ();
extern int msgAddSocket ();
extern int msgBlock ();
extern int msgConnect ();
extern int msgDeleteSocket ();
extern int msgDisable ();
extern int msgEnable ();
extern int msgEnabled ();
extern int msgFreadMsg ();
extern int msgFwriteMsg ();
extern int msgGetLength ();
extern int msgGetSize ();
extern int msgListen ();
extern int msgMsg2String ();
extern int msgPoll ();
extern int msgQueue ();
extern int msgReadMsg ();
extern int msgSetData ();
extern int msgString2Msg ();
extern int msgWaiting ();
extern int msgWriteMsg ();
extern int subsystem_code ();
extern int subsystem_hits ();
extern int system_code ();
extern int system_hits ();
extern int unit_code ();
extern int unit_hits ();
extern msg_t *msgGetDataPtr ();
extern msg_t msgGetData ();
extern void msgGetString ();
extern void msgInit ();
extern void msgSetLength ();
extern void msgSetString ();
extern void msgSetSync ();
extern void msgStatus ();

/* EXTERN_STOP */

#endif
