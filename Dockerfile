FROM ubuntu:20.04

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
		libxi-dev libxrandr-dev libxcomposite1 libxcomposite-dev libnss3-dev \
		xdg-utils curl jq wget xz-utils git \
		python3 python3-dev python3-pip python3-virtualenv python3-xdg \
		build-essential node-typescript node-typescript-types sassc rsync \
		nginx uwsgi-core uwsgi-plugin-python3 \
		libpq-dev

COPY calibre-${CALIBRE_RELEASE}-x86_64.txz /tmp/calibre-tarball.txz

RUN echo "=== install calibre ===" && \
	mkdir -p /opt/calibre && \
	tar xvf /tmp/calibre-tarball.txz -C /opt/calibre && \
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

RUN useradd -ms /bin/bash fichub_net

# add dev local version of fichub.net
COPY python-oil /opt/python-oil
COPY --chown=fichub_net fichub.net /home/fichub_net/fichub.net
RUN mkdir /var/www/fichub.net /var/www/b.fichub.net && \
	chown fichub_net:fichub_net /var/www/fichub.net && \
	chown fichub_net:fichub_net /var/www/b.fichub.net

USER fichub_net

RUN echo "=== fichub.net setup ===" && \
	ln -s /opt/python-oil/src /home/fichub_net/fichub.net/oil && \
	cd /home/fichub_net/fichub.net/ && \
	virtualenv venv && \
	./venv/bin/pip install -r requirements.txt && \
	make beta && make prod

ENV FLASK_APP=main.py
ENV FLASK_ENV=development

ENV OIL_DB_HOST=db
ENV OIL_DB_DBNAME=fichub
ENV OIL_DB_USER=fichub
ENV OIL_DB_PASSWORD=pgpass

CMD cd /home/fichub_net/fichub.net && \
	sleep 10s && \
	./venv/bin/flask run --host 0.0.0.0

