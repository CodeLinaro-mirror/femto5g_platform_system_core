ACLOCAL_AMFLAGS = -I m4

root_etcdir = "/etc"

host_sources    = log_event_write.c event_tag_map.c
host_sources   += fake_log_device.c logd_write_kern.c

target_sources  = log_event_write.c event_tag_map.c log_time.cpp
if USE_LOGD
target_sources += logd_write.c
target_sources += log_read.c
else
target_sources += logd_write_syslog.c
target_sources += log_read_kern.c
endif
target_sources += log_is_loggable.c
target_sources += logprint.c

requiredlibs = -lpthread @GLIB_LIBS@

# Build liblog.so
lib_LTLIBRARIES     = liblog.la

liblog_la_CPPFLAGS  = -I$(srcdir)/../include
liblog_la_CPPFLAGS += -DHAVE_PTHREADS
liblog_la_CPPFLAGS += -DHAVE_SYS_UIO_H
liblog_la_CPPFLAGS += -DLINUX_ENABLED
liblog_la_CPPFLAGS += -D__linux__
liblog_la_CPPFLAGS += -DLIBLOG_LOG_TAG=1005
liblog_la_CPPFLAGS += -DUSE_GLIB -Dstrlcpy=g_strlcpy @GLIB_CFLAGS@
liblog_la_LDFLAGS   = $(requiredlibs)

if BUILD_DEVICE
liblog_la_SOURCES   = $(target_sources)
liblog_la_CPPFLAGS += -DANDROID_SMP=0
endif

if BUILD_HOST
liblog_la_SOURCES   = $(host_sources)
liblog_la_CPPFLAGS += -DFAKE_LOG_DEVICE=1
endif

# Export headers
incdir = $(srcdir)/../include
log_includedir       = $(includedir)/log
log_include_HEADERS  = $(incdir)/log/event_tag_map.h
log_include_HEADERS += $(incdir)/log/logd.h
log_include_HEADERS += $(incdir)/log/logger.h
log_include_HEADERS += $(incdir)/log/log.h
log_include_HEADERS += $(incdir)/log/logprint.h
log_include_HEADERS += $(incdir)/log/log_read.h
log_include_HEADERS += $(incdir)/log/uio.h

alog_includedir      = $(includedir)/android
alog_include_HEADERS = $(incdir)/android/log.h

if HAS_CLASS_TARGET
liblogdir   = $(root_etcdir)/udev/rules.d
liblog_DATA = 50-log.rules
endif

pkgconfigdir   = $(libdir)/pkgconfig
pkgconfig_DATA = liblog.pc
EXTRA_DIST     = $(pkgconfig_DATA)
