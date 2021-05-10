ACLOCAL_AMFLAGS = -I m4

bin_PROGRAMS = logcat

logcat_SOURCES = logcat.cpp event.logtags

logcat_CPPFLAGS  = -Wall -Wno-unused-parameter
logcat_CPPFLAGS += -std=c++14
logcat_CPPFLAGS += -D_XOPEN_SOURCE
logcat_CPPFLAGS += -DHAVE_IOCTL -DHAVE_SYS_UIO_H

logcat_LDFLAGS = @LIBBASE_LIBS@ @LIBLOG_LIBS@ @LIBCUTILS_LIBS@

