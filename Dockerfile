ARG UBUNTU_VER="xenial"
FROM sparklyballs/ubuntu-test:${UBUNTU_VER}

# package versions
ARG UNIFI_BRANCH="unifi-5.6"

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
	\
# add mongodb repository
	\
	apt-key adv \
		--keyserver hkp://keyserver.ubuntu.com:80 \
		--recv 0C49F3730359A14518585931BC711F9BA15703C6 \
	&& echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" >> \
		/etc/apt/sources.list.d/mongo.list && \
	\
# install runtime packages
	apt-get update \
	&& apt-get install -y \
	--no-install-recommends \
		binutils \
		jsvc \
		mongodb-org-server \
		openjdk-8-jre-headless \
		wget \
	\
# install unifi
	\
	&& UNIFI_VERSION=$(curl -sX GET http://dl-origin.ubnt.com/unifi/debian/dists/${UNIFI_BRANCH}/ubiquiti/binary-amd64/Packages \
		| grep -A 7 -m 1 'Package: unifi' \
		| awk -F ': ' '/Version/{print $2;exit}' \
		| awk -F '-' '{print $1}') \
	&& curl -o \
	/tmp/unifi.deb -L \
	"http://dl.ubnt.com/unifi/${UNIFI_VERSION}/unifi_sysvinit_all.deb" \
	&& dpkg -i /tmp/unifi.deb \
	\
# cleanup
	\
	&& apt-get clean \
	&& rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

# add local files
COPY root/ /

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8081 8443 8843 8880
