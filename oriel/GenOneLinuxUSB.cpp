/*! 
* This Source Code Form is subject to the terms of the Mozilla Public
* License, v. 2.0. If a copy of the MPL was not distributed with this file,
* You can obtain one at http://mozilla.org/MPL/2.0/.
*
* Copyright(c) 2010 Apogee Instruments, Inc. 
* \class GenOneLinuxUSB 
* \brief Usb interface for *nix systems. 
* 
*/ 

#include "GenOneLinuxUSB.h" 
#include <cstring>
#include <sstream>
#include <stdio.h>

const int32_t INTERFACE_NUM = 0x0;
const uint32_t TIMEOUT = 10000;  
const uint16_t FW_VENDOR = 0x104d;
const uint16_t FW_PRODUCT = 0x1011;
static int ep_in_addr  = 0x81;
static int ep_out_addr = 0x02;

//////////////////////////// 
// CTOR
GenOneLinuxUSB::GenOneLinuxUSB(const uint16_t DeviceNum )
{

	int32_t result = libusb_init( &m_Context );
	if( result )
	{
		std::stringstream ss;
		ss << "libusb_init failed with error = " << result;
	}

	std::string errMsg;

	if( !OpenDeviceHandle(DeviceNum, errMsg) )
	{
		//failed to find device clean up and throw
		libusb_exit( m_Context);
	}

    //claim the interface
    int32_t getInterface = libusb_claim_interface( m_Device, INTERFACE_NUM );

    if( 0 != getInterface )
    {
        //clean up
        libusb_close( m_Device );
        libusb_exit( m_Context );

        //die
     }

    //log what device we have connected to
    std::stringstream ss;
    ss << "Connection to device " << m_DeviceNum << " is open.";

}

////////////////////////////
// DTOR 
GenOneLinuxUSB::~GenOneLinuxUSB() 
{ 
    int32_t result = 0;
    // if we are in an error state call a reset on the 
    // the USB port
    if(   m_IoError )
    {

        result = libusb_reset_device( m_Device );

        if( 0 != result )
        {
            std::stringstream ss;
			ss << "libusb_reset_device error = " << result;
         }

    }

    result = libusb_release_interface( m_Device, INTERFACE_NUM );

    if( 0 != result )
    {
        std::stringstream ss;
        ss << "libusb_release_interface error = " << result;
    }

	libusb_close( m_Device );
	libusb_exit( m_Context );

    //log what device we have disconnected from
    std::stringstream ss;
    ss << "Connection to device " << m_DeviceNum << " is closed.";

} 

////////////////////////////
//	OPEN		DEVICE		HANDLE
bool GenOneLinuxUSB::OpenDeviceHandle(const uint16_t DeviceNum,
 		                      std::string & err)
{
	//pointer to pointer of device, used to retrieve a list of devices
	libusb_device **devs = NULL;

	//get the list of devices
	const int32_t count = libusb_get_device_list(m_Context, &devs);

	bool result = false;
        int found=0;
	int32_t i=0;
	for(; i < count; ++i)
	{
		libusb_device_descriptor desc;
		int32_t r = libusb_get_device_descriptor(devs[i], &desc);
		if (r < 0)
		{
			//ignore and go to the next device
			continue;
		}

		//are we an apogee device
		if( desc.idVendor == FW_VENDOR && desc.idProduct == FW_PRODUCT )
		{
                        found++;
			const uint16_t num = libusb_get_device_address(devs[i]);
			if( found == DeviceNum)
			{
				//we found the device we want try to open
				//handle to it
				int32_t notOpened = libusb_open(devs[i], &m_Device);

				if( notOpened )
				{
					std::stringstream ss;
					ss << "libusb_open error = " << notOpened;
					err = ss.str();
					//bail out of for loop here
					break;
				}

				//save the descriptor information
				memcpy( &m_DeviceDescriptor, &desc, sizeof(libusb_device_descriptor) );

				//set the return value and break out of for loop
				result = true;
				break;

			}
		}
	}

	//see if we found a device
	if( count == i )
	{
		err.append("No device found");
	}

	libusb_free_device_list(devs, 1);


	return result;

}



//////////////////////////// 
//      IS     ERROR
bool GenOneLinuxUSB::IsError()
{
    // only check the ctrl xfer error, because
    // other error handling *should* clear the
    // m_ReadImgError
    return ( m_IoError ? true : false );
}


void GenOneLinuxUSB::write_cmd(unsigned char *cmd)
{
    /* To send a char to the device simply initiate a bulk_transfer to the
     * Endpoint with address ep_out_addr.
     */
    int actual_length;
    actual_length = strlen(cmd);
    if (libusb_bulk_transfer(m_Device, ep_out_addr, cmd, actual_length,
                             &actual_length, 0) < 0) {
        fprintf(stderr, "Error while sending char\n");
    }
}

int GenOneLinuxUSB::read_result(unsigned char *data, int size)
{
    /* To receive characters from the device initiate a bulk_transfer to the
     * Endpoint with address ep_in_addr.
     */
    int actual_length;
    int rc = libusb_bulk_transfer(m_Device, ep_in_addr, data, size, &actual_length,
                                  1000);
    if (rc == LIBUSB_ERROR_TIMEOUT) {
        printf("timeout (%d)\n", actual_length);
        return -1;
    } else if (rc < 0) {
        fprintf(stderr, "Error while waiting for char\n");
        return -1;
    }

    return actual_length;
}



