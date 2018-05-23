#!/bin/bash

MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

sw_vers | grep Build |sed "s/.*\://g" |xargs > /tmp/osversion.tmp

