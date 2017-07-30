/************************************************************************/
/* jouflu.h								*/
/*                                                                      */
/* Header file for the JOUFLU.						*/
/************************************************************************/
/*                                                                      */
/*     Center for High Angular Resolution Astronomy                     */
/* Georgia State University, Atlanta GA 30303-3083, U.S.A.              */
/*                                                                      */
/*                                                                      */
/* Telephone: 1-626-796-5405                                            */
/* Fax      : 1-626-796-6717                                            */
/* email    : theo@chara.gsu.edu                                        */
/* WWW      : http://www.chara.gsu.edu/~theo/theo.html                  */
/*                                                                      */
/* (C) This source code and its associated executable                   */
/* program(s) are copyright.                                            */
/*                                                                      */
/************************************************************************/
/*                                                                      */
/* Author : Theo and Nic                                                */
/* Date   : Nov 2011 	                                                */
/************************************************************************/

#ifndef __JOUFLU__
#define __JOUFLU__

#include <atmcdLXd.h>
#include <sys/time.h>
#include <pthread.h>
#include <zlib.h>
#include <fitsio.h>
#include <time.h>
#include <pthread.h>
#include <math.h>
//#include <clock.h>
#include <stdint.h>
#include <stdbool.h>

#define PIXMULT			20
#define FATAL -999

/* Which camera do we use? */

#define WFS_CAMERA 0

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

//#define u32  //NJS added to use 32bit instead of 16

extern bool verbose;
extern char wfs_name[256];
extern int  scope_number;
//NJS
#ifdef u32
extern at_u32 *image_data;
#else
extern at_u16 *image_data;
#endif
extern at_u16 *image_data;
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

/* Zaber */

#define ZABER_SERVER		"ZABER_1"
//#define ZABER_JOUFLU_A		"JOUFLU_A"
//#define ZABER_JOUFLU_B		"JOUFLU_B"
#define ZABER_JOUFLU_A		"FLUOR_A"
#define ZABER_JOUFLU_B		"FLUOR_B"
#define NUM_ZABER_POSITIONS	4
#define ZABER_FTS_OUT_OUT	0
#define ZABER_FTS_OUT_DICHROIC	1
#define ZABER_FTS_IN_OUT	2
#define ZABER_FTS_IN_DICHROIC	3
#define ZABER_DEFAULT_POS	ZABER_FTS_OUT_OUT
#define DEFAULT_ZABER_STEP_SIZE	40
#define NUM_ZABER_TYPES		2
#define ZABER_A			0
#define ZABER_B			1
#define LOCAL_ZABER_CONFIG_FILE	"jzaber.cfg"
#define NUM_ZABER_CONFIGS	3
#define LOCAL_CONFIG_FILE	0
#define ETC_CONFIG_FILE		1
#define NUMBER_OF_ZABERS	4
#define ZABER_TIME_OUT  	5
/*
 *  * Maximum number of Zaber units. 
 *   * Note that NUM_ZABER was defined in chara_messages.h.
 *    * This is dumb as it locks this number into a global configuration file ;-(
 *     */

#define MAX_ZABER               258

#define ZABER_ALL_UNITS         0x00

/* commands: */

#define ZABER_RESET             0x00
#define ZABER_HOME              0x01
#define ZABER_RENUMBER          0x02
#define ZABER_MOVE_ABS          0x14
#define ZABER_MOVE_REL          0x15
#define ZABER_MOVE_CONST_SPEED  0x16
#define ZABER_STOP              0x17
#define ZABER_RESTORE_FACT_SET  0x24
#define ZABER_SET_MODE          0x28
#define ZABER_SET_STEP_T        0x29
#define ZABER_SET_TARGET_STEP_T 0x2a
#define ZABER_SET_ACCELERATION  0x2b
#define ZABER_SET_MAX_RANGE_TRV 0x2c
#define ZABER_SET_CURRENT_POS   0x2d
#define ZABER_SET_MAX_REL_MOVE  0x2e
#define ZABER_SET_ALIAS         0x30
#define ZABER_RETURN_DEVICE_ID  0x32
#define ZABER_RETURN_FIRMWARE_V 0x33
#define ZABER_POWER_VOLTAGE     0x34
#define ZABER_RETURN_SETTING    0x35
#define ZABER_RETURN_POSITION   0x3c

/* modes */

#define ZABER_DISABLE_AUTO_REPLY            1
#define ZABER_ENABLE_ANTI_BACKLASH          2 
#define ZABER_ENABLE_ANTI_STICKTION         4
#define ZABER_DISABLE_POTENTIOMETER         8
#define ZABER_ENABLE_POSITION_TRACKING      16
#define ZABER_DISABLE_MAN_POSITION_TRACKING 32
#define ZABER_ENABLE_LOGIC_CHAN_COMM_MODE   64
#define ZABER_HOME_STATUS                   128

/* replies */

#define ZABER_CONSTANT_SPEED_POSITION_TRACKING 8
#define ZABER_MANUAL_POSITIN_CHANGE 10
#define ZABER_POWER_SUPPLY_OUT_OF_RANGE 14
#define ZABER_COMMAND_DATA_OUT_OF_RANGE 255

/* Maximum motion */

#define ZABER_MIN_POS   (-65536)
#define ZABER_MAX_POS   (60671)
struct zaber_message {
        unsigned char unit;
        unsigned char type;
        int data;
};

struct ZABER_POSITIONS {
        long input;
        long A;
        long B;
	long ext;
};

struct RESPONSE {
	char *unit;
	int axis;
	char *errorchk;
	char *status;
	char *spacer;
	long data;
};

typedef struct  {
        int hbin;       /* Number of pixels binned horizontally */
       int vbin;       /* NUmber of pixels binned vertically */
        int hstart;     /* Start column (1 is first, inclusive) */
        int hend;       /* End column (1 is first, inclusive) */
        int vstart;     /* Start column (1 is first, inclusive) */
       int vend;       /* Start column (1 is first, inclusive) */
             } s_wfs_andor_image;

typedef struct s_wfs_andor_setup {
        float exposure_time;    /* Exp time in seconds */
        float temperature;      /* Current temperature */
        float cam_frames_per_second; /* FPS for camera */
        float missed_frames_per_second; /* FPS for USB missing */
        float usb_frames_per_second; /* FPS for USB port */
        float camlink_frames_per_second; /* FPS for camlink port */
        float processed_frames_per_second; /* FPS for camlink port */
        float preamp_gain;      /* Gain of preamp */
        float vertical_speed;   /* Current Vertical Speed */
        float horizontal_speed[ANDOR_NUM_AMPLIFIERS];
                                /* Current Horizontal Speed */
        s_wfs_andor_image image; /* Readout area for the chip */
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
} s_wfs_andor_setup;

s_wfs_andor_setup andor_setup;


typedef struct  AP_TIME_STRUCT
        {
                char            sign; /* -1 or +1 */
                int      hrs;
                int      min;
                int      sec;
                int      tick;

        } ap_time_struct;       /* Structure used to send times */

/* Globals */

extern bool skip_zabers;
extern bool skip_cameras;
extern int zaber_server;
extern int  zaber_a_x[NUM_ZABER_POSITIONS];
extern int  zaber_a_y[NUM_ZABER_POSITIONS];
extern int  zaber_b_x[NUM_ZABER_POSITIONS];
extern int  zaber_b_y[NUM_ZABER_POSITIONS];
extern char *zaber_position[NUM_ZABER_POSITIONS+1];
extern char *zaber_types[NUM_ZABER_TYPES+1];
extern int zaber_spot;
extern int jouflu_a_axis_one;
extern int jouflu_a_axis_two;
extern int jouflu_b_axis_one;
extern int jouflu_b_axis_two;
extern struct JZABER_LIST jouflu_zaber_list;
extern char init_filename[256];
extern int  zaber_step_size;
extern int zaber_local_config;
extern char pi_name[5000];
extern char program_name[5000];
extern int num_zaber;
extern struct SZABER_LIST zaber_list;
extern bool bypass_hardware;
extern char init_filename[256];
extern char *zaber_units[NUMBER_OF_ZABERS+2];
//extern int zaberpos;
extern struct ZABER_POSITIONS zaberpos;

/* jouflu.c */

int main(int argc, char **argv);
void print_usage_message(char *name);
void jouflu_open_function(void);
void jouflu_close_function(void);
int wfs_periodic_job(void);

/* jouflu_background.c */

void setup_background_jobs(void);
int jouflu_top_job(void);
int linux_time_status(void);
int zaber_status(void);

/* jouflu_control.c */

int set_pi_name(int argc, char **argv);
int set_program_name(int argc, char **argv);

/* jouflu_zabers.c */

int scan_init_file(int);
int call_scan_init_file(int argc, char **argv);
int write_init_file(void);
int call_write_init_file(int argc, char **argv);
int move_zaber_default(int);
int call_move_zaber_default(int argc, char **argv);
int set_zaber_position_default(int);
int call_set_zaber_position_default(int argc, char **argv);
int set_zaber_step_size(int);
int call_set_zaber_step_size(int argc, char **argv);
void init_zaber_pos(void);
void set_port_name(char *name);
int open_zaber_port(void);
int call_open_zaber_port(int argc, char **argv);
void set_blocking(int zaber_portfd, int should_block);
long zaber_get_response(void);
void zaber_flush(void);
int zaber_renumber(void);
int call_zaber_renumber(int argc, char **argv);
int close_zaber_port(void);
int call_close_zaber_port(int argc, char **argv);
int zaber_readchar(unsigned char *achar);
int zaber_send_ascii_command_home(void);
int call_zaber_send_ascii_command_home(int argc, char **argv);
int zaber_send_ascii_command_move_max(void);
int call_zaber_send_ascii_command_move_max(int argc, char **argv);
int zaber_send_ascii_command_move_abs(int unit);
int call_zaber_send_ascii_command_move_abs(int argc, char **argv);
int zaber_send_ascii_command_move_rel(int unit);
int call_zaber_send_ascii_command_move_rel(int argc, char **argv);
int call_zaber_rel_move(int argc, char **argv);
int zaber_rel_move(int unit, long displacement);
int call_zaber_abs_move(int argc, char **argv);
int zaber_abs_move(int unit, long displacement);
int call_zaber_get_pos(int argc, char **argv);
int zaber_get_pos(int unit);
void zaber_reset_all_units(void);
void zaber_home(unsigned char unit);
void zaber_move_absolute(unsigned char unit, int position);
void zaber_move_relative(unsigned char unit, int Nsteps);
void zaber_set_mode(unsigned char unit, int mode);
void zaber_set_current_position(unsigned char unit, int position);
int zaber_return_position(unsigned char unit);
void send_unit_position(int unit, int position);
int zaber_set(int unit, char *command, char *setting, int value);
int call_zaber_set(int argc, char **argv);
int zaber_led_off(int argc, char **argv);
int zaber_led_on(int argc, char **argv);


/* wfs_andor.c */

int andor_setup_camera( s_wfs_andor_setup setup);
int andor_close(void);
int andor_send_setup(void);
int andor_set_acqmode(int acqmode);
int andor_set_exptime(float exptime);
int andor_set_shutter(int exptime);
int andor_set_shutter(int exptime);
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
void complete_data_record(void);

#endif
