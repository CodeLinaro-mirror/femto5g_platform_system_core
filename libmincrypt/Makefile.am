ACLOCAL_AMFLAGS = -I m4

libmincrypt_c_sources = dsa_sig.c p256.c p256_ec.c p256_ecdsa.c rsa.c sha.c sha256.c

# Build a shared lib
lib_LTLIBRARIES = libmincrypt.la

libmincrypt_la_SOURCES  = $(libmincrypt_c_sources)
libmincrypt_la_CPPFLAGS = -I$(srcdir)/../include/
libmincrypt_la_LDFLAGS  = -lm -lpthread

# Export headers
incdir = $(srcdir)/../include
mincrypt_includedir       = $(includedir)/mincrypt
mincrypt_include_HEADERS  = $(incdir)/mincrypt/dsa_sig.h
mincrypt_include_HEADERS += $(incdir)/mincrypt/hash-internal.h
mincrypt_include_HEADERS += $(incdir)/mincrypt/p256.h
mincrypt_include_HEADERS += $(incdir)/mincrypt/p256_ecdsa.h
mincrypt_include_HEADERS += $(incdir)/mincrypt/rsa.h
mincrypt_include_HEADERS += $(incdir)/mincrypt/sha.h
mincrypt_include_HEADERS += $(incdir)/mincrypt/sha256.h

pkgconfigdir   = $(libdir)/pkgconfig
pkgconfig_DATA = libmincrypt.pc
EXTRA_DIST     = $(pkgconfig_DATA)
