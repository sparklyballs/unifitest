ARG ALPINE_VER="3.9"
FROM alpine:${ALPINE_VER} as fetch_stage

############## fetch stage ##############

# install fetch packages
RUN \
	apk add --no-cache \
		bash \
		curl \
		unzip

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
	&& mkdir -p \
		/tmp/unifi \
	&& curl -o \
	/tmp/unifi.zip -L \
	"https://dl.ubnt.com/unifi/5.6.40/UniFi.unix.zip" \
	&& unzip -qq /tmp/unifi.zip -d /tmp/unifi \
	&& mv /tmp/unifi/* /usr/lib/unifi

FROM sparklyballs/alpine-test:${ALPINE_VER}

############## runtime stage ##############

# copy artifacts fetch stage
COPY --from=fetch_stage /usr/lib/unifi /usr/lib/unifi

# install runtime packages
RUN \
	apk add --no-cache \
		mongodb \
		openjdk8-jre \
	\
# move mongod bin file to fix mongo 4.x unifi bug
	\
	&& mv /usr/bin/mongod /usr/bin/mongod.bin

# add local files
COPY mongod /usr/bin/mongod
COPY root/ /

# ports and volumes
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8081 8443 8843 8880
