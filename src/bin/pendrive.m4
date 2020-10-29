#
# Part of: MMUX Removable Media Utilities
# Contents: USB pendrive control
# Date: Fri May 24, 2013
#
# Abstract
#
#
#
# Copyright (C) 2013, 2015, 2020 Marco Maggi <mrc.mgg@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it under the terms of the GNU
# General Public  License as  published by  the Free Software  Foundation, either  version 3  of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that  it will be useful, but WITHOUT ANY WARRANTY; without
# even the  implied warranty of MERCHANTABILITY  or FITNESS FOR  A PARTICULAR PURPOSE.  See  the GNU
# General Public License for more details.
#
# You should  have received a copy  of the GNU General  Public License along with  this program.  If
# not, see <http://www.gnu.org/licenses/>.
#

#page
#### global variables

declare -r script_PROGNAME=pendrive
declare -r script_VERSION=0.3.0-devel.0
declare -r script_COPYRIGHT_YEARS='2013, 2015, 2020'
declare -r script_AUTHOR='Marco Maggi'
declare -r script_LICENSE=GPL
declare script_USAGE="usage: ${script_PROGNAME} [action] [options]"
declare script_DESCRIPTION='Perform USB pendrive operations.'
declare script_EXAMPLES=

declare -r script_REQUIRED_MBFL_VERSION=v3.0.0-devel.4
declare -r COMPLETIONS_SCRIPT_NAMESPACE='p-mmux-removable-media-utilities'

### ------------------------------------------------------------------------

declare -r SCRIPT_ARGV0="$0"
declare -r DEFAULT_MOUNT_POINT=/mnt/stick
declare -r DEFAULT_GROUP_NAME=

#page
#### library loading and imports

mbfl_library_loader
m4_include([[[common.m4]]])

#page
#### script actions declaration

DEFINE_MAIN_ACTIONS_TREE([[[USB pendrive]]])

#page
#### action functions

DEVICE_GENERIC_ACTIONS([[[USB pendrive]]])

#page
#### let's go

mbfl_main

### end of file
# Local Variables:
# mode: sh
# End:
