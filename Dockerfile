#
# Pushpin Dockerfile
#
# https://github.com/fanout/docker-pushpin
# This folder configuration is maintained by bharath <bharath.vadithya@gmail.com>

# Pull the base image
FROM ubuntu:18.04
MAINTAINER Justin Karneges <justin@fanout.io>

# Add private APT repository
RUN \
  apt-get update && \
  apt-get install -y apt-transport-https software-properties-common && \
  echo deb https://fanout.jfrog.io/artifactory/debian fanout-bionic main \
    | tee /etc/apt/sources.list.d/fanout.list && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys \
    EA01C1E777F95324

ENV PUSHPIN_VERSION 1.32.2-1~bionic1

# Install Pushpin
RUN \
  apt-get update && \
  apt-get install -y pushpin=$PUSHPIN_VERSION

# Cleanup
RUN \
  apt-get clean && \
  rm -fr /var/lib/apt/lists/* && \
  rm -fr /tmp/*

# Add entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
# replace pushpin config files with bharath's configuration files
COPY pushpin/ /etc/

# Define default entrypoint and command
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pushpin", "--merge-output"]

# Expose ports.
# - 7999: HTTP port to forward on to the app
# - 5560: ZMQ PULL for receiving messages
# - 5561: HTTP port for receiving messages and commands
# - 5562: ZMQ SUB for receiving messages
# - 5563: ZMQ REP for receiving commands
EXPOSE 7999
EXPOSE 5560
EXPOSE 5561
EXPOSE 5562
EXPOSE 5563
