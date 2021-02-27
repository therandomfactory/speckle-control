#!/usr/bin/tclsh

source $env(SPECKLE_DIR)/gui-scripts/redisquery.tcl
redisConnect
after 500
updateRedisTelemetry active False
exit

