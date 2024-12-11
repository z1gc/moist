function __fish_reset_cursor_on_postexec --on-event fish_postexec
    # no quotes, we have two arguments:
    __fish_cursor_xterm $fish_cursor_default
end
