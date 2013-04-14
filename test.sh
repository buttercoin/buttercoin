#!/bin/sh

PATH=./node_modules/.bin:$PATH

mocha  --compilers coffee:coffee-script -R spec  test/*
