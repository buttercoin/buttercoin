#
# Local development start script for Buttercoin
#
# This script will start up three seperate node.js services
#

# Buttercoin trading engine
bin/engine &

# Buttercoin API server
bin/api &

# Buttercoin front-end server
bin/front