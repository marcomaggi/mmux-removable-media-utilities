dnl @configure_input@
dnl

AC_PREREQ([2.69])
MMUX_PKG_VERSIONS([1],[2],[1],,[noarch])
AC_INIT([MMUX Removable Media Utilities],MMUX_PACKAGE_VERSION,[marco.maggi-ipsu@poste.it],
   [mmux-removable-media-utilities],[http://github.com/marcomaggi/mmux-removable-media-utilities/])
MMUX_INIT
AC_CONFIG_SRCDIR([src])
AC_CONFIG_MACRO_DIR([meta/autotools])
AC_CONFIG_AUX_DIR([meta/autotools])
AM_INIT_AUTOMAKE([1.14 foreign subdir-objects dist-xz no-dist-gzip])
AM_MAINTAINER_MODE

AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P

MBFL_SETUP

AC_CONFIG_FILES([Makefile]
  [meta/slackware/doinst.sh])
MMUX_OUTPUT
AC_OUTPUT

### end of file
