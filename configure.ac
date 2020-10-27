dnl @configure_input@
dnl

AC_PREREQ([2.69])
MMUX_PKG_VERSIONS([2],[0],[0],[devel.0],[noarch])
AC_INIT([MMUX Removable Media Utilities],MMUX_PACKAGE_VERSION,
   [mrc.mgg@gmail.com],
   [mmux-removable-media-utilities],[http://github.com/marcomaggi/mmux-removable-media-utilities/])
MMUX_INIT
dnl This is the revision number of this configure.ac
AC_REVISION([0.3])
AC_COPYRIGHT([Copyright (c) 2013-2015, 2017, 2020 Marco Maggi <mrc.mgg@gmail.com>

This program is free software: you  can redistribute it and/or modify it
under the  terms of the GNU  General Public License as  published by the
Free Software Foundation,  either version 3 of the License,  or (at your
option) any later version.

This program  is distributed  in the  hope that it  will be  useful, but
WITHOUT   ANY   WARRANTY;  without   even   the   implied  warranty   of
MERCHANTABILITY  or  FITNESS FOR  A  PARTICULAR  PURPOSE.  See  the  GNU
General Public License for more details.

You should have received a copy  of the GNU General Public License along
with this program.  If not, see <http://www.gnu.org/licenses/>.
])
AC_CONFIG_SRCDIR([src])
AC_CONFIG_MACRO_DIR([meta/autotools])
AC_CONFIG_AUX_DIR([meta/autotools])
AC_CANONICAL_BUILD
AC_CANONICAL_HOST
AC_CANONICAL_TARGET
AM_INIT_AUTOMAKE([1.14 foreign subdir-objects])
AM_MAINTAINER_MODE

AC_PROG_INSTALL
AC_PROG_LN_S
AC_PROG_MAKE_SET
AC_PROG_MKDIR_P

AC_CHECK_PROG([BASH_PROGRAM],[bash],[bash],[:])
MBFL_SETUP

AC_CONFIG_FILES([Makefile]
  [meta/slackware/doinst.sh])
MMUX_OUTPUT
AC_OUTPUT

### end of file
