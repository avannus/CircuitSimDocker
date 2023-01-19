# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.17-v4

# Enable testing, update and upgrade current packages, install openjdk17 and openjfx.
RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk upgrade
RUN apk add openjdk17
RUN apk add openjfx

# Download CircuitSim.
RUN wget https://www.roiatalla.com/public/CircuitSim/Linux/CircuitSim1.9.0 -O /CircuitSim

# Copy the start script and window script.
COPY startapp.sh /startapp.sh
COPY main-window-selection.xml /etc/openbox/main-window-selection.xml

# Set the name of the application.
RUN set-cont-env APP_NAME "CircuitSim"

