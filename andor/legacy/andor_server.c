/************************************************************************/
/* wfs_server.c								*/
/*                                                                      */
/* Server program for WFSs, including telescope axis motion.		*/
/************************************************************************/
/*                                                                      */
/*                    CHARA ARRAY SERVER LIB   				*/
/*                 Based on the CHARA User Interface			*/
/*                 Based on the SUSI User Interface			*/
/*		In turn based on the CHIP User interface		*/
/*                                                                      */
/*            Center for High Angular Resolution Astronomy              */
/*              Mount Wilson Observatory, CA 91001, USA			*/
/*                                                                      */
/* Telephone: 1-626-796-5405                                            */
/* Fax      : 1-626-796-6717                                            */
/* email    : theo@chara.gsu.edu                                        */
/* WWW      : http://www.chara.gsu.edu			                */
/*                                                                      */
/* (C) This source code and its associated executable                   */
/* program(s) are copyright.                                            */
/*                                                                      */
/************************************************************************/
/*                                                                      */
/* Author : Theo ten Brummelaar 		                        */
/* Date   : Dec 2010							*/
/************************************************************************/


#include "andor_server.h"
#include <string.h>
#include <stdio.h>

/* Globals */

bool verbose = FALSE;
char wfs_name[256];
int  scope_number = 1;
struct s_wfs_andor_setup andor_setup;
at_u16 *image_data = NULL;
bool save_fits = FALSE;
bool use_cameralink = FALSE;
int number_of_processed_frames = 0;
float **data_frame = NULL;
float **dark_frame = NULL;
int dark_frame_num = 0;
float dark_frame_mean = 0.0;
float dark_frame_stddev = 0.0;
float **calc_dark_frame = NULL;
float **raw_frame = NULL;
float **sum_frame = NULL;
int sum_frame_num = 1;
float data_threshold = -1e32;
int num_mean_aberrations = 100;
bool set_subap_centroids_ref = FALSE;
bool fake_mirror = FALSE;
float max_radius = 0.0;
bool new_mean_aberrations = FALSE;
bool send_tiptilt_servo = FALSE;
bool include_old_S2_code = FALSE;

int main(int argc, char **argv)
{
	int	i = 0;
	char	s[80], *p = NULL;
/*	struct  s_process_sockets process; */
	char	*progname = NULL; 
	s_wfs_andor_image image;
	int	preamp_gain;
	int	vertical_speed;
	int	ccd_horizontal_speed;
	int	em_horizontal_speed;
	int	port;

	/* Create the restart_command 

	strcpy(process.restart_command,"/usr/local/bin/wfs_server");
	for(i=1; i<argc; i++)
	{
		strcat(process.restart_command," ");
		strcat(process.restart_command,argv[i]);
	}
   */

	/* Setup the defaults */

	image.hbin = DFT_ANDOR_HBIN;
	image.vbin = DFT_ANDOR_VBIN;
	image.hstart = DFT_ANDOR_HSTART;
	image.hend = DFT_ANDOR_HEND;
	image.vstart = DFT_ANDOR_VSTART;
	image.vend = DFT_ANDOR_VEND;
	preamp_gain = DFT_ANDOR_PREAMP_GAIN;
	vertical_speed = DFT_ANDOR_VERTICAL_SPEED;
	ccd_horizontal_speed = DFT_ANDOR_CCD_HORIZONTAL_SPEED;
	em_horizontal_speed = DFT_ANDOR_EMCCD_HORIZONTAL_SPEED;
	port = -1;

	/* Check the command line */

	progname = argv[0];
        p = s;
        while(--argc > 0 && (*++argv)[0] == '-')
        {
             for(p = argv[0]+1; *p != '\0'; p++)
             {
                switch(*p)
                {
			case 'B': if (sscanf(p+1,"%d,%d",
					&(image.hbin), &(image.vbin)) != 2)
                                  {
                                    print_usage_message(progname);
                                    exit;
                                  }
                                  while(*p != '\0') p++; p--;
                                  break;

                        case 'C': use_cameralink = !use_cameralink;
				  break;

			case 'G': if (sscanf(p+1,"%d", &preamp_gain) != 1)
                                  {
                                    print_usage_message(progname);
                                    exit;
                                  }
                                  while(*p != '\0') p++; p--;
                                  break;

                        case 'h': print_usage_message(progname);
                                  exit(0);

			case 'H': if (sscanf(p+1,"%d,%d", 
					&ccd_horizontal_speed,
					&em_horizontal_speed) != 2)
                                  {
                                    print_usage_message(progname);
                                    exit;
                                  }
                                  while(*p != '\0') p++; p--;
                                  break;

			case 'm': if (sscanf(p+1,"%f", &max_radius) != 1)
                                  {
                                    print_usage_message(progname);
                                    exit;
                                  }
                                  while(*p != '\0') p++; p--;
                                  break;

			case 'M': fake_mirror = !fake_mirror;
                                  while(*p != '\0') p++; p--;
                                  break;

                        case 'o': include_old_S2_code = !include_old_S2_code;
				  break;

			case 'R': if (sscanf(p+1,"%d,%d,%d,%d", 
					&(image.hstart),
					&(image.hend),
					&(image.vstart),
					&(image.vend)) != 4)
                                  {
                                    print_usage_message(progname);
                                    exit;
                                  }
				  error(MESSAGE,"Got image %d,%d,%d,%d.",
					image.hstart,
					image.hend,
					image.vstart,
					image.vend);
			
                                  while(*p != '\0') p++; p--;
                                  break;

			case 's': if (sscanf(p+1,"%d", &port) != 1)
                                  {
                                    print_usage_message(progname);
                                    exit;
                                  }
                                  while(*p != '\0') p++; p--;
                                  break;

                        case 'v': verbose = !verbose;
				  break;

			case 'V': if (sscanf(p+1,"%d", &vertical_speed) != 1)
                                  {
                                    print_usage_message(progname);
                                    exit;
                                  }
                                  while(*p != '\0') p++; p--;
                                  break;

			default: fprintf(stderr,"Unknown flag %c.\n",*p);
                                 print_usage_message(progname);
                                 exit;
                                 break;
		}
	     }
	}

	if (argc != 1)
	{
		print_usage_message(progname);
		exit;
	}

	if (verbose)
	{
		if (use_cameralink)
			error(MESSAGE,"Camera Link Enabled.");
		else
			error(MESSAGE,"Camera Link Disabled.");
	}
	
	/* Create the server neame */


	/* Which scope is this? */



	/* Set our jobs */

	/* OK, we try and open a connection to the camera */

	if (andor_open(WFS_CAMERA, image, preamp_gain, 
	  vertical_speed, ccd_horizontal_speed, em_horizontal_speed) != NOERROR)
	{
		error(ERROR, "Failed ot open Andor connection.");
	}


	/* Create the USB thread */

	andor_start_usb_thread();



	/* Should never reach here */

	exit(0);

} /* main() */

/************************************************************************/
/* close_function()							*/
/*									*/
/* Final closing down function.						*/
/************************************************************************/

void close_function(void)
{
	
	/* Stop the USB thread */

	andor_stop_usb();
	usleep(100000);
	andor_stop_usb_thread();

	/* Now stop talking to the camera */

	if (andor_close() != NOERROR)
	{
		error(ERROR, "Failed ot close Andor connection.");
	}

} /* close_function() */

/************************************************************************/
/* print_usage_message()                                                */
/*                                                                      */
/* Prints a usage message for this program.                             */
/************************************************************************/

void print_usage_message(char *name)
{

        fprintf(stderr,"usage: %s [-flags] SCOPE\n",name);
        fprintf(stderr,"Flags:\n");
        fprintf(stderr,"-B\t[Hbin,Vbin] Set binning (%d,%d)\n",
		DFT_ANDOR_HBIN, DFT_ANDOR_VBIN);
        fprintf(stderr,"-C\tToggle camera link (OFF)\n");
        fprintf(stderr,"-G\t[Gain] Set gain (%d)\n", DFT_ANDOR_PREAMP_GAIN);
        fprintf(stderr,"-h\tPrint this message\n");
        fprintf(stderr,"-H\t[CCD,EMCCD] Set horizontal speeds (%d,%d)\n",
		DFT_ANDOR_CCD_HORIZONTAL_SPEED,
		DFT_ANDOR_EMCCD_HORIZONTAL_SPEED);
        fprintf(stderr,"-m\tSet maximum radius of subap (OFF)\n");
        fprintf(stderr,"-M\tToggle fake mirror for tests (OFF)\n");
        fprintf(stderr,"-R\t[Hstart,Hend,Vstart,Vend] Set ROI (%d,%d,%d,%d)\n",
		DFT_ANDOR_HSTART, DFT_ANDOR_HEND,
		DFT_ANDOR_VSTART, DFT_ANDOR_VEND);
        fprintf(stderr,"-s\t[port] Bypass socket manager (FALSE)\n");
        fprintf(stderr,"-v\tToggle vergose mode (OFF)\n");
        fprintf(stderr,"-V\t[VSpeed] Set vertical speed (%d)\n",
		DFT_ANDOR_VERTICAL_SPEED);

} /* print_usage_message() */


