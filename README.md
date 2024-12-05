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

   And besure to setup the hostname, e.g.

   ```bash
   echo "evil" > /etc/hostname
   ```

2. First thing first, is to setup the Gentoo base (setting partition is some
   kind of difficult with only overlay), which includes:

   1. The `make.conf` generated based on what your machine defines.

   2. The profile which going to use.

   3. The UKI kernel config.

   4. The initial packages, such as `linux-firmware`, to prevent from failing
      the next step (UKI image will use the firmware to integrate ucode).

   5. The sets.

   Base on this, if you have new machine which want to install the Gentoo, try
   modify one of `set-up/portage/..` file.

   Then use `emerge -va set-up/portage` or other machine name to emerge it.

3. And the next step (huhm), is to setup your current user, for me I'm using
   the `emerge -va setup-user/byte` with `UID:GID = 1000:1000`.

4. The last step is to setup bootup things, like kernel and desktop environment.
   Just using world set, and it will be ready for you.

   The secret is `emerge -va @moist-world`.

5. Horray! I like the number five !)

## Arriving `$HOME`

For some dotfiles that are placed into `$HOME` directory, or systemd user
services, we use the `SLOT` in ebuild to indicate what user you're using.

For dynamic purpose, the `SLOT` will read from environment variable `$SUDO_USER`
and `$USER`.

## Testing

I'm using `podman` for testing if configuration is correct,

```bash
podman run -v $PWD:/var/db/repos/moist \
           -v /var/db/repos/gentoo:/var/db/repos/gentoo \
           -v /etc/portage/gnupg:/etc/portage/gnupg \
           --name moist -it -h $(hostname) gentoo/stage3:systemd

# In podman:
mkdir -p /etc/portage/repos.conf
echo -e "[moist]\nlocation=/var/db/repos/moist" \
   > /etc/portage/repos.conf/moist.conf
emerge -va set-up/portage
emerge ...
```

You can use `emerge -1` with `emerge -cva` for faster testing.
