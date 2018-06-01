

#
# This script assists the user in selecting the appropriate kernel module
# for an andor CCD camera driver.
#
wm withdraw .

set kext "o"
set marg ""
if { [file exists /usr/share/hal/fdi] } {
     exec sudo mkdir -p /usr/share/hal/fdi/information/20thirdparty
     exec sudo mkdir -p /usr/share/hal/fdi/policy/20thirdparty
     exec sudo cp $env(SPECKLE_DIR)/config/config/60-camera-andorusb.fdi /usr/share/hal/fdi/information/20thirdparty/.
     exec sudo cp $env(SPECKLE_DIR)/config/config/60-andorusb-camera-policy.fdi /usr/share/hal/fdi/policy/20thirdparty/.
     exec sudo cp $env(SPECKLE_DIR)/config/config/andorusb-set-procperm /usr/libexec/.
     set it [tk_dialog .d "andor" "andor HAL support configured" {} -1 OK]
}
if { [file exists /etc/udev/udev.conf] } {
     exec sudo cp $env(SPECKLE_DIR)/config/config/60-andor.rules /etc/udev/rules.d/.
     set it [ tk_dialog .d "andor-U" "andor-U udev support configured" {} -1 OK]   
} else {
if { [file exists /etc/hotplug/usb.usermap] } {
     set fusb [open /etc/hotplug/usb.usermap a]
     puts $fusb "# andor andor-U series CCD camera"
     puts $fusb "andor-andoru  0x0003      0x125c   0x0010    0x0000       0x0000      0x00         0x00            0x00            0x00            0x00               0x00               0x00000000"
     close $fusb
     exec cp $env(SPECKLE_DIR)/config/config/andor-andoru /etc/hotplug/usb/.
     exec chmod 755 /etc/hotplug/usb/andor-andoru
     set it [ tk_dialog .d "andor-U" "andor-U hotplug support configured" {} -1 OK]
} else {
     set it [ tk_dialog .d "andor-U" "andor-U models require hotplug support,\n please install it first" {} -1 OK]           
}


