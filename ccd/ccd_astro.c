/* Written May 29, 1999 by Ken Sills */
/* Generic routines used in the ap7 api files */

#include <math.h>

void  precess(double J2000, double jd, double *ra, double *dec);
void range (double *v, double r);
void mjd_year (double mjd, double *yr); 

#define degrad(x)       ((x)*PI/180.)
#define raddeg(x)       ((x)*180./PI)
#define hrdeg(x)        ((x)*15.)
#define deghr(x)        ((x)/15.)
#define hrrad(x)        degrad(hrdeg(x))
#define radhr(x)        deghr(raddeg(x))

/* convenient forms of trig functions for degree arguments */

#define DCOS(x)         cos(degrad(x))
#define DSIN(x)         sin(degrad(x))
#define DASIN(x)        raddeg(asin(x))
#define DATAN2(y,x)     raddeg(atan2((y),(x)))

/* starting point for MJD calculations */

#define MJD0  2415020.0               /* 1900 Jan 0.5 (noon)   */
#define J2000 (2451545.0 - MJD0)      /* let compiler optimise */
#define MJDF0 2400000.5               /* Recommended FITS/OGIP zero for MJD */
#define PI              3.141592653589793

/* other stuff */

#define SIDRATE 0.9972695677    /* ratio of synodic to sidereal rate */
#define SPD     (24.0*3600.0)   /* seconds per day */

int to_uppercase(char *keyword, int nchar)
{
  /* forces keyword of length nchar to all uppercase
     passes it back in keyword */

  char *pos;
  
  for (pos =  keyword; pos < (keyword + nchar) ; pos++) {
    *pos = toupper(*pos);
  }

  return(nchar);
}



/***************************************************************************
 * 
 * hjd - return the Heliocentric Julian Date given geocentric JD and
 *       object RA,Dec (J2000)
 *
 * Arguments:
 *   jd (double) - geocentric julian date
 *   dra (double) - object RA in decimal hours, equinox J2000
 *   ddec (double) - object DEC in decimal degrees, equinox J2000
 *
 * HJD computes the difference in light travel time between the Earth
 * and the Sun.  The correction (deltajd) is subtracted from the
 * geocentric jd to give the heliocentric jd
 *
 * Based largely on algorithms from Duffet-Smith and the usual run
 * of code that has been circulating around for years.  This one was
 * attributed to "RLM", whoever that is.
 *
 * calls precess()
 *
 ***************************************************************************/

double hjd (double jd, double dra, double ddec)
{
  double e;	       /* obliquity of ecliptic */
  double n;	       /* day number */
  double g;	       /* solar mean anomaly */
  double L;	       /* solar ecliptic longitude */
  double l;	       /* mean solar ecliptic longitude */
  double R;	       /* sun distance, AU */
  double X, Y;	       /* equatorial rectangular solar coords */
  double cdec, sdec;
  double cra, sra;
  double deltajd;      /* HJD = JD - deltajd */

  double ra, dec;    /* RA, Dec in radians */

  /* convert RA and Dec to radians */

  ra = radhr(dra);
  dec = raddeg(ddec);

  /*
   * precess from J2000 (input equinox) to the observation equinox,
   * where times are given in MJD
   */

  precess((double)J2000, (double)(jd - MJD0), &ra, &dec);

  /* do it to it */

  cdec = cos(dec);
  sdec = sin(dec);
  cra = cos(ra);
  sra = sin(ra);

  n = jd - 2451545.0;	/* use epoch 2000 */
  e = degrad(23.439 - 0.0000004*n);
  g = degrad(357.528) + degrad(0.9856003)*n;
  L = degrad(280.461) + degrad(0.9856474)*n;
  l = L + degrad(1.915)*sin(g) + degrad(0.02)*sin(2.0*g);
  R = 1.00014 - 0.01671*cos(g) - 0.00014*cos(2.0*g);
  X = R*cos(l);
  Y = R*cos(e)*sin(l);
  
  deltajd = 0.0057755 * (cdec*cra*X + (cdec*sra + tan(e)*sdec)*Y);

  return(jd-deltajd);

}

/***************************************************************************
 * 
 * cal_mjd - convert UT calendar date to modified Julian Date
 * given a UT date in months, days, & years, return the modified Julian date 
 *
 */

void cal_mjd (mn, dy, yr, mjd)
     int mn, yr;
     double dy;
     double *mjd;
{
  static double last_mjd, last_dy;
  static int last_mn, last_yr;
  int b, d, m, y;
  long c;
  
  if (mn == last_mn && yr == last_yr && dy == last_dy) {
    *mjd = last_mjd;
    return;
  }

  m = mn;
  y = (yr < 0) ? yr + 1 : yr;
  if (mn < 3) {
    m += 12;
    y -= 1;
  }

  if (yr < 1582 || (yr == 1582 && (mn < 10 || (mn == 10 && dy < 15))))
    b = 0;
  else {
    int a;
    a = y/100;
    b = 2 - a + a/4;
  }

  if (y < 0)
    c = (long)((365.25*y) - 0.75) - 694025L;
  else
    c = (long)(365.25*y) - 694025L;
  
  d = 30.6001*(m+1);

  *mjd = b + c + d + dy - 0.5;

  last_mn = mn;
  last_dy = dy;
  last_yr = yr;
  last_mjd = *mjd;
}


/***************************************************************************
 *
 * precess() - precess coordinates between two MJD equinoxes 
 *
 * Based on hiprec_precess(), which is Copyright (c) 1990 by Craig 
 * Counterman. All rights reserved.
 *
 * This software may be redistributed freely, not sold.
 * This copyright notice and disclaimer of warranty must remain
 *    unchanged. 
 *
 * No representation is made about the suitability of this
 * software for any purpose.  It is provided "as is" without express or
 * implied warranty, to the extent permitted by applicable law.
 *
 * Rigorous precession. From Astronomical Ephemeris 1989, p. B18
 *
 * 96-06-20 Hayo Hase <hase@wettzell.ifag.de>: theta_a corrected
 *
 * 98-07-09 R. Pogge <pogge@astronomy.ohio-state.edu>: modified for
 * inclusion in ariel.c for SAAO.
 *
 * corrects ra and dec, both in radians, for precession from epoch 1 to
 * epoch 2.  the epochs are given by their modified JDs, mjd1 and mjd2,
 * respectively.  N.B. ra and dec are modifed IN PLACE. 
 *
 * Calls range(), mjd_year(), 
 */

void precess(mjd1, mjd2, ra, dec)
     double mjd1, mjd2;	/* initial and final epoch modified JDs */
     double *ra, *dec;	/* ra/dec for mjd1 in, for mjd2 out */
{
  static double last_mjd1 = -213.432, last_from;
  static double last_mjd2 = -213.432, last_to;
  double zeta_A, z_A, theta_A;
  double T;
  double A, B, C;
  double alpha, delta;
  double alpha_in, delta_in;
  double from_equinox, to_equinox;
  double alpha2000, delta2000;

  /* convert mjds to years */

  if (last_mjd1 == mjd1)
    from_equinox = last_from;
  else {
    mjd_year (mjd1, &from_equinox);
    last_mjd1 = mjd1;
    last_from = from_equinox;
  }

  if (last_mjd2 == mjd2)
    to_equinox = last_to;
  else {
    mjd_year (mjd2, &to_equinox);
    last_mjd2 = mjd2;
    last_to = to_equinox;
  }

  /* convert coords in rads to degs */

  alpha_in = raddeg(*ra);
  delta_in = raddeg(*dec);

  /* precession progresses about 1 arc second in .047 years */
  /* From from_equinox to 2000.0 */

  if (fabs((double)(from_equinox-2000.0)) > .04) {

    T = (from_equinox - 2000.0)/100.0;
    zeta_A  = 0.6406161* T + 0.0000839* T*T + 0.0000050* T*T*T;
    z_A     = 0.6406161* T + 0.0003041* T*T + 0.0000051* T*T*T;
    theta_A = 0.5567530* T - 0.0001185* T*T - 0.0000116* T*T*T;
    
    A = DSIN(alpha_in - z_A) * DCOS(delta_in);
    B = DCOS(alpha_in - z_A) * DCOS(theta_A) * DCOS(delta_in)
                             + DSIN(theta_A) * DSIN(delta_in);
    C = -DCOS(alpha_in - z_A) * DSIN(theta_A) * DCOS(delta_in)
                              + DCOS(theta_A) * DSIN(delta_in);
    
    alpha2000 = DATAN2(A,B) - zeta_A;
    range (&alpha2000, 360.0);
    delta2000 = DASIN(C);

  } else {

    alpha2000 = alpha_in;
    delta2000 = delta_in;

  };

  /* From 2000.0 to to_equinox */

  if (fabs (to_equinox - 2000.0) > .04) {

    T = (to_equinox - 2000.0)/100.0;
    zeta_A  = 0.6406161* T + 0.0000839* T*T + 0.0000050* T*T*T;
    z_A     = 0.6406161* T + 0.0003041* T*T + 0.0000051* T*T*T;
    theta_A = 0.5567530* T - 0.0001185* T*T - 0.0000116* T*T*T;
    
    A = DSIN(alpha2000 + zeta_A) * DCOS(delta2000);
    B = DCOS(alpha2000 + zeta_A) * DCOS(theta_A) * DCOS(delta2000)
      - DSIN(theta_A) * DSIN(delta2000);
    C = DCOS(alpha2000 + zeta_A) * DSIN(theta_A) * DCOS(delta2000)
      + DCOS(theta_A) * DSIN(delta2000);
    
    alpha = DATAN2(A,B) + z_A;
    range(&alpha, 360.0);
    delta = DASIN(C);

  } else {

    alpha = alpha2000;
    delta = delta2000;

  };
  
  *ra = degrad(alpha);
  *dec = degrad(delta);

}

/***************************************************************************
 *
 * range(v,r) - ensures that v is in the range 0 <= v < r.
 *
 */

void range (v, r)
     double *v, r;
{
  *v -= r*floor(*v/r);
}


/***************************************************************************
 *
 * mjd_cal() - convert modified Julian Date to Calendar Date
 * 
 * given the modified Julian date, return the calendar date in months, days,
 * and year
 *
 */

void mjd_cal (mjd, mn, dy, yr)
     double mjd;
     int *mn, *yr;
     double *dy;
{
  static double last_mjd, last_dy;
  static int last_mn, last_yr;
  double d, f;
  double i, a, b, ce, g;

  /* MJD 0 = noon the last day of 1899. */

  if (mjd == 0.0) {
    *mn = 12;
    *dy = 31.5;
    *yr = 1899;
    return;
  }
  
  if (mjd == last_mjd) {
    *mn = last_mn;
    *yr = last_yr;
    *dy = last_dy;
    return;
  }
  
  d = mjd + 0.5;
  i = floor(d);
  f = d-i;
  if (f == 1) {
    f = 0;
    i += 1;
  }

  if (i > -115860.0) {
    a = floor((i/36524.25)+.99835726)+14;
    i += 1 + a - floor(a/4.0);
  }

  b = floor((i/365.25)+.802601);
  ce = i - floor((365.25*b)+.750001)+416;
  g = floor(ce/30.6001);
  *mn = g - 1;
  *dy = ce - floor(30.6001*g)+f;
  *yr = b + 1899;

  if (g > 13.5)
    *mn = g - 13;
  if (*mn < 2.5)
    *yr = b + 1900;
  if (*yr < 1)
    *yr -= 1;

  last_mn = *mn;
  last_dy = *dy;
  last_yr = *yr;
  last_mjd = mjd;
}

/***************************************************************************
 *
 * mjd_year - convert MJD to decimal UT year
 *
 * Calls mjd_cal() & cal_mjd() to do the dirty work
 *
 */

void mjd_year (mjd, yr)
     double mjd;
     double *yr;
{
  static double last_mjd, last_yr;
  int m, y;
  double d;
  double e0, e1;	/* mjd of start of this year, start of next year */

  if (mjd == last_mjd) {
    *yr = last_yr;
    return;
  }

  mjd_cal (mjd, &m, &d, &y);
  if (y == -1) y = -2;
  cal_mjd (1, 1.0, y, &e0);
  cal_mjd (1, 1.0, y+1, &e1);
  *yr = y + (mjd - e0)/(e1 - e0);
  
  last_mjd = mjd;
  last_yr = *yr;
}

/***************************************************************************
 *
 * year_mjd() - Converts decimal UT year to MJD
 *
 * calls cal_mjd() to do the dirty work
 * 
 */

void year_mjd (y, mjd)
     double y;
     double *mjd;
{
  double e0, e1;	/* mjd of start of this year, start of next year */
  int yf = floor (y);
  if (yf == -1) yf = -2;

  cal_mjd (1, 1.0, yf, &e0);
  cal_mjd (1, 1.0, yf+1, &e1);
  *mjd = e0 + (y - yf)*(e1-e0);
}
