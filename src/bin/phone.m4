#
# Part of: MMUX Removable Media Utilities
# Contents: USB phone control
# Date: Jul  7, 2017
#
# Abstract
#
#
#
# Copyright (C) 2017, 2020 Marco Maggi <mrc.mgg@gmail.com>
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

declare -r script_PROGNAME=phone
declare -r script_VERSION=0.2.0-devel.0
declare -r script_COPYRIGHT_YEARS='2017, 2020'
declare -r script_AUTHOR='Marco Maggi'
declare -r script_LICENSE=GPL
declare script_USAGE="usage: ${script_PROGNAME} [action] [options]"
declare script_DESCRIPTION='Perform USB phone operations.'
declare script_EXAMPLES=

declare -r script_REQUIRED_MBFL_VERSION=v3.0.0-devel.4
declare -r COMPLETIONS_SCRIPT_NAMESPACE='p-mmux-removable-media-utilities'

### ------------------------------------------------------------------------

declare -r SCRIPT_ARGV0="$0"
declare -r DEFAULT_MOUNT_POINT=/mnt/phone
declare -r DEFAULT_GROUP_NAME=

#page
#### library loading and imports

mbfl_library_loader
m4_include([[[common.m4]]])

#page
#### script actions

DEFINE_MAIN_ACTIONS_TREE([[[USB phone]]])

#page
#### action functions: generic actions

DEVICE_GENERIC_ACTIONS([[[USB phone]]])

#page
#### let's go

mbfl_main

### end of file
# Local Variables:
# mode: sh
# End:
