/** 
 * \file andor_tcl.h
 * \brief Tcl wrappers for the main camera control and data acquisition functions
 * 
 * This class provides a minimal interface for USB device control
 */


#ifndef __ANDOR_TCL__
#define __ANDOR_TCL__

#include "atmcdLXd.h"
#include <sys/time.h>
#include <pthread.h>
#include <time.h>
#include <math.h>
//#include <clock.h>
#include <stdint.h>
#include <stdbool.h>
#define PIXMULT			20

/* Camera Defaults */

#define DFT_ANDOR_EXPOSURE_TIME         0.001
#define DFT_ANDOR_SHUTTER               ANDOR_SHUTTER_CLOSE
#define DFT_ANDOR_HBIN                  1
#define DFT_ANDOR_VBIN                  1
#define DFT_ANDOR_HSTART                1
#define DFT_ANDOR_HEND                  90
#define DFT_ANDOR_VSTART                1
#define DFT_ANDOR_VEND                  90
#define DFT_ANDOR_AMPLIFIER             ANDOR_CCD
#define DFT_ANDOR_PREAMP_GAIN           2
#define DFT_ANDOR_EM_GAIN               30
#define DFT_ANDOR_TEMPERATURE           -50
#define DFT_ANDOR_VERTICAL_SPEED        2
#define DFT_ANDOR_CCD_HORIZONTAL_SPEED  0
#define DFT_ANDOR_EMCCD_HORIZONTAL_SPEED 0
#define DFT_ANDOR_EM_ADVANCED           0
#define DFT_ANDOR_CAMERA_LINK           1
#define WFS_PERIODIC                    1

#define ANDOR_NUM_READMODES                     5
#define ANDOR_READMODE_FULL_VERTICAL_BINNING    0
#define ANDOR_READMODE_MULTI_TRACK              1
#define ANDOR_READMODE_RANDOM_TRACK             2
#define ANDOR_READMODE_SINGLE_TRACK             3
#define ANDOR_READMODE_IMAGE                    4

#define ANDOR_NUM_ACQMODES                      5
#define ANDOR_ACQMODE_SINGLE_SCAN               1
#define ANDOR_ACQMODE_ACCUMULATE                2
#define ANDOR_ACQMODE_KINETICS                  3
#define ANDOR_ACQMODE_FAST_KINETICS             4
#define ANDOR_ACQMODE_RUN_TILL_ABORT            5
#define ANDOR_NUM_SHUTTERS                      3
#define ANDOR_SHUTTER_AUTO                      0
#define ANDOR_SHUTTER_OPEN                      1
#define ANDOR_SHUTTER_CLOSE                     2

#define ANDOR_NUM_AMPLIFIERS                    2
#define ANDOR_EMCCD                             0
#define ANDOR_CCD                               1

#define ANDOR_NUM_TEMPERATURE_STATUS            5
#define ANDOR_TEMPERATURE_OFF                   0
#define ANDOR_TEMPERATURE_STABILIZED            1
#define ANDOR_TEMPERATURE_NOT_REACHED           2
#define ANDOR_TEMPERATURE_DRIFT                 3
#define ANDOR_TEMPERATURE_NOT_STABILIZED        4

/* macro */

#define min(a,b)                        (((a)<(b))?(a):(b))
#define max(a,b)                        (((a)>(b))?(a):(b))


extern bool verbose;
at_u32 *image_data;
extern bool save_fits;
extern int number_of_processed_frames;
extern float **data_frame;
extern float **dark_frame;
extern float **calc_dark_frame;
extern int dark_frame_num;
extern float dark_frame_mean;
extern float dark_frame_stddev;
extern float **raw_frame;
extern float **sum_frame;
extern int sum_frame_num;
extern float data_threshold; /* For data in terms of STDDEV of dark frame. */

typedef struct {
        int hbin;       /* Number of pixels binned horizontally */
        int vbin;       /* NUmber of pixels binned vertically */
        int hstart;     /* Start column (1 is first, inclusive) */
        int hend;       /* End column (1 is first, inclusive) */
        int vstart;     /* Start column (1 is first, inclusive) */
        int vend;       /* Start column (1 is first, inclusive) */
} andor_image;

typedef struct {
        float exposure_time;    /* Exp time in seconds */
        float temperature;      /* Current temperature */
        float cam_frames_per_second; /* FPS for camera */
        float missed_frames_per_second; /* FPS for USB missing */
        float usb_frames_per_second; /* FPS for USB port */
        float camlink_frames_per_second; /* FPS for camlink port */
        float processed_frames_per_second; /* FPS for camlink port */
        float preamp_gain;      /* Gain of preamp */
        float vertical_speed;   /* Current Vertical Speed */
        float horizontal_speed[ANDOR_NUM_AMPLIFIERS];  /* Current Horizontal Speed */
        andor_image image; /* Readout area for the chip */
        int read_mode;          /* One of the readmodes */
        int acquisition_mode;   /* One of the acqmodes */
        int width;              /* Of the full detector */
        int height;             /* Of the full detector */
        int shutter;            /* State of shutter */
        int amplifier;          /* Output amplifier being used */
        int npixx;              /* Number of pixels in X */
        int npixy;              /* Number of pixels in Y */
        int npix;               /* Total number of pixels */
        int minimum_temperature;/* Minimum temperature in Deg C */
        int maximum_temperature;/* Maxnimum temperature in Deg C */
        int target_temperature; /* Target temperature in DC */
        int temperature_status; /* One of Defines above */
        int running;            /* True if camera is running */
        int usb_running;        /* True if USB data collection is running */
        int camlink_running;    /* True if USB data collection is running */
        int num_preamp_gains;   /* How many preamp gains are there? */
        int preamp_gain_index;  /* Which preamp gain index are we using? */
        int em_advanced;        /* Are the higher gains available? */
        int minimum_em_gain;    /* Minimum EM gain */
        int maximum_em_gain;    /* Maximum EM gain */
        int em_gain;            /* Current EM gain */
        int num_vertical_speeds; /* Number of vertical speeds possible */
        int vertical_speed_index; /* Current vertical speed index */
        int num_horizontal_speeds[ANDOR_NUM_AMPLIFIERS];
                                  /* Number of vertical speeds possible */
        int horizontal_speed_index[ANDOR_NUM_AMPLIFIERS];
                               /* Current vertical speed index */
} andor_setup;

/* Globals */


/** 
 * \brief Open a connection to an Andor camera
 * \param iSelectedCamera
 * \param image
 * \param preamp_gain
 * \param vertical_speed
 * \param ccd_horizontal_speed
 * \param em_horizontal_speed
 *
 */
int andor_open(int iSelectedCamera, andor_image image,
               int preamp_gain, int vertical_speed, int ccd_horizontal_speed,
                int em_horizontal_speed);
/** 
 * \brief Configure camera with "setup" parameters
 * \param setup Geometry and readout parameters
 */
int andor_setup_camera(andor_setup setup);
int andor_close(void);
int andor_send_setup(void);
int andor_set_acqmode(int acqmode);
int andor_set_exptime(float exptime);
int andor_set_shutter(int exptime);
int andor_set_shutter(int exptime);
int andor_set_image(andor_image image);
int andor_set_crop_mode(int heigth, int width, int vbin, int hbin);
int andor_set_amplifier(int amplifier);
int andor_start_acquisition(void);
int andor_abort_acquisition(void);
int andor_get_status(void);
int andor_wait_for_data(int timeout);
int andor_wait_for_idle(int timeout);
int andor_get_acquired_data(void);
int andor_set_temperature(int temperature);
int andor_get_temperature(void);
int andor_cooler_on(void);
int andor_cooler_off(void);
int andor_get_preamp_gain(int index, float *gain);
int andor_set_preamp_gain(int gain);
int andor_set_em_advanced(int em_advanced);
int andor_set_em_gain(int gain);
int andor_get_total_number_images_acquired(void);
int andor_get_oldest_image(void);
int andor_get_vertical_speed(int index, float *speed);
int andor_set_vertical_speed(int index);
int andor_get_horizontal_speed(int type, int index, float *speed);
int andor_set_horizontal_speed(int type, int index);
int andor_set_camera_link(int onoff);
int andor_get_single_frame(void);

/* wfs_andor_usb_data.c */

int andor_start_usb_thread(void);
int andor_stop_usb_thread(void);
int andor_start_usb(void);
int andor_stop_usb(void);
void *andor_usb_thread(void *arg);
void lock_usb_mutex(void);
void unlock_usb_mutex(void);
/* wfs_data.c */

void process_data(long time_stamp);
/*
int message_wfs_take_background(struct smessage *message);
int message_wfs_reset_background(struct smessage *message);
int message_wfs_set_threshold(struct smessage *message);
int message_wfs_set_num_frames(struct smessage *message);
int message_wfs_save_data(struct smessage *message);
 */

void complete_data_record(void);

#endif
