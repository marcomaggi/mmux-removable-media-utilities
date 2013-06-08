dnl @configure_input@
dnl

AC_PREREQ([2.69])
AC_INIT([MMUX Removable Media Utilities],[1.0a2],[marco.maggi-ipsu@poste.it],[mmux-removable-media-utilities])
AC_CONFIG_SRCDIR([src])
AC_CONFIG_MACRO_DIR([autotools])
AC_CONFIG_AUX_DIR([autotools])

AM_INIT_AUTOMAKE([foreign])
AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET

AC_CHECK_PROG([MBFLCONFIG],[mbfl-config],[mbfl-config],[:])
AS_IF([test "$MBFLCONFIG" = :],[AC_MSG_ERROR([cannot find MBFL],[1])])

AC_CHECK_PROG([MBFLPP],[mbflpp.sh],[mbflpp.sh],[:])
AS_IF([test "$MBFLPP" = :],[AC_MSG_ERROR([cannot find MBFL preprocessor],[1])])

AC_CONFIG_FILES([Makefile
                 src/bin/Makefile
                 src/completions/Makefile
                 src/etc/Makefile
                 doc/Makefile
                 meta/slackware/doinst.sh])
AC_OUTPUT

### end of file
# Local Variables:
# mode: autoconf
# page-delimiter: "^#page"
# End:
