API = require('./api')

module.exports = class Buttercoin
  constructor: ->
    API = new API( Engine() )

