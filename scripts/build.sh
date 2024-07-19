#!/bin/env bash

PODMAN_BUILD_FOLDER=/opt/podman-source
PODMAN_PKG_FOLDER=/opt/podman-build-v5.1.2-amd64

apt update
apt install btrfs-progs crun libassuan-dev libbtrfs-dev libc6-dev libdevmapper-dev libglib2.0-dev libgpgme-dev \
  libgpg-error-dev libprotobuf-dev libprotobuf-c-dev libseccomp-dev libselinux1-dev libsystemd-dev pkg-config uidmap \
  containernetworking-plugins gcc make autoconf automake libtool wget curl git libapparmor-dev \
  protobuf-compiler -y

curl https://sh.rustup.rs -sSf | sh -s -- -y

. "$HOME/.cargo/env"

mkdir -p $PODMAN_BUILD_FOLDER
mkdir -p $PODMAN_PKG_FOLDER/usr/bin
mkdir -p $PODMAN_PKG_FOLDER/etc/containers
export GOPATH=$PODMAN_BUILD_FOLDER/go
# shellcheck disable=SC2164
cd $PODMAN_BUILD_FOLDER

wget -c https://go.dev/dl/go1.22.0.linux-amd64.tar.gz
tar -C $PODMAN_BUILD_FOLDER -xzf go1.22.0.linux-amd64.tar.gz
export PATH=$GOPATH/bin:$PATH


git clone https://github.com/containers/conmon $GOPATH/src/conmon
# shellcheck disable=SC2164
cd $GOPATH/src/conmon
git checkout v2.1.12
# shellcheck disable=SC2155
export GOCACHE="$(mktemp -d)"
make
make podman

git clone https://github.com/containers/netavark.git $PODMAN_BUILD_FOLDER/netavark
# shellcheck disable=SC2164
cd $PODMAN_BUILD_FOLDER/netavark
make PREFIX=$PODMAN_PKG_FOLDER/usr
make install PREFIX=$PODMAN_PKG_FOLDER/usr

git clone https://github.com/opencontainers/runc.git $GOPATH/src/github.com/opencontainers/runc
# shellcheck disable=SC2164
cd $GOPATH/src/github.com/opencontainers/runc
git checkout v1.1.13
make BUILDTAGS="selinux seccomp apparmor systemd"
cp runc $PODMAN_PKG_FOLDER/usr/bin/runc

cp -rf "$HOME/registries.conf"  $PODMAN_PKG_FOLDER/etc/containers/
cp -rf "$HOME/policy.json"  $PODMAN_PKG_FOLDER/etc/containers/

git clone https://github.com/containers/podman/ $PODMAN_BUILD_FOLDER/podman
# shellcheck disable=SC2164
cd $PODMAN_BUILD_FOLDER/podman

make BUILDTAGS="selinux seccomp apparmor systemd" PREFIX=$PODMAN_PKG_FOLDER/usr
make install PREFIX=$PODMAN_PKG_FOLDER/usr

rm -rf $PODMAN_BUILD_FOLDER

echo "build done!"
echo "test: $PODMAN_PKG_FOLDER/usr/bin/podman --version"

exit 0