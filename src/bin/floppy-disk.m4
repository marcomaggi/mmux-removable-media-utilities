#!/bin/bash
#
# Part of: Removable Media Utilities
# Contents: floppy disk control
# Date: Fri Jun  7, 2013
#
# Abstract
#
#
#
# Copyright (C) 2013 Marco Maggi <marco.maggi-ipsu@poste.it>
#
# This  program  is free  software:  you  can redistribute  it
# and/or modify it  under the terms of the  GNU General Public
# License as published by the Free Software Foundation, either
# version  3 of  the License,  or (at  your option)  any later
# version.
#
# This  program is  distributed in  the hope  that it  will be
# useful, but  WITHOUT ANY WARRANTY; without  even the implied
# warranty  of  MERCHANTABILITY or  FITNESS  FOR A  PARTICULAR
# PURPOSE.   See  the  GNU  General Public  License  for  more
# details.
#
# You should  have received a  copy of the GNU  General Public
# License   along   with    this   program.    If   not,   see
# <http://www.gnu.org/licenses/>.
#

#page
#### global variables

declare -r script_PROGNAME=floppy-disk
declare -r script_VERSION=0.2d0
declare -r script_COPYRIGHT_YEARS='2013'
declare -r script_AUTHOR='Marco Maggi'
declare -r script_LICENSE=GPL
declare script_USAGE="usage: ${script_PROGNAME} [action] [options]"
declare script_DESCRIPTION='Perform floppy disk operations.'
declare script_EXAMPLES=

declare -r SCRIPT_ARGV0="$0"

declare -r DEFAULT_DEVICE=/dev/fd/0
declare -r DEFAULT_LABEL=nolabel
declare -r DEFAULT_MOUNT_POINT=/mnt/floppy

#page
#### library loading

mbfl_INTERACTIVE=no
mbfl_LOADED=no
mbfl_HARDCODED=
mbfl_INSTALLED=$(mbfl-config) &>/dev/null
for item in "$MBFL_LIBRARY" "$mbfl_HARDCODED" "$mbfl_INSTALLED"
do
    if test -n "$item" -a -f "$item" -a -r "$item"
    then
        if ! source "$item" &>/dev/null
	then
            printf '%s error: loading MBFL file "%s"\n' \
                "$script_PROGNAME" "$item" >&2
            exit 2
        fi
	break
    fi
done
unset -v item
if test "$mbfl_LOADED" != yes
then
    printf '%s error: incorrect evaluation of MBFL\n' \
        "$script_PROGNAME" >&2
    exit 2
fi

#page
#### program declarations

mbfl_program_enable_sudo
mbfl_declare_program /bin/mount
mbfl_declare_program /bin/umount
mbfl_declare_program /bin/grep
mbfl_declare_program /bin/gawk
mbfl_declare_program /bin/id
mbfl_declare_program /sbin/mke2fs

# The program "superformat" comes with the "fdutils" package.
mbfl_declare_program superformat

#page
#### script actions

mbfl_declare_action_set MAIN
mbfl_declare_action MAIN MOUNT		NONE mount		'Mount a floppy disk.'
mbfl_declare_action MAIN UMOUNT		NONE umount		'Unmount a floppy disk.'
mbfl_declare_action MAIN SHOW		NONE show		'Show floppy disk mount status.'
mbfl_declare_action MAIN FORMAT		NONE format		'Format a floppy disk.'
mbfl_declare_action MAIN SUDO_MOUNT	NONE sudo-mount		'Internal action.'
mbfl_declare_action MAIN SUDO_UMOUNT	NONE sudo-umount	'Internal action.'
mbfl_declare_action MAIN SUDO_FORMAT	NONE sudo-format	'Internal action.'
mbfl_declare_action MAIN SUDO_MKFS	NONE sudo-mkfs		'Internal action.'
mbfl_declare_action MAIN HELP		NONE help		'Print help screen and exit.'

function script_before_parsing_options_MOUNT () {
    script_USAGE="usage: ${script_PROGNAME} mount [options]"
    script_DESCRIPTION='Mount a floppy disk.'
    mbfl_declare_option MOUNT_POINT "$DEFAULT_MOUNT_POINT" m mount-point witharg 'Select the mount point.'
}
function script_before_parsing_options_UMOUNT () {
    script_USAGE="usage: ${script_PROGNAME} umount [options]"
    script_DESCRIPTION='Unmount a floppy disk.'
    mbfl_declare_option MOUNT_POINT "$DEFAULT_MOUNT_POINT" m mount-point witharg 'Select the mount point.'
}
function script_before_parsing_options_SHOW () {
    script_USAGE="usage: ${script_PROGNAME} show [options]"
    script_DESCRIPTION='Show floppy disk mount status.'
    mbfl_declare_option MOUNT_POINT "$DEFAULT_MOUNT_POINT" m mount-point witharg 'Select the mount point.'
}
function script_before_parsing_options_FORMAT () {
    script_USAGE="usage: ${script_PROGNAME} format [options]"
    script_DESCRIPTION='Format a floppy disk.  The device of integrated floppy drives
is something like "/dev/fd/0"; a pluggable USB floppy drive may
have device: "/dev/sdb".'
    mbfl_declare_option DEVICE "$DEFAULT_DEVICE" d device witharg 'Select the floppy disk device.'
    mbfl_declare_option LABEL  "$DEFAULT_LABEL"  l label  witharg 'Select the device label.'
}

## --------------------------------------------------------------------

function script_before_parsing_options_SUDO_FORMAT () {
    script_USAGE="usage: ${script_PROGNAME} sudo-format DEVICE [options]"
    script_DESCRIPTION='Format the floppy disk.'
}
function script_before_parsing_options_SUDO_MKFS () {
    script_USAGE="usage: ${script_PROGNAME} sudo-mkfs DEVICE LABEL [options]"
    script_DESCRIPTION='Create a file system on the floppy disk.'
}

#page
#### generic action functions

function main () {
    mbfl_main_print_usage_screen_brief
}
function script_action_SHOW () {
    show_mount_point "$script_option_MOUNT_POINT"
}
function script_action_HELP () {
    mbfl_actions_fake_action_set MAIN
    mbfl_main_print_usage_screen_brief
}

#page
#### core action functions

function script_action_MOUNT () {
    local ID USR_ID GRP_ID FLAGS
    ID=$(mbfl_program_found /bin/id)
    USR_ID=$(mbfl_program_exec "$ID" --user)
    GRP_ID=$(mbfl_program_exec "$ID" --group)
    mbfl_option_show_program && FLAGS="$FLAGS --show-program"
    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-mount "$script_option_MOUNT_POINT" "$USR_ID" "$GRP_ID" $FLAGS
    then
	mbfl_option_verbose && show_mount_point "$script_option_MOUNT_POINT"
	exit_success
    else
	mbfl_message_error 'error mounting floppy disk'
	exit_failure
    fi
}
function script_action_UMOUNT () {
    local FLAGS
    mbfl_option_show_program && FLAGS="$FLAGS --show-program"
    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-umount "$script_option_MOUNT_POINT" $FLAGS
	# Always try to show the mount point.
    then
	mbfl_option_verbose && show_mount_point "$script_option_MOUNT_POINT"
	exit_success
    else
	show_mount_point "$script_option_MOUNT_POINT"
	mbfl_message_error 'error unmounting floppy disk'
	exit_failure
    fi
}
function script_action_FORMAT () {
    local FLAGS
    mbfl_option_show_program && FLAGS="$FLAGS --show-program"
    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-format "$script_option_DEVICE" $FLAGS
    then exit_success
    else
	mbfl_message_error 'error formatting the floppy disk'
	exit_failure
    fi
    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-mkfs "$script_option_DEVICE" "$script_option_LABEL" $FLAGS
    then exit_success
    else
	mbfl_message_error 'error creating file system on the floppy disk'
	exit_failure
    fi
}

#page
#### super user action functions

function script_action_SUDO_MOUNT () {
    local MOUNT
    MOUNT=$(mbfl_program_found /bin/mount)
    if mbfl_wrong_num_args 3 $ARGC
    then
	local MOUNT_POINT=${ARGV[0]}
	local USR_ID=${ARGV[1]}
	local GRP_ID=${ARGV[2]}
	if mbfl_program_exec "$MOUNT" "$MOUNT_POINT" -o uid="$USR_ID",gid="$GRP_ID" >&2
	then true
	else
            # Not all  file systems  support UID and  GID options,  so retry
            # without those.
	    mbfl_program_exec "$MOUNT" "$MOUNT_POINT" >&2
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_failure
    fi
}
function script_action_SUDO_UMOUNT () {
    UMOUNT=$(mbfl_program_found /bin/umount)
    if mbfl_wrong_num_args 1 $ARGC
    then
	local MOUNT_POINT=${ARGV[0]}
	mbfl_program_exec "$UMOUNT" "$MOUNT_POINT" >&2
    else
	mbfl_main_print_usage_screen_brief
	exit_failure
    fi
}
function script_action_SUDO_FORMAT () {
    local SUPERFORMAT
    SUPERFORMAT=$(mbfl_program_found superformat) || exit $?
    if mbfl_wrong_num_args 1 $ARGC
    then
	local DEVICE=${ARGV[0]}
	mbfl_program_exec "$SUPERFORMAT" --verbosity 2 --superverify "$DEVICE" hd
    else
	mbfl_main_print_usage_screen_brief
	exit_failure
    fi
}
function script_action_SUDO_MKFS () {
    local MKE2FS INODESIZE=1024
    MKE2FS=$(mbfl_program_found /sbin/mke2fs) || exit $?
    if mbfl_wrong_num_args 2 $ARGC
    then
	local DEVICE=${ARGV[0]}
	local LABEL=${ARGV[1]}
	mbfl_program_exec "$MKE2FS" -c -i $INODESIZE -L "$LABEL" "$DEVICE"
    else
	mbfl_main_print_usage_screen_brief
	exit_failure
    fi
}

#page
#### helper functions

function show_mount_point () {
    local MOUNT GREP GAWK
    MOUNT=$(mbfl_program_found /bin/mount)
    GREP=$(mbfl_program_found /bin/grep)
    GAWK=$(mbfl_program_found /bin/gawk)
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

#page
#### let's go

mbfl_main

### end of file
# Local Variables:
# mode: sh-mode
# End:
