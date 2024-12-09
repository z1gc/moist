# Unstable Gentoo Overlay

This overlay aims to be reproducible of Gentoo Linux, of course, it couldn't.

It just a big mess repository that manages my personal machines, which are all
running the Gentoo Linux ;)

Why named Unstable? Because it's, really is, don't use it.

## Use

Unstable using `USE` flags for specifying components, and different machine/user
has different `SLOT` to indicate.

## Stages Design

For new build:

```bash
curl "https://raw.githubusercontent.com/z1gc/unstable/refs/heads/main/bootstrap.sh" | bash

echo "evil" > /etc/hostname
emerge -va1 pygoscelis-papua/portage
emerge -va -UNDu @world

reboot
```

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
