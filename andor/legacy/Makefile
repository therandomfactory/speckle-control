########################################################################
# Makefile                                                             #
#                                                                      #
# For jouflu 							       #
#                                                                      #
########################################################################
#                                                                      #
#		THE CHARA ARRAY					       #
#     Center for High Angular Resolution Astronomy                     #
# Georgia State University, Atlanta GA 30303-3083, U.S.A.              #
#                                                                      #
#                                                                      #
# Telephone: 1-626-796-5405                                            #
# Fax      : 1-626-796-6717                                            #
# email    : theo@chara.gsu.edu                                        #
# WWW      : http:www.chara.gsu.edu 		                       #
#                                                                      #
# (C) This source code and its associated executable                   #
# program(s) are copyright.                                            #
#                                                                      #
########################################################################
#                                                                      #
# Author : Theo ten Brummelaar                                         #
# Date   : Oct 2011      					       #
########################################################################

#
# Some definitions
#

CC= gcc
KCC= gcc
LCFLAGS= -g -O2 -Wall
LFLAGS=  -L/usr/X11R6/lib -lc -lchara -landor -lusb -lpthread -lopleft -lastroui -lastromod -linterferometry -lsla -lcharaui -luishut -luiclient -luizaber -lclient -lncurses -lchara -lnsimpleX -lX11 -lrwfits -lnrc -lsockman -lcfitsio -lm -lz
#LFLAGS=  -L/usr/X11R6/lib -lclock -lc -lserver -lchara -landor -lusb -lpthread -lopleft -lastroui -lastromod -linterferometry -lsla -lcharaui -luishut -luiclient -luizaber -lclient -lncurses -lchara -lnsimpleX -lX11 -lrwfits -lnrc -lsockman -lcfitsio -lm -lz
LIBDIR=/usr/local/lib
INCDIR=/usr/local/include ./andor/include
HELPDIR=/usr/local/lib/ui_help
BINDIR=/usr/local/bin
MODDIR=/usr/local/modules
ETCDIR=/local/lib/etc
LIBNAME=wfs

#
# The targets
#

all: jouflu

#
# The application target. This is to run in straight linux
#

OFILES = jouflu.o\
	 jouflu_background.o\
	 jouflu_control.o\
	 jouflu_functs.o\
	 jouflu_messages.o\
	 jouflu_zabers2.o\
	 Socket.o\
	 wfs_messages.o\
	 wfs_andor.o\
	 wfs_andor_usb_data.o\
	 wfs_data.o\

.c.o:
	${CC} -c ${LCFLAGS} $<

#
# The user interface
#

$(OFILES): jouflu.h

Socket.o: Socket.h

jouflu: $(OFILES)
	gcc -o jouflu $(OFILES) $(LFLAGS)

#
# Cleanup
#

clean:
	rm -rf core $(OFILES) jouflu 

#
# install
#

install: jouflu run_jouflu jouflu_help.ini jouflu_menus.ini jzaber.cfg 
	cp jouflu $(BINDIR)/jouflu
	chmod a+x $(BINDIR)/jouflu 
	chmod a+s $(BINDIR)/jouflu 
	cp run_jouflu $(BINDIR)/run_jouflu
	chmod a+rx $(BINDIR)/run_jouflu 
	cp jouflu_help.ini $(BINDIR)/jouflu_help.ini
	chmod a+r $(BINDIR)/jouflu_help.ini
	cp jouflu_menus.ini $(BINDIR)/jouflu_menus.ini
	chmod a+r $(BINDIR)/jouflu_menus.ini
	cp jzaber.cfg $(ETCDIR)/jzaber.cfg
	chown observe $(ETCDIR)/jzaber.cfg
	chgrp chara $(ETCDIR)/jzaber.cfg
	chmod g+wr $(ETCDIR)/jzaber.cfg


uninstall:
	rm -f $(BINDIR)/jouflu
	rm -f $(BINDIR)/run_jouflu
	rm -f $(BINDIR)/jouflu_help.ini
	rm -f $(BINDIR)/jouflu_menus.ini
	rm -f $(ETCDIR)/jzaber.cfg
