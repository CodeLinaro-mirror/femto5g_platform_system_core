AC_PREREQ(2.61)
AC_INIT([liblog],1.0.0)
AM_INIT_AUTOMAKE([-Wall gnu foreign])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

# Check for programs
AM_PROG_AR
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

AC_ARG_WITH([glib],
      AS_HELP_STRING([--with-glib],
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

AS_CASE([$host],
        [arm*], [ARM=yes],
        [ARM=no]
)
AM_CONDITIONAL(ARM, [test "x$ARM" = "xyes"])

AS_CASE([$host],
        [aarch64*], [ARM64=yes],
        [ARM64=no]
)
AM_CONDITIONAL(ARM64, [test "x$ARM64" = "xyes"])

AS_CASE([$host],
        [x86_64*], [X86_64=yes],
        [X86_64=no]
)
AM_CONDITIONAL(X86_64, [test "x$X86_64" = "xyes"])

AM_CONDITIONAL(BUILD_HOST, [test "x$X86_64" = "xyes"])
AM_CONDITIONAL(BUILD_DEVICE, [test "x$ARM$ARM64" != "xnono"])

AC_ARG_WITH([logd-logging],
      AS_HELP_STRING([--with-logd-logging],
         [enable logd based logging]))

AM_CONDITIONAL(USE_LOGD, [test "x${with_logd_logging}" = "xyes"])

AC_ARG_WITH(class-target,
        AS_HELP_STRING([--with-class-target], [enable class-target]),
        [CLASS_TARGET="yes"],
        [CLASS_TARGET="no"])

AM_CONDITIONAL([HAS_CLASS_TARGET], [test "x${CLASS_TARGET}" != "xno"])

AC_CONFIG_FILES([ \
    Makefile \
    liblog.pc
])
AC_OUTPUT
