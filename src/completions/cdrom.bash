# cdrom.bash --
#
# Completions for the "cdrom" script.

complete -F p-removable-media-utilities-completion-cdrom cdrom
function p-removable-media-utilities-completion-cdrom () {
    local word_to_be_completed=${COMP_WORDS[${COMP_CWORD}]}
    # COMP_CWORD is zero based.  Index 0 is the "cdrom" word.
    case "$COMP_CWORD" in
        1)
            local first_word_completions='mount umount show help'
            COMPREPLY=(`compgen -W "$first_word_completions" -- "$word_to_be_completed"`)
            ;;
    esac
}

### end of file
