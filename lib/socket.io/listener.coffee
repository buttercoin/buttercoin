_ = require('underscore')
io = require('socket.io')
stump = require('stump')
Q = require('q')

module.exports = class MtGoxSocketListener
  @default_options:
    port: 80

  constructor: (@options) ->
    stump.stumpify(this, @constructor.name)
    @options = _.extend(MtGoxSocketListener.default_options, @options)
    @do_not_know_how_to_make_protocol() unless @options.protocol_factory instanceof Function

  listen: =>
    @info 'LISTENING'
    return Q.fcall =>
      @io = io.listen(80)
      @io.sockets.on 'connection', @connection_made

  close: =>
    @io.server.close()
    return Q.when(true)

  connection_made: (socket) =>
    conn = new Connection(

  do_not_know_how_to_make_protocol: (connection) =>
    @error 'DO NOT KNOW HOW TO MAKE PROTOCOL'
    connection.disconnect()

