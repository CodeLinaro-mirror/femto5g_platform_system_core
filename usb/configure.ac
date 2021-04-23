AC_PREREQ(2.61)
AC_INIT([usb-composition],1.0.0)
AM_INIT_AUTOMAKE([-Wall gnu foreign])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

# Check for programs
AM_PROG_AS
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_LIBTOOL
AC_PROG_AWK
AC_PROG_CPP
AC_PROG_CXX
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
PKG_PROG_PKG_CONFIG

PKG_CHECK_MODULES([LIBCUTILS], [libcutils])
AC_SUBST([LIBCUTILS_CFLAGS])
AC_SUBST([LIBCUTILS_LIBS])

PKG_CHECK_MODULES([LIBUTILS], [libutils])
AC_SUBST([LIBUTILS_CFLAGS])
AC_SUBST([LIBUTILS_LIBS])

AC_ARG_WITH(sanitized-headers,
      AS_HELP_STRING([--with-sanitized-headers=DIR],
         [Specify the location of the sanitized Linux headers]),
      [CPPFLAGS="$CPPFLAGS -idirafter $withval"])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
