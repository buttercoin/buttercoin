#!/usr/bin/env bash

if [[ ! -e $TMPDIR ]]; then
    TMPDIR=/tmp
fi

PIDFILE=$TMPDIR/buttercoin.dev-standalone.pid

if [[ "$1" == "stop" ]] || [[ -e $PIDFILE ]]; then
    kill -s KILL `cat $PIDFILE`
    rm $PIDFILE
fi

if [[ "$1" == "clean" ]]; then
    rm *.testjournal
fi

if [[ "$1" == "start" ]] || [[ -z "$1" ]]; then
    coffee bin/dev-standalone &
    pid=$!
    echo $pid > $PIDFILE
fi

