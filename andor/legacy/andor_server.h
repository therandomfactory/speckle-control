/************************************************************************/
/* wfs_server.h								*/
/*                                                                      */
/* General Header File.							*/
/************************************************************************/
/*                                                                      */
/*                    CHARA ARRAY CLIENT/SERVER				*/
/*                 Based on the CHARA User Interface			*/
/*                 Based on the SUSI User Interface			*/
/*		In turn based on the CHIP User interface		*/
/*                                                                      */
/*            Center for High Angular Resolution Astronomy              */
/*              Mount Wilson Observatory, CA 91001, USA			*/
/*                                                                      */
/* Telephone: 1-626-796-5405                                            */
/* Fax      : 1-626-796-6717                                            */
/* email    : theo@@chara.gsu.edu                                       */
/* WWW      : http://www.chara.gsu.edu			                */
/*                                                                      */
/* (C) This source code and its associated executable                   */
/* program(s) are copyright.                                            */
/*                                                                      */
/************************************************************************/
/*                                                                      */
/* Author : Theo ten Brummelaar                          		*/
/* Date   : Aug 2012							*/
/************************************************************************/

#ifndef __WFS_CLISERV__
#define __WFS_CLISERV__

#define SERVER
#undef __CLISERV__
#include <stdint.h>
#include <time.h>
#include <math.h>
#include <atmcdLXd.h>
#include <zlib.h>
#include <pthread.h>
#include <stdbool.h>
#include "jouflu.h"

#define NOERROR 0
#define ERROR -1
#define MESSAGE 1
#define FATAL -999
#define NUM_SCOPES 1
#define TRUE 1
#define FALSE 0

/* Which camera do we use? */

#define WFS_CAMERA 0

/* Camera Defaults */

#define DFT_ANDOR_EXPOSURE_TIME		0.001
#define DFT_ANDOR_SHUTTER 		ANDOR_SHUTTER_CLOSE
#define DFT_ANDOR_HBIN			1
#define DFT_ANDOR_VBIN			1
#define DFT_ANDOR_HSTART		1
#define DFT_ANDOR_HEND			90
#define DFT_ANDOR_VSTART		1
#define DFT_ANDOR_VEND			90
#define DFT_ANDOR_AMPLIFIER		ANDOR_CCD
#define DFT_ANDOR_PREAMP_GAIN		2
#define DFT_ANDOR_EM_GAIN		30
#define DFT_ANDOR_TEMPERATURE		-50
#define DFT_ANDOR_VERTICAL_SPEED	2
#define DFT_ANDOR_CCD_HORIZONTAL_SPEED	0
#define DFT_ANDOR_EMCCD_HORIZONTAL_SPEED 0
#define DFT_ANDOR_EM_ADVANCED		0
#define DFT_ANDOR_CAMERA_LINK		1

#define WFS_PERIODIC			1

#define REF_CENTROID_FILENAME          "reference_centroids.dat"

#define	DFT_DENOM_CLAMP_SUBAP		6
#define	DFT_MIN_FLUX_SUBAP		10
#define	DFT_CLAMP_FLUX_SUBAP		-1000

#define MAX_MIRROR_DELTA		0.1
#define MAX_MIRROR			1.75


#define MIR_CALIB			6.8 /* From old system */
#define DET_CALIB			2.1 /* From old system */

#define DEFAULT_GAIN_X			(-0.15)
#define DEFAULT_DAMP_X			(0.25)
#define DEFAULT_GAIN_Y			(-0.15)
#define DEFAULT_DAMP_Y			(0.25)

/*Shack Hartmann rotation stage */

#define TDC                             "/dev/ttyUSB1"
#define TDC_BRATE                       B115200
#define DFT_TDC_MAX_VEL                 5.
#define DFT_TDC_ACCEL                   2.
#define DFT_TDC_LED_ACT                 FALSE

/* macro */

#define min(a,b)                        (((a)<(b))?(a):(b))
#define max(a,b)                        (((a)>(b))?(a):(b))

extern bool verbose;
extern char wfs_name[256];
extern int  scope_number;
extern struct s_wfs_andor_setup andor_setup;
extern at_u16 *image_data;
extern bool save_fits;
extern bool use_cameralink;
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
extern struct s_wfs_tdc_status tdc_status;
extern struct s_wfs_subap_centroids subap_centroids_mean;
extern struct s_wfs_subap_centroids subap_centroids_ref;
extern struct s_wfs_subap_centroids subap_centroids_offset;
extern struct s_wfs_subap_centroids subap_centroids;
extern struct s_wfs_clamp_fluxes clamp_fluxes;
extern struct s_wfs_tiptilt wfs_tiptilt;
extern int num_mean_aberrations;
extern struct s_wfs_aberrations wfs_mean_aberrations;
extern struct s_wfs_aberrations wfs_aberrations;
extern bool set_subap_centroids_ref;
extern struct s_wfs_tiptilt_modulation wfs_tiptilt_modulation;
extern struct s_wfs_tiptilt_servo wfs_tiptilt_servo;
extern bool fake_mirror;
extern float max_radius;
extern bool new_mean_aberrations;
extern bool send_tiptilt_servo;
extern bool include_old_S2_code;


/* Prototypes */

/* wfs_server.c */

int main(int argc, char **argv);
void close_function(void);
void print_usage_message(char *name);

int andor_open(int iSelectedCamera, s_wfs_andor_image image,
	       int preamp_gain, int vertical_speed, int ccd_horizontal_speed,
		int em_horizontal_speed);
int andor_setup_camera(s_wfs_andor_setup setup);
int andor_close(void);
int andor_send_setup(void);
int andor_set_acqmode(int acqmode);
int andor_set_exptime(float exptime);
int andor_set_shutter(int exptime);
int andor_set_image(s_wfs_andor_image image);
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
void complete_data_record(void);
#endif
