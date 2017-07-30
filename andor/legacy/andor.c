/************************************************************************/
/* wfs_andor.c								*/
/*                                                                      */
/* Routines to control the actual camera.				*/
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

/* Globals */

static bool andor_is_open = FALSE;
static bool do_shutter = TRUE;
static at_32 lCameraHandle = 0;
static at_32 lNumCameras = 0;
#define NOERROR 0
#define ERROR -1
#define MESSAGE 1

/************************************************************************/
/* andor_open()								*/
/*									*/
/* Setup and initialize the camera.					*/
/* If it is already open it will close the connection.			*/
/* Return error level.							*/
/* Assumes only one andor camera is connected to the USB ports.		*/
/* Will setup a basic set of things so it will produce an image 	*/
/* of some kind.							*/
/************************************************************************/

int andor_open(int iSelectedCamera,  s_wfs_andor_image image,
		int preamp_gain, int vertical_speed, int ccd_horizontal_speed,
		int em_horizontal_speed)
{
	int	bitdepth;
	int	width, height;
	int	min, max;
	int	i, j, numgains;
	float	gain;
	int	num_ad;
	int	num_vspeeds;
	int	num_hspeeds;
	float	speed;
	AndorCapabilities caps;
	s_wfs_andor_setup setup;

	/* Close the camera if it is open already */

	if (andor_is_open && andor_close()) return ERROR;
		
	error(MESSAGE,"Initializing Andor Camera.");

	/* 
	 * STEP ONE - Connect to camera and find out what we can about it.
	 * How many cameras are connected?
	 */

	switch(GetAvailableCameras(&lNumCameras))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
			"Andor:GetAvailableCameras():Unknown error.");

		case DRV_GENERAL_ERRORS: return error(ERROR,
		"Andor:GetAvailableCameras():Failed to get number of cameras.");
	}

	if (verbose) error(MESSAGE, "Found %d cameras", lNumCameras);

	/* Have we asked for an existing camera? */

	if (iSelectedCamera >= lNumCameras)
	{
		return error(ERROR,"Requested camera %d does not exist.",
			iSelectedCamera);
	}

	/* OK We're assuming only one Andor camera is attached */

	switch (GetCameraHandle(0, &lCameraHandle))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
			"Andor:GetCameraHandle():Unknown error.");

		case DRV_P1INVALID: return error(ERROR,
			"Andor:GetCameraHandle():Invalid camera index.");
	}

	/* and that one has to be the one we are talking to */

	switch (SetCurrentCamera(lCameraHandle))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
			"Andor:SetCurrentCamera():Unknown error.");

		case DRV_P1INVALID: return error(ERROR,
			"Andor:SetCurrentCamera():Invalid camera index.");
	}

	/* Initialize the CCD */

//	switch (Initialize("/home/nic/control/cliserv/jouflu/server-stripped/andor/etc"))
	switch (Initialize("/usr/local/etc/andor"))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetCurrentCamera():Unknown error.");

		case DRV_VXDNOTINSTALLED: return error(ERROR,
		    "Andor:Initialize(): VxD not loaded.");

		case DRV_INIERROR: return error(ERROR,
		    "Andor:Initialize(): Unable to load DETECTOR.INI.");

		case DRV_COFERROR: return error(ERROR,
		    "Andor:Initialize(): Unable to load *.COF.");

		case DRV_FLEXERROR: return error(ERROR,
		    "Andor:Initialize(): Unable to load *.RBF.");

		case DRV_ERROR_ACK: return error(ERROR,
		    "Andor:Initialize(): Unable to communicate with card.");

		case DRV_ERROR_FILELOAD: return error(ERROR,
		    "Andor:Initialize(): Unable to load COF or RBF files.");

		case DRV_ERROR_PAGELOCK: return error(ERROR,
		    "Andor:Initialize(): Unable to acquire lock on memory.");

		case DRV_USBERROR: return error(ERROR,
			"Andor:Initialize(): Unable to detect USB device.");

		case DRV_ERROR_NOCAMERA: return error(ERROR,
			"Andor:Initialize(): No camera found.");
	}

	if (verbose) error(MESSAGE, "Camera Initialized");

	/* Wait for this to happen */

	sleep(2);

	/* Make sure the shutter is closed */

	if (andor_set_shutter(ANDOR_SHUTTER_CLOSE) == NOERROR && !verbose)
	{
		error(MESSAGE, "Andor: shutter closed.");
	}

	/* What Capabilities do we have? */

	caps.ulSize = sizeof(caps);
	switch (GetCapabilities(&caps))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetCapabilities():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetCapabilities(): Not initialized.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:GetCapabilities(): Invalid CAPS parameter.");
	}

	if (caps.ulCameraType & AC_CAMERATYPE_IXON)
		error(MESSAGE,"Andor: Camera is an iXon.");
	else
		error(MESSAGE,"Andor: Camera is not an iXon.");

	if (caps.ulAcqModes & AC_ACQMODE_FRAMETRANSFER)
		error(MESSAGE,"Andor: Frame transfer is available.");
	else
		error(MESSAGE,"Andor: Frame transfer is not available.");

	if (caps.ulSetFunctions & AC_SETFUNCTION_CROPMODE)
		error(MESSAGE,"Andor: Crop mode is available.");
	else
		error(MESSAGE,"Andor: Crop mode is not available.");

	/* Find out what the width and height are */

	switch(GetDetector(&width, &height))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetDetector():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetDetector():Not initialized.");
	}

	andor_setup.width = width;
	andor_setup.height = height;
	error(MESSAGE,"Andor: full size %dx%d.", width, height);
	
	/* What is the allowable temperature range? */

	switch(GetTemperatureRange(&min, &max))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetTemperatureRange():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetTemperatureRange():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetTemperatureRange():Acquisition in progress.");

	}
	error(MESSAGE,"Andor: temperature range is %d to %d C.", min, max);
	andor_setup.minimum_temperature = min;
	andor_setup.maximum_temperature = max;
	
	/* How many preamp gains do we have? */

	switch(GetNumberPreAmpGains(&numgains))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetNumberPreAmpGains():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetNumberPreAmpGains():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetNumberPreAmpGains():Acquisition in progress.");

	}
	error(MESSAGE,"Andor: number of preamp gains is %d.",
	    andor_setup.num_preamp_gains = numgains);

	/* Let's find out what these gains are */

	for (i=0; i<numgains; i++)
	{
		if (andor_get_preamp_gain(i, &gain) == NOERROR && !verbose)
			error(MESSAGE,"Andor: Preamp Gain %d is %f.",
				i, gain);
	}

	/* How many vertical speeds do we have? */

	switch(GetNumberVSSpeeds(&num_vspeeds))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetNumberVSSpeeds():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetNumberVSSpeeds():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetNumberVSSpeeds():Acquisition in progress.");

	}
	error(MESSAGE,"Andor: number of Vertical Speeds is %d.",
		andor_setup.num_vertical_speeds = num_vspeeds);

	/* Let's find out what these gains are */

	for (i=0; i<num_vspeeds; i++)
	{
		if (andor_get_vertical_speed(i, &speed) == NOERROR)
			error(MESSAGE,"Andor: Vertical Speed %d is %.2f uS.",
				i, speed);
	}

	/* OK, Horizontal speeds depend on readout amplifier */

	for(j = 0; j < ANDOR_NUM_AMPLIFIERS; j++)
	{
	    if (j == 0)
		    error(MESSAGE,"For EMCCD output:");
	    else
		    error(MESSAGE,"For CCD output:");

	    /* How many horizontal speeds do we have? */

	    switch(GetNumberHSSpeeds(0, j, &num_hspeeds))
	    {
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetNumberHSSpeeds():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetNumberHSSpeeds():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetNumberHSSpeeds():Acquisition in progress.");

	    }
	    error(MESSAGE,"Andor: number of Horizontal Speeds is %d.",
		andor_setup.num_horizontal_speeds[j] = num_hspeeds);

	    /* Let's find out what these gains are */

	    for (i=0; i<num_hspeeds; i++)
	    {
		if (andor_get_horizontal_speed(j, i, &speed) == NOERROR)
			error(MESSAGE,
				"Andor: Horizontal Speed %d is %.2f MHz.",
				i, speed);
	    }

	}

	/* What is the range of gain settings? */

	switch(GetEMGainRange(&min, &max))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetEMGainRange():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetEMGainRange():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetEMGainRange():Acquisition in progress.");

	}

	andor_setup.minimum_em_gain = min;
	andor_setup.maximum_em_gain = max;;

	error(MESSAGE,"Andor: EM Gain range is %d to %d C.", min, max);

	/* How many AD channels are there? */

	if (GetNumberADChannels(&num_ad) != DRV_SUCCESS)
	{
		error(ERROR, "Andor: Failed to get nunmber of AD channels.");
	}
	else if (verbose)
	{
		error(MESSAGE,"Andor: Number of AD channels = %d", num_ad);
	}

	/* What are the bit depths? */

	for(i=0; i < num_ad; i++)
	{
	    if (GetBitDepth(i, &bitdepth) != DRV_SUCCESS)
	    {
		error(ERROR,"Andor: Failed to get bit depth for AD channel %d.",
			i);
	    }
	    else if (verbose)
	    {
		error(MESSAGE,"Andor: AD channel %d has bit depth %d", 
			i, bitdepth);
	    }
	}

/*	if (use_cameralink)
	{
	    error(MESSAGE,"Really?");
	    switch(SetCameraLinkMode(DFT_ANDOR_CAMERA_LINK))
	    {
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetCameraLinkMode():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetCameraLinkMode():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetCameraLinkMode():Acquisition in progress.");

		case DRV_NOT_SUPPORTED: return error(ERROR,
		    "Andor:SetCameraLinkMode():Camera Link Not Supported.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetCameraLinkMode():Bad data.");
	    }
	    if (verbose) error(MESSAGE,"Camera Link Enabled.");
	}
*/
	/* We should have a default target temperature */

	if (andor_set_temperature(DFT_ANDOR_TEMPERATURE) != NOERROR) return ERROR;
	if (!verbose) error(MESSAGE,"Andor: Temperature set to %d", DFT_ANDOR_TEMPERATURE);

	/* We should begin with the cooling OFF */

	if (andor_cooler_off() != NOERROR) return ERROR;
	if (!verbose) error(MESSAGE,"Andor: Cooling off.");

	/* Let's set all the defaults we wish to use */

	setup.amplifier = DFT_ANDOR_AMPLIFIER;
	setup.em_gain = DFT_ANDOR_EM_GAIN;
	setup.em_advanced = DFT_ANDOR_EM_ADVANCED;
	setup.horizontal_speed_index[ANDOR_CCD] = ccd_horizontal_speed;
	setup.horizontal_speed_index[ANDOR_EMCCD] = em_horizontal_speed;
	setup.vertical_speed_index = vertical_speed;
	setup.preamp_gain_index = preamp_gain;
	setup.image = image;
	setup.exposure_time = DFT_ANDOR_EXPOSURE_TIME;

	do_shutter = TRUE;
	andor_setup_camera(setup);
	do_shutter = FALSE;

	/* That should be all */

	andor_is_open = TRUE;
	return error(NOERROR,"Andor: camera connection is open.");

} /* andor_open() */

/************************************************************************/
/* andor_setup_camera()							*/
/*									*/
/* Try to setup the camera as best we can. There are a few odd things	*/
/* in here that have proved necessary to make things work. See comments */
/* in the code. Returns error level.					*/
/************************************************************************/

int andor_setup_camera( s_wfs_andor_setup setup)
{
	int	min, max;
	bool old_verbose;

	if (andor_setup.running) return error(ERROR,
		"Can not change parameters while the camera is running.");

	old_verbose = verbose;
	verbose = TRUE;

	/* Put us in Frame Transfer Mode */

	error(MESSAGE, "Andor: Turning on Frame Transfer Mode.");
	switch(SetFrameTransferMode(1))
	{
		case DRV_SUCCESS: break;

		default: verbose = old_verbose;
			return error(ERROR,
		    "Andor:SetFrameTransferMode():Unknown error.");

		case DRV_NOT_INITIALIZED: verbose = old_verbose;
			return error(ERROR,
		    "Andor:SetFrameTransferMode():Not initialized.");

		case DRV_ACQUIRING: verbose = old_verbose;
			return error(ERROR,
	    "Andor:Andor:SetFrameTransferMode():Acquisition in progress.");

		case DRV_P1INVALID: verbose = old_verbose;
			return error(ERROR,
		    "Andor:Andor:SetFrameTransferMode():Invalid parameter.");
	}

	/* Set amplifier */

	if (andor_set_amplifier(setup.amplifier) != NOERROR)
	{
		verbose = old_verbose;
		return ERROR;
	}

	if (!verbose) switch(setup.amplifier)
	{
		case ANDOR_EMCCD: error(MESSAGE,
				"Andor: output amplifier set to EMCCD.");
				  break;

		case ANDOR_CCD: error(MESSAGE,
				"Andor: output amplifier set to CCD.");
				 break;

		default: error(ERROR,"Unknown Andor: output amplifier.");
	}

	/* Turn on advanced EM settings */

	if (andor_set_em_advanced(setup.em_advanced) != NOERROR)
	{
		verbose = old_verbose;
		return ERROR;
	}

	/* Default for EM gain */

	if (andor_set_em_gain(setup.em_gain) != NOERROR)
	{
		verbose = old_verbose;
		return ERROR;
	}

	/* Set our horizontal speed. */

	switch(setup.amplifier)
	{
		case ANDOR_EMCCD: if (andor_set_horizontal_speed(ANDOR_EMCCD, 
				setup.horizontal_speed_index[ANDOR_EMCCD]) != 
					NOERROR)
				{
					verbose = old_verbose;
					return ERROR;
				}
				break;

		case ANDOR_CCD: if (andor_set_horizontal_speed(ANDOR_CCD, 
				setup.horizontal_speed_index[ANDOR_CCD]) !=
					NOERROR)
				{
					verbose = old_verbose;
					return ERROR;
				}
				 break;

		default: error(ERROR,"Unknown Andor: output amplifier.");
	}


	/* Set our vertical speed to the desired one. */

	if (andor_set_vertical_speed(setup.vertical_speed_index) != NOERROR)
	{
		verbose = old_verbose;
		return ERROR;
	}

	/* Set our preamp gain to the desired one. */

	if (andor_set_preamp_gain(setup.preamp_gain_index) != NOERROR)
	{
		verbose = old_verbose;
		return ERROR;
	}

	/* Setup a default read mode. to image */

	switch(SetReadMode(ANDOR_READMODE_IMAGE))
	{
		case DRV_SUCCESS: break;

		default: verbose = old_verbose;
			return error(ERROR,
		    "Andor:SetReadMode():Unknown error.");

		case DRV_NOT_INITIALIZED: verbose = old_verbose;
			return error(ERROR,
		    "Andor:SetReadMode():Not initialized.");

		case DRV_ACQUIRING: verbose = old_verbose;
			return error(ERROR,
		    "Andor:SetReadMode():Acqusition in progress.");

		case DRV_P1INVALID: verbose = old_verbose;
			return error(ERROR,
		    "Andor:SetReadMode():Invalid readmode.");
	}
	andor_setup.read_mode = ANDOR_READMODE_IMAGE;
	error(MESSAGE,"Andor: read mode set to (%d) IMAGE.",
		ANDOR_READMODE_IMAGE);

	/* 
	 * Now here is one weird bit. We will try and read images now
	 * which might result in an error, but if we don't do that now
	 * then later things, like cropping, will not work.
	 */

	SetAcquisitionMode(5);
        PrepareAcquisition();
        StartAcquisition();
        sleep(1);
        AbortAcquisition();

	/* What is the range of gain settings? */

	switch(GetEMGainRange(&min, &max))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetEMGainRange():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetEMGainRange():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetEMGainRange():Acquisition in progress.");

	}
	andor_setup.minimum_em_gain = min;
	andor_setup.maximum_em_gain = max;;
	error(MESSAGE,"Andor: EM Gain range is %d to %d C.", min, max);

	/* Now set the crop mode */

	if (setup.amplifier == ANDOR_EMCCD)
	{
	    if (andor_set_crop_mode(setup.image.vend, setup.image.hend, 
				setup.image.vbin, setup.image.hbin) != NOERROR)
	    {
		verbose = old_verbose;
		return ERROR;
	    }
	}

	/* Set default image */

	if (setup.image.hbin < 1 || setup.image.vbin < 1 ||
		setup.image.hstart < 1 || 
		setup.image.hstart > andor_setup.width ||
		setup.image.hstart > setup.image.hend ||
		setup.image.vstart < 1 || 
		setup.image.vstart > andor_setup.height ||
		setup.image.vstart > setup.image.vend)
	{
		error(ERROR, "Selected ROI out of range, using full chip.");
		setup.image.hbin = setup.image.vbin =
		setup.image.hstart = setup.image.vstart =
		setup.image.hend = setup.image.vend = 0;
	}

	if (setup.image.hbin * setup.image.vbin * 
		setup.image.hstart * setup.image.hend *
		setup.image.vstart * setup.image.vend == 0)
	{
		error(ERROR,
		"Image selected %d,%d,%d,%d out of range, using default.",
			setup.image.hstart, setup.image.hend,
			setup.image.vstart, setup.image.vend);
		setup.image.hbin = DFT_ANDOR_HBIN;
		setup.image.vbin = DFT_ANDOR_VBIN;
		setup.image.hstart = DFT_ANDOR_HSTART;
		setup.image.hend = DFT_ANDOR_HEND;
		setup.image.vstart = DFT_ANDOR_VSTART;
		setup.image.vend = DFT_ANDOR_VEND;
	}

	if (andor_set_image(setup.image) != NOERROR)
	{
		verbose = old_verbose;
		return ERROR;
	}
	error(MESSAGE,"Andor: npix %dx%d = %d", 
		andor_setup.npixx, andor_setup.npixy, andor_setup.npix);

	/* Set default exposure time */

	if (andor_set_exptime(setup.exposure_time) != NOERROR)
	{
		verbose = old_verbose;
		return ERROR;
	}

	/* Set Kinetic Cycle time to the smallest possible value */

	error(MESSAGE, "Andor: Setting Kinetic Cycle time to minimum..");
	switch(SetKineticCycleTime(0.0))
	{
		case DRV_SUCCESS: break;

		default: verbose = old_verbose;
			return error(ERROR,
		    "Andor:SetKineticCycleTime():Unknown error.");

		case DRV_NOT_INITIALIZED: verbose = old_verbose;
			return error(ERROR,
		    "Andor:SetKineticCycleTime():Not initialized.");

		case DRV_ACQUIRING: verbose = old_verbose;
			return error(ERROR,
	    "Andor:Andor:SetKineticCycleTime():Acquisition in progress.");

		case DRV_P1INVALID: verbose = old_verbose;
			return error(ERROR,
		    "Andor:Andor:SetKineticCycleTime():Invalid Time.");
	}

	/* Set default acquisition mode */

	if (andor_set_acqmode(ANDOR_ACQMODE_RUN_TILL_ABORT) != NOERROR)
		return ERROR;
	error(MESSAGE,"Andor: acquisition mode set to RUN_TILL_ABORT.");

	/* Set default shutter */

	if (do_shutter && andor_set_shutter(DFT_ANDOR_SHUTTER) != NOERROR)
	{
		verbose = old_verbose;
		return ERROR;
	}

	verbose = old_verbose;
	return NOERROR;
//	return andor_send_setup();

} /* andor_setup_camera() */
	
/************************************************************************/
/* andor_close()							*/
/*									*/
/* Closes the connection to the andor camera.				*/
/* Return error level.							*/
/************************************************************************/

int andor_close(void)
{
	if (!andor_is_open) return NOERROR;

	andor_stop_usb();
        if (!verbose) error(MESSAGE,"Andor USB data collection stopped.");

	andor_cooler_off();
	if (!verbose) error(MESSAGE,"Andor: cooling turned off.");

	andor_set_shutter(ANDOR_SHUTTER_CLOSE);
	if (!verbose) error(MESSAGE,"Andor: Closing shutter.");

	if (ShutDown() != DRV_SUCCESS)
	{
		return error(ERROR, "Failed to shutdown Andor system.");
	}
	error(MESSAGE,"Andor: shutdown.");

	if (image_data != NULL) free(image_data);

	andor_is_open = FALSE;

	error(MESSAGE,"Andor: camera connection is closed.");

	return NOERROR;

} /* andor_close() */
	
/************************************************************************/
/* andor_send_setup()							*/
/*									*/
/* Send all clients the current setup. Returns error level.		*/
/************************************************************************/
/*
int andor_send_setup(void)
{
	struct smessage mess;

	mess.type = WFS_ANDOR_SETUP;
	mess.data = (unsigned char *)&andor_setup;
	mess.length = sizeof(andor_setup);

	if (server_send_message_all(&mess) != NOERROR)
                return error(ERROR,"Failed to send andor setup.");

	return NOERROR;

}*/ /* andor_send_setup() */

/************************************************************************/
/* andor_set_acqmode()							*/
/*									*/
/* Tries to set the acquisition mode.					*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_acqmode(int acqmode)
{
	/* Is it within range? */

	if (acqmode < 1 || acqmode > ANDOR_NUM_ACQMODES)
		return error(ERROR,"Acqusition mode out of range.");

	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not set acquisition mode while camera is running.");

	/* Set the acqusition mode. */

	switch(SetAcquisitionMode(acqmode))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetAcquisitionMode():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetAcquisitionMode():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetAcquisitionMode():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetAcquisitionMode():Invalid readmode.");
	}

	andor_setup.acquisition_mode = acqmode;

	if (verbose) error(MESSAGE, "Andor: Acqusition Mode = %d.", acqmode);

	return NOERROR;

} /* andor_set_acqmode() */

/************************************************************************/
/* andor_set_exptime()							*/
/*									*/
/* Tries to set the exposure time in seconds.				*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_exptime(float exptime)
{
	/* Is it within range? */

	if (exptime <= 0.0) return error(ERROR,"Exposure time out of range.");

	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not set exposure time while camera is running.");

	/* Set the exposure time. */

	switch(SetExposureTime(exptime))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetExposureTime():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetExposureTime():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetExposureTime():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetExposureTime():Invalid readmode.");
	}

	andor_setup.exposure_time = exptime;

	if (verbose) error(MESSAGE, "Andor: Exposure time = %.3f S.", exptime);

	return NOERROR;

} /* andor_set_exptime() */

/************************************************************************/
/* andor_set_shutter()							*/
/*									*/
/* Tries to set the exposure time in seconds.				*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_shutter(int shutter)
{
	/* Is it within range? */

	if (shutter < 0 || shutter >= ANDOR_NUM_SHUTTERS)
		return error(ERROR,"Shutter out of range.");

	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not move shutter while camera is running.");

	/* Set the shutter. */

	switch(SetShutter(1, shutter, 50, 50))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetShutter():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetShutter():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetShutter():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetShutter():Invalid readmode.");

		case DRV_P2INVALID: return error(ERROR,
		    "Andor:SetShutter():Invalid internal mode.");

		case DRV_P3INVALID: return error(ERROR,
		    "Andor:SetShutter():Invalid time to open.");

		case DRV_P4INVALID: return error(ERROR,
		    "Andor:SetShutter():Invalid time to close.");

		case DRV_P5INVALID: return error(ERROR,
		    "Andor:SetShutter():Invalid external mode.");
	}

	andor_setup.shutter = shutter;

	if (verbose)
	{
		switch(shutter)
		{
		    case ANDOR_SHUTTER_AUTO:
			error(MESSAGE, "Andor: Shutter Auto.");
			break;
		    case ANDOR_SHUTTER_OPEN:
			error(MESSAGE, "Andor: Shutter Open.");
			break;
		    case ANDOR_SHUTTER_CLOSE:
			error(MESSAGE, "Andor: Shutter Closed.");
			break;
		    default:
			error(MESSAGE, "Andor: Shutter has bad command.");
			break;
	        }
	}

	return NOERROR;

} /* andor_set_shutter() */

/************************************************************************/
/* andor_set_image()							*/
/*									*/
/* Tries to set the image area.						*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_image(s_wfs_andor_image image)
{
	bool ok = FALSE;
	int	i,j;

	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not set ROI while camera is running.");

	/* Set the mage. */

	switch(SetImage(image.hbin, image.vbin, 
			image.hstart, image.hend,
			image.vstart, image.vend))
	{
		case DRV_SUCCESS: ok = TRUE;
				  break;

		default: return error(ERROR,
		    "Andor:SetImage():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetImage():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetImage():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetImage():Hbin paramter invalid.");

		case DRV_P2INVALID: return error(ERROR,
		    "Andor:SetImage():Vbin paramter invalid.");

		case DRV_P3INVALID: return error(ERROR,
		    "Andor:SetImage():Hstart parameter invalid.");

		case DRV_P4INVALID: return error(ERROR,
		    "Andor:SetImage():Hend parameter invalid.");

		case DRV_P5INVALID: return error(ERROR,
		    "Andor:SetImage():Vstart parameter invalid.");

		case DRV_P6INVALID: return error(ERROR,
		    "Andor:SetImage():Vend parameter invalid.");

	}

	/* If that failed go back to old one */

	if (!ok)
	{
            switch(SetImage(andor_setup.image.hbin, andor_setup.image.vbin,
                        andor_setup.image.hstart, andor_setup.image.hend,
                        andor_setup.image.vstart, andor_setup.image.vend))
            {
                case DRV_SUCCESS: ok = TRUE;
                                  break;

                default: return error(ERROR,
                    "Andor:SetImage():Unknown error.");

                case DRV_NOT_INITIALIZED: return error(ERROR,
                    "Andor:SetImage():Not initialized.");

                case DRV_ACQUIRING: return error(ERROR,
                    "Andor:SetImage():Acqusition in progress.");

                case DRV_P1INVALID: return error(ERROR,
                    "Andor:SetImage():Hbin paramter invalid.");

                case DRV_P2INVALID: return error(ERROR,
                    "Andor:SetImage():Vbin paramter invalid.");

                case DRV_P3INVALID: return error(ERROR,
                    "Andor:SetImage():Hstart parameter invalid.");

                case DRV_P4INVALID: return error(ERROR,
                    "Andor:SetImage():Hend parameter invalid.");

                case DRV_P5INVALID: return error(ERROR,
                    "Andor:SetImage():Vstart parameter invalid.");

                case DRV_P6INVALID: return error(ERROR,
                    "Andor:SetImage():Vend parameter invalid.");

            }

	    if (!ok) return error(ERROR,"Serious ROI failure.");
	}
	else
	{
	    /* Release ememory */

	    if (image_data != NULL) free(image_data);
/*
	    if (data_frame != NULL) free(data_frame, 
			1, andor_setup.npixx, 1, andor_setup.npixy);
	    if (dark_frame != NULL) free(dark_frame, 
			1, andor_setup.npixx, 1, andor_setup.npixy);
	    if (calc_dark_frame != NULL) free(calc_dark_frame, 
			1, andor_setup.npixx, 1, andor_setup.npixy);
	    if (raw_frame != NULL) free(raw_frame, 
			1, andor_setup.npixx, 1, andor_setup.npixy);
	    if (sum_frame != NULL) free(sum_frame, 
			1, andor_setup.npixx, 1, andor_setup.npixy);
 */
	    /* 
	     * We now know how many pixels we have
	     * This should include the binning if we are using it.
	     */

	    andor_setup.npixx = (image.hend - image.hstart + 1)/image.hbin;
	    andor_setup.npixy = (image.vend - image.vstart + 1)/image.vbin;
	    andor_setup.npix = andor_setup.npixx * andor_setup.npixy;

	    /* Allocate memory for the images */

	    image_data = malloc(andor_setup.npix * sizeof(*image_data));
	    if (image_data == NULL) error(FATAL,"Ran out of memory.");

/*	    data_frame = matrix(1, andor_setup.npixx, 1, andor_setup.npixy);
	    dark_frame = matrix(1, andor_setup.npixx, 1, andor_setup.npixy);
	    calc_dark_frame = matrix(1, andor_setup.npixx,1,andor_setup.npixy);
	    raw_frame = matrix(1, andor_setup.npixx, 1, andor_setup.npixy);
	    sum_frame = matrix(1, andor_setup.npixx, 1, andor_setup.npixy);
*/
	    for(i=1; i <= andor_setup.npixx; i++)
	    for(j=1; j <= andor_setup.npixy; j++)
	    {
		data_frame[i][j] = 0.0;
		dark_frame[i][j] = 0.0;
		calc_dark_frame[i][j] = 0.0;
		sum_frame[i][j] = 0.0;
		raw_frame[i][j] = 0.0;
	    }

	    /* Tell the user about this */

	    andor_setup.image.hbin = image.hbin;
	    andor_setup.image.vbin = image.vbin;
	    andor_setup.image.hstart = image.hstart;
	    andor_setup.image.hend = image.hend;
	    andor_setup.image.vstart = image.vstart;
	    andor_setup.image.vend = image.vend;
	}

	if (verbose) error(MESSAGE,"Andor: Image set to %d,%d,%d,%d,%d,%d.", 
		image.hbin, image.vbin, image.hstart, 
		image.hend, image.vstart, image.vend);
		
	return NOERROR;

} /* andor_set_image() */

/************************************************************************/
/* andor_set_crop_mode()                                                */
/*                                                                      */
/* Treis to set a crop mode.						*/
/* Returns error level.                                                 */
/************************************************************************/

int andor_set_crop_mode(int height, int width, int vbin, int hbin)
{
        /* Are we collecting data right now? */

        if (andor_setup.running) return error(ERROR,
                "Can not set CROP MODE while camera is running.");

        /* First, we would like to be in cropped mode. */

        switch(SetIsolatedCropMode(1, height, width, vbin, hbin))
        {
                case DRV_SUCCESS: break;

                default: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Unknown error.");

                case DRV_NOT_INITIALIZED: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Not initialized.");

                case DRV_ACQUIRING: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Acqusition in progress.");

                case DRV_P1INVALID: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Active paramter invalid.");

                case DRV_P2INVALID: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Height paramter invalid.");

                case DRV_P3INVALID: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Width parameter invalid.");

                case DRV_P4INVALID: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Vbin parameter invalid.");

                case DRV_P5INVALID: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Hbin parameter invalid.");

                case DRV_NOT_SUPPORTED: return error(ERROR,
                    "Andor:SetIsolatedCropMode():Crop mode not supported.");

        }

	if (verbose) error(MESSAGE,"Andor: Isolated Crop mode %dx%d Binning %d-%d.",
				width, height, hbin, vbin);

	return NOERROR;

} /* andor_set_crop_mode() */

/************************************************************************/
/* andor_set_amplifier()						*/
/*									*/
/* Tries to set the amplifier.						*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_amplifier(int amplifier)
{
	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not set amplifier while camera is running.");

	/* Set the amplifier. */

	switch(SetOutputAmplifier(amplifier))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetOutputAmplifier():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetOutputAmplifier():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetOutputAmplifier():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetOutputAmplifier():Amplifier paramter invalid.");

	}

	andor_setup.amplifier = amplifier;

	if (verbose) switch(amplifier)
	{
		case ANDOR_EMCCD: error(MESSAGE,
				"Andor: output amplifier set to EMCCD.");
				  break;

		case ANDOR_CCD: error(MESSAGE,
				"Andor: output amplifier set to CCD.");
				 break;

		default: error(ERROR,"Unknown Andor: output amplifier.");
	}

	return NOERROR;

} /* andor_set_amplifier() */

/************************************************************************/
/* andor_start_acquisition()						*/
/*									*/
/* Start acquiring data.						*/
/* Returns error level.							*/
/************************************************************************/

int andor_start_acquisition(void)
{ 
	int i;
	switch (i = PrepareAcquisition())
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
			"Andor:PrepareAcquisition():Unknown error (%d).",i);

		case DRV_NOT_INITIALIZED: return error(ERROR,
			"Andor:PrepareAcquisition(): Not initialized.\n");
			break;

		case DRV_ACQUIRING: return error(ERROR,
			"Andor:PrepareAcquisition(): ACQUIRING.\n");
			break;

		case DRV_VXDNOTINSTALLED: return error(ERROR,
			"Andor:PrepareAcquisition(): VXDNOTINSTALLED.\n");
			break;

		case DRV_ERROR_ACK: return error(ERROR,
			"Andor:PrepareAcquisition(): ERROR_ACK.\n");
			break;

		case DRV_INIERROR: return error(ERROR,
			"Andor:PrepareAcquisition(): INIERROR.\n");
			break;

		case DRV_ERROR_PAGELOCK: return error(ERROR,
			"Andor:PrepareAcquisition(): ERROR_PAGELOCK.\n");
			break;

		case DRV_INVALID_FILTER: return error(ERROR,
			"Andor:PrepareAcquisition(): INVALID_FILTER.\n");
			break;

		case DRV_BINNING_ERROR: return error(ERROR,
			"Andor:PrepareAcquisition(): BINNING_ERROR.\n");
			break;

		case DRV_SPOOLSETUPERROR: return error(ERROR,
			"Andor:PrepareAcquisition(): SPOOLSETUPERROR.\n");
			break;
	}

	switch (i = StartAcquisition())
        {
		case DRV_SUCCESS: break;

		default: return error(ERROR,
			"Andor:StartAcquisition():Unknown error (%d).",i);

		case DRV_ACQUIRING: return error(ERROR,
			"Andor:StartAcquisition(): ACQUIRING.\n");
			break;

		case DRV_VXDNOTINSTALLED: return error(ERROR,
			"Andor:StartAcquisition(): VXDNOTINSTALLED.\n");
			break;

		case DRV_ERROR_ACK: return error(ERROR,
			"Andor:StartAcquisition(): ERROR_ACK.\n");
			break;

		case DRV_INIERROR: return error(ERROR,
			"Andor:StartAcquisition(): INIERROR.\n");
			break;

		case DRV_ERROR_PAGELOCK: return error(ERROR,
			"Andor:StartAcquisition(): ERROR_PAGELOCK.\n");
			break;

		case DRV_INVALID_FILTER: return error(ERROR,
			"Andor:StartAcquisition(): INVALID_FILTER.\n");
			break;

		case DRV_BINNING_ERROR: return error(ERROR,
			"Andor:StartAcquisition(): BINNING_ERROR.\n");
			break;

		case DRV_SPOOLSETUPERROR: return error(ERROR,
			"Andor:StartAcquisition(): SPOOLSETUPERROR.\n");
			break;
	}

	andor_setup.running = TRUE;

	return NOERROR;

} /* andor_start_acquisition() */

/************************************************************************/
/* andor_abort_acquisition()						*/
/*									*/
/* Start acquiring data.						*/
/* Returns error level.							*/
/************************************************************************/

int andor_abort_acquisition(void)
{ 
	switch (AbortAcquisition())
        {
		case DRV_SUCCESS: break;

		default: return error(ERROR,
			"Andor:AbortAcquisition():Unknown error.");

		case DRV_VXDNOTINSTALLED: return error(ERROR,
			"Andor:AbortAcquisition(): VXDNOTINSTALLED.\n");
			break;

		case DRV_IDLE: return error(ERROR,
			"Andor:AbortAcquisition(): Camera IDLE.\n");
			break;
	}

	andor_setup.running = FALSE;

	if (andor_wait_for_data(2) != NOERROR) return ERROR;

	return NOERROR;

} /* andor_abort_acquisition() */

/************************************************************************/
/* andor_get_status()							*/
/*									*/
/* Get the statuis of the camera.					*/
/* Returns status.							*/
/************************************************************************/

int andor_get_status(void)
{ 
	int	status;

	switch (GetStatus(&status))
        {
		case DRV_SUCCESS: break;

		default: return error(ERROR,
			"Andor:GetStatus():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
			"Andor:GetStatus(): Not initialized.\n");
			break;
	}

	return status;

} /* andor_get_status() */

/************************************************************************/
/* andor_wait_for_data()						*/
/*									*/
/* Wait for the data to be available.					*/
/* Returns error level.							*/
/************************************************************************/

int andor_wait_for_data(int timeout)
{ 
	time_t start;

	start = time(NULL);

	do	
	{
		if (time(NULL) > start + timeout)
		    return error(ERROR, "Timed out while waiting for data.");

	} while (andor_get_status() == DRV_ACQUIRING);

	return NOERROR;

} /* andor_wait_for_data() */

/************************************************************************/
/* andor_wait_for_idle()                                                */
/*                                                                      */
/* Wait for the data to be available.                                   */
/* Returns error level.                                                 */
/************************************************************************/

int andor_wait_for_idle(int timeout)
{
        time_t start;

        start = time(NULL);

        do
        {
                if (time(NULL) > start + timeout)
                    return error(ERROR, "Timed out while waiting for status.");

        } while (andor_get_status() != DRV_IDLE);

        return NOERROR;

} /* andor_wait_for_idle() */

/************************************************************************/
/* andor_get_acquired_data()						*/
/*									*/
/* Get current data.							*/
/* Returns error level.							*/
/************************************************************************/

int andor_get_acquired_data(void)
{ 
	if (image_data == NULL) return 
	    error(ERROR,"Andor: Tried to collect data with no image memory.");

	switch(GetAcquiredData16(image_data, andor_setup.npix))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetAcquiredData():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetAcquiredData():Not initialized.");

		case DRV_ERROR_ACK: return error(ERROR,
		    "Andor:GetAcquiredData():Unable to communicate with card.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:GetAcquiredData():Invalid pointer.");

		case DRV_P2INVALID: return error(ERROR,
		    "Andor:GetAcquiredData():Image size is incorrect.");

		case DRV_NO_NEW_DATA: return error(ERROR,
		    "Andor:GetAcquiredData():No acquisition has taken place.");
	}
	
	return NOERROR;

} /* andor_get_acquired_data() */

/************************************************************************/
/* andor_set_temperature()						*/
/*									*/
/* Set the target temperature.						*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_temperature(int temperature)
{ 
	/* IS this OK? */

	if (temperature < andor_setup.minimum_temperature  ||
	    temperature > andor_setup.maximum_temperature)
		return error(ERROR,
		"Andor target temperature %d is outside the range of %d to %d.",
		temperature,
		andor_setup.minimum_temperature,
		andor_setup.maximum_temperature);

	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not set target temperature while camera is running.");

	/* Do it. */

	switch(SetTemperature(temperature))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetTemperature():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetTemperature():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetTemperature(): Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetTemperature(): Temperature %d invalid.",
			temperature);

		case DRV_NOT_SUPPORTED: return error(ERROR,
		    "Andor:SetTemperature(): No cooling available.");
	}
	
	andor_setup.target_temperature= temperature;

	if (verbose) error(MESSAGE, "Andor: Target temperature set to %d C.",
			temperature);
		
	return NOERROR;

} /* andor_set_temperature() */

/************************************************************************/
/* andor_get_temperature()						*/
/*									*/
/* Get the current temperature.						*/
/* Also checks if cooler is on.						*/
/* Returns error level.							*/
/************************************************************************/

int andor_get_temperature(void)
{ 
	float	temp;

	/* Are we collecting data right now? */

	//if (andor_setup.running) return error(ERROR,
		//"Can not get current temperature while camera is running.");

	/* Do it. */

	switch(GetTemperatureF(&temp))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetTemperature():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetTemperature():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetTemperature():Acqusition in progress.");

		case DRV_TEMP_OFF: 
		     andor_setup.temperature_status =
				ANDOR_TEMPERATURE_OFF;
		     break;

		case DRV_TEMP_STABILIZED: 
		     andor_setup.temperature_status =
				ANDOR_TEMPERATURE_STABILIZED;
		     break;

		case DRV_TEMP_NOT_REACHED: 
		     andor_setup.temperature_status =
				ANDOR_TEMPERATURE_NOT_REACHED;
		     break;

		case DRV_TEMP_DRIFT: 
		     andor_setup.temperature_status =
				ANDOR_TEMPERATURE_DRIFT;
		     break;

		case DRV_TEMP_NOT_STABILIZED: 
		     andor_setup.temperature_status =
				ANDOR_TEMPERATURE_NOT_STABILIZED;
		     break;
	}
	
	andor_setup.temperature = temp;

/*
	if (verbose)
	{
		error(MESSAGE, "Andor: Temperature = %.2f C.", temp);
		if (andor_setup.temperature_status == ANDOR_TEMPERATURE_OFF)
			error(MESSAGE, "Andor: Cooler OFF.");
		else
			error(MESSAGE, "Andor: Cooler ON.");
	}
*/
		
	return NOERROR;

} /* andor_get_temperature() */

/************************************************************************/
/* andor_cooler_on()							*/
/*									*/
/* Turns cooler on.							*/
/* Returns error level.							*/
/************************************************************************/

int andor_cooler_on(void)
{ 
	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not turn cooling on while camera is running.");

	/* Do it. */

	switch(CoolerON())
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:CoolerON():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:CoolerON():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:CoolerON():Acqusition in progress.");
	}
	
	if (verbose) error(MESSAGE, "Andor: Cooler turned ON.");
		
	return NOERROR;

} /* andor_cooler_on() */

/************************************************************************/
/* andor_cooler_off()							*/
/*									*/
/* Turns cooler off.							*/
/* Returns error level.							*/
/************************************************************************/

int andor_cooler_off(void)
{ 
	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not turn cooling off while camera is running.");

	/* Do it. */

	switch(CoolerOFF())
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:CoolerOFF():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:CoolerOFF():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:CoolerOFF():Acqusition in progress.");
	}
	
	if (verbose) error(MESSAGE, "Andor: Cooler turned OFF.");
		
	return NOERROR;

} /* andor_cooler_off() */

/************************************************************************/
/* andor_get_preamp_gain()						*/
/*									*/
/* Tries to find out gain of preamp for given index.			*/
/* Returns error level.							*/
/************************************************************************/

int andor_get_preamp_gain(int index, float *gain)
{ 
	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not get preamp gain while camera is running.");

	/* Is the index OK? */

	if (index < 0 || index >= andor_setup.num_preamp_gains)
		return error(ERROR, "Gain index %d is out of range (0-%d).",
			index, andor_setup.num_preamp_gains);

	/* Do it. */

	switch(GetPreAmpGain(index, gain))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetPreAmpGain():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetPreAmpGain():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetPreAmpGain():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:GetPreAmpGain():Invalid Index.");
	}
	
	return NOERROR;

} /* andor_get_preamp_gain() */

/************************************************************************/
/* andor_set_preamp_gain()						*/
/*									*/
/* Tries to set preamp to given index.					*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_preamp_gain(int index)
{ 
	float	gain;

	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not get preamp gain while camera is running.");

	if (index < 0 || index >= andor_setup.num_preamp_gains)
		return error(ERROR, "Gain index %d is out of range (0-%d).",
			index, andor_setup.num_preamp_gains);
	/* Do it. */

	switch(SetPreAmpGain(index))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetPreAmpGain():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetPreAmpGain():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetPreAmpGain():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetPreAmpGain():Invalid Index.");
	}
	
	if (andor_get_preamp_gain(index, &gain) != NOERROR) return ERROR;

	andor_setup.preamp_gain = gain;
	andor_setup.preamp_gain_index = index;

	if (verbose) error(MESSAGE, "Andor: Gain is now index %d Gain = %f.",
				index, gain);
		
	return NOERROR;

} /* andor_set_preamp_gain() */

/************************************************************************/
/* andor_set_em_advanced()						*/
/*									*/
/* Tries to find out gain of preamp for given index.			*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_em_advanced(int em_advanced)
{ 
	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not set EM advanced while camera is running.");

	/* Do it. */

	switch(SetEMAdvanced(em_advanced))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetEMAdvanced():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetEMAdvanced():Not initialized.");

		case DRV_NOT_AVAILABLE: return error(ERROR,
		    "Andor:SetEMAdvanced():EM Advanced not available.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetEMAdvanced():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetEMAdvanced():Invalid Index.");
	}
	
	andor_setup.em_advanced = em_advanced;

	if (verbose) error(MESSAGE, "Andor: EM Advanced is now %d.",
				em_advanced);
		
	return NOERROR;

} /* andor_set_em_advanced() */

/************************************************************************/
/* andor_set_em_gain()							*/
/*									*/
/* Tries to find out gain of preamp for given index.			*/
/* Returns error level.							*/
/************************************************************************/

int andor_set_em_gain(int gain)
{ 
	int	min, max;

	/* Are we collecting data right now? */

	if (andor_setup.running) return error(ERROR,
		"Can not set EM gain while camera is running.");

	/* What is the current range of gain settings? */

	switch(GetEMGainRange(&min, &max))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetEMGainRange():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetEMGainRange():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:GetEMGainRange():Acquisition in progress.");

	}
	andor_setup.minimum_em_gain = min;
	andor_setup.maximum_em_gain = max;;
	if (verbose) error(MESSAGE,
			"Andor: EM Gain range is %d to %d C.", min, max);

	if (gain < min || gain > max) return error(ERROR,
		"Gain %d is out of range (%d-%d).", gain, min, max);

	/* Do it. */

	switch(SetEMCCDGain(gain))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetEMCCDGain():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetEMCCDGaiN():Not initialized.");

		case DRV_NOT_AVAILABLE: return error(ERROR,
		    "Andor:SetEMCCDGain():EM Advanced not available.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetEMCCDGain():Acqusition in progress.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetEMCCDGain():Invalid Gain.");
	}
	
	andor_setup.em_gain = gain;

	if (verbose) error(MESSAGE, "Andor: EM gain is now %d.", gain);
		
	return NOERROR;

} /* andor_set_em_gain() */

/************************************************************************/
/* andor_get_total_number_images_acquired()				*/
/*									*/
/* Tries to find out how many images have been acquired. Returns ERROR	*/
/* if there is a problem.						*/
/************************************************************************/

int andor_get_total_number_images_acquired(void)
{
	int	 num;

	switch(GetTotalNumberImagesAcquired(&num))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetEMCCDGain():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetEMCCDGaiN():Not initialized.");
	}

	return num;

} /* andor_get_total_number_images_acquired() */

/************************************************************************/
/* andor_get_oldest_image()						*/
/*									*/
/* Get oldest image in buffer.						*/
/* Returns error level.							*/
/************************************************************************/

int andor_get_oldest_image(void)
{ 
	if (image_data == NULL) return 
	    error(ERROR,"Andor: Tried to collect data with no image memory.");

	switch(GetOldestImage16(image_data, andor_setup.npix))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:GetAcquiredData():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:GetAcquiredData():Not initialized.");

		case DRV_ERROR_ACK: return error(ERROR,
		    "Andor:GetAcquiredData():Unable to communicate with card.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:GetAcquiredData():Invalid pointer.");

		case DRV_P2INVALID: return error(ERROR,
		    "Andor:GetAcquiredData():Image size is incorrect.");

		case DRV_NO_NEW_DATA: return error(ERROR,
		    "Andor:GetAcquiredData():No acquisition has taken place.");
	}
	
	return NOERROR;

} /* andor_get_oldest_image() */

/************************************************************************/
/* andor_get_vertical_speed()                                           */
/*                                                                      */
/* Tries to find out value of vertical_speed for given index.           */
/* Returns error level.                                                 */
/************************************************************************/

int andor_get_vertical_speed(int index, float *speed)
{
        /* Are we collecting data right now? */

        if (andor_setup.running) return error(ERROR,
                "Can not get Vertical Speed while camera is running.");

        /* Is the index OK? */

        if (index < 0 || index >= andor_setup.num_vertical_speeds)
                return error(ERROR, "Speed index %d is out of range (0-%d).",
                        index, andor_setup.num_vertical_speeds);
        /* Do it. */

        switch(GetVSSpeed(index, speed))
        {
                case DRV_SUCCESS: break;

                default: return error(ERROR,
                    "Andor:GetVSSpeed():Unknown error.");

                case DRV_NOT_INITIALIZED: return error(ERROR,
                    "Andor:GetVSSpeed():Not initialized.");

                case DRV_ACQUIRING: return error(ERROR,
                    "Andor:VSSpeed():Acqusition in progress.");

                case DRV_P1INVALID: return error(ERROR,
                    "Andor:VSSpeed():Invalid Index %d.",index);
        }

        return NOERROR;

} /* andor_get_vertical_speed() */

/************************************************************************/
/* andor_set_vertical_speed()                                           */
/*                                                                      */
/* Tries to set Vertical Speed to given index.				*/
/* Returns error level.                                                 */
/************************************************************************/

int andor_set_vertical_speed(int index)
{
        float   speed;

        /* Are we collecting data right now? */

        if (andor_setup.running) return error(ERROR,
                "Can not set Vertical Speed while camera is running.");

        if (index < 0 || index >= andor_setup.num_vertical_speeds)
                return error(ERROR, "VSpeed index %d is out of range (0-%d).",
                        index, andor_setup.num_vertical_speeds);
        /* Do it. */

        switch(SetVSSpeed(index))
        {
                case DRV_SUCCESS: break;

                default: return error(ERROR,
                    "Andor:SetVSSpeed():Unknown error.");

                case DRV_NOT_INITIALIZED: return error(ERROR,
                    "Andor:SetVSSpeed():Not initialized.");

                case DRV_ACQUIRING: return error(ERROR,
                    "Andor:SetVSSpeed():Acqusition in progress.");

                case DRV_P1INVALID: return error(ERROR,
                    "Andor:SetVSSpeed():Invalid Index %d.", index);
        }

        if (andor_get_vertical_speed(index, &speed) != NOERROR) return ERROR;

        andor_setup.vertical_speed = speed;
        andor_setup.vertical_speed_index = index;

        if (verbose) error(MESSAGE,
			"Andor: VSpeed is now index %d Speed = %.2f uS.",
                        index, speed);

	return NOERROR;

} /* andor_set_vertical_speed() */

/************************************************************************/
/* andor_get_horizontal_speed()                                         */
/*                                                                      */
/* Tries to find out value of horizontal_speed for given index.         */
/* Returns error level.                                                 */
/************************************************************************/

int andor_get_horizontal_speed(int type, int index, float *speed)
{
        /* Are we collecting data right now? */

        if (andor_setup.running) return error(ERROR,
                "Can not get Horizontal Speed while camera is running.");

        /* Is the index OK? */

        if (index < 0 || index >= andor_setup.num_horizontal_speeds[type])
                return error(ERROR, "Speed index %d is out of range (0-%d).",
                        index, andor_setup.num_horizontal_speeds[type]);
        /* Do it. */

        switch(GetHSSpeed(0, type, index, speed))
        {
                case DRV_SUCCESS: break;

                default: return error(ERROR,
                    "Andor:GetHSSpeed():Unknown error.");

                case DRV_NOT_INITIALIZED: return error(ERROR,
                    "Andor:GetHSSpeed():Not initialized.");

                case DRV_ACQUIRING: return error(ERROR,
                    "Andor:HSSpeed():Acqusition in progress.");

                case DRV_P1INVALID: return error(ERROR,
                    "Andor:HSSpeed():Invalid Index %d.",index);
        }

        return NOERROR;

} /* andor_get_horizontal_speed() */

/************************************************************************/
/* andor_set_horizontal_speed()                                         */
/*                                                                      */
/* Tries to set Horizontal Speed to given index.			*/
/* Returns error level.                                                 */
/************************************************************************/

int andor_set_horizontal_speed(int type, int index)
{
        float   speed;

        /* Are we collecting data right now? */

        if (andor_setup.running) return error(ERROR,
                "Can not set Horizontal Speed while camera is running.");

        if (index < 0 || index >= andor_setup.num_horizontal_speeds[type])
                return error(ERROR, "HSpeed index %d is out of range (0-%d).",
                        index, andor_setup.num_horizontal_speeds[type]);

        /* Do it. */

        switch(SetHSSpeed(type, index))
        {
                case DRV_SUCCESS: break;

                default: return error(ERROR,
                    "Andor:SetHSSpeed():Unknown error.");

                case DRV_NOT_INITIALIZED: return error(ERROR,
                    "Andor:SetHSSpeed():Not initialized.");

                case DRV_ACQUIRING: return error(ERROR,
                    "Andor:SetHSSpeed():Acqusition in progress.");

                case DRV_P1INVALID: return error(ERROR,
                    "Andor:SetHSSpeed():Invalid Index %d.", index);
        }

        if (andor_get_horizontal_speed(type, index, &speed) != NOERROR)
		return ERROR;

        andor_setup.horizontal_speed[type] = speed;
        andor_setup.horizontal_speed_index[type] = index;

        if (verbose) error(MESSAGE,
		"Andor: HSpeed type %d is now index %d Speed = %.2f MHz.",
		type, index, speed);

	return NOERROR;

} /* andor_set_horizontal_speed() */

/************************************************************************/
/* andor_set_camera_link()						*/
/*									*/
/* Turn camera link interface on or off.				*/
/************************************************************************/

int andor_set_camera_link(int onoff)
{

	switch(SetCameraLinkMode(onoff))
	{
		case DRV_SUCCESS: break;

		default: return error(ERROR,
		    "Andor:SetCameraLinkMode():Unknown error.");

		case DRV_NOT_INITIALIZED: return error(ERROR,
		    "Andor:SetCameraLinkMode():Not initialized.");

		case DRV_ACQUIRING: return error(ERROR,
		    "Andor:SetCameraLinkMode():Acquisition in progress.");

		case DRV_NOT_SUPPORTED: return error(ERROR,
		    "Andor:SetCameraLinkMode():Camera Link Not Supported.");

		case DRV_P1INVALID: return error(ERROR,
		    "Andor:SetCameraLinkMode():Bad data.");
	}

	if (verbose)
	{
		if (onoff)
		     error(MESSAGE,"Camera Link Enabled.");
		else
		     error(MESSAGE,"Camera Link Disabled.");
	}

	return NOERROR;

} /* andor_set_camera_link() */

/************************************************************************/
/* andor_get_single_frame()                                             */
/*                                                                      */
/* Gets one frame and saves it                                          */
/************************************************************************/

int andor_get_single_frame(void)
{
	int status;

	andor_start_acquisition();

	andor_get_acquired_data();
	
   	GetStatus(&status);
        while(status==DRV_ACQUIRING) GetStatus(&status);
        printf("SaveAsFITS %d\n", SaveAsFITS("./image.fit", 4));
	
	return NOERROR;
}

