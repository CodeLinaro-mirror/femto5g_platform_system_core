ACLOCAL_AMFLAGS = -I m4

root_sbindir       = "/sbin"
root_libdir        = "/lib"
root_etcdir        = "/etc"
root_sbin_PROGRAMS = leprop-service

bin_PROGRAMS     = setprop
setprop_SOURCES  = setprop.c
setprop_CFLAGS   = -I$(top_srcdir) @LIBCUTILS_CFLAGS@
setprop_LDFLAGS  = -lselinux @LIBCUTILS_LIBS@

bin_PROGRAMS    += getprop
getprop_SOURCES  = getprop.c
getprop_CFLAGS   = -I$(top_srcdir) @LIBCUTILS_CFLAGS@
getprop_LDFLAGS  = -lselinux @LIBCUTILS_LIBS@

leprop_service_SOURCES  = property_service.c
leprop_service_SOURCES += ll.c

leprop_service_CPPFLAGS = -I$(top_srcdir) @LIBCUTILS_CFLAGS@
leprop_service_LDFLAGS  = @LIBLOG_LIBS@ @LIBCUTILS_LIBS@

if PROPTRIGGER
leprop_service_CPPFLAGS += -DPROP_TRIGGER

root_etc_SCRIPTS  = proptrigger.sh
root_etc_SCRIPTS += proptrigger.conf

install-data-hook:
	chmod  go-x $(DESTDIR)$(root_etcdir)/proptrigger.sh
	chmod  go-x $(DESTDIR)$(root_etcdir)/proptrigger.conf
endif

if USE_SYSTEMD
leproperties_systemddir   = $(root_libdir)/systemd/system
leproperties_systemd_DATA = leprop.service
endif
