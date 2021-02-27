#include <stdio.h>
#include <math.h>
#include <stdlib.h>

#define VOID void
#define STATUS int
#define OK 0
#define XROISIZE 76


double qfwhm(double *y, double Intensity, int nPts);

int gaussfit(double *y, double *a, int nPts, int MA);

void fgauss(double x, double a[], double *y, double dyda[], int na);

void gaussj(int n, int m);

void covsrt(int ma, int ia[], int mfit);

void mrqcofa(double x[], double y[], double sig[], int ndata, double a[], int ia[],int ma, double beta[], double *chisq);
void mrqcofc(double x[], double y[], double sig[], int ndata, double a[], int ia[],int ma, double beta[], double *chisq);

void mrqmin(double x[], double y[], double sig[], int ndata, double a[], int ia[],int ma,  double *chisq, double *alamda, int getmem);

int *ivector(int nl, int nh);

void free_ivector(int *v, int nl, int nh);

double *dvector(int nl, int nh);

void free_dvector(double *v, int nl, int nh);

double **dmatrix(int nrl, int nrh, int ncl, int nch);

void free_dmatrix(double **m, int nrl, int nrh, int ncl, int nch);

double covar[4][4], alpha[4][4], oneda[4][4];
int testbuffer[4096];


/************************************/
#define SPREAD 0.001
#define SWAP(a,b) { double temp=(a);(a)=(b);(b)=temp;}

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/
double qfwhm(double *y,double Intensity, int nPts)
{
    int i;

    double lefthalf=20.0, righthalf=40.0, dfwhm=10.0;
    double test=0;   



/*Calculate the direct FWHM.*/

test = Intensity/2.0;

for (i=2; i <= nPts;  i++){

	if( y[i] >= test ) {
       		lefthalf = ((double)(i-1))  +   (test - y[i-1]) / ( y[i]-y[i-1] );
		i=nPts+1;
		}
	}





for (i=(nPts-1); i>=1; i--){

	if ( y[i] > test ) {
		righthalf = ((double)(i-1)) + (test - y[i-1])/(y[i]-y[i-1]);
		i=0;
    }
}

    dfwhm = (righthalf-lefthalf);


   if ( (dfwhm < 5.) || (dfwhm > 30.) ) dfwhm = 10.0;

return (double)(dfwhm);
}




/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/

/*---------------------------------------------------------------------------*/
/*---------------------------------------------------------------------------*/

/*Gaussian Function Driver***********************************************/
/* Driver for routine mrqmin ********************************************/


int gaussfit(double *y, double *a, int nPts, int MA)
{
	int i,iter,itst,k,mfit=MA;
        int getmem;
	double alamda,chisq,ochisq;
        double x[XROISIZE], sig[XROISIZE];
        int ia[4];
/*        double *x,*sig,**covar,**alpha;
          int *ia;
	x=dvector(1,nPts);
	ia=ivector(1,MA);
	sig=dvector(1,nPts);
	covar=dmatrix(1,MA,1,MA);
	alpha=dmatrix(1,MA,1,MA);
 */
/***********************************************************************/
/*Populate the vector 'sig' with values inversely proportional to ******/
/*the corresponding y value intensity **********************************/
/*'sig' should be a vector of standard deviations corresponding ********/
/*values.***************************************************************/

	for (i=1; i<=nPts; i++) {
	

		x[i]=(double)(i);
		
		sig[i]=(sqrt(y[i]*0.001));
		if(sig[i]<=0.00)sig[i]=.3;
		else{
		sig[i]=1.0/ sqrt( (double)(sig[i]) );
		}
/*	printf("sig[%d]:%.2lf\n",i,sig[i]);  */
	}

/***********************************************************************/
/*The intensity of the profile is known, will not fit.  Fit center and */
/*fwhm parameter only****************************************************/ 
	ia[1]=0;
	for (i=2;i<=mfit;i++) ia[i]=1;
/***********************************************************************/


	for (iter=1;iter<=2;iter++) {
		alamda = -1;
                getmem=1;
		mrqmin(x,y,sig,nPts,a,ia,MA,&chisq,&alamda,getmem);
		k=1;
		itst=0;
		for (;;) {
			getmem=0;
		/*	printf("\n%s %2d %17s %10.4lf %10s%9.2e\n","Iteration#",k,"chi-squared:",chisq,"alamda:",alamda);
			printf("%8s %8s %8s\n","a[1]","a[2]","a[3]");
		*/

	/*	for (i=1;i<=mfit;i++) printf("%.4lf  ",a[i]);
		
			printf("\n");
	*/
			k++;
			ochisq=chisq;
			mrqmin(x,y,sig,nPts,a,ia,MA,&chisq,&alamda,getmem);
/*	removed temporarily		if (chisq > ochisq)
				itst=0;
			else if (fabs(ochisq-chisq) < 0.1)
				itst++;
 */
			itst++;
			if (itst < 4) continue;
			alamda=0.0;
                        getmem = -1;
			mrqmin(x,y,sig,nPts,a,ia,MA,&chisq,&alamda,getmem);
/*			printf("\nUncertainties:\n");  
			for (i=1;i<=mfit;i++) printf("%.6lf  ",sqrt(covar[i][i]));
			printf("\n");  */
			break;
		}


/*		if (iter == 1) {							*/
/*			printf("press return to continue with constraint\n");		*/
/*			(void) getchar();						*/
/*			printf("holding a[2] and a[5] constant\n");			*/
/*			for (j=1;j<=MA;j++) a[j] += 0.1;				*/
/*			a[2]=2.0;							*/
/*			ia[2]=0;							*/
/*			a[5]=5.0;							*/
/*			ia[5]=0;							*/
/*		}									*/




	}
/*	free_dmatrix(alpha,1,MA,1,MA);
	free_dmatrix(covar,1,MA,1,MA);
	free_dvector(sig,1,nPts);
	free_ivector(ia,1,MA);
  */
	return 0;
}



/************************************************************************/
/************************************************************************/
/************************************************************************/

/*fguass, defines model function and it's variable dependent derivatives*/

void fgauss(double x, double a[], double *y, double dyda[], int na)
{
	int i;
	double fac,ex,arg;

	*y=0.0;
for (i=1;i<=na-1;i+=3) { 
		arg=(x-a[i+1])/a[i+2];
		ex=exp(-arg*arg);
		fac=a[i]*ex*2.0*arg;
		*y += a[i]*ex;
		dyda[i]=ex;
		dyda[i+1]=fac/a[i+2];
		dyda[i+2]=fac*arg/a[i+2];
	} 
}
/************************************************************************/


/*gaussj, Gauss Jordan Elimiantion***************************************/


void gaussj(int n, int m)
{
/*	int *indxc,*indxr,*ipiv; */
        int indxc[4], indxr[4], ipiv[4];
	int i,icol,irow,j,k,l,ll;
	double big,dum,pivinv;

        icol = 1;
        irow = 1;
        pivinv = 0.0;
/*	indxc=ivector(1,n);
	indxr=ivector(1,n);
	ipiv=ivector(1,n);
 */
	for (j=1;j<=n;j++) ipiv[j]=0;
	for (i=1;i<=n;i++) {
		big=0.0;
		for (j=1;j<=n;j++)
			if (ipiv[j] != 1)
				for (k=1;k<=n;k++) {
					if (ipiv[k] == 0) {
						if (fabs( covar[j][k]) >= big) {
							big=fabs((float)covar[j][k]);
							irow=j;
							icol=k;
						}
					} else if (ipiv[k] > 1) printf("gaussj: Singular Matrix-1\n");
				}
		++(ipiv[icol]);
		if (irow != icol) {
			for (l=1;l<=n;l++) SWAP(covar[irow][l],covar[icol][l])
			for (l=1;l<=m;l++) SWAP(oneda[irow][l],oneda[icol][l])
		}
		indxr[i]=irow;
		indxc[i]=icol;
		if (covar[icol][icol] == 0.0) {
                    printf("gaussj: Singular Matrix-2\n");
                } else {
  		   pivinv=1.0/covar[icol][icol];
                }
		covar[icol][icol]=1.0;
		for (l=1;l<=n;l++) covar[icol][l] *= pivinv;
		for (l=1;l<=m;l++) oneda[icol][l] *= pivinv;
		for (ll=1;ll<=n;ll++)
			if (ll != icol) {
				dum=covar[ll][icol];
				covar[ll][icol]=0.0;
				for (l=1;l<=n;l++) covar[ll][l] -= covar[icol][l]*dum;
				for (l=1;l<=m;l++) oneda[ll][l] -= oneda[icol][l]*dum;
			}
	}
	for (l=n;l>=1;l--) {
		if (indxr[l] != indxc[l])
			for (k=1;k<=n;k++)
				SWAP(oneda[k][indxr[l]],oneda[k][indxc[l]]);
	}
/*	free_ivector(ipiv,1,n);
	free_ivector(indxr,1,n);
	free_ivector(indxc,1,n);
 */
}

/************************************************************************/
/*covsrt Covariance Matrix***********************************************/


void covsrt(int ma, int ia[], int mfit)
{
	int i,j,k;
	

	for (i=mfit+1;i<=ma;i++)
		for (j=1;j<=i;j++) covar[i][j]=covar[j][i]=0.0;
	k=mfit;
	for (j=ma;j>=1;j--) {
		if (ia[j]) {
			for (i=1;i<=ma;i++) SWAP(covar[i][k],covar[i][j])
			for (i=1;i<=ma;i++) SWAP(covar[k][i],covar[j][i])
			k--;
		}
	}
}

/************************************************************************/
/*mrqcof, Marquardt Coefficients Evaluator*******************************/


void mrqcofa(double x[], double y[], double sig[], int ndata, double a[], int ia[],
	int ma, double beta[], double *chisq
	)
{
	int i,j,k,l,m,mfit=0;
	double ymod,wt,sig2i,dy;
        double dyda[4];
/*        double *dyda;
	dyda=dvector(1,ma);
 */
	for (j=1;j<=ma;j++)
		if (ia[j]) mfit++;
	for (j=1;j<=mfit;j++) {
		for (k=1;k<=j;k++) alpha[j][k]=0.0;
		beta[j]=0.0;
	}
	*chisq=0.0;
	for (i=1;i<=ndata;i++) {
		fgauss(x[i],a,&ymod,dyda,ma);
		sig2i=1.0/(sig[i]*sig[i]);
		dy=y[i]-ymod;
		for (j=0,l=1;l<=ma;l++) {
			if (ia[l]) {
				wt=dyda[l]*sig2i;
				for (j++,k=0,m=1;m<=l;m++)
					if (ia[m]) alpha[j][++k] += wt*dyda[m];
				beta[j] += dy*wt;
			}
		}
		*chisq += dy*dy*sig2i;
	}
	for (j=2;j<=mfit;j++)
		for (k=1;k<j;k++) alpha[k][j]=alpha[j][k];
/*	free_dvector(dyda,1,ma); */
}

void mrqcofc(double x[], double y[], double sig[], int ndata, double a[], int ia[],
	int ma, double beta[], double *chisq
	)
{
	int i,j,k,l,m,mfit=0;
	double ymod,wt,sig2i,dy;
        double dyda[4];
/*        double *dyda;
	dyda=dvector(1,ma);
 */
	for (j=1;j<=ma;j++)
		if (ia[j]) mfit++;
	for (j=1;j<=mfit;j++) {
		for (k=1;k<=j;k++) covar[j][k]=0.0;
		beta[j]=0.0;
	}
	*chisq=0.0;
	for (i=1;i<=ndata;i++) {
		fgauss(x[i],a,&ymod,dyda,ma);
		sig2i=1.0/(sig[i]*sig[i]);
		dy=y[i]-ymod;
		for (j=0,l=1;l<=ma;l++) {
			if (ia[l]) {
				wt=dyda[l]*sig2i;
				for (j++,k=0,m=1;m<=l;m++)
					if (ia[m]) covar[j][++k] += wt*dyda[m];
				beta[j] += dy*wt;
			}
		}
		*chisq += dy*dy*sig2i;
	}
	for (j=2;j<=mfit;j++)
		for (k=1;k<j;k++) covar[k][j]=covar[j][k];
/*	free_dvector(dyda,1,ma); */
}



/************************************************************************/
/*Mrqmin, Levenburg-Marquardt Method*************************************/


void mrqmin(double x[], double y[], double sig[], int ndata, double a[], int ia[],
	int ma, double *chisq,
        double *alamda, int getmem)
{
	void covsrt(int ma, int ia[], int mfit);
	void gaussj(int n, int m);
	void mrqcofa(double x[], double y[], double sig[], int ndata, double a[],
		int ia[], int ma, double beta[], double *chisq
		);
	void mrqcofc(double x[], double y[], double sig[], int ndata, double a[],
		int ia[], int ma, double beta[], double *chisq
		);
	int j,k,l;
	static int mfit;
	static double ochisq;
/*        static double *atry,*beta,*da,**oneda; */
        double atry[4], beta[4], da[4], oneda[4][4];
	if (getmem == 1) {
/*		atry=dvector(1,ma);
		beta=dvector(1,ma);
		da=dvector(1,ma);
 */
		for (mfit=0,j=1;j<=ma;j++)
			if (ia[j]) mfit++;
/*		oneda=dmatrix(1,mfit,1,1); */
		*alamda=0.001;
		mrqcofa(x,y,sig,ndata,a,ia,ma,beta,chisq);
		ochisq=(*chisq);
		for (j=1;j<=ma;j++) atry[j]=a[j];
	}
	for (j=1;j<=mfit;j++) {
		for (k=1;k<=mfit;k++) covar[j][k]=alpha[j][k];
		covar[j][j]=alpha[j][j]*(1.0+(*alamda));
		oneda[j][1]=beta[j];
	}
	gaussj(mfit,1);
	for (j=1;j<=mfit;j++) da[j]=oneda[j][1];
	if (getmem == -1) {
		covsrt(ma,ia,mfit);
/*		free_dmatrix(oneda,1,mfit,1,1);
		free_dvector(da,1,ma);
		free_dvector(beta,1,ma);
		free_dvector(atry,1,ma); */
		return;
	}
	for (j=0,l=1;l<=ma;l++)
		if (ia[l]) atry[l]=a[l]+da[++j];
	mrqcofc(x,y,sig,ndata,atry,ia,ma,da,chisq);
	if (*chisq < ochisq) {
		*alamda *= 0.1;
		ochisq=(*chisq);
		for (j=1;j<=mfit;j++) {
			for (k=1;k<=mfit;k++) alpha[j][k]=covar[j][k];
			beta[j]=da[j];
		}
		for (l=1;l<=ma;l++) a[l]=atry[l];
	} else {
		*alamda *= 10.0;
		*chisq=ochisq;
	}
}

/************************************************************************/
/************************************************************************/
/************************************************************************/
/************************************************************************/
/************************************************************************/
/************************************************************************/
/************************************************************************/
/*Utilities**************************************************************/

int *ivector(int nl, int nh)
{
    int *v ;

    v=(int*)malloc((unsigned)(nh-nl+1+1)*sizeof(int));
    if (!v){
        printf("ERROR: allocation failure in ivector\n");
    }
    return (v-nl+1);
}
/*---------------------------------------------------------------------------*/
void free_ivector(int *v, int nl, int nh)
{
    free((char*)(v+nl-1));
}

/*---------------------------------------------------------------------------*/
double *dvector(int nl, int nh)
{
    double *v;

    v=(double*)malloc((unsigned)(nh-nl+1+1)*sizeof(double));
    if (!v) {
        printf("ERROR: allocation failure in dvector\n");
    }
    return (v-nl+1);
}

/*---------------------------------------------------------------------------*/
void free_dvector(double *v, int nl, int nh)
{
    free((char*)(v+nl-1));
}

/*---------------------------------------------------------------------------*/
double **dmatrix(int nrl, int nrh, int ncl, int nch)
{
    int i,nrow=nrh-nrl+1,ncol=nch-ncl+1;
    double **m;

    m = (double **)malloc((unsigned)(nrow+1)*sizeof(double*));

    if (!m){
        printf("ERROR: allocation failure 1 in dmatrix\n");
    }
    m +=1;	
    m -= nrl;

    m[nrl]=(double *) malloc((unsigned) ((nrow*ncol+1)*sizeof (double)));

        if (!m[nrl]) {
            printf("ERROR: allocation failure 2 in dmatrix\n");
        }
        m[nrl] += 1;
        m[nrl] -= ncl;

    for (i=nrl+1; i<=nrh ;i++) m[i]=m[i-1]+ncol;


    return (m);
}

/*---------------------------------------------------------------------------*/
void free_dmatrix(double **m, int nrl, int nrh, int ncl, int nch)
{
    free((char*) (m[nrl] + ncl - 1));
    free((char*) (m+nrl - 1));

}



