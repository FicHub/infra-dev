#!/usr/bin/bash
set -e

base="https://athena.fanfic.dev/dat"

export CALIBRE_RELEASE=5.12.0
export BUILD_DATE="$(date +'%Y-%m-%d')"
export VERSION="0.0.1"

for f in calibre-${CALIBRE_RELEASE}-x86_64.txz{,.signature} ; do
	wget -c -q -O "${f}" "${base}/${f}"
done

md5sum -c calibre.md5

if [[ ! -d ./fichub.net/ ]]; then
	git clone -b dev/iris/infra https://github.com/FicHub/fichub.net.git fichub.net
fi
if [[ ! -d ./python-oil/ ]]; then
	git clone https://github.com/FanFicDev/python-oil.git python-oil
fi

cd ./fichub.net/
if ! ./bin/check_setup.sh; then
	exit $?
fi
cd ..

docker build \
	--build-arg "CALIBRE_RELEASE=${CALIBRE_RELEASE}" \
	--build-arg "BUILD_DATE=${BUILD_DATE}" \
	--build-arg "VERSION=${VERSION}" \
	-t fichub/fichub_net:${VERSION} \
	.

