# speckle-control
Controller components and GUI for Speckle (NN-EXPLORE Exoplanet &amp; Stellar Speckle Imager)

This project is to provide controller software (server and GUI) for the instrument described below.
It is being undertaken by "The Random Factory" (www.randomfactory.com) located in Tucson AZ.

This effort is funded under NASA Grant and Cooperative agreement #NNX14AR61A

Principal Investigator : Steve B. Howell, NASA Ames Research Center, Senior Research Scientist

The NN-EXPLORE program provides about 50 percent of the observing time on the Kitt Peak WIYN (Wisconsin-Indiana-Yale-NOAO) 3.5-meter telescope to the exoplanet community. WIYN’s suite of instruments include HYDRA, a multi-fiber medium to high-resolution bench spectrograph, WHIRC, a near-IR imager, ODI, an optical wide-field optical imager, and for over a decade, a visiting speckle camera called DSSI (Horch et al. 2009). The telescope’s instruments also include several integral field units, bundles of optical fiber that feed light from the telescope to an instrument, in this case a spectrograph, that lives in an environmentally controlled room in the WIYN telescope basement. Beginning in 2017, thanks to funding support from the NASA Exoplanet program, DSSI has been replaced by a modern, more functional, community available observatory instrument named NESSI.

NN-EXPLORE Exoplanet & Stellar Speckle Imager at WIYN, was commissioned during the fall of 2016 and is now available for community use. Speckle imaging allows telescopes to achieve diffraction limited imaging performance—that is, collecting images with resolutions equal to that which would be possible if the atmosphere were removed. The technique employs digital cameras capable of reading out frames at a very fast rate, effectively “freezing out” atmospheric seeing. The resulting speckles are correlated and combined in Fourier space to produce reconstructed images with resolutions at the diffraction limit of the telescope (see Howell et al., 2011). Achievable spatial resolutions at WIYN are 39 milliarcseconds (550 nanometers) and 64 milliarcseconds (880 nanometers).

There are now 3 Speckle Instruments, residing at WIYN (NESSI), Gemini-South (Zorro), and Gemini-North (Alopeke).

# Installation

If you are installing from scratch, first 

cd $HOME
git clone https://github.com/therandomfactory/speckle-control
cd speckle-control

and then run the 'install' script or click the desktop icon.

This will install any required dependencies, compile the speckle 
shared libraries, setup the desktop environment, and do a quick
hardware inventory.

The primary target operating system is Ubuntu. Other Linux flavours may
require some changes to the 'install' script.

To check for and optionally install updates, either run the "checkUpdate"
script or click the desktop icon.

To run in simulation mode with no hardware, type

```. simulationMode
. startspeckle2```

and 

`unset SPECKLE_SIM`

to cancel it.

