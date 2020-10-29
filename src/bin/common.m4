#
# Part of: MMUX Removable Media Utilities
# Contents: common functions
# Date: Oct 29, 2020
#
# Abstract
#
#	This module is meant to be included in all the source code of all the scripts.
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
#### program declarations

mbfl_program_enable_sudo
mbfl_declare_program /bin/mount
mbfl_declare_program /bin/umount
mbfl_declare_program /bin/grep
mbfl_declare_program /bin/gawk

#page
#### script actions declaration

# DEFINE_MAIN_ACTIONS_TREE(DEVICE_NAME)
#
m4_define([[[DEFINE_MAIN_ACTIONS_TREE]]],[[[
mbfl_declare_action_set HELP
mbfl_declare_action HELP HELP_USAGE			NONE usage			'Print the help screen and exit.'
mbfl_declare_action HELP HELP_PRINT_COMPLETIONS_SCRIPT	NONE print-completions-script	'Print the completions script for this program.'

mbfl_declare_action_set MAIN
mbfl_declare_action MAIN MOUNT		NONE mount		'Mount a $1.'
mbfl_declare_action MAIN UMOUNT		NONE umount		'Unmount a $1.'
mbfl_declare_action MAIN SHOW		NONE show		'Show $1 mount status.'
mbfl_declare_action MAIN SUDO_MOUNT	NONE sudo-mount		'Internal action.'
mbfl_declare_action MAIN SUDO_UMOUNT	NONE sudo-umount	'Internal action.'
mbfl_declare_action MAIN HELP		HELP help		'Help the user of this script.'
]]])

#page
#### action functions: core, device generic, actions

# DEVICE_GENERIC_ACTIONS(DEVICE_NAME)
#
m4_define([[[DEVICE_GENERIC_ACTIONS]]],[[[
function script_before_parsing_options_MOUNT () {
    script_USAGE="usage: ${script_PROGNAME} mount [options]"
    script_DESCRIPTION='Mount a $1.'
    mbfl_declare_option MOUNT_POINT "$DEFAULT_MOUNT_POINT" m mount-point witharg 'Select the mount point.'
    mbfl_declare_option GROUP_NAME  "$DEFAULT_GROUP_NAME"  g group       witharg "Select the user's group name."
}
function script_action_MOUNT () {
    mbfl_local_varref(USERID)
    mbfl_local_varref(GROUPID)

    mbfl_system_effective_user_id_var mbfl_datavar(USERID)
    if mbfl_string_is_empty "$script_option_GROUP_NAME"
    then mbfl_system_effective_group_id_var mbfl_datavar(GROUPID)
    else mbfl_system_effective_group_id_var mbfl_datavar(GROUPID) "$script_option_GROUP_NAME"
    fi

    mbfl_local_varref(FLAGS)
    mbfl_getopts_gather_mbfl_options_var mbfl_datavar(FLAGS)

    mbfl_message_verbose_printf 'mounting a $1 under the mount point: "%s"\n' "$script_option_MOUNT_POINT"
    mbfl_message_verbose_printf 'using the user id "%s" and group id "%s"\n' "$USERID" "$GROUPID"

    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-mount "$script_option_MOUNT_POINT" "$USERID" "$GROUPID" $FLAGS
    then
	if mbfl_option_verbose
	then show_mount_point "$script_option_MOUNT_POINT"
	fi
	exit_because_success
    else
	mbfl_message_error_printf 'error mounting $1 under the mount point: "%s"' "$script_option_MOUNT_POINT"
	exit_because_failure
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_UMOUNT () {
    script_USAGE="usage: ${script_PROGNAME} umount [options]"
    script_DESCRIPTION='Unmount a $1.'
    mbfl_declare_option MOUNT_POINT "$DEFAULT_MOUNT_POINT" m mount-point witharg 'Select the mount point.'
}
function script_action_UMOUNT () {
    mbfl_local_varref(FLAGS)
    mbfl_getopts_gather_mbfl_options_var mbfl_datavar(FLAGS)

    mbfl_program_declare_sudo_user root
    if mbfl_program_exec "$SCRIPT_ARGV0" sudo-umount "$script_option_MOUNT_POINT" $FLAGS
    then
	# Always try to show the mount point.
	if mbfl_option_verbose
	then show_mount_point "$script_option_MOUNT_POINT"
	fi
	exit_success
    else
	show_mount_point "$script_option_MOUNT_POINT"
	mbfl_message_error_printf 'error unmounting $1 from: "%s"' "$script_option_MOUNT_POINT"
	exit_failure
    fi
}

### ------------------------------------------------------------------------

function script_before_parsing_options_SHOW () {
    script_USAGE="usage: ${script_PROGNAME} show [options]"
    script_DESCRIPTION='Show $1 mount status.'
    mbfl_declare_option MOUNT_POINT "$DEFAULT_MOUNT_POINT" m mount-point witharg 'Select the mount point.'
}
function script_action_SHOW () {
    show_mount_point "$script_option_MOUNT_POINT"
}

### ------------------------------------------------------------------------

function script_action_SUDO_MOUNT () {
    if mbfl_wrong_num_args 3 $ARGC
    then
	local MOUNT
	mbfl_program_found_var MOUNT /bin/mount || exit $?
	mbfl_command_line_argument(MOUNT_POINT, 0)
	mbfl_command_line_argument(USERID,      1)
	mbfl_command_line_argument(GROUPID,     2)
	if mbfl_program_exec "$MOUNT" "$MOUNT_POINT" -o uid="$USERID",gid="$GROUPID" >&2
	then true
	     # Not all file systems support UID and GID options, so retry without those.
	elif mbfl_program_exec "$MOUNT" "$MOUNT_POINT" >&2
	then true
	else exit_failure
	fi
    else
	mbfl_main_print_usage_screen_brief
	exit_because_wrong_num_args
    fi
}

### ------------------------------------------------------------------------

function script_action_SUDO_UMOUNT () {
    if mbfl_wrong_num_args 1 $ARGC
    then
	mbfl_command_line_argument(MOUNT_POINT, 0)
	local UMOUNT
	mbfl_program_found_var UMOUNT /bin/umount || exit $?
	mbfl_program_exec "$UMOUNT" "$MOUNT_POINT" >&2
    else
	mbfl_main_print_usage_screen_brief
	exit_failure
    fi
}

]]])

#page
#### help actions definition

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
#### main function

function main () {
    mbfl_main_print_usage_screen_brief
}

#page
#### miscellaneous functions

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

### end of file
# Local Variables:
# mode: sh
# End:
