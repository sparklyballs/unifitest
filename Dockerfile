ARG ALPINE_VER="3.9"
FROM alpine:${ALPINE_VER} as fetch-stage

############## fetch stage ##############

# package versions
ARG UNIFI_BRANCH="unifi-5.6"

# install fetch packages
RUN \
	set -ex \
	&& apk add --no-cache \
		bash \
		curl \
		unzip

# set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# set workdir
WORKDIR /tmp/unifi-src

# fetch source code
RUN \
	set -ex \
	&& UNIFI_VERSION=$(curl -sX GET http://dl-origin.ubnt.com/unifi/debian/dists/${UNIFI_BRANCH}/ubiquiti/binary-amd64/Packages \
		| grep -A 7 -m 1 'Package: unifi' \
		| awk -F ': ' '/Version/{print $2;exit}' \
		| awk -F '-' '{print $1}') \
	&& curl -o \
	unifi.zip -L \
	"http://www.ubnt.com/downloads/unifi/${UNIFI_VERSION}/UniFi.unix.zip"

# unpack source code
RUN \
	set -ex \
	&& unzip -q unifi.zip \
	&& mv UniFi unifi \
	&& rm unifi/bin/mongod

FROM sparklyballs/alpine-test:${ALPINE_VER}

############## runtime stage ##############

FROM sparklyballs/alpine-test:${ALPINE_VER}

############## runtime stage ##############

# copy artifacts fetch stage
COPY --from=fetch-stage /tmp/unifi-src/unifi/ /usr/lib/unifi/

# add script for mongo
COPY mongod /usr/lib/unifi/bin/mongod

# install runtime packages
RUN \
	set -ex \
	&& apk add --no-cache \
	java-snappy \
	mongodb \
	openjdk8-jre-base \
	\
# make mongo script executable
	\
	&& chmod +x /usr/lib/unifi/bin/mongod

# add local files
COPY root/ /

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8081 8443 8843 8880
