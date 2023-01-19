#!/bin/sh
# exec /usr/bin/xterm

export HOME=/config

exec java \
--module-path /usr/lib/openjfx/ \
--add-modules=javafx.base,javafx.controls,javafx.fxml,javafx.graphics,javafx.media,javafx.swing,javafx.web \
-jar \
/CircuitSim
