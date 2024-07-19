#!/bin/env bash

PODMAN_VERSION=v5.1.2
RUNC_VERSION=v1.1.13
NETAVARK_VERSION=v1.11.0
CONMON_VERSION=v2.1.12
GO_VERSION=1.22.0

PODMAN_BUILD_FOLDER=/opt/podman-source
PODMAN_PKG_FOLDER=/opt/podman-build-${PODMAN_VERSION}-amd64

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

wget https://raw.githubusercontent.com/LittleOwle/podman-to-ubuntu/main/source/etc/containers/policy.json -O $PODMAN_PKG_FOLDER/etc/containers/policy.json
wget https://raw.githubusercontent.com/LittleOwle/podman-to-ubuntu/main/source/etc/containers/registries.conf -O $PODMAN_PKG_FOLDER/etc/containers/registries.conf

## GO v${GO_VERSION}
wget -c https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
tar -C $PODMAN_BUILD_FOLDER -xzf go${GO_VERSION}.linux-amd64.tar.gz
export PATH=$GOPATH/bin:$PATH

## Conmon ${CONMON_VERSION}
git clone https://github.com/containers/conmon $GOPATH/src/conmon
# shellcheck disable=SC2164
cd $GOPATH/src/conmon
git checkout ${CONMON_VERSION}
# shellcheck disable=SC2155
export GOCACHE="$(mktemp -d)"
make
make podman

## Netavark ${NETAVARK_VERSION}
git clone https://github.com/containers/netavark.git $PODMAN_BUILD_FOLDER/netavark
# shellcheck disable=SC2164
cd $PODMAN_BUILD_FOLDER/netavark
git checkout ${NETAVARK_VERSION}
make PREFIX=$PODMAN_PKG_FOLDER/usr
make install PREFIX=$PODMAN_PKG_FOLDER/usr

## RunC ${RUNC_VERSION}
git clone https://github.com/opencontainers/runc.git $GOPATH/src/github.com/opencontainers/runc
# shellcheck disable=SC2164
cd $GOPATH/src/github.com/opencontainers/runc
git checkout ${RUNC_VERSION}
make BUILDTAGS="selinux seccomp apparmor systemd"
cp runc $PODMAN_PKG_FOLDER/usr/bin/runc

## Podman ${PODMAN_VERSION}
git clone https://github.com/containers/podman/ $PODMAN_BUILD_FOLDER/podman
# shellcheck disable=SC2164
cd $PODMAN_BUILD_FOLDER/podman
git checkout ${PODMAN_VERSION}

make BUILDTAGS="selinux seccomp apparmor systemd" PREFIX=$PODMAN_PKG_FOLDER/usr
make install PREFIX=$PODMAN_PKG_FOLDER/usr

# shellcheck disable=SC2164
cd $PODMAN_PKG_FOLDER
rm -rf $PODMAN_BUILD_FOLDER

echo ""
echo "build done!"
echo ""
echo "Podman ${PODMAN_VERSION}"
echo "Netavark ${NETAVARK_VERSION}"
echo "RunC ${RUNC_VERSION}"
echo "Binaries:  /opt/podman-build-v5.1.2-amd64/usr/bin"
echo "Configuration files: $PODMAN_PKG_FOLDER/etc/containers"
echo ""
echo "test: $PODMAN_PKG_FOLDER/usr/bin/podman --version"
echo ""

exit 0
