# pendrive.bash --
#
# Completions for the "pendrive" script.

complete -F p-removable-media-utilities-completion-pendrive pendrive
function p-removable-media-utilities-completion-pendrive () {
    local word_to_be_completed=${COMP_WORDS[${COMP_CWORD}]}
    # COMP_CWORD is zero based.  Index 0 is the "pendrive" word.
    case "$COMP_CWORD" in
        1)
            local first_word_completions='mount umount help version version-only'
            COMPREPLY=(`compgen -W "$first_word_completions" -- "$word_to_be_completed"`)
            ;;
    esac
}

### end of file
