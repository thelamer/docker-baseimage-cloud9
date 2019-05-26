FROM lsiobase/ubuntu:bionic as builder

ARG DEBIAN_FRONTEND="noninteractive"
ARG NPM_CONFIG_UNSAFE_PERM=true

RUN \
 echo "**** install build packages ****" && \
 apt-get update && \
 apt-get install -y \
	g++ \
	gcc \
	git \
	make \
	python && \
 echo "**** Compile Cloud9 from source ****" && \
 git clone --depth 1 \
	https://github.com/c9/core.git c9sdk && \
 cd c9sdk && \
 mkdir -p /c9bins && \
 HOME=/c9bins scripts/install-sdk.sh && \
 echo "**** Restructure files for copy ****" && \
 mkdir -p \
	/buildout && \
 rm -Rf \
	/c9bins/.c9/tmp && \
 mv \
	/c9bins \
	/buildout/c9bins && \
 mv \
	/c9sdk \
	/buildout/

# runtime stage
FROM lsiobase/ubuntu:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# Env 
ARG DEBIAN_FRONTEND="noninteractive"

# add local files and files from c9base
COPY --from=builder /buildout/ /

RUN \
 echo "**** install base packages ****" && \
 apt-get update && \
 apt-get install -y --no-install-recommends \
	curl \
	git \
	gnupg \
	sudo && \
 echo "**** Cleanup and user perms ****" && \
 usermod -aG sudo \
	abc && \
 apt-get autoclean && \
 rm -rf \
        /var/lib/apt/lists/* \
        /var/tmp/* \
        /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8000
VOLUME /code
