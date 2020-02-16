#!/bin/sh

sudo apt-get install tk tk-dev g++ pkg-config libglib2.0-dev bwidget libexpat1-dev libtiff5-dev libjpeg-turbo8-dev libgsf-1-dev libfftw3-dev
export SPECKLE_DIR=${HOME}/speckle-control
export PKG_CONFIG_PATH=$SPECKLE_DIR/lib/pkgconfig
cd ../andor
sudo ./install_andor
cd $SPECKLE_DIR/vips-8.5.9
./confgure --prefix=${HOME}/speckle-control
make ; make install
cd ..
echo "******************************************************************************************"
echo "************************   Speckle software installed   **********************************"
echo "******************************************************************************************"


