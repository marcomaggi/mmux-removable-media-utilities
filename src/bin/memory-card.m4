#!/bin/bash
#
# Part of: Removable Media Utilities
# Contents: SD memory card control
# Date: Tue Dec 23, 2014
#
# Abstract
#
#
#
# Copyright (C) 2014 Marco Maggi <marco.maggi-ipsu@poste.it>
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

declare -r script_PROGNAME=memory-card
declare -r script_VERSION=0.1d0
declare -r script_COPYRIGHT_YEARS='2014'
declare -r script_AUTHOR='Marco Maggi'
declare -r script_LICENSE=GPL
declare script_USAGE="usage: ${script_PROGNAME} [action] [options]"
declare script_DESCRIPTION='Perform SD memory card operations.'
declare script_EXAMPLES=

declare -r SCRIPT_ARGV0="$0"

declare script_option_MEMORY_CARD_MOUNT_POINT=/media/memory

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

#page
#### script actions

mbfl_declare_action_set MAIN
mbfl_declare_action MAIN MOUNT		NONE mount		'Mount a SD memory card.'
mbfl_declare_action MAIN UMOUNT		NONE umount		'Unmount a SD memory card.'
mbfl_declare_action MAIN SHOW		NONE show		'Show SD memory card mount status.'
mbfl_declare_action MAIN SUDO_MOUNT	NONE sudo-mount		'Internal action.'
mbfl_declare_action MAIN SUDO_UMOUNT	NONE sudo-umount	'Internal action.'
mbfl_declare_action MAIN HELP		NONE help		'Print help screen and exit.'

mbfl_declare_option MEMORY_CARD_MOUNT_POINT '/media/memory' m mount-point witharg 'Select the mount point.'

function script_before_parsing_options_MOUNT () {
    script_USAGE="usage: ${script_PROGNAME} mount [options]"
    script_DESCRIPTION='Mount a SD memory card.'
}
function script_before_parsing_options_UMOUNT () {
    script_USAGE="usage: ${script_PROGNAME} umount [options]"
    script_DESCRIPTION='Unmount a SD memory card.'
}
function script_before_parsing_options_SHOW () {
    script_USAGE="usage: ${script_PROGNAME} show [options]"
    script_DESCRIPTION='Show SD memory card mount status.'
}

#page
#### action functions

function script_action_MOUNT () {
    local ID USR_ID GRP_ID EXIT_CODE
    ID=$(mbfl_program_found /bin/id)
    USR_ID=$(mbfl_program_exec "$ID" --user)
    GRP_ID=$(mbfl_program_exec "$ID" --group)
    mbfl_message_verbose 'mounting SD memory card\n'
    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-mount "$USR_ID" "$GRP_ID" --mount-point="$script_option_MEMORY_CARD_MOUNT_POINT"
    then
	mbfl_option_verbose && show_mount_point "$script_option_MEMORY_CARD_MOUNT_POINT"
	exit_success
    else
	mbfl_message_error 'error mounting SD memory card'
	exit_failure
    fi
}
function script_action_UMOUNT () {
    mbfl_program_declare_sudo_user root
    mbfl_message_verbose 'unmounting SD memory card\n'
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-umount --mount-point="$script_option_MEMORY_CARD_MOUNT_POINT"
	# Always try to show the mount point.
    then
	mbfl_option_verbose && show_mount_point "$script_option_MEMORY_CARD_MOUNT_POINT"
	exit_success
    else
	show_mount_point "$script_option_MEMORY_CARD_MOUNT_POINT"
	mbfl_message_error 'error unmounting SD memory card'
	exit_failure
    fi
}
function script_action_SHOW () {
    show_mount_point "$script_option_MEMORY_CARD_MOUNT_POINT"
}
function script_action_SUDO_MOUNT () {
    local MOUNT USR_ID GRP_ID
    mbfl_wrong_num_args 2 $ARGC
    MOUNT=$(mbfl_program_found /bin/mount)
    USR_ID=${ARGV[0]}
    GRP_ID=${ARGV[1]}
    mbfl_message_verbose 'running mount command\n'
    if mbfl_program_exec "$MOUNT" "$script_option_MEMORY_CARD_MOUNT_POINT" -o uid="$USR_ID",gid="$GRP_ID" >&2
    then true
    else
	mbfl_message_verbose 'mounting with UID and GID settings failed\n'
	mbfl_message_verbose 'trying to mount without UID and GID settings\n'
        # Not all  file systems  support UID and  GID options,  so retry
        # without those.
	if mbfl_program_exec "$MOUNT" "$script_option_MEMORY_CARD_MOUNT_POINT" >&2
	then true
	else exit_failure
	fi
    fi
}
function script_action_SUDO_UMOUNT () {
    UMOUNT=$(mbfl_program_found /bin/umount)
    mbfl_program_exec "$UMOUNT" "$script_option_MEMORY_CARD_MOUNT_POINT" >&2
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

function main () {
    mbfl_main_print_usage_screen_brief
}
function script_action_HELP () {
    mbfl_actions_fake_action_set MAIN
    mbfl_main_print_usage_screen_brief
}
mbfl_main

### end of file
# Local Variables:
# mode: sh-mode
# End:
