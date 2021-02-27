#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define VOID void
#define STATUS int
#define ERROR 1
#define OK 0

double **dmatrix(int nrl, int nrh, int ncl, int nch);
double *dvector(int nl, int nh);
int *ivector(int nl, int nh);
void free_dmatrix(double **m, int nrl, int nrh, int ncl, int nch);
void free_ivector(int *v, int nl, int nh);
void free_dvector(double *v, int nl, int nh);
void fgauss(double x, double *a, double *y, double *dyda, int na);
void covsrt(double **covar, int ma, int *lista, int mfit);
STATUS gaussj(double **a, int n, double **b, int m);
void mrqcof(double *x, double* y, double *sig, int ndata,
	    double *a, int ma, int *lista, int mfit,double **alpha,
	    double *beta, double *chisq, void (*funcs)());
VOID mrqmin(double *x, double *y, double *sig, int ndata,
	    double *a, int ma, int *lista, int mfit, double **covar,
	    double **alpha, double *chisq, void (*funcs)(), double *alamda);

#define MA 3
#define SPREAD 0.001
#define SWAP(a,b) {float temp=(a);(a)=(b);(b)=temp;}
double inten,mininten;

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
/* SIDE EFFECTS:                                                             */
/*---------------------------------------------------------------------------*/
STATUS
quickcenter(double *x, double *y, int nPts, double *a)
{
    int i,imax,imin;
    double dmax,dmin,dthresh,dsum,dcent,dinteg,dfwhm;
    double lefthalf, righthalf;
   
    dmax = -9999999.;
    dmin = 999999.;
    lefthalf = 0.0;
    righthalf = 0.0;

    for (i=1;i<=nPts;i++) {
       if (y[i] > dmax) {
           dmax = y[i];
	   imax = i;
       }
       if (y[i] < dmin) {
           dmin = y[i];
	   imin = i;
       }
    }
    dthresh = dmin + 0.15 * (dmax-dmin);
    dinteg = 0.0;
    dsum = 0.0;
    for (i=1;i<=nPts;i++) {
       if (y[i] > dthresh) {
          dsum = dsum + y[i];
          dinteg = dinteg + x[i]*y[i];    
       }
    }
    dcent = dinteg / dsum;
    dthresh = dmin + (dmax-dmin)/2.0;
    i=1;
    while (y[i]-dthresh <= 0. && i <= nPts) {
       i++;
       lefthalf = (double)i + (0.-(y[i-1]-dmax/2.0)) / (y[i]-y[i-1]);
    }
    i=nPts;
    while (y[i]-dthresh <= 0. && i > 0) {
       i--;
       righthalf = (double)i + (0.-(y[i-1]-dmax/2.0)) / (y[i]-y[i-1]);
    }
    dfwhm = (righthalf-lefthalf)/2.0; 
    if (dfwhm < 1. || dfwhm > 10.) { dfwhm = 5.0; }  
    mininten = dmin;
    inten = dmax - dmin;
    a[1] = dmax;
    a[3] = dfwhm;
    a[2] = dcent; 
    return 0;
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
/* SIDE EFFECTS:                                                             */
/*---------------------------------------------------------------------------*/
STATUS
oldgaussfit(double *x, double *y, double *a, int nPts)
{
    int i, itst, k, mfit, *lista;
    double alamda, chisq, ochisq,  *sig;
    double **covar, **alpha;
    
      
    mfit = MA;
    lista = ivector(1,mfit);
    sig = dvector(1,nPts);
    covar = dmatrix(1,mfit,1,mfit);
    alpha = dmatrix(1,mfit,1,mfit);
    /*
    ** set the std dev acceptable for each data point
    */
    for (i=1; i<=nPts; i++) {
	sig[i] = y[i] * SPREAD;
    }

    
    for (i=1; i<=mfit; i++){
	lista[i] = i;
    }

    alamda = -1;

    mrqmin(x,y,sig,nPts,a,mfit,lista,mfit,covar,alpha,&chisq,fgauss,&alamda);

    k = 1;
    itst = 0;

    while (itst < 2) {

	k++;
	ochisq=chisq;

	mrqmin(x,y,sig,nPts,a,mfit,lista,mfit,covar,alpha,&chisq,fgauss,&alamda);

	if (chisq > ochisq) {
	    itst = 0;
	} else if (fabs(ochisq-chisq) < 0.1) {
	    itst++;
	}

	if (k>100){
	    break;
	}

    }

    free_dmatrix(alpha,1,mfit,1,mfit);
    free_dmatrix(covar,1,mfit,1,mfit);
    free_dvector(sig,1,nPts);
    free_ivector(lista,1,mfit);

    return(OK);
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
/* SIDE EFFECTS:                                                             */
/*---------------------------------------------------------------------------*/
double
cog(double *x, double *y, int nPts)
{
    int hk, k;
    double sum, hsum, c;
    
    hk = 0.0;
    sum = 0.0;
    hsum = 0.0;
    for (k=1;k<=nPts;k++) {
        if (y[k] > 0.0) { sum = sum+y[k]; }
    }
    for (k=1;k<=nPts;k++) {
      if (y[k] > 0.0) { 
         if (hsum < sum/2.0) { 
	    hsum = hsum+y[k]; 
	    hk = k;
	 }
      }
    }
    c = (hsum-sum/2.0) / y[hk] + x[hk] - 0.5;  
    return c; 
}





