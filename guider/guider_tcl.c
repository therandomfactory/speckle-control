
#include <string.h>
#include "tcl.h"
#include "ccd.h"
#include "guider.h"

#define MINBORDER 16

SCREENTEXT Messages[32];
GUIDER Guider;
FOP Fop[32];
MARKER Marker[32];
int gdrDebug=0;

int lossOfSignal; 
int tcl_locateStars(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_calcCentroid(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_onscreenMsg(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int tcl_onscreenMarker(ClientData clientData, Tcl_Interp *interp, int argc, char **argv);
int calc_profiles(void *src_buffer, int roinum);
int pH[1024];
int pV[1024];
int pjunk[10];


extern void calc_centroid (void *src_buffer);
extern void calc_plsphot (void *src_buffer, int roinum, int saturation, double *centx, double *centy);
extern void calc_cmass (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
extern void calc_cmoment (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
extern void calc_quadrant (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
extern void calc_gaussian (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
extern void calc_fop1 (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
extern void calc_fop2 (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
extern void calc_fop3 (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
#define MAX_CCD_BUFFERS  1000
typedef struct {
     void           *pixels;
     int            size;
     int          xdim;
     int          ydim;
     int          zdim;
     int          xbin;
     int          ybin;
     int          type;
     char           name[64];
     int            shmid;
     size_t         shmsize;
     char           *shmem;
} CCD_FRAME;
extern CCD_FRAME CCD_Frame[MAX_CCD_BUFFERS];

int tcl_locateStars(clientData, interp, argc, argv)
ClientData clientData;
Tcl_Interp *interp;
int argc;
char **argv;
{
   int stepsize, smoothing, maxstars;
   int bnum;
   int ifound;
   char bufname[64];
   unsigned int *cframe;
   int line, pixel, ii,jj;
   int xmaxat, ymaxat;
   int image_width,image_height;
   double maxsum, csum;
   char starpos[16];

   xmaxat = 0;
   ymaxat = 0;
   maxsum = 0.0;

   if ( argc < 4 ) {
           Tcl_AppendResult (interp, "wrong # args: should be \"", argv[0],
            " buffer stepsize smoothing maxstars\"", (char *) NULL);
           return TCL_ERROR;
   }
   strcpy(bufname,(char *)argv[1]);
   sscanf (argv[2],"%d", &stepsize);
   sscanf (argv[3],"%d", &smoothing);
   sscanf (argv[4],"%d", &maxstars);
   bnum = CCD_locate_buffernum(bufname);

   cframe = (unsigned int *)CCD_Frame[bnum].pixels;
   image_width = CCD_Frame[bnum].xdim;
   image_height = CCD_Frame[bnum].ydim;

   ifound = 0;
   while (ifound < maxstars) {
     xmaxat = 0;
     ymaxat = 0;
     maxsum = 0.0;
     for (line = MINBORDER; line <= image_height-MINBORDER; line=line+stepsize) {
       for (pixel = MINBORDER; pixel <= image_width-MINBORDER; pixel=pixel+stepsize) {
        csum = 0.0;
        for (ii=-1*smoothing;ii<=smoothing;ii++) {
          for (jj=-1*smoothing;jj<=smoothing;jj++) {
             csum = csum + (double)cframe[(line+ii) * image_width + pixel+jj];
          }
        }
        if (csum > maxsum) {
           xmaxat = pixel;
           ymaxat = line;
           maxsum = csum;
        }
      }
     }
     ifound++;
     sprintf(starpos,"%d %d ",xmaxat,ymaxat);
     Tcl_AppendResult (interp,starpos,(char *) NULL);
     for (ii=-10;ii<=10;ii++) {
          for (jj=-10;jj<=10;jj++) {
             cframe[(ymaxat+ii) * image_width + xmaxat+jj] = 0;
          }
     }
    }
    return TCL_OK;
}


int tcl_onscreenMsg(clientData, interp, argc, argv)
ClientData clientData;
Tcl_Interp *interp;
int argc;
char **argv;
{
   int msgid;  
   int ix, iy;
   
   if ( argc ==1 ) {
     sscanf (argv[1],"%d", &msgid);
     Messages[msgid].x = 0;
     return TCL_OK;
   }
   
   if (argc < 4) {
         Tcl_AppendResult (interp, "wrong # args: should be \"", argv[0],
            " msgnum x y text\"", (char *)NULL);
           return TCL_ERROR;
   }

   sscanf (argv[1],"%d", &msgid);
   sscanf (argv[2],"%d", &ix);
   sscanf (argv[3],"%d", &iy);
   Messages[msgid].x = ix;
   Messages[msgid].y = iy;
   strcpy(Messages[msgid].text,argv[4]);
   return TCL_OK;
}


int tcl_onscreenMarker(clientData, interp, argc, argv)
ClientData clientData;
Tcl_Interp *interp;
int argc;
char **argv;
{
   int markid;  
   int ix, iy,ishape;
   
   if ( argc == 2 ) {
     sscanf (argv[1],"%d", &markid);
     Marker[markid].shape = 0;
     return TCL_OK;
   }
   
   if (argc < 5) {
         Tcl_AppendResult (interp, "wrong # args: should be \"", argv[0],
            " marker x y shape\"", (char *) NULL);
           return TCL_ERROR;
   }

   sscanf (argv[1],"%d", &markid);
   sscanf (argv[2],"%d", &ix);
   sscanf (argv[3],"%d", &iy);
   sscanf (argv[4],"%d", &ishape);
   Marker[markid].x = ix;
   Marker[markid].y = iy;
   Marker[markid].shape = ishape;
   
   return TCL_OK;
}

int tcl_calcCentroid(clientData, interp, argc, argv)
ClientData clientData;
Tcl_Interp *interp;
int argc;
char **argv;
{
   
   int bnum;
   char bufname[64];
   unsigned int *cframe;
   int saturation;
   int roinum, i;
   double guider_centx, guider_centy;
   double lowside, hiside;
   int image_width, image_height;
   char starpos[32];

   if ( argc < 3 ) {
           Tcl_AppendResult (interp, "wrong # args: should be \"", argv[0],
            " buffer roi-number saturation-level\"", (char *) NULL);
           return TCL_ERROR;
   }
   strcpy(bufname,(char *)argv[1]);
   sscanf (argv[2],"%d", &roinum);
   if (roinum > Guider.numroi) {
           Tcl_AppendResult (interp, "ROI not defined\n", (char *) NULL);
           return TCL_ERROR;
   }

   sscanf (argv[3],"%d", &saturation);
   bnum = CCD_locate_buffernum(bufname);

   cframe = (unsigned int *)CCD_Frame[bnum].pixels;
   image_width = CCD_Frame[bnum].xdim;
   image_height = CCD_Frame[bnum].ydim;
   guider_centx = -1.0;
   guider_centy = -1.0;

   switch (Guider.algorithm) {
   case CHISQ_METHOD:
      calc_plsphot (cframe, roinum,saturation, &guider_centx, &guider_centy);
      break;
   case CMASS_METHOD:
      calc_cmass (cframe, roinum,saturation, &guider_centx, &guider_centy);
      break;
   case CMOMENT_METHOD:
      calc_cmoment (cframe, roinum, saturation, &guider_centx, &guider_centy);
      break;
   case QUADR_METHOD:
      calc_quadrant (cframe, roinum, saturation, &guider_centx, &guider_centy);
      break;
   case GAUSS_METHOD:
      calc_gaussian (cframe, roinum, saturation, &guider_centx, &guider_centy);
      break;
   default:
     Tcl_AppendResult (interp,"ERROR: Unknown centroid algorithm",(char *) NULL);
      break;
   }

   for (i=0;i<256;i++) {
        Guider.roi[roinum].histogram[i] = 0;
   }
   lowside = 0.0;
   hiside = 0.0;

   if (lossOfSignal ==0) {
     calc_profiles(cframe, roinum);
     for (i=0;i<127;i++) {
          lowside = lowside + (double)Guider.roi[roinum].histogram[i];
     }
     for (i=128;i<255;i++) {
          hiside = hiside + (double)Guider.roi[roinum].histogram[i];
     }
/*
     if ( (hiside/lowside) < 1.2) {
        Guider.roi[roinum].xcorr = -1.0;
        Guider.roi[roinum].ycorr = -1.0;
        Tcl_AppendResult (interp,"WARNING: loss of signal - histogram",(char *) NULL);
     } else {
 */
        Guider.roi[roinum].xcorr = guider_centx;
        Guider.roi[roinum].ycorr = guider_centy;
        sprintf(starpos,"%8.2lf %8.2lf ",guider_centx, guider_centy);
        Tcl_AppendResult (interp,starpos,(char *) NULL);
/*     }    */
   } else {
     Guider.roi[roinum].xcorr = -1.0;
     Guider.roi[roinum].ycorr = -1.0;
     Tcl_AppendResult (interp,"WARNING: loss of signal",(char *) NULL);
   }
 
   return TCL_OK;
}


int calc_profiles(void *src_buffer, int roinum)
{
  int lx, ly, ux, uy;
  int pHmax, pVmax;
  int pHmin, pVmin;
  unsigned int *src_32;
  int dn;
  int pixel, line;

  src_32 = (unsigned int *) src_buffer;


  lx = Guider.roi[roinum].xc - Guider.roi[roinum].xs/2;
  ux = lx + Guider.roi[roinum].xs; 
  ly = Guider.roi[roinum].yc - Guider.roi[roinum].ys/2;
  uy = ly + Guider.roi[roinum].ys; 
  for (pixel = lx; pixel <= ux; pixel++) {
      pH[pixel] = 0;
  }
  for (line = ly; line <= uy; line++) {
    pV[line] = 0;
    for (pixel = lx; pixel <= ux; pixel++) {
      dn = src_32[line * Guider.framewidth + pixel];
      pH[pixel]  += dn;
      pV[line] += dn;
      Guider.roi[roinum].histogram[dn] = Guider.roi[roinum].histogram[dn] +1;
    }
   }

  pVmax = 0;
  pHmax = 0;
  pVmin = 999999;
  pHmin = 999999;
  for (pixel = lx; pixel <= ux; pixel++) {
      if (pH[pixel] > pHmax) {
        pHmax = pH[pixel];
      }
      if (pH[pixel] < pHmin) {
        pHmin = pH[pixel];
      }
  }
  for (line = ly; line <= uy; line++) {
      if (pV[line] > pVmax) {
        pVmax = pV[line];
      }
      if (pV[line] < pVmin) {
        pVmin = pV[line];
      }
  }
  for (pixel = lx; pixel <= ux; pixel++) {
      pH[pixel] = (pH[pixel] - pHmin) * 32 / (pHmax - pHmin +1);
  }
  for (line = ly; line <= uy; line++) {
      pV[line] = (pV[line] - pVmin) * 32 / (pVmax - pVmin +1);
  }

  return 0;
}












