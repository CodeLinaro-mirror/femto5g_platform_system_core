AC_PREREQ(2.61)

AC_INIT([system-core-powerapp],1.0.0)

AC_CONFIG_AUX_DIR([build-aux])

AM_INIT_AUTOMAKE([-Wall gnu foreign])

AM_MAINTAINER_MODE

AC_CONFIG_HEADER([config.h])

AC_CONFIG_MACRO_DIRS([m4])

# Checks for programs.
AM_PROG_AS
AC_PROG_CC
AM_PROG_CC_C_O
AC_PROG_LIBTOOL
AC_PROG_AWK
AC_PROG_CPP
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
PKG_PROG_PKG_CONFIG

AC_ARG_WITH([glib],
      AC_HELP_STRING([--with-glib],
         [enable glib, building HLOS systems which use glib]))

if (test "x${with_glib}" = "xyes"); then
    AC_DEFINE(ENABLE_USEGLIB, 1, [Define if HLOS systems uses glib])
    PKG_CHECK_MODULES(GTHREAD, gthread-2.0 >= 2.16, dummy=yes,
                AC_MSG_ERROR(GThread >= 2.16 is required))
    PKG_CHECK_MODULES(GLIB, glib-2.0 >= 2.16, dummy=yes,
                AC_MSG_ERROR(GLib >= 2.16 is required))
    GLIB_CFLAGS="$GLIB_CFLAGS $GTHREAD_CFLAGS"
    GLIB_LIBS="$GLIB_LIBS $GTHREAD_LIBS"

    AC_SUBST(GLIB_CFLAGS)
    AC_SUBST(GLIB_LIBS)
fi
AM_CONDITIONAL(USE_GLIB, test "x${with_glib}" = "xyes")

#AC_CHECK_HEADERS([sys/uio.h])

#
# Build all components by default
#
# To add new components: add AC_ARG_ENABLE, AM_CONDITIONAL and update AC_OUTPUT
#

AC_ARG_WITH(systemd,
        AS_HELP_STRING([--with-systemd], [enable powerapp in systemd]),
        [SYSTEMD="yes"],
        [SYSTEMD="no"])
AM_CONDITIONAL([USE_SYSTEMD], [test "x${SYSTEMD}" != "xno"])

AS_CASE([$host],
        [arm*], [ARM=yes],
        [ARM=no]
)
AM_CONDITIONAL(ARM, [test "x$ARM" = "xyes"])

AC_CHECK_FUNCS([strlcpy],[STRLCPY=yes],[STRLCPY=no])
AM_CONDITIONAL([HAVE_STRLCPY],[test "x$STRLCPY" = "xyes"])

AC_ARG_ENABLE([vm-config],
              AC_HELP_STRING([--enable-vm-config],
                             [Enable VM power config]),
                             [has_vmconfig=${enableval}])

AM_CONDITIONAL([ENABLE_VM_POWER_CONFIG], [test "x$has_vmconfig" = "xyes"])

AC_OUTPUT([ \
        Makefile
])
