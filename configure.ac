dnl @configure_input@
dnl

AC_PREREQ([2.69])
MMUX_PKG_VERSIONS([2],[0],[0],[devel.1],[noarch])
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

dnl --------------------------------------------------------------------

# We can  use "CDROM_MOUNT_POINT" on  the commnd line of  "configure" to
# select     a    value.      We     can     use    the     substitution
# "DEFAULT_CDROM_MOUNT_POINT" to use the value in scripts.
#
# Similarly for other devices.
#
AC_DEFUN([MMUX_DEFINE_MOUNT_POINT_OPTION],
  [AS_VAR_SET([PRESET_$1_MOUNT_POINT],['$2'])
   AC_CACHE_CHECK([default mount point for $1],[mmux_cv_DEFAULT_$1_MOUNT_POINT],
     [AS_IF([test -n "$$1_MOUNT_POINT"],
            [AS_VAR_SET([mmux_cv_DEFAULT_$1_MOUNT_POINT],["$$1_MOUNT_POINT"])],
            [AS_VAR_SET([mmux_cv_DEFAULT_$1_MOUNT_POINT],["$PRESET_$1_MOUNT_POINT"])])])
   AC_SUBST([DEFAULT_$1_MOUNT_POINT],[$mmux_cv_DEFAULT_$1_MOUNT_POINT])])

MMUX_DEFINE_MOUNT_POINT_OPTION([CDROM],[/mnt/cdrom])
MMUX_DEFINE_MOUNT_POINT_OPTION([FLOPPY_DISK],[/mnt/floppy])
MMUX_DEFINE_MOUNT_POINT_OPTION([MEMORY_CARD],[/mnt/memory])
MMUX_DEFINE_MOUNT_POINT_OPTION([PENDRIVE],[/mnt/stick])
MMUX_DEFINE_MOUNT_POINT_OPTION([PHONE],[/mnt/phone])

dnl --------------------------------------------------------------------

AC_CONFIG_FILES([Makefile]
  [meta/slackware/doinst.sh]
  [src/bin/cdrom.m4]
  [src/bin/floppy-disk.m4]
  [src/bin/memory-card.m4]
  [src/bin/pendrive.m4]
  [src/bin/phone.m4])
MMUX_OUTPUT
AC_OUTPUT

### end of file
