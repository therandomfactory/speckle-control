#
# APOGEE makefile for linux
# $Id: Makefile.svr4,v 1.4 1995/06/15 07:34:43 gillies Exp $
#
BASE = guider
LNAME = lib$(BASE)
MACHINE = linux
M = linux
# Version and minor version
V = 1
MV = 0


DEVHOME		= .
LIBDIR		= $(DEVHOME)
STATICLIBRARY	= $(LIBDIR)/$(LNAME)_$(M).a
SHAREDLIB	= $(LIBDIR)/$(LNAME)_$(M).so.$(V).$(MV)	# ignored
SHAREDLIBDATA	= $(LIBDIR)/$(LNAME)_$(M).sa.$(V).$(MV)	# ignored
SHAREDLIBLN	= $(LIBDIR)/$(LNAME)_$(M).so
INSTALL_DIR	= $(NESSI_DIR)

.PRECIOUS:	$(STATICLIBRARY) $(LIBDIR)/$(LNAME)_$(M).so.$(V).$(MV) $(LIBDIR)/$(LNAME)_$(M).sa.$(V).$(MV)

# Test program
TPROG = apwish.$(M)
TSRC =  tkMain.c myAppInit.c 
TOBJ =	$(TSRC:%.c=%.o)


# -R$(DEVHOME):$(GWCHOME)/lib -lsocket -lnsl
# If you don't have TkPixmap tk leave out Xpm
XPMLIBS = -lXpm 
LDLIBS += -L$(HOME)/speckle-control/lib -lccd -lX11 -lm 

.KEEP_STATE:
CC =	gcc
INCDIR		= $(DEVHOME) -I../ccd
PRIVATEINCDIR	= $(DEVHOME)

#CFLAGS 		+= -O -g -D_POSIX_C_SOURCE 
CFLAGS 		+= -pipe  -g -D$(MACHINE)  -DLINUX -Wall  -I$(TCLSRC) -I$(TKSRC)     


CPPFLAGS	= -I$(HOME)/speckle-control/include -I/usr/local/include -I/usr/include/tcl -I$(INCDIR) -DVER=\"$(V).$(MV)\"

INCLUDES =	

PRIVATE_INCLUDES =	

LIBSOURCES =    guiderPackage.c  \
		guiderVersion.c \
		guiderAppInit.c \
		guider_tcl.c  \
		guider_calc.c  \
		chisqLib.c \
		gauss.c \
		newstar.c

LIBDATA =	

CSOURCE_ALL = $(LIBSOURCES) $(LIBDATA)

STATICLIBDIR=Static
SHAREDLIBDIR=Shared

CONFIGPIC		= -fPIC
CONFIGSHAREDLIBLD	= ld -shared $(LDLIBS) -o $@ -h $(LNAME)_$(M).so.$(V).$(MV) $?

SHAREDLIB		= $(LIBDIR)/$(LNAME)_$(M).so.$(V).$(MV)
CONFIGTARGETS		= $(SHAREDLIB)

CFLAGS		+= -DSVR4
NSLLIB		= -lnsl

all: Static Shared $(LIBDIR) $(CONFIGTARGETS) $(STATICLIBRARY) $(SHAREDLIBLN)
#all: Shared $(LIBDIR) $(CONFIGTARGETS) $(SHAREDLIBLN)
#all: Static $(LIBDIR) $(CONFIGTARGETS) $(STATICLIBRARY) 
test: $(TPROG)

$(STATICLIBRARY):	$(CSOURCE_ALL:%.c=Static/%.o)
	ar rv $@ $?

$(STATICLIBDIR)/%.o: %.c $(PRIVATE_INCLUDES) $(INCLUDES)
	$(CC) $(CFLAGS) $(CPPFLAGS) -c $< -o $@

$(SHAREDLIB):	$(CSOURCE_ALL:%.c=Shared/%.o)
	$(CONFIGSHAREDLIBLD)

$(SHAREDLIBDATA): $(LIBDATA:%.c=Shared/%.o)
	ar ruv $(SHAREDLIBDATA) $?
	-ranlib $(SHAREDLIBDATA)

$(SHAREDLIBDIR)/%.o: %.c $(PRIVATE_INCLUDES) $(INCLUDES)
	$(CC) $(CFLAGS) $(CONFIGPIC) $(CPPFLAGS) -c $< -o $@

$(SHAREDLIBLN):
	rm -f $(SHAREDLIBLN) 
	ln -s $(SHAREDLIB) $(SHAREDLIBLN)

xdr:	edm.x
	rpcgen -C edm.x

$(TPROG): $(TSRC) $(TOBJ) $(STATICLIBRARY)
	$(LINK.c) -o $@ $(TOBJ)  libapogee_linux.a /-l$(BASE)_$(M) $(LDLIBS)

sunos:
	@-rm makefile
	ln -s Makefile.sunos makefile

solaris:
	@-rm makefile
	ln -s Makefile.solaris makefile

linux:
	@-rm makefile
	ln -s Makefile.linux makefile

Shared:
	-mkdir Shared

Static:
	-mkdir Static

$(LIBDIR):
	-mkdir $(LIBDIR)


install: $(STATICLIBRARY) $(SHAREDLIB) FORCE
	-mkdir $(INSTALL_DIR)/lib
	cp $(STATICLIBRARY) $(INSTALL_DIR)/lib
	cp $(SHAREDLIB) $(INSTALL_DIR)/lib
	-mkdir $(INSTALL_DIR)/include/$(BASE)
	cp $(INCLUDES) $(INSTALL_DIR)/include/$(BASE)
	cp pkgIndex.tcl $(INSTALL_DIR)/lib
	rm -f $(INSTALL_DIR)/lib/$(LNAME)_$(M).so
	ln -s $(INSTALL_DIR)/lib/$(LNAME)_$(M).so.$(V).$(MV) $(INSTALL_DIR)/lib/$(LNAME)_$(M).so
	rm -f $(INSTALL_DIR)/lib/$(LNAME).so
	ln -s $(INSTALL_DIR)/lib/$(LNAME)_$(M).so.$(V).$(MV) $(INSTALL_DIR)/lib/$(LNAME).so

clean:
	rm -rf Shared Static
	rm -f tags TAGS .make.state .nse_depinfo Makefile $(TOBJ)

tags:
	ctags $(LIBSOURCES)

FORCE:




