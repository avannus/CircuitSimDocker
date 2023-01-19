# Pull base image.
FROM jlesage/baseimage-gui:ubuntu-20.04-v4

RUN apt-get update -y
RUN apt-get upgrade -y

RUN apt-get install -y openjdk-17-jdk\
  && apt-get install -y openjfx

RUN apt-get install -y wget
RUN wget https://www.roiatalla.com/public/CircuitSim/Linux/CircuitSim1.9.0 -O /CircuitSim

RUN apt-get update -y\
  && apt-get upgrade -y\
  && apt-get clean -y

# Copy the start script.
COPY startapp.sh /startapp.sh
COPY main-window-selection.xml /etc/openbox/main-window-selection.xml

# # Set the name of the application.
RUN set-cont-env APP_NAME "CircuitSim"

