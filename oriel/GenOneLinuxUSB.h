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
		GenOneLinuxUSB( const uint16_t DeviceNum );
		virtual ~GenOneLinuxUSB();

		void GetVendorInfo(uint16_t & VendorId,
		uint16_t & ProductId, uint16_t  & DeviceId);

                void write_cmd(unsigned char *cmd);
                int read_result(unsigned char *res, int size);

	        bool IsError();

	        uint16_t GetDeviceNum() { return m_DeviceNum; }

		bool OpenDeviceHandle (const uint16_t DeviceNum,
 		                       std::string & err);

		libusb_context * m_Context;
		libusb_device_handle  * m_Device;
		libusb_device_descriptor m_DeviceDescriptor;
	        bool m_IoError;
	        uint16_t m_DeviceNum;

	        GenOneLinuxUSB(const GenOneLinuxUSB&);
	        GenOneLinuxUSB& operator=(GenOneLinuxUSB&);
}; 

#endif


