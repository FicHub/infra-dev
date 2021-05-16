FROM ubuntu:20.04

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CALIBRE_RELEASE
LABEL build_version="version:- ${VERSION} build-date:- ${BUILD_DATE}"
LABEL maintainer="iris"

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

ENV APPNAME="fichub_net" UMASK_SET="022"

RUN \
	echo "=== initial setup ===" && \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg2

COPY GPG-KEY-elasticsearch /tmp/GPG-KEY-elasticsearch
RUN \
	apt-key add /tmp/GPG-KEY-elasticsearch && \
	echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" >> /etc/apt/sources.list.d/elastic-7.x.list

RUN \
	apt-get update && \
	apt-get install -y --no-install-recommends \
		dbus \
		fcitx-rime \
		fonts-wqy-microhei \
		ttf-wqy-zenhei \
		libqpdf26 \
		libxkbcommon-x11-0 \
		libxcb-icccm4 \
		libxcb-image0 \
		libxcb-keysyms1 \
		libxcb-randr0 \
		libxcb-render-util0 \
		libxcb-xinerama0 \
		libxi-dev libxrandr-dev libxcomposite1 libxcomposite-dev \
		curl jq wget xz-utils \
		python3 python3-dev python3-pip python3-virtualenv build-essential \
		python3-xdg python3-flask python3-lxml python3-dateutil \
		nginx uwsgi-core uwsgi-plugin-python3 \
		postgresql postgresql-contrib python3-psycopg2 \
		apache2-utils \
		elasticsearch

COPY calibre-${CALIBRE_RELEASE}-x86_64.txz /tmp/calibre-tarball.txz

RUN echo "=== install calibre ===" && \
	mkdir -p \
		/opt/calibre && \
	tar xvf /tmp/calibre-tarball.txz -C \
		/opt/calibre && \
		/opt/calibre/calibre_postinstall

RUN echo "=== dev tools ===" && \
	apt-get install -y --no-install-recommends \
		vim tmux # for poking around

RUN echo "=== finalize ===" && \
	dbus-uuidgen > /etc/machine-id && \
	apt-get clean && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*


# add local files
#COPY fichub.net/ /
CMD /usr/bin/bash
#ENTRYPOINT /bin/bash

