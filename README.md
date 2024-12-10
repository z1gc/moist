# Unstable Gentoo Overlay

This overlay aims to be reproducible of Gentoo Linux, of course, it couldn't.

It just a big mess repository that manages my personal machines, which are all
running the Gentoo Linux ;)

Why named Unstable? Because it's, really is, don't use it.

## Use

Unstable using `USE` flags for specifying components, and different machine/user
has different `USE_EXPAND` to indicate.

```bash
# Machine is Not Stable
pygoscelis-papua/portage MNSTABLE: evil

# User is Not Stable
aptenodytes-forsteri/gnome UNSTABLE: byte
```

## Stages Design

For new build:

```bash
curl -L https://github.com/z1gc/unstable/raw/refs/heads/main/boostrap.sh | bash

# If you want to change your machine, or add user, or something else, re-run it:
MNSTABLE=evil UNSTABLE=byte emerge -va1 pygoscelis-papua/portage
emerge -va -UNDu @world

reboot
```

Notice Gentoo will [cache the USE flags](https://devmanual.gentoo.org/general-concepts/portage-cache/index.html),
and since the USE flags in unstable are generated at the run-time, it will lead
portage selecting wrong USE flags when `MNSTABLE=` or `UNSTABLE=` is being
changed.

```bash
# Or you can remove the entire `edb` directory, it's safe.
rm -rfv /var/cache/edb/dep/var/db/repos/unstable
```

This may work.

## Next Step

[ ] Simplify the build steps more...

## Testing

I'm using `podman` for testing if configuration is correct,

```bash
podman run -v $PWD:/var/db/repos/unstable \
           -v /var/db/repos/gentoo:/var/db/repos/gentoo \
           --rm -it -h $(hostname) gentoo/stage3:systemd

# In podman:
mkdir -p /etc/portage/repos.conf
echo -e "[unstable]\nlocation=/var/db/repos/unstable" \
   > /etc/portage/repos.conf/unstable.conf
emerge ...
```

You can use `emerge -1` with `emerge -vac` for faster testing.
