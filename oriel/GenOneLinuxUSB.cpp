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

const int32_t INTERFACE_NUM = 0x0;
const uint32_t TIMEOUT = 10000;  
const uint16_t FW_VENDOR = 0x1234;
const uint16_t FW_PRODUCT = 0x5678;

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
			const uint16_t num = libusb_get_device_address(devs[i]);
			if( num == DeviceNum)
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
// APN      USB        REQUEST      IN
void GenOneLinuxUSB::UsbRequestIn(uint8_t RequestCode,
		uint16_t	Index, uint16_t	Value,
		uint8_t * ioBuf, uint32_t BufSzInBytes)
{
	const int32_t result = libusb_control_transfer(
				m_Device,
				LIBUSB_ENDPOINT_IN | LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_RECIPIENT_DEVICE,
				RequestCode,
				Value,
				Index,
				ioBuf,
				BufSzInBytes,
				TIMEOUT);

	if( result < 0 )
	{
        m_IoError = true;
		std::stringstream err;
		err << "UsbRequestIn failed with error ";
		err << result << ".  ";
		err << "RequestCode = " << std::hex << static_cast<int32_t>(RequestCode);
		err << " : Index = " << Index << " : Value = " << Value;
	}

    m_IoError = false;
}

////////////////////////////
// APN      USB        REQUEST      OUT
void GenOneLinuxUSB::UsbRequestOut(uint8_t RequestCode,
		uint16_t Index, uint16_t Value,
		const uint8_t * ioBuf, uint32_t BufSzInBytes)
{
	const int32_t result = libusb_control_transfer(
					m_Device,
					LIBUSB_ENDPOINT_OUT | LIBUSB_REQUEST_TYPE_VENDOR | LIBUSB_RECIPIENT_DEVICE,
					RequestCode,
					Value,
					Index,
					const_cast<uint8_t*>(ioBuf),
					BufSzInBytes,
					TIMEOUT);

	if( result < 0 )
	{
            m_IoError = true;
		    std::stringstream err;
		    err << "UsbRequestOut failed with error ";
		    err << result << ".  ";
		    err << "RequestCode = " << std::hex << static_cast<int32_t>(RequestCode);
		    err << " : Index = " << Index << " : Value = " << Value;
	}

    m_IoError = false;
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

