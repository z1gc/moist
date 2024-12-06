# Moist Gentoo Overlay

This overlay aims to be reproducible of Gentoo Linux, of course, it couldn't.

It just a big mess repository that manages my personal machines, which are all
running the Gentoo Linux ;)

Why named Moist? I've no idea.

## Stages Design

For new build:

```bash
cd /tmp

# TODO: More shorten way?
curl https://gist.githubusercontent.com/z1gc/a732d040583611956036ceeccc2b6aa8/raw/install-gitoxide.sh | bash
./gix clone --depth 1 https://mirrors.ustc.edu.cn/gentoo.git /var/db/repos/gentoo
./gix clone --depth 1 https://github.com/z1gc/moist /var/db/repos/moist
rm -fv gix

echo -e "[moist]\nlocation=/var/db/repos/moist" \
   > /etc/portage/repos.conf/moist.conf

# Global config using USE:
echo "evil" > /etc/hostname
emerge -va pygoscelis-papua/portage
emerge --sync

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

# In podman:
mkdir -p /etc/portage/repos.conf
echo -e "[moist]\nlocation=/var/db/repos/moist" \
   > /etc/portage/repos.conf/moist.conf
emerge ...
```

You can use `emerge -1` with `emerge -vac` for faster testing.
