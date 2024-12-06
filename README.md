# Moist Gentoo Overlay

This overlay aims to be reproducible of Gentoo Linux, of course, it couldn't.

It just a big mess repository that manages my personal machines, which are all
running the Gentoo Linux ;)

Why named Moist? I've no idea.

## Use

Moist using `USE` flags for specifying components, and different machine/user
has different `SLOT` to indicate.

## Stages Design

For new build:

```bash
curl "https://raw.githubusercontent.com/z1gc/moist/refs/heads/main/bootstrap.sh" | bash

emerge -va1 pygoscelis-papua/portage:evil
emerge -va -UNDu @world

reboot
```

## Next Step

[ ] Simplify the build steps more...

## Testing

I'm using `podman` for testing if configuration is correct,

```bash
podman run -v $PWD:/var/db/repos/moist \
           -v /var/db/repos/gentoo:/var/db/repos/gentoo \
           -v /etc/portage/gnupg:/etc/portage/gnupg \
           --rm -it -h $(hostname) gentoo/stage3:systemd
```

You can use `emerge -1` with `emerge -vac` for faster testing.
