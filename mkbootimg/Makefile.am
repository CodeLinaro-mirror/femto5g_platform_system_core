ACLOCAL_AMFLAGS = -I m4

bin_PROGRAMS = mkbootimg

mkbootimg_SOURCES   = mkbootimg.c

mkbootimg_CPPFLAGS  = -I. @LIBMINCRYPT_CFLAGS@

mkbootimg_LDADD     = @LIBMINCRYPT_LIBS@
