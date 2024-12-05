# theme for fish shell : graystatus
# https://github.com/usami-k/graystatus/blob/e12bb14f8416d5e56d1be79a5e2dab03b10522b9/functions/fish_prompt.fish

set __fish_git_prompt_showdirtystate yes
set __fish_git_prompt_showstashstate yes
set __fish_git_prompt_showuntrackedfiles yes
set __fish_git_prompt_showupstream informative
set __fish_git_prompt_describe_style default

function fish_prompt
    set -g fish_last_status $status
    set -l host ""
    if set -q SSH_TTY
        set host "@"(string split -f1 -m1 ' ' $SSH_CONNECTION)
    end

    printf "\033[K"
    set_color brblack
    echo -n '['(prompt_pwd -d 0)"]$host"
    echo -n (fish_vcs_prompt)
    echo

    echo -n (string repeat -n $SHLVL '$')
    echo -n ' '
    set_color normal
end

function fish_cmd_duration_prompt
    if test $CMD_DURATION -ne 0
        # https://unix.stackexchange.com/a/27014
        set -l d (math -s 0 $CMD_DURATION / 1000 / 60 / 60 / 24)
        set -l h (math -s 0 $CMD_DURATION / 1000 / 60 / 60 % 24)
        set -l m (math -s 0 $CMD_DURATION / 1000 / 60 % 60)
        set -l s (math -s 0 $CMD_DURATION / 1000 % 60)
        set -l ms (math -s 0 $CMD_DURATION % 1000)

        test $d -gt 0 && echo -n "$d""d"
        test $h -gt 0 && echo -n "$h""h"
        test $m -gt 0 && echo -n "$m""m"
        test $s -gt 0 && echo -n "$s""s"
        echo -n "$ms""ms$argv"
    end
end

function fish_right_prompt
    # The first line right prompt, from:
    # https://github.com/fish-shell/fish-shell/issues/1706#issuecomment-2430550184
    tput sc
    tput cuu1
    tput cuf 2

    if test $fish_last_status -ne 0
        set_color red
        echo -n "$fish_last_status"
        set_color brblack
        echo -n " | "
    else
        set_color brblack
    end

    fish_cmd_duration_prompt " | "
    echo -n (date +"%F%%%T")

    tput rc

    # Can place other info in the second line right prompt :)
    set_color normal
end
