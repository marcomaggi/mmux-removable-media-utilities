#
# Part of: MMUX Removable Media Utilities
# Contents: SD memory card control
# Date: Tue Dec 23, 2014
#
# Abstract
#
#
#
# Copyright (C) 2014, 2015, 2020 Marco Maggi <mrc.mgg@gmail.com>
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

declare -r script_PROGNAME=memory-card
declare -r script_VERSION=0.2.0-devel.0
declare -r script_COPYRIGHT_YEARS='2014, 2015, 2020'
declare -r script_AUTHOR='Marco Maggi'
declare -r script_LICENSE=GPL
declare script_USAGE="usage: ${script_PROGNAME} [action] [options]"
declare script_DESCRIPTION='Perform SD memory card operations.'
declare script_EXAMPLES=

declare -r script_REQUIRED_MBFL_VERSION=v3.0.0-devel.4
declare -r COMPLETIONS_SCRIPT_NAMESPACE='p-mmux-removable-media-utilities'

### ------------------------------------------------------------------------

declare -r SCRIPT_ARGV0="$0"
declare -r DEFAULT_MOUNT_POINT=/media/memory
declare -r DEFAULT_GROUP_NAME=

#page
#### library loading and imports

mbfl_library_loader
m4_include([[[common.m4]]])

#page
#### script actions declaration

mbfl_declare_action_set MAIN
mbfl_declare_action MAIN MOUNT		NONE mount		'Mount a SD memory card.'
mbfl_declare_action MAIN UMOUNT		NONE umount		'Unmount a SD memory card.'
mbfl_declare_action MAIN SHOW		NONE show		'Show SD memory card mount status.'
mbfl_declare_action MAIN SUDO_MOUNT	NONE sudo-mount		'Internal action.'
mbfl_declare_action MAIN SUDO_UMOUNT	NONE sudo-umount	'Internal action.'
mbfl_declare_action MAIN HELP		HELP help		'Help the user of this script.'

#page
#### action functions: generic actions

DEVICE_GENERIC_ACTIONS([[[SD memory card]]])

#page
#### let's go

mbfl_main

### end of file
# Local Variables:
# mode: sh
# End:
