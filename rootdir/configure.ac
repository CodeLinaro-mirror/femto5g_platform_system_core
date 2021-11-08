AC_PREREQ(2.61)
AC_INIT([post-boot],1.0.0)
AM_INIT_AUTOMAKE([-Wall gnu foreign])

# Check for programs
AC_PROG_INSTALL
AC_PROG_MAKE_SET
PKG_PROG_PKG_CONFIG

#basemachine
AC_MSG_CHECKING([which base machine to use])
AC_ARG_WITH([basemachine],
            [AS_HELP_STRING([--with-basemachine],
            [Specify the base machine])],
            [machine_selected="$withval"],
            [machine_selected=none])

AC_MSG_RESULT([$machine_selected])
AC_SUBST([MACHINE_ENABLED],[$machine_selected])

#systemd
AC_ARG_WITH(systemd,
        AS_HELP_STRING([--with-systemd], [enable post boot systemd services]),
        [SYSTEMD="yes"],
        [SYSTEMD="no"])
AM_CONDITIONAL([USE_SYSTEMD], [test "x${SYSTEMD}" != "xno"])

#logging restrictions
AC_ARG_ENABLE([logrestrict],
              [AS_HELP_STRING([--enable-logrestrict],
              [Specify if log restrictions are needed])],
              [logres="$enableval"], [logres="no"])

AM_CONDITIONAL(LOG_RESTRICT, [test "x$logres" = "xyes"])

#debugging
AC_ARG_ENABLE([debug],
              [AS_HELP_STRING([--enable-debug],
              [Specify if debug features are needed])],
              [dbg="$enableval"], [dbg="no"])

AM_CONDITIONAL(ENABLE_DEBUG, [test "x$dbg" = "xyes"])

AC_CONFIG_FILES([ \
    Makefile \
])
AC_OUTPUT
