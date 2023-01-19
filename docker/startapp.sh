#!/bin/sh

export HOME=/config

exec java --module-path /usr/share/openjfx/lib/ --add-modules=javafx.base,javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.swing,javafx.web -jar /CircuitSim
