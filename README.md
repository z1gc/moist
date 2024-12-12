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

The `pygoscelis-papua` group is mainly a meta-package contains most of what you
need.

The `aptenodytes-forsteri` group is small components, like your dotfiles or
the things that needs by `pygoscelis-papua`.

Relation is `world` contains `pygoscelis-papua` contains `aptenodytes-forsteri`.

## Stages Design

For new build:

```bash
curl -L https://github.com/z1gc/unstable/raw/refs/heads/main/boostrap.sh | bash

# If you want to change your machine, or add user, or something else, re-run it:
MNSTABLE=evil UNSTABLE=byte emerge -va1 pygoscelis-papua/portage
emerge -va -UNDu @world

reboot
```

If anything inside `pygoscelis-papua/portage` is changed, you'd better re-merge
it as well :O

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

* [ ] Simplify the build steps more...
* [ ] Make a snapshot after full installation, and make Gento persists.
* [ ] Don't send BUGs to Gentoo developers, it's kind of my personal flavor.

## FAQ or Notes

If you're switching profile, such as from systemd to gnome/systemd, you may
encounter [the circular dependencies](https://wiki.gentoo.org/wiki/Portage/Help/Circular_dependencies#harfbuzz_and_freetype)
problem, which is kind of annoying, and should be fix before you upgrade the
whole `@world` :/

For SSH connection, be sure to reset your `LANGUAGE` and `LC_MESSAGES` back to
`C` when doing a fresh installation, some package will fail if your `locale.gen`
hasn't ready yet.

If you want to start debugging, or to verify whether this overlay breaks your
system, you can always check `/var/db/pkg/...` for informations, some useful
files may be:

* `CONTENTS`, this is what the emerge actually merged into the system, with the
  corresponding checksum (md5sum) and timestamp (seems like mtime)
* `environment.bz2`, this is the whole build script

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

## Example Build

With Gentoo livecd, following the [AMD64 handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage).

```bash
# in livecd
cfdisk /dev/vda
mkfs.fat -F 32 /dev/vda1
mkfs.btrfs /dev/vda2
mount /dev/vda2 /mnt/gentoo
btrfs subvolume create /mnt/gentoo/@gentoo
btrfs subvolume create /mnt/gentoo/@home
umount /mnt/gentoo
mount -o subvol=@gentoo /dev/vda2 /mnt/gentoo

cd /mnt/gentoo
wget '.../stage3-...'
tar xpf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo
rm -fv stage3-*.tar.xz
cp -L /etc/resolv.conf /mnt/gentoo/etc/
arch-chroot /mnt/gentoo

# in chroot
mkdir /efi
mount /dev/vda1 /efi
mount -o subvol=@home /dev/vda2 /home

# following the "Stage Design" part
export LC_ALL="C"
emerge ...
```
