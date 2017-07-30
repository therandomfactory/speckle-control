/************************************************************************/
/* wfs_andor_usb_data.c							*/
/*                                                                      */
/* Routines to perform the USB part of data collection.			*/
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
/* Date   : Aug 2012							*/
/************************************************************************/

#include "jouflu.h"
#define NOERROR 0
#define ERROR -1
#define MESSAGE 1

static int number_of_usb_frames = 0;
static time_t start_time_of_usb_frames = 0;
static bool usb_thread_running = FALSE;
static pthread_t usb_thread;
static pthread_mutex_t usb_mutex = PTHREAD_MUTEX_INITIALIZER;
static int last_number_usb_images = 0;
static time_t last_fps_time = 0;

/************************************************************************/
/* andor_start_usb_thread()						*/
/*									*/
/* Setup and start the USB thread.					*/
/************************************************************************/

int andor_start_usb_thread(void)
{

	/* Create the thread */

        if (pthread_mutex_init(&usb_mutex, NULL) != 0)
        {
                return error(ERROR, "Unable to create usb mutex.");
        }

        usb_thread_running = TRUE;
        if (pthread_create(&usb_thread, NULL, andor_usb_thread, NULL) != 0)
        {
                return error(ERROR, "Error creating USB thread.");
        }

	error(MESSAGE,"Setup USB thread complete.");

	return NOERROR;

} /* andor_start_usb_thread() */

/************************************************************************/
/* andor_stop_usb_thread()						*/
/*									*/
/* Stop the USB thread.							*/
/************************************************************************/

int andor_stop_usb_thread(void)
{
	if (!usb_thread_running) return NOERROR;

	/* Let the thread know to stop */

        usb_thread_running = FALSE;

        /* Wait for the thread to stop */

        error(MESSAGE,"Waiting for usb thread to terminate.");
        if (pthread_join(usb_thread,NULL) != 0)
        {
                return error(ERROR, "Error waiting for usb thread to stop.");
        }

	return NOERROR;

} /* andor_stop_usb_thread() */

/************************************************************************/
/* andor_start_usb()							*/
/*									*/
/* Begin data collection using USB.					*/
/* Return error level.							*/
/************************************************************************/

int andor_start_usb(void)
{
	if (andor_setup.usb_running) return error(ERROR,
		"The camera is already running in USB mode.");

	/* Initialize the globals */

	lock_usb_mutex();
	number_of_usb_frames = 0;
	andor_setup.usb_frames_per_second = 0.0;
	andor_setup.cam_frames_per_second = 0.0;
	andor_setup.missed_frames_per_second = 0.0;
	last_number_usb_images = 0;

	/* Wait for the camera to be idle */

	if (andor_wait_for_idle(2) != NOERROR)
	{
		unlock_usb_mutex();
		return error(ERROR,
		"Timed out wait for camera to be idle.");
	}

	/* Wait for the second to pass by */

	start_time_of_usb_frames = time(NULL);
	while(time(NULL) <= start_time_of_usb_frames);
	start_time_of_usb_frames = time(NULL);
	last_fps_time = start_time_of_usb_frames;

	if (!andor_setup.running && andor_start_acquisition() != NOERROR)
	{
		unlock_usb_mutex();
                return ERROR;
	}

	/* That should be all */

	andor_setup.usb_running = TRUE;
	unlock_usb_mutex();

	if (verbose) error(MESSAGE,"Andor USB data collection started.");
//	send_wfs_text_message("Andor USB data collection started.");

	return NOERROR;
//	return andor_send_setup();

} /* andor_start_usb() */

/************************************************************************/
/* andor_stop_usb()							*/
/*									*/
/* End data collection using USB.					*/
/* Return error level.							*/
/************************************************************************/

int andor_stop_usb(void)
{
	if (!andor_setup.usb_running) return NOERROR;

	lock_usb_mutex();

	/* Stop getting data */

	if (andor_setup.running) andor_abort_acquisition();

	/* Wait for this to happen */

	unlock_usb_mutex();

	/* Stop the thread */

	usleep(2e6*andor_setup.exposure_time);
	andor_setup.usb_running = FALSE;
	usleep(2e6*andor_setup.exposure_time);

	/* Update globals */

	andor_setup.usb_frames_per_second = 0.0;
	andor_setup.cam_frames_per_second = 0.0;
	andor_setup.processed_frames_per_second = 0.0;
	andor_setup.missed_frames_per_second = 0.0;

	/* That should be all */

	if (verbose) error(MESSAGE,"Andor USB data collection stopped.");
//	send_wfs_text_message("Andor USB data collection stopped.");

	return NOERROR;
//	return andor_send_setup();

} /* andor_stop_usb() */

/************************************************************************/
/* andor_usb_thread()							*/
/*									*/
/* Thread to deal with the USB stuff. WIll go as fast as possible.	*/
/* Return error level.							*/
/************************************************************************/

void *andor_usb_thread(void *arg)
{
					 // These from begining of time
	int this_number_usb_images = 0;	 // #Images reported by harware
	int last_number_usb_count = 0; // For tracking data rate
	int n;
	int i;
	int year, month, day, doy;
	char s[256], filename_base[256], filename[256];
	FILE	*output;

	error(MESSAGE,"Entering USB Thread.");
	while(usb_thread_running)
	{
		/* 
		 * Do we need to do anything?
		 * We should always empty the USB data
		 * even if camera link is running as it is always sent
		 * and we don't wish to have problems with over-full
		 * buffers.
		 */

		if (!andor_setup.running)
		{
			usleep(1000);
			continue;
		}

		/* Is there any data to get? */

		lock_usb_mutex();

		/* Is there a new frame? */

		if ((this_number_usb_images = 
			andor_get_total_number_images_acquired()) == ERROR)
		{
			unlock_usb_mutex();
			continue;
		}

		/* Is there something new? */

		if (this_number_usb_images == last_number_usb_images)
		{
			unlock_usb_mutex();
			usleep(500);
			continue;
		}

		/* How many new images ? */

		n = this_number_usb_images - last_number_usb_images;
		last_number_usb_images = this_number_usb_images;

		/* Save as FITs if we have been asked to */

		if (save_fits)
		{
			/* Build the filename */

			sprintf(filename_base,"andorTest_");
 
			for(i=1; i<999; i++)
			{
				sprintf(filename,"%s_%03d.fit",
					filename_base, i);
				if ((output = fopen(filename, "r")) == NULL)
					break;
				fclose(output);
			}

			/* Save the file. */

			if (i <= 999) SaveAsFITS(filename, 0);

			save_fits = FALSE;
		}

		/* OK, go get all the data */

		for(i=0; i<n; i++)
		{
		    if (andor_get_oldest_image() != NOERROR)
		    {
			unlock_usb_mutex();
			continue;
		    }

		    /* OK, we got one more USB frame */

		    ++number_of_usb_frames;


		    /* Process this if required */

/*		    if (!andor_setup.camlink_running)
		    {
			process_data(chara_time_now()); 
		    }
		    else
		    {
*/			    /* Make some room for the other threads */
			
#warning I wonder about this usleep and some others
			    usleep(5000);
//		    }
		}

		if (time(NULL) > last_fps_time)
		{
		    /* Do frames per second calculation */

		    last_fps_time = time(NULL);

		    andor_setup.usb_frames_per_second = number_of_usb_frames;
		    andor_setup.cam_frames_per_second = 
				this_number_usb_images - last_number_usb_count;
		    if (andor_setup.usb_running)
		    {
		        andor_setup.missed_frames_per_second = 
				andor_setup.cam_frames_per_second -
				andor_setup.usb_frames_per_second;
		    }

		    number_of_usb_frames = 0;
		    last_number_usb_count = this_number_usb_images;
		 }

		/* That should be all */

		unlock_usb_mutex();
	}
	error(MESSAGE,"Leaving USB Thread.");

	return NULL;

} /* andor_usb_thread() */

/************************************************************************/
/* lock_usb_mutex()                                                     */
/*                                                                      */
/* So outside programs can lock the mutex.                              */
/************************************************************************/

void lock_usb_mutex(void)
{
        pthread_mutex_lock(&usb_mutex);

} /* lock_usb_mutex() */

/************************************************************************/
/* unlock_usb_mutex()                                                   */
/*                                                                      */
/* So outside programs can unlock the mutex.                            */
/************************************************************************/

void unlock_usb_mutex(void)
{
        pthread_mutex_unlock(&usb_mutex);

} /* unlock_usb_mutex() */
