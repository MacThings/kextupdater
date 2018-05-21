#!/bin/bash

MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

cat script.command |grep ScriptVersion | head -n1 | sed -e "s/.*\=//g" > /tmp/kuversion.tmp
