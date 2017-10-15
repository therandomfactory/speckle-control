
# Generic WIYN Client: names.tcl

#  Module name:
#       names.tcl

#  Function:
#	Used at runtime to define the SSDA mapping.  

#  WARNING:
#	The order of these items is very important, and must never 
#	change (or old archives	are made obsolete). New items must
#	be added at the end of the list.  Also, the 'names.tcl'
#	files on each machine must be the same.

#  Description:
#       The default .tcl file loaded by GWC into the names library.

#  Language:
#     C

#  Support: Bob Marshall, NOAO

#

#  History:
#     12 Dec 94: Version 2 - goes into CVS
#     20 Nov 97: added GCC streams  (DJM)
#
#  Rcs Id:  $Id: names.tcl,v 1.23 2013/11/20 21:22:15 behzad Exp $


# Add systems
nadd system ""
nadd system ARC
nadd system ASTRO1
nadd system ASTRO2
nadd system GEMINI
nadd system HSP
nadd system KECK
nadd system KPNO_4M
nadd system KPNO_84
nadd system PBO_16
nadd system PBO_36
nadd system SAL
nadd system WISP
nadd system WIYN
nadd system WUPPE
nadd system KPNO_36
nadd system KPNO_CF
# phantom tcs
nadd system PHTCS
# <behzad 22 Jan 2004: newfirm streams/>
nadd system CTIO_4M

#Add actions
nadd action NONE
nadd action ABORT
nadd action ACCELERATE
nadd action ADJUST
nadd action ARM 
nadd action BEGIN
nadd action CANCEL
nadd action CAPTURE
nadd action CLEAR
nadd action CLOSE
nadd action CONTINUE
nadd action DECELERATE
nadd action DELETE
nadd action DISABLE
nadd action DISARM
nadd action DISENGAGE
nadd action DUMP
nadd action ED_DISABLE
nadd action ED_ENABLE
nadd action ENABLE
nadd action END
nadd action ENGAGE
nadd action FREE
nadd action GO
nadd action INITIALIZE
nadd action INSERT
nadd action INSTALL
nadd action KILL
nadd action LOGIN
nadd action LOGOUT
nadd action MARK
nadd action MASK_BIT_CLEAR
nadd action MASK_BIT_SET
nadd action MASK_DEFAULT
nadd action MASK_SET
nadd action MAXIMIZE
nadd action MINIMIZE
nadd action MODIFY
nadd action OFF
nadd action ON
nadd action OPEN
nadd action PAUSE
nadd action PERIOD_DECREMENT
nadd action PERIOD_DEFAULT
nadd action PERIOD_INCREMENT
nadd action PERIOD_SET
nadd action QUERY
nadd action QUIT
nadd action REMOVE
nadd action RESET
nadd action RESTART
nadd action RESUME
nadd action SEARCH
nadd action SELECT
nadd action SEND
nadd action SET
nadd action SKIP
nadd action START
nadd action STOP
nadd action SUBSCRIBE
nadd action SUSPEND
nadd action TRIGGER
nadd action UNSUBSCRIBE
nadd action ED_TRIGGER
nadd action ID_REQUEST
nadd action STREAM_REQUEST
nadd action EXECUTE
nadd action SHOW
nadd action SEND_CLI
#device action status
nadd action ACKNOWLEDGED
nadd action BUSY
nadd action FAILED
nadd action TRIGGER
nadd action ERROR
nadd action DONE
# more devices
nadd action REBOOT
# MSE
nadd action MOVE
nadd action STATUS
nadd action FORWARD
nadd action REVERSE
nadd action INDEX
# PFCCD
nadd action CENTER
# IASCOMM sg 6/17/2008
nadd action HOME
nadd action PARK

#devices
nadd device ALL
nadd device ADC
nadd device AZIMUTH
nadd device BORESIGHT
nadd device CAMERA
nadd device CASS
nadd device CATALOG_AGK3
nadd device CATALOG_FK4
nadd device CATALOG_FK5
nadd device CATALOG_GC
nadd device CATALOG_GSC
nadd device CATALOG_PERTH70
nadd device CATALOG_PERTH75
nadd device CATALOG_SAO
nadd device CATALOG_YBS
nadd device COMPUTER
nadd device COUNTERBALANCE
nadd device COUNTERBALANCE_LOWER
nadd device COUNTERBALANCE_UPPER
nadd device DEVICE
nadd device DOME
nadd device EDMG
nadd device ELEVATION
nadd device FLATFIELD
nadd device FLATFIELD1
nadd device FLATFIELD2
nadd device GEOMETRY
nadd device HXFORM
nadd device IAS_MANAGER
nadd device IMAGE
nadd device MAIN
nadd device MDCS
nadd device MIRROR
nadd device MIRROR_COVER
nadd device MNIR
nadd device NIR
nadd device OSS_MANAGER
nadd device PADDLE
nadd device PRIMARY
nadd device PROBE1
nadd device PROBE2
nadd device SECONDARY
nadd device SNAPSHOT
nadd device SSD
nadd device TARGET
nadd device TELESCOPE
nadd device TERTIARY
nadd device THERMOCOUPLE
nadd device TIME
nadd device TPRO
nadd device UPS
nadd device VSIO
nadd device WEATHER
nadd device WNIR
nadd device THERMAL
nadd device ACTIVE
nadd device TPOINT
nadd device INVERTER
nadd device IDSERVER
nadd device MONITOR
nadd device NAMESTREAM
nadd device COMMSTATUS
nadd device ROUTERCLI
nadd device UPPERBALANCE
nadd device LOWERBALANCE
nadd device SHUTTER
nadd device FILTER
nadd device FIELD
nadd device ASSIGN
nadd device GUIDER
nadd device GRIPPER
# added devices for IAS 9512.01 jll
nadd device POWERSUPPLY
nadd device SPARESTAGE
nadd device DARKSLIDE
nadd device GUIDEPROBE
nadd device FOCUSPROBE
nadd device CALIBLAMPS
nadd device FEEDMIRROR
nadd device WFSCAM
# added for 4m PMTC bob 8 Mar 96
nadd device PMCCH
# MSE
nadd device CAMERA1
nadd device CAMERA2
nadd device ADC1
nadd device ADC2
nadd device PEDESTAL
nadd device WATCHER
# PFCCD
nadd device SCANTABLE
nadd device TV
# TCS
nadd device OFFSET
# added for arInt/icsInfo djm 9 Jan 97
nadd device ARINT
# 4m ICC/GCC
nadd device INSTRUMENT
nadd device COLLIMATOR
nadd device DECKER
nadd device SLIT
nadd device GRATING
nadd device DISPERSER
nadd device PRESLIT
nadd device POSTSLIT
nadd device LENS
nadd device VIEWER
nadd device BAFFLE
nadd device COMPARISON
# 4m GCC
nadd device NORTH
nadd device SOUTH
nadd device ROTATOR
# 4m rgwc 
nadd device TELESCOPE
nadd device RA
nadd device DEC
# 4m VDU
nadd device ALERT
# new VDU
nadd device SCREEN1
nadd device SCREEN2
nadd device SCREEN3
# nodding
nadd device NOD
# 4m f/8
nadd device FOCUS
nadd device TIP
nadd device TILT
# WIYN dust monitor
nadd device PARTICLE_COUNTER
# WTTM devices
nadd device WTTMMIRROR
nadd device CODE
nadd device APD
nadd device DIO
nadd device GAIN
# WIYN CassIAS
nadd device X
nadd device Y 
# WIYN Universal Fiber Foot
nadd device SLIDE                                                                  

# <behzad 14 Jan 2003: arcon streams>
nadd device BENCH
nadd device MOSAIC
nadd device WTTM
# </behzad 14 Jan 2003: arcon streams>

# <behzad 22 Jan 2004: newfirm streams>
nadd device ECOVER
nadd device PRESSURE
nadd device VACUUM
# </behzad 22 Jan 2004: newfirm streams>

# <behzad 27 July 2005: Shelby's x-z slide/>
nadd device Z

# <behzad 26 June 2006: HA restored/>
nadd device HA 

# <behzad 17 Aug 2006: WTTM (WHIRC Extension)>
nadd device ACQUISITION
nadd device TIPTILT 
nadd device INTEGRAL 
# </behzad 17 Aug 2006: WTTM (WHIRC Extension)>

# <behzad 7 Nov 2006: Shelby's new items>
nadd device FLAT
nadd device SOURCE
nadd device LAMP
nadd device HENEAR
nadd device QUARTZ
# </behzad 7 Nov 2006: Shelby's new items>

nadd device TEMPERATURE
nadd device TEMPERATURE_CMD
nadd device FILTER1
nadd device FILTER2

# <lana 3 April 2008: dewpoint sensor/>
nadd device SENSOR 

nadd device PRISM 

# <shelby 17 June 2010: 4m dome control>
nadd device SERVO
nadd device ENCODER
nadd device MOTOR
# </shelby 17 June 2010: 4m dome control>

# <shelby 29 April 2013: 4m PLC/>
nadd device DATA 

# <doug 29 April 2013: informs/>
nadd device WHIRC 

# <shelby 17 Sept 2013: 4m PLC/>
nadd device COMMAND

# subsystems
nadd subsystem ALL
nadd subsystem ARCHIVER
nadd subsystem CCS
nadd subsystem CLI
nadd subsystem CVT
nadd subsystem DCS
nadd subsystem DISPLAY
nadd subsystem DS
nadd subsystem GUI
nadd subsystem HPOL
nadd subsystem IAS
nadd subsystem IMAGES
nadd subsystem MOS
nadd subsystem OBJECTS
nadd subsystem OSS
nadd subsystem PMS
nadd subsystem POLARIMETER
nadd subsystem ROUTER
nadd subsystem SI1
nadd subsystem SI2
nadd subsystem SI3
nadd subsystem SI4
nadd subsystem SI5
nadd subsystem SMS
nadd subsystem SUBSYSTEM
nadd subsystem TCS
nadd subsystem TSIM
nadd subsystem BSA
nadd subsystem IPS
nadd subsystem GWC
nadd subsystem HYDRA
nadd subsystem ARCON
nadd subsystem TEST
nadd subsystem FSA 
# added for jsj by bob 28Jun95
nadd subsystem CRIS
nadd subsystem WIFOE
# added for 4m PMTC bob 8 Mar 96
nadd subsystem PMTC
# MSE
nadd subsystem MSE
# PFCCD
nadd subsystem PFCCD
# 4m Instrument Control Computer
# WIYN Integrating Camera Control
nadd subsystem ICC
# 4m Guider Control Computer
nadd subsystem GCC
# 4m new VDU
nadd subsystem VDU
# 4m f/8
nadd subsystem F8
# added for WIYN dust monitor
nadd subsystem ENVIRONMENT
# WTTM subsystem
nadd subsystem WTTM
# WIYN CassIAS
nadd subsystem CIAS
# WIYN Universal Fiber Foot
nadd subsystem WUFF
nadd subsystem FWC
# <behzad 22 Jan 2004: newfirm streams/>
nadd subsystem NEWFIRM
# <behzad 31 Mar 2005: GGC (Gold Guider Control)/>
nadd subsystem GGC
# <behzad 27 July 2005: Shelby's x-z slide/>
nadd subsystem SLIDES
# <behzad 19 Sep 2005: Shelby's dome logic status/>
nadd subsystem SES
# <behzad 2 Mar 2006: WIYN new instruments/>
nadd subsystem ODI
nadd subsystem QUOTA

# <behzad 7 Nov 2006: Shelby's new items>
nadd subsystem TCP 
# </behzad 7 Nov 2006: Shelby's new items>

# <shelby 30 Jan 2007: Passive Support Subsystem/>
nadd subsystem PSS

nadd subsystem WHIRC

# <lana 3 April 2008: dewpoint sensor/>
nadd subsystem DEWPOINT 

nadd subsystem WFS

# <lana 8 May 2008: sound server/>
nadd subsystem SOUND 

# <behzad 21 April 2010: MOP for INFORMS (request from Dave Mills)/>
nadd subsystem MOP 

# <shelby 29 April 2013: 4m PLC/>
nadd subsystem PLC 

# <bob 2013-10-03: KOSMOS/COSMOS>
nadd subsystem KOSMOS
nadd subsystem COSMOS

# Units
nadd units ""
nadd units AMPS
nadd units ARCSECONDS
nadd units BTUS
nadd units CALORIES
nadd units CENTIMETERS
nadd units CENTURIES
nadd units COULOMBS
nadd units COUNTS
nadd units CYCLES
nadd units DAYS
nadd units DEGREES
nadd units DYNES
nadd units ERGS
nadd units FEET
nadd units GAUSS
nadd units GRAMS
nadd units HERTZ
nadd units HOURS
nadd units INCHES
nadd units JOULES
nadd units KILOGRAMS
nadd units KILOMETERS
nadd units KNOTS
nadd units LIGHTYEARS
nadd units METERS
nadd units MICROMETERS
nadd units MICRORADIANS
nadd units MILES
nadd units MILLIARCSECONDS
nadd units MILLIMETERS
nadd units MINUTES
nadd units MONTHS
nadd units NEWTONS
nadd units OHMS
nadd units PARSECS
nadd units PASCALS
nadd units POUNDS
nadd units RADIANS
nadd units REVOLUTIONS
nadd units SECONDS
nadd units SLUGS
nadd units STEPS
nadd units UNITLESS
nadd units VOLTS
nadd units WATTS
nadd units YARDS
nadd units YEARS
nadd units STRUCT_S_PMS
nadd units STRUCT_INFODGH
nadd units NONE
# 4m ICC/GCC
nadd units MICRONS
nadd units ENCODER
nadd units ANGSTROMS
nadd units ARCSEC

nadd attributes ALL
nadd attributes ACCELERATION
nadd attributes ACTUATOR
nadd attributes AIR
nadd attributes ALARM
nadd attributes ALTITUDE
nadd attributes AMPLIFIER
nadd attributes ANGLE
nadd attributes AREA
nadd attributes ATTRIBUTE
nadd attributes AXIS
nadd attributes BETA
nadd attributes BITLIST
nadd attributes BRAKE
nadd attributes BRIGHTNESS
nadd attributes CENTURY
nadd attributes CLAMP
nadd attributes COMMENT
nadd attributes CURRENT
nadd attributes DATA
nadd attributes DAY
nadd attributes DECELERATION
nadd attributes JOGSPEED
nadd attributes DELAY
nadd attributes DELTA_AT
nadd attributes DELTA_UT
nadd attributes DEMAND
nadd attributes DISTANCE
nadd attributes EDM
nadd attributes ENCODER
nadd attributes ENCODER_CONSTANT
nadd attributes ENCODER_MODE
nadd attributes EPOCH
nadd attributes EQUINOX
nadd attributes FILTER
nadd attributes FLIPPER
nadd attributes FOCUS
nadd attributes FOOTER
nadd attributes FREQUENCY
nadd attributes GAIN
nadd attributes GAST
nadd attributes GMST
nadd attributes HEADER
nadd attributes HORIZON
nadd attributes HOUR
nadd attributes HOUR_ANGLE
nadd attributes INDEX
nadd attributes INDEX_POSITION
nadd attributes INTERFACE
nadd attributes INTERLOCK
nadd attributes INTERPOLATOR
nadd attributes IRIG
nadd attributes JERK
nadd attributes LAST
nadd attributes LATITUDE
nadd attributes LEFT
nadd attributes LIMIS
nadd attributes LMST
nadd attributes LOAD_CELL
nadd attributes LOAD_LIMITS
nadd attributes LOAD_RANGE
nadd attributes LONGITUDE
nadd attributes LOWER
nadd attributes LVDT
nadd attributes MAPPER
nadd attributes MASS
nadd attributes MINUTE
nadd attributes MONTH
nadd attributes MOTION
nadd attributes MOTOR_RATIO
nadd attributes NAME
nadd attributes OFFSET
nadd attributes PAGE
nadd attributes PARALLAX
nadd attributes PERIOD
nadd attributes PIXLIST
nadd attributes POINTER
nadd attributes POLARIZATION
nadd attributes POLE
nadd attributes PORT
nadd attributes POSITION
nadd attributes POWER
nadd attributes PRESSURE
nadd attributes REGULATOR
nadd attributes RESOLUTION
nadd attributes RIGHT
nadd attributes DEADBAND
nadd attributes ROTATOR
nadd attributes SEARCHED
nadd attributes SEARCHING
nadd attributes SECOND
nadd attributes SERVO
nadd attributes SIMULATOR
nadd attributes SLEWER
nadd attributes MODEL
nadd attributes SPEED
nadd attributes STATE
nadd attributes STATUS
nadd attributes STEPPER
nadd attributes TAI
nadd attributes TDB
nadd attributes TDT
nadd attributes TEMPERATURE
nadd attributes THRESHOLD
nadd attributes TORQUE
nadd attributes TRACK
nadd attributes TRACKER
nadd attributes UPPER
nadd attributes UT1
nadd attributes UTC
nadd attributes VACUUM
nadd attributes VELOCITY
nadd attributes VOLTAGE
nadd attributes VOLUME
nadd attributes WAVELENGTH
nadd attributes WEEK
nadd attributes WORK
nadd attributes XPOLE
nadd attributes YEAR
nadd attributes YPOLE
nadd attributes ZENITH
nadd attributes ZENITH_DISTANCE
nadd attributes SOFTWARE_DEBUG
nadd attributes SOFTWARE_VERBOSE
nadd attributes SOFTWARE_STRUCT
nadd attributes FORCE
nadd attributes TF
nadd attributes TX
nadd attributes IE
nadd attributes IA
nadd attributes CA
nadd attributes AN
nadd attributes AW
nadd attributes NPAE
nadd attributes ACES
nadd attributes ACEC
nadd attributes ECES
nadd attributes ECEC
nadd attributes MNRX
nadd attributes MNRY
nadd attributes WNRX
nadd attributes WNRY
nadd attributes AUX1A
nadd attributes AUX1S
nadd attributes AUX1E
nadd attributes PAA
nadd attributes PZZ
nadd attributes STEPPER_POWER
nadd attributes STEPPER_SPEED
nadd attributes STEPPER_ACCEL
nadd attributes CMDSTREAM
# 4m ICC/GCC
nadd attributes IDENT
nadd attributes PID
nadd attributes HOST
nadd attributes LINK
nadd attributes MINIMUM
nadd attributes MAXIMUM
nadd attributes TOLERANCE
nadd attributes WIDTH
# WTTM attributes
nadd attributes VERSION
nadd attributes UPDATE
nadd attributes X
nadd attributes Y
nadd attributes Z
nadd attributes INTERVAL
