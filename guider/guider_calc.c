
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <sys/time.h>
#include <unistd.h>
#include <math.h>
#include "guider.h"
#include "chisqLib.h"

extern int gdrDebug;
extern GUIDER Guider;
extern int lossOfSignal;

/*----------------------------------------------------------------------
 *	Function Prototypes
 *---------------------------------------------------------------------*/

void calc_centroid (void *src_buffer);
void calc_plsphot (void *src_buffer, int roinum, int saturation, double *centx, double *centy);
void calc_cmass (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
void calc_cmoment (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
void calc_quadrant (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
void calc_gaussian (void *src_buffer, int roinum, int saturation,double *centx, double *centy);
double fmax(double a, double b);
static int imin(int a, int b);
double fX[512], fV[512], fH[512];
double acc[AMAX], alim[AMAX];
int image_bk, image_mx, image_tc;
int nsaturated;
double image_fw;

extern void quickcenter(double *fX, double *fY, int ux, double *a); 		
extern int gaussfit(double *y, double *a, int nPts, int ma);
extern double qfwhm(double *y, double Intensity, int nPts);

void fwhmx_iraf(void *src_buffer, int nbx, int nby, double xc, double yc, double *fwhm);

/*---------------------------------------------------------------------
 *	Global Variables
 *--------------------------------------------------------------------*/



/*----------------------------------------------------------------------
 *	Local Variables
 *---------------------------------------------------------------------*/
/*----------------------------------------------------------------------
 * calc_quadrant - quadrant method
 *
 * The size of the box is been resized to have an even number of pixel
 * in each of its sides for simetric purposes. Have in mind that only
 * odd numbers are acceptable for the box size.
 *---------------------------------------------------------------------*/
void calc_quadrant (void *src_buffer, int roinum, int saturation, double *centx, double *centy)
{
  unsigned int *src_32;
  int line, pixel, lx, ux, uy, ly, midx, midy, halfbox, nsamples, nX;
  int mx1, mx2, my1, my2, sumD, sumI, maxI;
  double sky, maxH, maxV;
  double graylevel, avg;
 
  lx = Guider.roi[roinum].xc - Guider.roi[roinum].xs/2;
  ux = lx + Guider.roi[roinum].xs; 
  ly = Guider.roi[roinum].yc - Guider.roi[roinum].ys/2;
  uy = lx + Guider.roi[roinum].ys; 
  Guider.roi[roinum].nsaturated = 0;
  Guider.roi[roinum].background = -1.0;
  Guider.roi[roinum].fmin = -1.0;
  Guider.roi[roinum].fmax = -1.0;
  Guider.roi[roinum].mean = -1.0;
 
  midx = (lx + ux) / 2;
  midy = (uy + ly) / 2;
  halfbox = (ux - lx + 1) / 2;
  mx1 = mx2 = my1 = my2 = sumD = maxI = 0;

  src_32 = (unsigned int *) src_buffer;
  for (line = ly; line <= uy; line++) {
    for (pixel = lx; pixel <= midx; pixel++) {
      mx1 += (int) src_32[line * Guider.framewidth + pixel];
      if (((int) src_32[line * Guider.framewidth + pixel]) > maxI)
        maxI = (int) src_32[line * Guider.framewidth + pixel];
      if (((int) src_32[line * Guider.framewidth + pixel]) > saturation)
          Guider.roi[roinum].nsaturated++;
    }
  }
  for (line = ly; line <= uy; line++) {
    for (pixel = midx + 1; pixel <= ux; pixel++) {
      mx2 += (int) src_32[line * Guider.framewidth + pixel];
      if (((int) src_32[line * Guider.framewidth + pixel]) > maxI)
        maxI = (int) src_32[line * Guider.framewidth + pixel];
    }
  }
  for (line = ly; line <= midy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      my1 += (int) src_32[line * Guider.framewidth + pixel];
    }
  }
  for (line = midy + 1; line <= uy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      my2 += (int) src_32[line * Guider.framewidth + pixel];
    }
  }
  sumI = mx1 + mx2;
  if (sumI == 0.0) {
    *centx = (double) Guider.roi[roinum].xc;
    *centy = (double) Guider.roi[roinum].yc;
  }
  else {
    *centx = (double) (halfbox * (mx2 - mx1)) / (double) (mx1 + mx2) + (double) Guider.roi[roinum].xc;
    *centy = (double) (halfbox * (my2 - my1)) / (double) (mx1 + mx2) + (double) Guider.roi[roinum].yc;
  }

  if (gdrDebug) {
     printf ("QUAD CENTROID mx2 %d, mx1 %d, my1 %d, my2 %d\n",mx1,mx2,my1,my2);
  }
  image_mx = maxI;
  image_tc = sumI;
  image_bk = sumI / ((ux - lx) *
             (ux - lx));

  nsamples = ux-lx+1;
  for (nX = 1; nX <= nsamples; nX++){
	fX[nX] = (double)nX;
	fH[nX] = (double)0.0;
	fV[nX] = (double)0.0;
  }
  sky = 0.0;
  avg = 0.0;
  for (line = ly; line <= uy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      graylevel = (double)src_32[line * Guider.framewidth + pixel];
      fH[pixel-lx+1]  += graylevel;
      fV[line-ly+1] += graylevel;
      avg += graylevel;
      if ( line==ly || line==uy || pixel==lx || pixel==ux ) {
         sky = sky + graylevel;
      }
    }
  }
  sky = sky/4.0;
  maxH = 0.0;
  maxV = 0.0;
  for (nX = 1; nX <= nsamples; nX++){
    fH[nX] = fH[nX] - sky;
     fV[nX] = fV[nX] - sky;
     if (fH[nX] > maxH) {
         maxH = fH[nX];
     }       
     if (fV[nX] > maxV) {
         maxV = fV[nX];
     }       
  }
  image_fw = ( qfwhm(fH,maxH,ux - lx + 1)/2.0 + qfwhm(fV,maxV,ux - lx + 1)/2.0  ) / 2.0;
  sky = sky/nsamples;
  avg = avg/(ux-lx+1)/(uy-ly+1);

  Guider.roi[roinum].background = sky;
  Guider.roi[roinum].mean = avg;
  Guider.roi[roinum].fmax = (double)maxI;

  if (avg/sky > Guider.losthresh) {
      lossOfSignal = 0;
  } else {
      lossOfSignal = 1;
  }

}

/*----------------------------------------------------------------------
 * calc_cmass - intensity centroid algorithm.
 *
 *---------------------------------------------------------------------*/
void calc_cmass (void *src_buffer, int roinum, int saturation, double *centx, double *centy)
{
  unsigned int *src_32;
  double graylevel, g2;
  int sumD, sumI, sumX, sumY, maxI = 0;
  int line, pixel, nsamples, nX;
  double maxH, maxV, sky, avg;
  double savex, savey;
  int lx, ly, ux, uy;

  lx = Guider.roi[roinum].xc - Guider.roi[roinum].xs/2;
  ux = lx + Guider.roi[roinum].xs; 
  ly = Guider.roi[roinum].yc - Guider.roi[roinum].ys/2;
  uy = ly + Guider.roi[roinum].ys; 
  Guider.roi[roinum].nsaturated = 0;
  Guider.roi[roinum].background = -1.0;
  Guider.roi[roinum].fmin = -1.0;
  Guider.roi[roinum].fmax = -1.0;
  Guider.roi[roinum].mean = -1.0;

  *centx = 0.0;
  *centy = 0.0;

  sumD = sumI = sumX = sumY = maxI = 0;
  src_32 = (unsigned int *) src_buffer;

  nsamples = ux-lx+1;
  for (nX = 1; nX <= nsamples; nX++){
	fX[nX] = (double)nX;
	fH[nX] = (double)0.0;
	fV[nX] = (double)0.0;
  }
  sky = 0.0;
  avg = 0.0;
  for (line = ly; line <= uy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      graylevel = (double)src_32[line * Guider.framewidth + pixel];
      fH[pixel-lx+1]  += graylevel;
      fV[line-ly+1] += graylevel;
      avg += graylevel;
      if ( line==ly || line==uy || pixel==lx || pixel==ux ) {
         sky = sky + graylevel;
      }
      if (((int) src_32[line * Guider.framewidth + pixel]) > saturation)
          Guider.roi[roinum].nsaturated++;
      if (((int) src_32[line * Guider.framewidth + pixel]) > Guider.roi[roinum].fmax )
          Guider.roi[roinum].fmax = (int)graylevel;
    }
  }
  sky = sky/4.0;
  maxH = 0.0;
  maxV = 0.0;
  for (nX = 1; nX <= nsamples; nX++){
    fH[nX] = fH[nX] - sky;
     fV[nX] = fV[nX] - sky;
     if (fH[nX] > maxH) {
         maxH = fH[nX];
     }       
     if (fV[nX] > maxV) {
         maxV = fV[nX];
     }       
  }
  image_fw = ( qfwhm(fH,maxH,ux - lx + 1)/2.0 + qfwhm(fV,maxV,ux - lx + 1)/2.0  ) / 2.0;

  sky = sky / nsamples;
  avg = avg/(ux-lx+1)/(uy-ly+1);

  Guider.roi[roinum].background = sky;
  Guider.roi[roinum].mean = avg;
  Guider.roi[roinum].fwhm = image_fw;

  if (avg/sky > Guider.losthresh) {
      lossOfSignal = 0;
  } else {
      lossOfSignal = 1;
  }

  for (line = ly; line <= uy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      graylevel = (double)src_32[line * Guider.framewidth + pixel];
      g2 = (graylevel-sky);
      sumX += (int)g2 * pixel;
      sumY += (int)g2 * line;
      sumI += (int)g2;
      if (g2 > maxI)
        maxI = (int)g2; 
    }
  }
  if (sumI != 0) {
    *centx = ((double) sumX / (double) sumI);
    *centy = ((double) sumY / (double) sumI);
    savex = *centx;
    savey = *centy;
  }

  image_mx = maxI;
  image_tc = sumI;
  image_bk = sky;



}



/*----------------------------------------------------------------------
 * calc_cmoment - moment centroid algorithm.
 *
 *---------------------------------------------------------------------*/
void calc_cmoment(void *src_buffer, int roinum, int saturation, double *centx, double *centy)
{
  unsigned int *src_32;
  double graylevel;
  int sumD, sumI, sumX, sumY, maxI = 0;
  int line, pixel, nsamples, nX;
  double maxH, maxV, sky, avg;
  int x,y;
  double xsum=0.0, ysum=0.0, xxsum=0.0, yysum=0.0;
  int lx, ly, ux, uy;

  lx = Guider.roi[roinum].xc - Guider.roi[roinum].xs/2;
  ux = lx + Guider.roi[roinum].xs; 
  ly = Guider.roi[roinum].yc - Guider.roi[roinum].ys/2;
  uy = ly + Guider.roi[roinum].ys; 
  Guider.roi[roinum].nsaturated = 0;
  Guider.roi[roinum].background = -1.0;
  Guider.roi[roinum].fmin = -1.0;
  Guider.roi[roinum].fmax = -1.0;
  Guider.roi[roinum].mean = -1.0;
  *centx = 0.0;
  *centy = 0.0;

  sumD = sumI = sumX = sumY = maxI = 0;
  src_32 = (unsigned int *) src_buffer;

  nsamples = ux-lx+1;
  for (nX = 1; nX <= nsamples; nX++){
	fX[nX] = (double)nX;
	fH[nX] = (double)0.0;
	fV[nX] = (double)0.0;
  }
  sky = 0.0;
  avg = 0.0;
  for (line = ly; line <= uy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      graylevel = (double)src_32[line * Guider.framewidth + pixel];
      fH[pixel-lx+1]  += graylevel;
      fV[line-ly+1] += graylevel;
      avg += graylevel;
      if ( line==ly || line==uy || pixel==lx || pixel==ux ) {
         sky = sky + graylevel;
      }
      sumI = sumI + (int)graylevel;
      if (((int) src_32[line * Guider.framewidth + pixel]) > saturation)
          Guider.roi[roinum].nsaturated++;
      if (((int) src_32[line * Guider.framewidth + pixel]) > Guider.roi[roinum].fmax )
          Guider.roi[roinum].fmax = (int)graylevel;
    }
  }
  sky = sky/4.0;
  maxH = 0.0;
  maxV = 0.0;
  for (nX = 1; nX <= nsamples; nX++){
    fH[nX] = fH[nX] - sky;
     fV[nX] = fV[nX] - sky;
     if (fH[nX] > maxH) {
         maxH = fH[nX];
     }       
     if (fV[nX] > maxV) {
         maxV = fV[nX];
     }       
  }
  image_fw = ( qfwhm(fH,maxH,ux - lx + 1)/2.0 + qfwhm(fV,maxV,ux - lx + 1)/2.0  ) / 2.0;

  sky = sky / nsamples;
  avg = avg/(ux-lx+1)/(uy-ly+1);

  Guider.roi[roinum].background = sky;
  Guider.roi[roinum].mean = avg;
  Guider.roi[roinum].fwhm = image_fw;

  if (avg/sky > Guider.losthresh) {
      lossOfSignal = 0;
  } else {
      lossOfSignal = 1;
  }

  for (line = ly; line <= uy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      graylevel = (double)src_32[line * Guider.framewidth + pixel] - sky;
      y = line - ly + 1;
      x = pixel - lx + 1;
      if (graylevel < 0.0)
        graylevel = 0.0;
      if (graylevel > maxI)
        maxI = (int)graylevel;
      xxsum+=(double)x*graylevel;
      xsum+=graylevel;
      yysum+=(double)y*graylevel;
      ysum+=graylevel;
    }
  }
  image_mx = maxI;
  image_tc = sumI;
  image_bk = sky;
  *centx = xxsum/xsum;
  *centy = yysum/ysum;
}

/*----------------------------------------------------------------------
 * calc_plsphot - old shectman guider algorithm.
 *
 * ix and iy are arrays containing the x,y pair coordinates of the
 * intensities in array z. Array e is an error tolerance. n is
 * the number of elements in array ix, iy, z and e. Argument fit
 * must be an array of six elements.
 *---------------------------------------------------------------------*/
void calc_plsphot (void *src_buffer, int roinum, int saturation, double *centx, double *centy)
{
  unsigned int *src_32;
  int n, imax, it;
  int line, pixel, box_x, box_y;
  double av, aux, chi2, area, fmaj;
  static int ix[225], iy[225];
  static double z[225], e[225];
  int lx, ly, ux, uy;
  double a[AMAX];

  lx = Guider.roi[roinum].xc - Guider.roi[roinum].xs/2;
  ux = lx + Guider.roi[roinum].xs; 
  ly = Guider.roi[roinum].yc - Guider.roi[roinum].ys/2;
  uy = ly + Guider.roi[roinum].ys; 
  Guider.roi[roinum].nsaturated = 0;
  Guider.roi[roinum].background = -1.0;
  Guider.roi[roinum].fmin = -1.0;
  Guider.roi[roinum].fmax = -1.0;
  Guider.roi[roinum].mean = -1.0;

  if ((ux - lx + 1) > 15) {  /* AOI too big    */
    return;
  }

  box_x = (ux + lx) / 2;
  box_y = (uy + ly) / 2;
  src_32 = (unsigned int *) src_buffer;

  /* prepare the data arrays and get the max and average values */
  n = 0;
  imax = 0;
  av = 0.0;
  aux = -1e10;
  for (line = ly; line <= uy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      ix[n] = pixel - box_x;
      iy[n] = line - box_y;
      z[n] = (double) src_32[line * Guider.framewidth + pixel];
      e[n] = 1.0;
      av += z[n];
      if (z[n] > aux) {
	imax = n;
	aux = z[n];
      }
      n++;
      if (((int) src_32[line * Guider.framewidth + pixel]) > saturation)
          Guider.roi[roinum].nsaturated++;
      if (((int) src_32[line * Guider.framewidth + pixel]) > Guider.roi[roinum].fmax )
          Guider.roi[roinum].fmax = (int) src_32[line * Guider.framewidth + pixel];
    }
  }
  av /= n;
  if (av == 0.0) {
    *centx = (double) Guider.roi[roinum].xc;
    *centy = (double) Guider.roi[roinum].yc;
    return;
  }

  /* fill the array with the variables of interest */
  a[0] = av;
  a[1] = (double) ix[imax] + (double) Guider.roi[roinum].xc;
  a[2] = (double) iy[imax] + (double) Guider.roi[roinum].yc;
  a[3] = z[imax] - av;
  a[4] = (double) 1.;
  if (gdrDebug) {
      printf ("SHECTMAN CENTROID av %f, x %f, y %f, z %f, e %f\n",a[0], a[1], a[2], a[3], a[4]);
  }

  /* the chi square distribution */
  it = 8;
  chi2 = chisq (ix, iy, z, e, n, a, acc, alim, &it);
  if (chi2 == 1e10) {
    it = -(it);
  }
  ellipse (a[4], &area, &fmaj);

  if (gdrDebug) {
      printf ("SHECTMAN CENTROID av %f, x %f, y %f, z %f, e %f\n\n", a[0], a[1], a[2], a[3], a[4]);
  }

  /* update the global variables with the current values */
  *centx = a[1];
  *centy = a[2];
  image_bk = a[0];
  image_tc = area * a[3];
  image_fw = fmaj;
  image_mx = z[imax];
  Guider.roi[roinum].background = image_bk;
  Guider.roi[roinum].fwhm = (double)fmaj;
}



/*----------------------------------------------------------------------
 * calc_gaussian - gaussian centroid algorithm.
 *
 *---------------------------------------------------------------------*/
void calc_gaussian (void *src_buffer, int roinum, int saturation, double *centx, double *centy)
{
  unsigned int *src_32;
  double graylevel;
  int line, pixel;
  int nNumSat, nX, nsamples;
  double sum, sky, avg;
  int lx, ly, ux, uy;
  double a[6];

  lx = Guider.roi[roinum].xc - Guider.roi[roinum].xs/2;
  ux = lx + Guider.roi[roinum].xs; 
  ly = Guider.roi[roinum].yc - Guider.roi[roinum].ys/2;
  uy = ly + Guider.roi[roinum].ys; 
  Guider.roi[roinum].nsaturated = 0;
  Guider.roi[roinum].background = -1.0;
  Guider.roi[roinum].fmin = -1.0;
  Guider.roi[roinum].fmax = -1.0;
  Guider.roi[roinum].mean = -1.0;
  *centx = 0.0;
  *centy = 0.0;
  nNumSat = 0;
  sum = 0.0;
  nsamples = ux-lx+1;
  
  /*
   ** zero the marginal distributions
  */
    
  for (nX = 1; nX <= nsamples; nX++){
	fX[nX] = (double)nX;
	fH[nX] = (double)0.0;
	fV[nX] = (double)0.0;
  }

  sky = 0.0;
  avg = 0.0;
  src_32 = (unsigned int *) src_buffer;
  for (line = ly; line <= uy; line++) {
    for (pixel = lx; pixel <= ux; pixel++) {
      graylevel = (double)src_32[line * Guider.framewidth + pixel];
      fH[pixel-lx+1]  += graylevel;
      fV[line-ly+1] += graylevel;
      sum = sum + graylevel;
      if ( line==ly || line==uy || pixel==lx || pixel==ux ) {
         sky = sky + graylevel;
      }
      if (((int) src_32[line * Guider.framewidth + pixel]) > saturation)
          Guider.roi[roinum].nsaturated++;
      if (((int) src_32[line * Guider.framewidth + pixel]) > Guider.roi[roinum].fmax )
          Guider.roi[roinum].fmax = (int)graylevel;
    }
  }

 
  a[0] = (double) 0.0;
  a[1] = (double) 0.0;
  a[2] = (double) 0.0;
  a[3] = (double) 0.0;
  a[4] = (double) 0.0;

  
  /*
  ** record image quality data
  */
  quickcenter(fX,fH,nsamples,a);  
 
    
  /*
  ** compute the fit
  */
  gaussfit(fH, a, nsamples, 3);  
  *centx = a[2];
  
  a[4] = 0.0;
  a[5] = 0.0;
    
  /*
  ** record image quality data
  */
  quickcenter(fX,fV,nsamples,a); 
   
    
  /*
  ** compute the fit
  */
  gaussfit(fV, a, nsamples, 3);   
  *centy = a[2];
  image_tc = sum;
  image_bk = (int)sum / (nsamples*nsamples);
  image_fw = (double)a[3];

  sky = sky / nsamples / 4.0;
  avg = sum/(ux-lx+1)/(uy-ly+1);

  Guider.roi[roinum].background = sky;
  Guider.roi[roinum].mean = avg;
  Guider.roi[roinum].fwhm = image_fw;


  if (avg/sky > Guider.losthresh) {
      lossOfSignal = 0;
  } else {
      lossOfSignal = 1;
  }

}


/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
  fwhmx_iraf - approximate FWHM using linear least squares to logarithmic
          transform of Gaussian equation. Note that the function being
          minimized by this routine is the ratio of computed to actual
          data values, not the sum of the differences.
 
          This version, using weighted sums, was written by Frank
          Valdes for the IRAF IMEXAMINE task in SPP, and was re-written
         in FORTRAN here, 
                             and now in C (DJM - Apr 2000)
 
 	  This version expects the skyval precalculated and input
          to this routine.
 
 ----------------------------------------------------------------------*/

void fwhmx_iraf (void *box, int nbx, int nby, double xc, double yc, double *fwhm)
{
        unsigned int *src_32;
        double strsum, dy, dx;
        int i, j, ix1, ix2, iy1, iy2, k, ixc, iyc;           
        double	r, radius, graylevel;      
        int x1, x2, y1, y2, nx, ny, npts, nstr;
        double	xlast, ylast, r2, xcntr,ycntr;
        double	mean, sum, sum1, sum2, sum3;
        double  sumw, sumrr, sumr, sumrl, suml, dsq, rsq, r1, w;
/* Intrinsic optical error to remove quadratically. */
        double fwhm0, fwhml;

        int nfwb = 16;
        src_32 = (unsigned int *) box;
        fwhml = *fwhm;
        r2 = image_bk;
	fwhm0 = 0.0;
	radius = 5.;
        xlast = 99.;
	ylast = 99.;
        xcntr = 0.0;
        ycntr = 0.0;
	for (k=1;k<=3;k++) {
	  if ( abs(xcntr-xlast) > 0.001 || abs(ycntr-ylast) > 0.001  ) {
   
	    xlast = (int)xc;
	    ylast = (int)yc;
	    x1 = (int)(xc - radius + 0.5);
	    x2 = (int)(xc + radius + 0.5);
	    y1 = (int)(yc - radius + 0.5);
	    y2 = (int)(yc + radius + 0.5);
	   

	    nx = x2 - x1 + 1;
	    ny = y2 - y1 + 1;
	    npts = nx * ny;
            sum = 0.;
            for (i=y1; i<=y2; i++) {
              for (j=x1;j<=x2;j++) {
                graylevel = (double)src_32[i * Guider.framewidth + j];
                sum += graylevel;
              }
            }
	    mean = sum / nx;
	    sum1 = 0.;
	    sum2 = 0; 
            for (i=y1; i<=y2; i++) {
	   
		sum3 = 0.;
                for (j=x1;j<=x2;j++) {
                   graylevel = (double)src_32[i * Guider.framewidth + j];
                   sum3 += graylevel;		  
	        }
		sum3 = sum3 - mean;
		if (sum3 > 0.) {
		    sum1 = sum1 + i * sum3;
		    sum2 = sum2 + sum3;
		}
		
	    }
	    xc = sum1 / sum2;

	 
	    mean = sum / ny;
	    sum1 = 0.;
	    sum2 = 0.;
            for (j=x1;j<=x2;j++) {
		sum3 = 0.;
                for (i=y1; i<=y2; i++) {
                    graylevel = (double)src_32[i * Guider.framewidth + j];
                    sum3 += graylevel;
                }		

		sum3 = sum3 - mean;
		if (sum3 > 0.) {
		    sum1 = sum1 + j * sum3;
		    sum2 = sum2 + sum3;
		}
	    }
	    yc = sum1 / sum2;
          }
        }
        fprintf(stderr,"Center located at %f , %f" ,xc,yc);
        ix1 = (int)fmax (xc - nfwb/2, 1.);
        ix2 = (int)imin (ix1 + nfwb - 1, nbx);

        iy1 = (int)fmax (yc - nfwb/2, 1.);
        iy2 = (int)imin (iy1 + nfwb -1, nby);

        radius = 5;

        sumw  = 0.0;
        sumrr = 0.0;
        sumr  = 0.0;
        sumrl = 0.0;
        suml  = 0.0;
        strsum = 0.0;
        nstr = 0;
        ixc = (int)xc;
	iyc = (int)yc;
	
	

/* Compute sums for FWHM */
        for (j=iy1;j<=iy2;j++) {
            dy = j - yc;
            dsq = dy*dy;

/* Note that delta x must be increased by 1.21 for RS-170 grab factor */
            for (i=ix1;i<=ix2;i++) {
                dx = (i - xc); 
/* or maybe not! * 1.21 */
                r = sqrt (dx*dx + dsq);
                rsq = r*r;

               graylevel = (double)src_32[i * Guider.framewidth + j];
               r1 = graylevel - r2;

               if (r < radius && r1 > 0.0) {
                    w = r1 / fmax(0.1, rsq); 
                    sumw = sumw + w;
                    sumr = sumr + w * rsq;
                    suml = suml + w * log (r1);
                    sumrr = sumrr + w * rsq*rsq;
                    sumrl = sumrl + w * rsq * log (r1);
                    strsum = strsum + r1;
                    nstr = nstr + 1;
                }
            }
        }

        w = sumw * sumrr - sumr*sumr;
        if (w > 0.0) {
            fwhml = (sumw * sumrl - sumr * suml) / w;
        } else {
            fwhml = 0.0;
        }

        if (fwhml < 0.0) {
            fwhml = 2.0 * sqrt (-log(2.0)/fwhml);
        } else {
            fwhml = 0.00;
        }

        if (nstr > 0) {
                strsum = strsum / nstr;
        } else {
                strsum = 0;
        }
        if (fwhml > fwhm0) fwhml = sqrt (fwhml*fwhml - fwhm0*fwhm0);

/* rescale to fit with imexamine algorithm */
        *fwhm = fwhml / 0.94;      

        return;
}


double fmax(double a, double b)
{
   if (a > b) { 
      return(a);
   } else {
      return(b);
   }
}


int imin(int a, int b)
{
   if (a < b) { 
      return(a);
   } else {
      return(b);
   }
}


