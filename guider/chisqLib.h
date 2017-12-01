/* chisqLib.h      02/17/1999      NOAO    */

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

#ifndef __CHISQLIB_H
#define __CHISQLIB_H

#define AMAX	5

extern double chisq (int * ix, int *iy, double *z, double *e, int n, double *a,
              double *acc, double *alim, int *it);
extern void ellipse (double b5, double *area, double *amaj);

#endif
