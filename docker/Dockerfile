# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.17-v4

# Enable testing repo for openjfx
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

RUN apk update && apk upgrade
RUN apk add openjdk17
RUN apk add openjfx

# Copy the start script and window script.
COPY startapp.sh /startapp.sh
COPY main-window-selection.xml /etc/openbox/main-window-selection.xml

ARG LINK
ARG NAME

# Download CircuitSim.
RUN wget $LINK -O /CircuitSim

# Set the name for the GUI.
RUN set-cont-env APP_NAME $NAME
