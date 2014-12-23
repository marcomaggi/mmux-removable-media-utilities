# memory-card.bash --
#
# Completions for the "memory-card" script.

complete -F p-mmux-removable-media-utilities-completion-memory-card memory-card
function p-mmux-removable-media-utilities-completion-memory-card () {
    local word_to_be_completed=${COMP_WORDS[${COMP_CWORD}]}
    # COMP_CWORD is zero based.  Index 0 is the "memory-card" word.
    case "$COMP_CWORD" in
        1)
            local first_word_completions='mount umount show help'
            COMPREPLY=(`compgen -W "$first_word_completions" -- "$word_to_be_completed"`)
            ;;
    esac
}

### end of file
