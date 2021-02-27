#define MAXROI 16
#define DEFROISIZE 32
#define MAXLEAK 64
#define MAXMARKER 64
#define FIBERSPERFOP   (7)
#define AOIXSIZE       (75)
#define AOIYSIZE       (75)
#define HALFCELLX      (int)((double)AOIXSIZE/2.0)
#define HALFCELLY      (int)((double)AOIYSIZE/2.0)
#define FBOXSIZEX      (14)
#define FBOXSIZEY      (14)
#define FIBERSPERFOP   (7)
#define NUMBEROFFOPS   (12)
#define GUIDEFOP       (1)
#define REFFOP         (2)
#define MONITORFOP     (3)
#define FOPNOTTRACKING    (0)
#define FOPACTIVE       (1)
#define FOPTRACKING       (1)
#define FOPGUIDERRESET    (2)
#define FOPAUTOFOCUS      (3)
#define FOPFOCUSCOMPLETE  (4)


#define ACTIVE         (1)
#define INACTIVE       (2)
#define ROTACTIVE      (1)
#define ROTINACTIVE    (2)

enum DisplayType {
	SDL_Display = 0,	/* SDL , setenv SDL_VIDEODEVICE controls type */
	CDL_Display,		/* DS9/Ximtool , setenv IMTDEV */
	VNC_Display,		/* VNC server */
	RVD_Display,		/* RealPlayer streaming video */
	MJPEG_Display,		/* MJPEG streaming video */
	CMPR_Display		/* Bitplane compressed streaming */
};

	
enum CentroidAlgorithm { 
	CHISQ_METHOD = 0,
	CMASS_METHOD,
	QUADR_METHOD,
	GAUSS_METHOD,
	CMOMENT_METHOD,
	FOP1_METHOD,
	FOP2_METHOD,
	FOP3_METHOD,
	FOP4_METHOD,
	FOP5_METHOD
};

typedef struct {

  int xc;
  int yc;
  int xs;
  int ys;
  int dispx;
  int dispy;
  double zoom;
  int type;
  double lockx;
  double locky;
  double gain;
  double weight;
  int nsaturated;
  double background;
  double mean;
  double xcorr;
  double ycorr;
  double fmax;
  double fmin;
  double fwhm;
  int histogram[256];
} BOX;

typedef struct {

  int x;
  int y;
  int col;
  int flash;
  int shape;

} MARKER;

typedef struct {
  int framewidth;
  int frameheight;
  int numroi;
  BOX roi[MAXROI];
  int leak;
  int backsub;
  int flatfield;
  int algorithm;
  double losthresh;
  int nsaturated;
  double skylevel;
  double framebias;
  double theta;
  int state;
} GUIDER;

typedef struct { 
  int x[16];
  int y[16];
  int mode;
  int status;
  int type;
  int nsaturated;
  double fmin;
  double fmax;
  double fmean;
  double fnormal[16];
  double fmeanint[16];
  double xc;
  double yc;
} FOP;

typedef struct {

  int x;
  int y;
  int col;
  int *font;
  char text[128];

} SCREENTEXT;















