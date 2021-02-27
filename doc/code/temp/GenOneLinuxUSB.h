/** 
 * \file GenOneLinuxUSB.h
 * \brief Simple usb device interface class
 * 
 * This class provides a minimal interface for USB device control
 */

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


#ifndef GENONELINUXUSB_INCLUDE_H__ 
#define GENONELINUXUSB_INCLUDE_H__ 

#include <string>
#include <vector>
#include <libusb-1.0/libusb.h>


class GenOneLinuxUSB
{ 
    public: 
/** 
 * \brief Constructor initializes libusb and Opens the numbered device
 * \param DeviceNum Number of the required device
 *
 */
		GenOneLinuxUSB( const uint16_t DeviceNum );

/** 
 * \brief Destructor closes and resets the device
 *
 */
		virtual ~GenOneLinuxUSB();

		void GetVendorInfo(uint16_t & VendorId,
		uint16_t & ProductId, uint16_t  & DeviceId);

/** 
 * \brief Write a command to the device
 * \param cmd Text of command
 *
 */
                void write_cmd(unsigned char *cmd);
/** 
 * \brief Read response from a device
 * \param data The response string
 * \param size Number of bytes returned
 *
 */
                int read_result(unsigned char *res, int size);

/** 
 * \brief Check if an error condition
 *
 */
	        bool IsError();

	        uint16_t GetDeviceNum() { return m_DeviceNum; }

/** 
 * \brief Open the device and check vendor and descriptor
 * \param DeviceNum Number of the required device
 * \param err Error code
 *
 */
		bool OpenDeviceHandle (const uint16_t DeviceNum,
 		                       std::string & err);
/** 
 * \brief Return the address of the device
 *
 */
                int GetAddress();
/** 
 * \brief Return the bus number of the device
 *
 */
                int GetBus();

		libusb_context * m_Context;
		libusb_device_handle  * m_Device;
		libusb_device_descriptor m_DeviceDescriptor;
	        bool m_IoError;
	        uint16_t m_DeviceNum;
                uint16_t uBus;
                uint16_t uAddress;

	        GenOneLinuxUSB(const GenOneLinuxUSB&);
	        GenOneLinuxUSB& operator=(GenOneLinuxUSB&);
}; 

#endif


