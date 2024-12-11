#!/usr/bin/env bash

set -xeu

function gitoxide() {
  if [[ ! -x /tmp/gix ]]; then
    local version="v0.39.0"
    local arch="$(uname -m)"
    local spec="gitoxide-max-pure-$version-$arch-unknown-linux-gnu"

    pushd /tmp
    wget -O "rel.tar.gz" "https://github.com/GitoxideLabs/gitoxide/releases/download/$version/$spec.tar.gz"
    tar -xf "rel.tar.gz"
    mv "$spec/gix" gix
    rm -rf "rel.tar.gz" "$spec"
    popd
  fi

  /tmp/gix "$@"
}

function add_repo() {
  local append="$1"
  local name="$2"
  local uri="$3"
  local is_main="$4"

  local spec="/etc/portage/repos.conf/$append.conf"
  local target="/var/db/repos/$name"

  if [[ -f "$target" ]]; then
    echo "repo $name exists"
    return
  fi

  if $is_main; then
    echo "# template: /usr/share/portage/config/repos.conf
[DEFAULT]
main-repo = gentoo
" >> "$spec"
  fi

  echo "[$name]
location = $target
sync-type = git
sync-url = $uri" >> "$spec"

  if $is_main; then
    echo "auto-sync = yes
sync-rsync-verify-jobs = 1
sync-rsync-verify-metamanifest = yes
sync-rsync-verify-max-age = 3
sync-openpgp-key-path = /usr/share/openpgp-keys/gentoo-release.asc
sync-openpgp-keyserver = hkps://keys.gentoo.org
sync-openpgp-key-refresh-retry-count = 40
sync-openpgp-key-refresh-retry-overall-timeout = 1200
sync-openpgp-key-refresh-retry-delay-exp-base = 2
sync-openpgp-key-refresh-retry-delay-max = 60
sync-openpgp-key-refresh-retry-delay-mult = 4
sync-webrsync-verify-signature = yes" >> "$spec"
  fi

  gitoxide clone --depth 1 "$uri" "$target"
}

# emerge repo, they will be overwritten by pygoscelis-papau/portage
add_repo "gentoo" "gentoo" "https://mirrors.ustc.edu.cn/gentoo.git" true
add_repo "unstable" "unstable" "https://github.com/z1gc/unstable.git" false
add_repo "unstable" "gentoo-zh" "https://mirrors.cqu.edu.cn/gentoo-zh.git" false
add_repo "unstable" "guru" "https://github.com/gentoo-mirror/guru.git" false

# cleanup
rm -f /tmp/gix
