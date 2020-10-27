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

declare script_option_CDROM_MOUNT_POINT=/mnt/cdrom
declare script_option_GROUP_NAME=

#page
#### library loading

mbfl_library_loader

#page
#### program declarations

mbfl_program_enable_sudo
mbfl_declare_program /bin/mount
mbfl_declare_program /bin/umount
mbfl_declare_program /bin/grep
mbfl_declare_program /bin/gawk
mbfl_declare_program /bin/id
mbfl_declare_program mkisofs
mbfl_declare_program cdrecord

#page
#### script actions

mbfl_declare_action_set HELP
mbfl_declare_action HELP HELP_USAGE			NONE usage			'Print the help screen and exit.'
mbfl_declare_action HELP HELP_PRINT_COMPLETIONS_SCRIPT	NONE print-completions-script	'Print the completions script for this program.'

### --------------------------------------------------------------------

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
#### main function

function main () {
    mbfl_main_print_usage_screen_brief
}

#page
#### action functions

function script_before_parsing_options_MOUNT () {
    script_USAGE="usage: ${script_PROGNAME} mount [options]"
    script_DESCRIPTION='Mount a CD-ROM.'

    mbfl_declare_option CDROM_MOUNT_POINT '/mnt/cdrom' m mount-point witharg 'Select the mount point.'
    mbfl_declare_option GROUP_NAME        ''           g group       witharg "Select the user's group name."
}
function script_action_MOUNT () {
    local ID USR_ID GRP_ID

    mbfl_program_found_var ID /bin/id || exit $?

    mbfl_option_test_save
    {
	USR_ID=$(mbfl_program_exec "$ID" --user)

	if mbfl_string_is_empty "$script_option_GROUP_NAME"
	then GRP_ID=$(mbfl_program_exec "$ID" --group)
	else GRP_ID=$(mbfl_program_exec "$ID" "$script_option_GROUP_NAME" --group)
	fi
    }
    mbfl_option_test_restore

    mbfl_message_verbose_printf 'mounting a CD-ROM under the mount point: "%s"\n' "$script_option_CDROM_MOUNT_POINT"
    mbfl_message_verbose_printf 'using the user id "%s" and group id "%s"\n' "$USR_ID" "$GRP_ID"

    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-mount "$USR_ID" "$GRP_ID" --mount-point="$script_option_CDROM_MOUNT_POINT"
    then
	if mbfl_option_verbose
	then show_mount_point "$script_option_CDROM_MOUNT_POINT"
	fi
	exit_because_success
    else
	mbfl_message_error_printf 'error mounting CD-ROM under the mount point: "%s"' "$script_option_CDROM_MOUNT_POINT"
	exit_because_failure
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_UMOUNT () {
    script_USAGE="usage: ${script_PROGNAME} umount [options]"
    script_DESCRIPTION='Unmount a CD-ROM.'

    mbfl_declare_option CDROM_MOUNT_POINT '/mnt/cdrom' m mount-point witharg 'Select the mount point.'
}
function script_action_UMOUNT () {
    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-umount --mount-point="$script_option_CDROM_MOUNT_POINT"
    then
	# Always try to show the mount point.
	if mbfl_option_verbose
	then show_mount_point "$script_option_CDROM_MOUNT_POINT"
	fi
	exit_success
    else
	show_mount_point "$script_option_CDROM_MOUNT_POINT"
	mbfl_message_error_printf 'error unmounting CD-ROM from: "%s"' "$script_option_CDROM_MOUNT_POINT"
	exit_failure
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_SHOW () {
    script_USAGE="usage: ${script_PROGNAME} show [options]"
    script_DESCRIPTION='Show CD-ROM mount status.'

    mbfl_declare_option CDROM_MOUNT_POINT '/mnt/cdrom' m mount-point witharg 'Select the mount point.'
}
function script_action_SHOW () {
    show_mount_point "$script_option_CDROM_MOUNT_POINT"
}

### ------------------------------------------------------------------------

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

	local MKISOFS MKISOFS_FLAGS="-v -allow-leading-dots -dir-mode 0555 -iso-level 4"
	mbfl_program_found_var MKISOFS mkisofs || exit $?

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

### ------------------------------------------------------------------------

function script_before_parsing_options_SUDO_MOUNT () {
    mbfl_declare_option CDROM_MOUNT_POINT '/mnt/cdrom' m mount-point witharg 'Select the mount point.'
}
function script_action_SUDO_MOUNT () {
    if mbfl_wrong_num_args 2 $ARGC
    then
	local MOUNT USR_ID GRP_ID
	mbfl_program_found_var MOUNT /bin/mount || exit $?
	USR_ID=${ARGV[0]}
	GRP_ID=${ARGV[1]}
	if mbfl_program_exec "$MOUNT" "$script_option_CDROM_MOUNT_POINT" -o uid="$USR_ID",gid="$GRP_ID" >&2
	then true
	else
	    # Not all file systems support UID and GID options, so retry without those.
	    if mbfl_program_exec "$MOUNT" "$script_option_CDROM_MOUNT_POINT" >&2
	    then true
	    else exit_failure
	    fi
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_SUDO_UMOUNT () {
    mbfl_declare_option CDROM_MOUNT_POINT '/mnt/cdrom' m mount-point witharg 'Select the mount point.'
}
function script_action_SUDO_UMOUNT () {
    local UMOUNT
    mbfl_program_found_var UMOUNT /bin/umount || exit $?
    mbfl_program_exec "$UMOUNT" "$script_option_CDROM_MOUNT_POINT" >&2
}

#page
#### help actions

function script_before_parsing_options_HELP () {
    script_USAGE="usage: ${script_PROGNAME} help [action] [options]"
    script_DESCRIPTION='Help the user of this program.'
}
function script_action_HELP () {
    # By faking the  selection of the MAIN action: we  cause "mbfl_main_print_usage_screen_brief" to
    # print the main usage screen.
    mbfl_actions_fake_action_set MAIN
    mbfl_main_print_usage_screen_brief
}

### ------------------------------------------------------------------------

function script_before_parsing_options_HELP_USAGE () {
    script_USAGE="usage: ${script_PROGNAME} help usage [options]"
    script_DESCRIPTION='Print the usage screen and exit.'
}
function script_action_HELP_USAGE () {
    if mbfl_wrong_num_args 0 $ARGC
    then
	# By faking the selection of  the MAIN action: we cause "mbfl_main_print_usage_screen_brief"
	# to print the main usage screen.
	mbfl_actions_fake_action_set MAIN
	mbfl_main_print_usage_screen_brief
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

## --------------------------------------------------------------------

function script_before_parsing_options_HELP_PRINT_COMPLETIONS_SCRIPT () {
    script_PRINT_COMPLETIONS="usage: ${script_PROGNAME} help print-completions-script [options]"
    script_DESCRIPTION='Print the command-line completions script and exit.'
}
function script_action_HELP_PRINT_COMPLETIONS_SCRIPT () {
    if mbfl_wrong_num_args 0 $ARGC
    then mbfl_actions_completion_print_script "$COMPLETIONS_SCRIPT_NAMESPACE" "$script_PROGNAME"
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

#page
#### helper functions

function show_mount_point () {
    mbfl_option_show_program_save
    mbfl_option_test_save
    {
	local MOUNT GREP GAWK
	mbfl_program_found_var MOUNT /bin/mount
	mbfl_program_found_var GREP  /bin/grep
	mbfl_program_found_var GAWK  /bin/gawk
	mbfl_program_exec "$MOUNT" -l | mbfl_program_exec "$GREP" "$1" | mbfl_program_exec "$GAWK" '
BEGIN {
   COLOR_NORM_GREEN="\033[32;40m"
   COLOR_BOLD_GREEN="\033[32;40;1m"
   COLOR_NORM_PURPLE="\033[35;40m"
   COLOR_BOLD_PURPLE="\033[35;40;1m"
   COLOR_NORM_YELLOW="\033[33;40m"
   COLOR_BOLD_YELLOW="\033[33;40;1m"
   COLOR_NORM_CYAN="\033[36;40m"
   COLOR_BOLD_CYAN="\033[36;40;1m"
   COLOR_RESET="\033[0m"
}
// {
   device=$1
   mount_point=$3
   fs_type=$5
   options=$6
   label1=$7
   label2=$8
   label3=$9
   printf "%s%-12s%s", \
     COLOR_BOLD_YELLOW, device, COLOR_RESET
   printf " on"
   printf " %s%-12s%s",
     COLOR_BOLD_CYAN, mount_point, COLOR_RESET
   printf " %s%s%s", COLOR_NORM_GREEN, fs_type, COLOR_RESET
   printf " %s", options
   printf " %s%s %s %s%s", \
     COLOR_BOLD_PURPLE, label1, label2, label3, COLOR_RESET
   printf "\n"
}'
    }
    mbfl_option_show_program_restore
    mbfl_option_test_restore
}

#page
#### let's go

mbfl_main

### end of file
# Local Variables:
# mode: sh
# End:
