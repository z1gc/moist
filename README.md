# Moist Gentoo Overlay

This overlay aims to be reproducible of Gentoo Linux, of course, it couldn't.

It just a big mess repository that manages my personal machines, which are all
running the Gentoo Linux ;)

Why named Moist? I've no idea.

## Stages Design

It's hard to keep everything shiny with just one `emerge` command, therefore we
use multiple stages, to successfully setup the machine:

1. Install Gentoo as usual, after `chroot` and `emerge-webrsync`, add this repo
   to overlay using `eselect repository` (you might need to install some
   dependency tools).

2. First thing first, is to setup the Gentoo base (setting partition is some
   kind of difficult with only overlay), which includes:

   1. The `make.conf` generated based on what your machine defines.

   2. The profile which going to use.

   3. The UKI kernel config.

   4. The initial packages, such as `linux-firmware`, to prevent from failing
      the next step (UKI image will use the firmware to integrate ucode).

   5. The world sets.

   Base on this, if you have new machine which want to install the Gentoo, try
   modify one of `setup-machine/..` file.

   Then use `emerge -a setup-machine/evil` or other machine name to emerge it.

3. And the next step (huhm), is to setup your current user, for me I'm using
   the `emerge -a setup-user/byte` with `UID:GID = 1000:1000`.

   The `@moist-world` will emerge what you selected.

4. The last step is to setup bootup things, like kernel and desktop environment.
   Just using world set, and it will be ready for you.

   The secret is `emerge -a @moist-world`.

## Arriving `$HOME`

For some dotfiles that are placed into `$HOME` directory, or systemd user
services, we use the `SLOT` in ebuild to indicate what user you're using.

For dynamic purpose, the `SLOT` will read from environment variable `$SUDO_USER`
and `$USER`.
