/* chisqLib.c      02/17/1999      NOAO    */

/*
 *  Developed 1998 by the National Optical Astronomy Observatories(*)
 *
 * (*) Operated by the Association of Universities for Research in
 *     Astronomy, Inc. (AURA) under cooperative agreement with the
 *     National Science Foundation.
 */

/*
 * modification history
 * --------------------
 * 01a 30mar99, rcr - Ported to C.
 */

/*----------------------------------------------------------------------
 * chisqLib.c
 *
 * This module contains the porting of Shectman's fortran code for the
 * chi square fitting routine.
 *---------------------------------------------------------------------*/

#include <stdio.h>
#include <math.h>
#include "chisqLib.h"

#define HALF 0.5
#define THIRD 0.3333333
#define EXPMIN -23
#define MMAX 11

static double b[MMAX][MMAX] =
{
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0}
};

static double v[MMAX] =
{
  0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
};

static double fa[AMAX] =
{
  0.0, 0.0, 0.0, 0.0, 0.0
};

static double c[AMAX][AMAX] =
{
  {0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0},
  {0.0, 0.0, 0.0, 0.0, 0.0}
};

/*----------------------------------------------------------------------
 *	Local Function Prototypes
 *---------------------------------------------------------------------*/

static double pseud2d (int ix, int iy, double *a, double *fa);
static int ludcmp (double carray[AMAX][AMAX], int *indx, int n);
static void lubksb (double carray[AMAX][AMAX], int *indx, double *b, int n);
#if 0
static void dump_array (double *array, int n, int m);
#endif

/*----------------------------------------------------------------------
 * chisq -
 *
 *---------------------------------------------------------------------*/
double chisq (int *ix, int *iy, double *z, double *e, int n, double *a,
	      double *acc, double *alim, int *it)
{
  int limit, i, j, k, l, kk, ifact;
  int marq, conv, test;
  int indx[MMAX];
  double f, f2, chiold, perdeg, div;
  double fakk, fact, save, ye1;
  double chi;

  /* check for out of limit values in array "a" */
  chiold = 0.0;
  chi = 0.0;
  limit = 0;
  for (j = 0; j < AMAX; j++) {
    if (alim[j] < (float) 0.) {	/* only bounded fields */
      limit = fabs (a[j]) > fabs (alim[j]);
    }
  }

  ifact = 0;

  i = 1;
  conv = 0;
  while (i <= *it && !conv && !limit) {

    chi = 0.0;
    for (j = 0; j < AMAX; j++) {
      b[j][AMAX] = 0.0;
      for (kk = 0; kk < AMAX; kk++) {
	b[j][kk] = 0.0;
      }
    }

    for (j = 0; j < n; j++) {
      f = pseud2d (ix[j], iy[j], a, fa) - z[j];
      f2 = f * f;
      ye1 = 1.0 / e[j];
      chi += f2 * ye1;
      for (kk = 0; kk < AMAX; kk++) {
	if (fa[kk] != 0.0) {
	  fakk = fa[kk] / e[j];
	  b[kk][AMAX] += fakk * f;
	  for (l = 0; l <= kk; l++) {
	    if (fa[l] != 0.0) {
	      b[kk][l] += fakk * fa[l];
	    }
	  }
	}
      }
    }

    chiold = chi;
    k = 1;
    marq = 0;
    while (k <= 10 && !marq && !limit) {

      if (k == 1) {
	conv = 1;
	fact = 0.0;
      }
      else {
	fact = pow (2.0, ifact);
      }

      for (j = 0; j < AMAX; j++) {
	l = 1;
	while (l < j) {
	  c[j][l] = b[j][l];
	  c[l][j] = b[j][l];
	  l++;
	}
	c[j][j] = (fact + 1) * b[j][j];
	v[j] = b[j][AMAX];
      }

      test = ludcmp (c, indx, AMAX);
      if (!test) {
	return 0.0;
      }
      lubksb (c, indx, v, AMAX);

      for (j = 0; j < AMAX; j++) {
	a[j] -= v[j];
	if (alim[j] > 0.0) {
	  limit |= (int) (fabs (v[j] / a[j]) > alim[j]);
	}
	else if (alim[j] < 0.0) {
	  limit |= (int) (fabs (a[j]) > fabs (alim[j]));
	}
	if (acc[j] >= 0.0) {
	  conv &= (int) ((fabs (v[j]) / a[j]) <= acc[j]);
	}
	else {
	  conv &= (int) (fabs (v[j]) <= fabs (acc[j]));
	}
      }

      if (conv) {
	marq = (1);
      }
      else if (!limit) {
	chi = 0.0;
	for (j = 1; j < n; j++) {
	  f = pseud2d (ix[j], iy[j], a, fa) - z[j];
	  f2 = f * f;
	  ye1 = 1.0 / e[j];
	  chi += f2 * ye1;
	}
	if (k == 2) {
	  --ifact;
	}
	if (chi < chiold * 1.0001) {
	  marq = (1);
	}
	else {
	  if (k == 2) {
	    ifact++;
	  }
	  if (k >= 2) {
	    ifact++;
	  }
	  if (ifact > 10) {
	    break;
	  }
	  for (j = 1; j < AMAX; j++) {
	    a[j] += v[j];

	  }
	}
      }
      k++;
    }
    i++;
  }

  *it = i - 1;
  if (!limit) {
    for (j = 0; j < AMAX; j++) {
      for (i = 0; i < AMAX; i++) {
	b[i][j] = 0.0;
      }
      b[j][j] = 1.0;
      lubksb (c, indx, &b[0][j], AMAX);
    }
  }

  if (conv && !limit) {

    if ((n - AMAX) > 1)
      div = (double) (n - AMAX);
    else
      div = 1.0;
    perdeg = sqrt (chi / div);
    for (i = 0; i < AMAX; i++) {
      if (b[i][i] > 0.0) {
	save = sqrt (b[i][i]);
      }
      else {
	save = 1e10;
      }
      for (j = 0; j < AMAX; ++j) {
	c[i][j] = b[i][j] / save;
	c[j][i] = b[j][i] / save;
      }
      c[i][i] = save * perdeg;
    }
    return (chiold);
  }
  else {
    return 1.0e10;
  }
}

/*----------------------------------------------------------------------
 * pseud2d -
 *
 *---------------------------------------------------------------------*/
static double pseud2d (int ix, int iy, double *a, double *fa)
{
  double x, y, tx, ty, t;
  double dddt, pexp, denom;

  x = ix - a[1];
  y = iy - a[2];
  tx = (1.0 / a[4]) * x;
  ty = (1.0 / a[4]) * y;
  t = HALF * (tx * x + ty * y);

  if (t > 0.0) {
    denom = 1 + t + (t * t * HALF) + (THIRD * HALF * t * t * t);
    dddt = 1 + t + (t * t * HALF);
    pexp = 1 / denom;
  }
  else {
    if (t < EXPMIN)
      t = EXPMIN;
    pexp = exp (-t);
    denom = 1.0;
    dddt = 1.0;
  }

  fa[3] = pexp;
  pexp = a[3] * pexp;
  fa[4] = pexp * dddt / denom;
  fa[1] = tx * fa[4];
  fa[2] = ty * fa[4];
  fa[4] = HALF * (tx * tx + ty * ty) * fa[4];
  fa[0] = 1.0;

  return (pexp + a[0]);
}

/*----------------------------------------------------------------------
 * ludcmp -
 *
 *---------------------------------------------------------------------*/
static int ludcmp (double carray[AMAX][AMAX], int *indx, int n)
{
  int i, j, k, imax;
  double dum, sum, aamax, vv[100];

  imax = 0;
  for (i = 0; i < n; i++) {
    aamax = 0.0;
    for (j = 0; j < n; j++) {
      if (fabs (carray[i][j]) > aamax)
	aamax = fabs (carray[i][j]);
    }
    if (aamax == 0.0)
      return 0;
    vv[i] = 1.0 / aamax;
  }

  for (j = 0; j < n; j++) {
    if (j > 0) {
      for (i = 0; i < j; i++) {
	sum = carray[i][j];
	if (i > 0) {
	  for (k = 0; k < i; k++) {
	    sum -= carray[i][k] * carray[k][j];
	  }
	  carray[i][j] = sum;
	}
      }
    }

    aamax = 0.0;
    for (i = j; i < n; i++) {
      sum = carray[i][j];
      if (j > 0) {
	for (k = 0; k < j; k++) {
	  sum -= carray[i][k] * carray[k][j];
	}
	carray[i][j] = sum;
      }
      dum = vv[i] * fabs (sum);
      if (dum >= aamax) {
	imax = i;
	aamax = dum;
      }
    }

    if (j != imax) {
      for (k = 0; k < n; k++) {
	dum = carray[imax][k];
	carray[imax][k] = carray[j][k];
	carray[j][k] = dum;
      }
      vv[imax] = vv[j];
    }
    indx[j] = imax;
    if (j != n) {
      if (carray[j][j] == 0.0) {
	carray[j][j] = 1e-20;
      }
      dum = 1.0 / carray[j][j];
      for (i = j + 1; i < n; i++) {
	carray[i][j] *= dum;
      }
    }
  }
  if (carray[n][n] == 0.0) {
    carray[n][n] = 1e-20;
  }

  return 1;
}

/*----------------------------------------------------------------------
 * lubksb -
 *
 *---------------------------------------------------------------------*/
static void lubksb (double carray[AMAX][AMAX], int *indx,
		    double *barray, int n)
{
  int i, j, ii, ll;
  double sum;

  ii = 0;
  for (i = 0; i < n; i++) {
    ll = indx[i];
    sum = barray[ll];
    barray[ll] = barray[i];
    if (ii != 0) {
      for (j = ii; j < i; j++) {
	sum -= carray[i][j] * barray[j];
      }
    }
    else if (sum != 0.0) {
      ii = i;
    }
    barray[i] = sum;
  }

  for (i = n - 1; i >= 0; i--) {
    sum = barray[i];
    if (i < n - 1) {
      for (j = i + 1; j < n; j++) {
	sum -= carray[i][j] * barray[j];
      }
    }
    barray[i] = sum / carray[i][i];
  }
}

/*----------------------------------------------------------------------
 * ellipse
 *
 *---------------------------------------------------------------------*/
void ellipse (double b5, double *area, double *amaj)
{
  if (b5 > 0.0) {
    *area = 6.2832 * b5;
    *amaj = sqrt (b5) * 2.35482;
  }
  else {
    *area = 0.0;
    *amaj = 0.0;
  }
}

#if 0
static void dump_array (double *array, int n, int m)
{
  int i, j;

  for (i = 0; i < n; i++) {
    for (j = 0; j < m; j++) {
      fprintf (stderr, "%4.2f ", array[i + n * j]);
    }
    fprintf (stderr, "\n");
  }
  fprintf (stderr, "\n");

}
#endif

