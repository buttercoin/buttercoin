#!/bin/sh
# please do not assume everyone installs npm packages globally
PATH=node_modules/.bin:$PATH

cake test
