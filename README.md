# podman-to-ubuntu
build utilities and installation of updated version of podman on ubuntu
                     
created for internal use by Jamil Services

~~~bash
$ cat /etc/lsb-release 
DISTRIB_ID=Ubuntu
DISTRIB_RELEASE=22.04
DISTRIB_CODENAME=jammy
DISTRIB_DESCRIPTION="Ubuntu 22.04.4 LTS"
~~~

podman: https://github.com/containers/podman

install:
~~~bash
curl https://raw.githubusercontent.com/LittleOwle/podman-to-ubuntu/main/scripts/build.sh -sSf | sudo bash
~~~


remove:
~~~bash
curl https://raw.githubusercontent.com/LittleOwle/podman-to-ubuntu/main/scripts/remove.sh -sSf | sudo bash
~~~


export:
~~~bash
export PATH=/opt/podman-build-v5.1.2-amd64/usr/bin:$PATH
~~~
