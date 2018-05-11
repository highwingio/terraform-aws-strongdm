#!/usr/bin/env bash

sdm status >/dev/null;
sdm relay create > /tmp/key
SDM_RELAY_TOKEN=$(cat /tmp/key)
export SDM_RELAY_TOKEN
sdm relay
#echo $SDM_RELAY_TOKEN
