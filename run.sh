#!/bin/bash
plackup --port 5080 -R $(dirname $0) $(dirname $0)/app.psgi
