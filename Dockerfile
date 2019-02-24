ARG UBUNTU_VER="xenial"
FROM sparklyballs/ubuntu-test:${UBUNTU_VER}

# package versions
ARG UBUNTU_VER

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# fetch version file
RUN \
	set -ex \
	&& curl -o \
	/tmp/version.txt -L \
	"https://raw.githubusercontent.com/sparklyballs/versioning/master/version.txt"

# fetch source code
# hadolint ignore=SC1091
RUN \
	. /tmp/version.txt \
	&& set -ex \
	&& curl -o \
	/tmp/unifi.deb -L \
	"http://dl.ubnt.com/unifi/${UNIFI_RELEASE}/unifi_sysvinit_all.deb" \
	\
# add mongodb repository
	\
	&& apt-key adv \
		--keyserver hkp://keyserver.ubuntu.com:80 \
		--recv 0C49F3730359A14518585931BC711F9BA15703C6 \
	&& echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu $UBUNTU_VER/mongodb-org/3.4 multiverse" >> \
		/etc/apt/sources.list.d/mongo.list && \
	\
# install runtime packages
	\
	apt-get update \
	&& apt-get install -y \
	--no-install-recommends \
		binutils \
		jsvc \
		mongodb-org-server \
		openjdk-8-jre-headless \
		wget \
	\
# install unifi
	\
	&& dpkg -i /tmp/unifi.deb \
	\
# cleanup
	\
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# add local files
COPY root/ /

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8081 8443 8843 8880
