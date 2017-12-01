/*---------------------------------------------------------------------------*/
/* Source Control Options: @(#)derotate.c 1.1 11/18/97 12:30:28                               */
/*                                                                           */
/*  Source File:                                                             */
/*   Written By:                                                             */
/* Date Written:                                                             */
/*                                                                           */
/* Description:                                                              */
/*                                                                           */
/* This source file contains the following functions:                        */
/*                                                                           */
/* Below is area to log changes made to this source file                     */
/*                                                                           */
/* Modification History:                                                     */
/*                                                                           */
/* Date      Initials         Modifications to source file                   */
/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
/* 	Includes			                                     */
/*---------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <sys/stat.h>
#include "cent.h"
#include "detrot.h"

/*---------------------------------------------------------------------------*/
/* 	Defines	               		                                     */
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*      Globals                                                              */
/*---------------------------------------------------------------------------*/
IMPORT Guider GuiderObj;
IMPORT GuiderState GuiderCtrl;
IMPORT SysManager IpsSysManager;
IMPORT Fop *FopList[NUMBEROFFOPS];
IMPORT int nDebugLevel2, nDetrotMonitor;
IMPORT double fDetrotSign;
IMPORT int msgSetData P_((struct s_msg *pmsg, int slot, msg_t x));  
double fTheta = 0.0;
IMPORT FILE *dlog; 
int    Rotflag = FALSE;
struct rotStats RotData;

void
deRotate()
{
  IMPORT int edouble P_((struct s_msg *pmsg, int n, double dval));
  void initRotation P_((struct rotStats *pRot));
  void addRotationPt P_((struct rotStats *rot, char *name,
			 struct plate_coords *starPt,
			 struct plate_coords *measPt));
  void generatePairs P_((struct rotStats *rotationData));
  void enablePairs P_((struct rotStats *rot));
  void listRotationPts P_((struct rotStats *rot));
  void listRotationPrs P_((struct rotStats *rot));
  void zeroCents P_((void));
  double calcRotation P_((struct rotStats *rot));

  LOCAL char szNameMap[12][5] = {"fopA","fopB","fopC",
				 "fopD","fopE","fopF",
				 "fopG","fopH","fopI",
				 "fopJ","fopK","fopL" };
  double fTemp[7];
  int nFop, nParams, nTheta, nMatch;
  char szBuffer[BUFSIZ], szName[BUFSIZ];
  FILE *pHydraFile = NULL;
  Fop *pFop = NULL;
  struct s_msg Msg;  
  struct plate_coords Centroids;
  struct plate_coords Hydra;

  /*
  ** create new memory pools
  */

/*
  if (pointPool == NULL || pairPool == NULL){
    pointPool = poolCreate("points", sizeof(struct rotPoint), 70, 70);
    pairPool  = poolCreate("pairs ", sizeof(struct rotPair), 70, 70);
  }
 

  RotData.nextPoint = NULL;
  RotData.nextPair  = NULL;
 */



    if ( (RotateStatus(GuiderCtrl) == ROTINACTIVE) ||
         (GuiderStatus(GuiderCtrl) == NOTTRACKING) ){

      zeroCents();
      dmpc_text_out(DispMod(GuiderObj), 610,24, " ");
      return;
    }

/*    dmpc_text_out(DispMod(GuiderObj), 610,24, "R");  */

    if (!(pHydraFile = fopen(DATFILE, "r")) ){
      (void)dmpc_text_out(DispMod(GuiderObj), 3, 24, "ERROR: No data ");
      return;
    }

    if (NumActive(GuiderObj) < 3){
       (void)dmpc_text_out(DispMod(GuiderObj), 3, 24, "ERROR: # FOPS < 3 ");
       return;
    }

    /*
    ** free memory allocated 
    ** from last iteration
    */
    initRotation(&RotData);

    for (nFop = 0; nFop < NUMBEROFFOPS; nFop++){
      
      pFop = FopList[nFop];

      if ( (FopStatus(pFop) == ACTIVE) && (FopType(pFop) == GUIDEFOP) ){
	
	Centroids.x = FopMeanXCent(pFop);
	Centroids.y = FopMeanYCent(pFop);
	Centroids.x *= STEPSPERARCSEC;
	Centroids.y *= STEPSPERARCSEC;
	
	nMatch = FALSE;
	
	/*
	** find the FOP in the data file
	** and read Hydra data point here
	*/
	while(!feof(pHydraFile)){
	  
	  nMatch = FALSE;
	  fgets(szBuffer, 90, pHydraFile);
	  nParams = sscanf(szBuffer, "%s %lf %lf %lf %lf %lf %lf %lf",
			   &szName[0], &fTemp[0], &fTemp[1], &fTemp[2],
			   &fTemp[3], &fTemp[4], &fTemp[5], &fTemp[6]);
	  
	  if (nParams != 8){
	    sprintf(ipsError,"ERROR: Format error in hydra data file\n");
	    return;
	  }
	  
	  if (strstr(szName, szNameMap[nFop])){
	    Hydra.x = fTemp[0];
	    Hydra.y = fTemp[1];
	    nMatch = TRUE;
	    break;
	  }
	  
	}	
	
	(void)rewind(pHydraFile);
	
	/*
	** add the point to the list
	*/
	if (nMatch){
	  Centroids.x = Hydra.x + Centroids.x;
	  Centroids.y = Hydra.y + Centroids.y;	    
	  addRotationPt(&RotData, FopId(pFop), &Hydra, &Centroids);
	  nMatch = FALSE;
	}

      }
    }
    
    (void)fclose(pHydraFile);

    /*
    ** Compute the rotation angle
    */
    generatePairs(&RotData);
    enablePairs(&RotData);
    fTheta = calcRotation(&RotData);
    fTheta *= (double)fDetrotSign;

/*    (void)sprintf(szBuffer,
		  "Theta: %3.6f  ",RTOD(fTheta));
    (void)dmpc_text_out(DispMod(GuiderObj), 3, 23, szBuffer);
 */
    fprintf(stderr,"Theta: %3.6f\n",RTOD(fTheta));

    if (nDebugLevel2){
      listRotationPts(&RotData);
      listRotationPrs(&RotData);
    }

    /*
    ** adjust the NIR rotator
    */
    if (fabs(fTheta) >= DetRotTol(GuiderCtrl)){
       nTheta = RTOD(fTheta) * 3.6e6;
      if (!nDetrotMonitor){
         (void)msgInit(&Msg, WIYN, TCS, MNIR, DELTA, ADJUST);
         (void)msgSetData(&Msg, 0, (msg_t)nTheta); 
         (void)msgWriteMsg(RouterSocket(GuiderCtrl), &Msg);
   fprintf(dlog,"Rotation theta = %f\n",fTheta);
      }
    }

    zeroCents();

/*    dmpc_text_out(DispMod(GuiderObj), 610,24, " "); */
  
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
zeroCents()
{
  Fop *pFop = NULL;
  int nFop;

  for (nFop = 0; nFop < NUMBEROFFOPS; nFop++){
    pFop = FopList[nFop];
    FopSumXCent(pFop) = 0.0;
    FopSumYCent(pFop) = 0.0;
    FopCentCnt(pFop) = 1;
  }
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
initRotation(struct rotStats *pRot)
{
  struct rotPoint *allocRotationPt P_((void));
  struct rotPoint *freeRotationPt P_((struct rotPoint *thePoint, int flag));
  struct rotPair  *allocRotationPr P_((void));
  struct rotPair  *freeRotationPr P_((struct rotPair  *thePair, int flag));

  pRot->numberOfPairs = 0;
  pRot->workingAngle  = 0.0;
  pRot->defaultAngle  = 0.0;
  pRot->sumAngles     = 0.0;

  freeRotationPt(pRot->nextPoint, RECURSE);
  freeRotationPr(pRot->nextPair, RECURSE);

  /*
  ** create dummy records
  */
  if ( (pRot->nextPoint = allocRotationPt() ) == NULL ){
    sprintf(ipsError,"ERROR: Couldn't allocate rotation point %s %d\n",
	     __FILE__,__LINE__);
  }

  if ( (pRot->nextPair = allocRotationPr() ) == NULL ){
    sprintf(ipsError,"ERROR: Couldn't allocate rotation pair %s %d\n",
	     __FILE__,__LINE__); 
  }

}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
addRotationPt(struct rotStats *rot, char *name,
	      struct plate_coords *starPt, struct plate_coords *measPt)
{
  void   rotate P_((struct aPoint *pCoords, double angle));
  void   generatePairs P_((struct rotStats *rotationData));
  void   enablePairs P_((struct rotStats *rot));
  double calcRotation P_((struct rotStats *rot));
  struct rotPoint *allocRotationPt P_((void));
  struct rotPair *freeRotationPr P_((struct rotPair *thePair, int flag));

  struct rotPoint *currentPoint = NULL;
  struct rotPoint *pt = NULL;

#ifdef DEBUG
  assert(rotStats);
  assert(name);
  assert(starPt);
  assert(measPt);
#endif

  currentPoint = rot->nextPoint;

  while( currentPoint->nextPoint != NULL ){
    currentPoint = currentPoint->nextPoint;
  }

  if( (currentPoint->nextPoint = allocRotationPt() ) == NULL ){
    sprintf(ipsError,"ERROR: Couldn't allocate rotation point %s %d",
	     __FILE__,__LINE__);
  }

  pt = currentPoint->nextPoint;

  (void)strcpy( pt->pointName, name );

  pt->id = abs( currentPoint->id ) + 1;

  pt->starLoc.x = starPt->x;
  pt->starLoc.y = starPt->y;

  pt->measLoc.x = measPt->x;
  pt->measLoc.y = measPt->y;

  if ( Rotflag ){
    rotate( &pt->starLoc, -(rot->aveAngle) );
  }
  
  rot->nextPair->nextPair = freeRotationPr( rot->nextPair->nextPair, RECURSE );
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
double
calcRotation(struct rotStats *rot)
{
  void calculatePairs P_((struct rotStats *rot));

  struct rotPair *dataPair = NULL;

#ifdef DEBUG
  assert(rot);
#endif

  dataPair = rot->nextPair;
  rot->numberOfPairs = 0.0;
  rot->sumAngles     = 0.0;
  rot->sumWeights    = 0.0;
  rot->workingAngle  = 0.0;
  
  calculatePairs(rot);

  while ( (dataPair = dataPair->nextPair) != NULL) {
    if (dataPair->id > 0){
      rot->sumAngles += (dataPair->rotAngle * dataPair->rSep2);
      rot->sumWeights += dataPair->rSep2;
      rot->numberOfPairs++;
    }
  }

  rot->workingAngle = rot->sumAngles / rot->sumWeights;

  return(rot->workingAngle);
    
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
generatePairs(struct rotStats *rotationData)
{
  void addRotationPair P_((struct rotPoint *point1, struct rotPoint *point2,
			   struct rotStats *rotationData));

  struct rotPoint *point1 = NULL;
  struct rotPoint *point2 = NULL;

#ifdef DEBUG
  assert(rotationData);
#endif

  point1 = rotationData->nextPoint;

  while((point1 = point1->nextPoint) != NULL){
    point2 = point1;
    while((point2 = point2->nextPoint) != NULL){
      addRotationPair(point1, point2, rotationData);
    }
  }
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
enablePairs(struct rotStats *rot)
{
  /*
  ** we expect the firstpointer to be set to the header
  ** record and so we will bump it past the header whe
  ** we enter the loop
  */
  struct rotPair  *currentPair = NULL;
  struct rotPoint *point1 = NULL;
  struct rotPoint *point2 = NULL;

#ifdef DEBUG
  assert(rot);
#endif

  currentPair = rot->nextPair;

  while((currentPair = currentPair->nextPair) != NULL){
    point1 = currentPair->point1;
    point2 = currentPair->point2;

    /*
    ** check that the two points exits
    ** and are enabled
    */
    if ( (point1 != NULL) && (point2 != NULL) &&
	 (point1->id > 0) && (point2->id > 0) ){
      currentPair->id = abs(currentPair->id);
    } else {
      currentPair->id = -abs(currentPair->id);
    }
  }    
  
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
addRotationPair(struct rotPoint *point1, struct rotPoint *point2,
		struct rotStats *rotationData)
{
  struct rotPair *allocRotationPr P_((void));

  struct rotPair *currentPair = NULL;

#ifdef DEBUG
  assert(point1);
  assert(point2);
  assert(rotationsData);
#endif

  currentPair = rotationData->nextPair;

  /*
  ** don't create points for which
  ** there is no data
  */
  if ( (point1 != NULL) && (point2 != NULL) ){
    
    /*
    ** find the location for and
    ** create the next entry
    */
    while (currentPair->nextPair != NULL){
      currentPair = currentPair->nextPair;
    }

    if ( (currentPair->nextPair = allocRotationPr()) == NULL){
      sprintf(ipsError,"ERROR: Couldn't allocate rotation pair %s %d\n",
	       __FILE__,__LINE__);
    }

    /*
    ** link the two points 
    */
    currentPair->nextPair->point1 = point1;
    currentPair->nextPair->point2 = point2;

    /*
    ** create the name and ID
    ** number for the pair
    */
    currentPair->nextPair->id = abs(currentPair->id) + 1;

    sprintf(currentPair->nextPair->pairName,
	    "p%02d '%-10.10s' & p%02d '%-10.10s'",
	    point1->id, point1->pointName,
	    point2->id, point2->pointName );
  }  
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void 
listRotationPts(struct rotStats *rot)
{
  struct rotPoint *thePoint = NULL;

#ifdef DEBUG
  assert(rot);
#endif

  thePoint = rot->nextPoint->nextPoint;

  sprintf(ipsError,"INFO: \n\n");
  sprintf(ipsError,"INFO: %3s  %16s\n", "id#", "Object Name");
  sprintf(ipsError,"INFO: \n");

  while(thePoint != NULL){
    
    sprintf(ipsError,"INFO: %3d  %16s ",abs(thePoint->id),thePoint->pointName);
    
    sprintf(ipsError,"INFO: expected at %7.2f, %7.2f ",
	     thePoint->starLoc.x, thePoint->starLoc.y);
    
    sprintf(ipsError,"INFO: found at %7.2f, %7.2f",
	     thePoint->measLoc.x, thePoint->measLoc.y);
    
    if (thePoint->id < 0){
      sprintf(ipsError,"INFO: %s\n", "*deleted*");
    } else {
      sprintf(ipsError,"INFO:\n");
    }
    
    thePoint = thePoint->nextPoint;
  }
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
calculatePairs(struct rotStats *rot)
{
  double normalize P_((double angle));

#ifdef DEBUG
  assert(rot);
#endif

  struct rotPair *currentPair = NULL;
  struct rotPoint *point1 = NULL;
  struct rotPoint *point2 = NULL;
  double dxCalc, dxMeas, thetaCalc;
  double dyCalc, dyMeas, thetaMeas;

  currentPair = rot->nextPair;

  while ( (currentPair = currentPair->nextPair) != NULL ){

    point1 = currentPair->point1;
    point2 = currentPair->point2;

    /*
    ** check that the two points exists
    ** and that they should be allowed
    ** to enter into the calculation
    ** flag pairs that are not valid as
    ** deleted
    */
    if ( (point1 != NULL) && (point2 != NULL) &&
	 (currentPair->id > 0) ){
      
      /*
      ** find the two legs of each
      ** triangle-measured and calculated
      */
      dxCalc = point1->starLoc.x - point2->starLoc.x;
      dyCalc = point1->starLoc.y - point2->starLoc.y;

      dxMeas = point1->measLoc.x - point2->measLoc.x;
      dyMeas = point1->measLoc.y - point2->measLoc.y;

      currentPair->rSep2 = ((dxCalc*dxCalc) + (dyCalc*dyCalc) ) / 1.0e9;

      /*
      ** find the absolute angles
      ** of each line wrt x axis
      */
      thetaCalc = normalize(atan2(dyCalc, dxCalc));
      thetaMeas = normalize(atan2(dyMeas, dxMeas));

      /*
      ** now find the rotation angle
      ** for this pair
      */
      currentPair->rotAngle = normalize(thetaMeas - thetaCalc);
    }
  }

}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
double
normalize(double angle)
{
  if (angle > M_PI_2){
    return(angle - M_PI);
  }

  if (angle < -M_PI_2){
    return(angle + M_PI);
  }else{
    return(angle);
  }
    
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
struct rotPoint
*allocRotationPt()
{
  struct rotPoint *tmpPt = NULL;

/*tmpPt = (struct rotPoint*)poolGetItem(pointPool); */
  tmpPt = (struct rotPoint*)malloc(sizeof(struct rotPoint));
  

  if (tmpPt == NULL){
    return(tmpPt);
  }

  tmpPt->nextPoint = NULL;
  tmpPt->id = 0;
  *tmpPt->pointName = '\0';
  tmpPt->starLoc.x = 0.0;
  tmpPt->starLoc.y = 0.0;
  tmpPt->measLoc.x = 0.0;
  tmpPt->measLoc.y = 0.0;

  return(tmpPt);
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
struct rotPoint
*freeRotationPt(struct rotPoint *thePoint, int flag)
{
  struct rotPoint *freeRotationPt P_((struct rotPoint *thPoint, int flag));

  struct rotPoint *tmpPt = NULL;

#ifdef DEBUG
  assert(thePoint);
#endif

  if (thePoint == NULL){
    return(NULL);
  } else {
    tmpPt = thePoint->nextPoint;

/*  poolFreeItem(pointPool, (char*)thePoint); */
    free((char *)thePoint);

    if (flag == SAVEPOINT){
      return(tmpPt);
    }else{
      return(freeRotationPt(tmpPt, RECURSE));
    } 
  }
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
struct rotPair
*allocRotationPr()
{
  struct rotPair *tmpPt = NULL;

/*  tmpPt = (struct rotPair*)poolGetItem(pairPool); */
  tmpPt = (struct rotPair*)malloc(sizeof(struct rotPair));
  if (tmpPt == NULL){
    return(tmpPt);
  }
  
  tmpPt->nextPair = NULL;
  tmpPt->id = 0;
  *tmpPt->pairName = '\0';
  tmpPt->point1 = NULL;
  tmpPt->point2 = NULL;
  tmpPt->rotAngle = 0;

  return(tmpPt);

}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
struct rotPair 
*freeRotationPr(struct rotPair *thePair, int flag)
{
  struct rotPair *freeRotationPr P_((struct rotPair *thePair, int flag));

  struct rotPair *tmpPr = NULL;

#ifdef DEBUG
  assert(thePair);
#endif

  if (thePair == NULL){
    return(NULL);
  } else {
    tmpPr = thePair->nextPair;

/*    poolFreeItem(pairPool, (char*)thePair); */
    free((char *)thePair);

    if (flag == SAVEPOINT){
      return (tmpPr);
    }else{
      return(freeRotationPr(tmpPr, RECURSE));
    }
  }
}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
rotate(struct aPoint *pCoords, double angle)
{
  double r, phi1, phi2;

  double x = pCoords->x;
  double y = pCoords->y;

#ifdef DEBUG
  assert(pCoords);
#endif

  r = sqrt( (x*x) + (y*y) );

  if ( (x != 0) || (y != 0) ){
    phi1 = atan2f(y,x);
  }else{
    phi1 = 0.0;
  }

  phi2 = phi1 + angle;

  pCoords->x = (int)((double)r * cos((double)phi2));
  pCoords->y = (int)((double)r * sin((double)phi2));

}

/*---------------------------------------------------------------------------*/
/* FUNCTION:                                                                 */
/*                                                                           */
/* DESCRIPTION:                                                              */
/*                                                                           */
/* PARAMETERS:                                                               */
/*                                                                           */
/* RETURNS:                                                                  */
/*                                                                           */
/* CREATED:                                                                  */
/*                                                                           */
/* SIDE EFFECTS                                                              */
/*                                                                           */
/* EXAMPLES:                                                                 */
/*---------------------------------------------------------------------------*/
void
listRotationPrs(struct rotStats *rot)
{
  struct rotPair *thePair = rot->nextPair->nextPair;

  double deltaR;
  double weight;

#ifdef DEBUG
  assert(rot);
#endif

  sprintf(ipsError,"INFO: \n\n");
  sprintf(ipsError,"INFO: %3s    %-30.30s   %s   %8s   %s\n",
	   "id#","Object  Pair","Abs.Rot.","Delta","Weight");

  sprintf(ipsError,"INFO:\n");
  
  while (thePair != NULL){

    if (Rotflag){
      deltaR = thePair->rotAngle - rot->aveAngle;
    }else{
      deltaR = thePair->rotAngle;
    }

    if (thePair->id < 0){
      weight = 0.0;
    }else{
      weight = thePair->rSep2;
    }

    if(thePair->id >= 0){
      sprintf(ipsError,"INFO: %3d   %30.30s     %8.5f %8.5f %8.5f \n",
	       abs(thePair->id),
	       thePair->pairName,
	       RTOD(thePair->rotAngle),
	       RTOD(deltaR),
	       weight);
    }

    thePair = thePair->nextPair;
  }

    sprintf(ipsError,"INOF:\nINFO: Absolute Rotation based on these points: %f\n",
	     RTOD(rot->workingAngle));

    if (Rotflag){
      sprintf(ipsError,"INFO: Rotation angle currently in use:          %f\n",
	       rot->aveAngle);
      sprintf(ipsError,"INFO:                           Difference:     %f\n",
	       rot->workingAngle - rot->aveAngle);
    }
}
