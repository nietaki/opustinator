FROM debian:latest

RUN mkdir -p /usr/local/app

RUN apt-get update && \
    apt-get install -y --no-install-recommends opus-tools

ENV PUID=1001
ENV PGID=100

# Set the application directory

USER root

RUN apt-get update && apt-get install -y --no-install-recommends bash opus-tools \
&& groupadd -f -g "$PGID" abc \
&& useradd -l -u "$PUID" -g "$PGID" -d "/usr/local/app" -s /bin/bash -r -m abc \
&& chown -R abc:abc "/usr/local/app" \
&& chmod -R 755 "/usr/local/app" 

USER abc

WORKDIR /usr/local/app

# copy the execution script
COPY --chown=abc:abc ./convert_all.sh /usr/local/app/convert_all.sh
RUN chmod +x /usr/local/app/convert_all.sh

# input volume
VOLUME /input
# output volume
VOLUME /output
# # config volume
# VOLUME /config

# ENTRYPOINT "/bin/bash"
ENTRYPOINT "/usr/local/app/convert_all.sh"
