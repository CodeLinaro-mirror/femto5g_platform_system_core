ACLOCAL_AMFLAGS = -I m4

# Build shared lib.
lib_LTLIBRARIES = liblogwrap.la

liblogwrap_la_SOURCES = logwrap.c
liblogwrap_la_CFLAGS  = -I$(top_srcdir)/include
liblogwrap_la_LDFLAGS = @LIBLOG_LIBS@ @LIBCUTILS_LIBS@

# Build logwrapper daemon
bin_PROGRAMS = logwrapper

logwrapper_SOURCES  = logwrapper.c
logwrapper_CFLAGS   = -I$(top_srcdir)/include
logwrapper_LDADD    = liblogwrap.la
logwrapper_LDADD   += -lpthread @LIBLOG_LIBS@ @LIBCUTILS_LIBS@

# Export headers
logwrapper_includedir      = $(includedir)/logwrap
logwrapper_include_HEADERS = $(top_srcdir)/include/logwrap/logwrap.h

pkgconfigdir   = $(libdir)/pkgconfig
pkgconfig_DATA = logwrapper.pc
EXTRA_DIST     = $(pkgconfig_DATA)

