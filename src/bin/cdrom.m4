#
# Part of: MMUX Removable Media Utilities
# Contents: CD-ROM control
# Date: Fri May 24, 2013
#
# Abstract
#
#	For the hardware CD-ROM operations we rely on the package "cdrecord".
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

declare -r script_PROGNAME=cdrom
declare -r script_VERSION=0.3.0
declare -r script_COPYRIGHT_YEARS='2013, 2015, 2020'
declare -r script_AUTHOR='Marco Maggi'
declare -r script_LICENSE=GPL
declare script_USAGE="usage: ${script_PROGNAME} [action] [options]"
declare script_DESCRIPTION='Perform CD-ROM operations.'
declare script_EXAMPLES=

declare -r script_REQUIRED_MBFL_VERSION=v3.0.0-devel.4
declare -r COMPLETIONS_SCRIPT_NAMESPACE='p-mmux-removable-media-utilities'

### ------------------------------------------------------------------------

declare -r SCRIPT_ARGV0="$0"
declare -r DEFAULT_MOUNT_POINT=/mnt/cdrom
declare -r DEFAULT_GROUP_NAME=

#page
#### library loading and imports

mbfl_library_loader
m4_include([[[common.m4]]])

#page
#### program declarations

mbfl_declare_program mkisofs
mbfl_declare_program cdrecord

#page
#### script actions declaration

mbfl_declare_action_set MAIN
mbfl_declare_action MAIN MOUNT		NONE mount		'Mount a CD-ROM.'
mbfl_declare_action MAIN UMOUNT		NONE umount		'Unmount a CD-ROM.'
mbfl_declare_action MAIN SHOW		NONE show		'Show CD-ROM mount status.'

mbfl_declare_action MAIN MAKE_IMAGE	NONE make-image		'Prepare an ISO9660 CD-ROM image file from a selected directory.'
mbfl_declare_action MAIN MOUNT_IMAGE	NONE mount-image	'Mount an ISO9660 CD-ROM image file under "/mnt/tmp" using the loop device.'
mbfl_declare_action MAIN BURN_DATA	NONE burn-data		'Burn an already prepared ISO9660 CD-ROM image to the device "/dev/cdrom".'
mbfl_declare_action MAIN BURN_AUDIO	NONE burn-audio		'Burn an audio CD-ROM to the device "/dev/cdrom".'
mbfl_declare_action MAIN ERASE		NONE erase		'Erase a CD-ROM in the device "/dev/cdrom".'

mbfl_declare_action MAIN SUDO_MOUNT	NONE sudo-mount		'Internal action.'
mbfl_declare_action MAIN SUDO_UMOUNT	NONE sudo-umount	'Internal action.'
mbfl_declare_action MAIN HELP		HELP help		'Help the user of this script.'

#page
#### action functions: generic actions

DEVICE_GENERIC_ACTIONS([[[CD-ROM]]])

#page
#### script actions: device specific actions

function script_before_parsing_options_MAKE_IMAGE () {
    script_USAGE="usage: ${script_PROGNAME} make-image [options] PATH/TO/DIR IMAGENAME.iso 'THE-LABEL'"
    script_DESCRIPTION='Prepare an ISO9660 CD-ROM image file from a selected directory.'
}
function script_action_MAKE_IMAGE () {
    if mbfl_wrong_num_args 3 $ARGC
    then
	mbfl_command_line_argument(SOURCE_DIRECTORY, 1)
	mbfl_command_line_argument(IMAGE_FILE, 2)
	mbfl_command_line_argument(LABEL, 3)

	if ! mbfl_file_is_directory "$SOURCE_DIRECTORY"
	then
	    mbfl_message_error_printf 'source directory does not exist: "%s"' "$SOURCE_DIRECTORY"
	    exit_because_failure
	fi
	if mbfl_file_is_file "$IMAGE_FILE"
	then
	    mbfl_message_error_printf 'target image file already exists: "%s"' "$IMAGE_FILE"
	    exit_because_failure
	fi
	if mbfl_string_is_empty "$LABEL"
	then
	    mbfl_message_error_printf 'invalid empty label.'
	    exit_because_failure
	fi

	mbfl_local_varref(MKISOFS)
	local MKISOFS_FLAGS="-v -allow-leading-dots -dir-mode 0555 -iso-level 4"
	mbfl_program_found_var mbfl_datavar(MKISOFS) mkisofs || exit $?

	mbfl_program_exec "$MKISOFS" $MKISOFS_FLAGS -A '$LABEL' -o "$IMAGE_FILE" "$SOURCE_DIRECTORY"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_MOUNT_IMAGE () {
    script_USAGE="usage: ${script_PROGNAME} mount-image [options] IMAGE_PATHNAME"
    script_DESCRIPTION='Mount a CD-ROM image file under "/mnt/tmp" using the loop device.'
}
function script_action_MOUNT_IMAGE () {
    if mbfl_wrong_num_args 1 $ARGC
    then
	mbfl_command_line_argument(IMAGE_FILE, 1)

	local MOUNT
	mbfl_program_found_var MOUNT /bin/mount || exit $?

	local -r LOOP_DEVICE=/dev/loop1
	local -r MOUNT_POINT=/mnt/tmp

	mbfl_message_verbose_printf 'mounting image under: "%s"' "$MOUNT_POINT"
	if ! mbfl_program_exec "$MOUNT" -o loop="$LOOP_DEVICE" "$IMAGE_FILE" "$MOUNT_POINT"
	then exit_failure
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_BURN_DATA () {
    script_USAGE="usage: ${script_PROGNAME} burn-data [options] IMAGE_PATHNAME"
    script_DESCRIPTION='Burn an already prepared ISO9660 CD-ROM image to the device "/dev/cdrom".'
}
function script_action_BURN_DATA () {
    if mbfl_wrong_num_args 1 $ARGC
    then
	mbfl_command_line_argument(IMAGE_FILE, 1)

	local CDRECORD CDRECORD_FLAGS="-v -raw dev=/dev/cdrom -eject"
	mbfl_program_found_var CDRECORD cdrecord || exit $?

	mbfl_program_exec "$CDRECORD" $CDRECORD_FLAGS "$IMAGE_FILE"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_BURN_AUDIO () {
    script_USAGE="usage: ${script_PROGNAME} burn-data [options] AUDIOFILE1.cdr AUDIOFILE.cdr ..."
    script_DESCRIPTION='Burn an audio CD-ROM to the device "/dev/cdrom".\n
The arguments AUDIOFILE.cdr must be the names of the files to write, in the
specified order; there must be at least one of them.'
}
function script_action_BURN_AUDIO () {
    if mbfl_wrong_num_args_range 1 999 $ARGC
    then
	local CDRECORD CDRECORD_FLAGS='-v -dao -audio -text -useinfo speed=2 dev=/dev/cdrom'
	mbfl_program_found_var CDRECORD cdrecord || exit $?

	mbfl_program_exec "$CDRECORD" $CDRECORD_FLAGS "${ARGV[@]}"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_ERASE () {
    script_USAGE="usage: ${script_PROGNAME} erase [options]"
    script_DESCRIPTION='Erase a CD-ROM in the device "/dev/cdrom".'
}
function script_action_ERASE () {
    local CDRECORD CDRECORD_FLAGS="-v dev=/dev/cdrom blank=fast"
    mbfl_program_found_var CDRECORD cdrecord || exit $?

    mbfl_program_exec "$CDRECORD" $CDRECORD_FLAGS
}

#page
#### let's go

mbfl_main

### end of file
# Local Variables:
# mode: sh
# End:
