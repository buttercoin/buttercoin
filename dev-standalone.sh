#!/usr/bin/env bash

if [ "$1" == "stop" ]; then
    kill -s KILL `cat $TMPDIR/buttercoin.dev-standalone.pid`
else
    rm *.testjournal
    coffee bin/dev-standalone &
    pid=$!
    echo $pid > $TMPDIR/buttercoin.dev-standalone.pid 
fi

