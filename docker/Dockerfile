# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-20.04

ENV LANG='en_US.UTF-8' \
  LANGUAGE='en_US.UTF-8' \
  LC_ALL='en_US.UTF-8' \
  APP_NAME="CircuitSim"

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install -y locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN locale-gen 

# RUN apt-get install -y xserver-xorg-video-dummy
RUN apt-get install -y libgl1-mesa-glx
RUN apt-get install -y openjdk-17-jdk
RUN apt-get install -y openjfx

RUN apt-get install -y wget

RUN wget https://www.roiatalla.com/public/CircuitSim/Linux/CircuitSim1.9.0 -O /CircuitSim

# Copy the start script.
COPY startapp.sh /startapp.sh


# Install xterm.
# RUN add-pkg xterm

# Copy the start script.
COPY startapp.sh /startapp.sh

# # Set the name of the application.
# RUN set-cont-env APP_NAME "CircuitSim"

