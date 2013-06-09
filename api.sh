#!/usr/bin/env bash

if [[ ! -e $TMPDIR ]]; then
    TMPDIR=/tmp
fi

PIDFILE=$TMPDIR/buttercoin.api-server.pid

if [[ "$1" == "stop" ]] || [[ -e $PIDFILE ]]; then
    kill -s KILL `cat $PIDFILE`
    rm $PIDFILE
fi

if [[ "$1" == "start" ]] || [[ -z "$1" ]]; then
    if [[ -z "$BUTTERCOIN_CONFIG_FILE" ]]; then
        if [[ -z "$2" ]]; then
	    BUTTERCOIN_CONFIG_FILE="`pwd`/config/api.json"
    	else
	    BUTTERCOIN_CONFIG_FILE="$2"
    	fi
    fi

    coffee bin/api --config "$BUTTERCOIN_CONFIG_FILE" &
    pid=$!
    echo $pid > $PIDFILE
fi

