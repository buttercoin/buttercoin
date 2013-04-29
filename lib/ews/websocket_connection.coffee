WebSocket = require('wsany')
is_node = require('isnode')

Q = require('q')
helpers = require('enkihelpers')
wrap_error = helpers.wrap_error

stump = require('stump')
EventEmitter = require('eemitterport').EventEmitter

globalconncounter = 0

module.exports = class Connection extends EventEmitter
  constructor: (@parent) ->
    @parent.stumpify(@, @_get_obj_desc)

    @conncounter = globalconncounter
    globalconncounter += 1

    @ws = null
    deferred = Q.defer()
    @senddeferred = deferred

  socket_accepted: (@ws) =>
    @prepare_ws()
    @senddeferred.resolve(@ws.send)
    wrap_error(@handle_open, @uncaught_exception)()

  connect: (wsconfig) =>
    @info 'STARTING TO CONNECT'
    @ws = new WebSocket( wsconfig )

    @prepare_ws()

    @once 'open', =>
      @info 'ONCEOPEN'
      @senddeferred.resolve(@ws.send)
      # .done()

    @once 'close', =>
      @info 'ONCECLOSE'
      @senddeferred.reject( "Connection closed" )
      # .done()

  prepare_ws: =>  
    @ws.on 'error', @handle_error
    @ws.on 'open', wrap_error(@handle_open, @uncaught_exception)
    @ws.on 'close', wrap_error(@handle_close, @uncaught_exception)
    @ws.on 'message', wrap_error(@handle_data, @uncaught_exception)

  _get_obj_desc: =>
    return @constructor.name + ' #' + @conncounter

  uncaught_exception: (exc) =>
    @error 'uncaught exception', exc, '\n', exc.stack
    if not is_node
      throw exc

    @disconnect()

  handle_error: (error) =>
    @error 'uncaught error', error, '\n', error.stack
    @disconnect()
    if not is_node
      throw error

  handle_open: =>
    @info 'handle_open'
    @emit('open', @)

  handle_close: =>
    @info 'Connection Closed'
    @emit('close')

  handle_data: (data, flags) =>
    # @info 'handle_data', data
    obj = JSON.parse(data)

    @emit('parsed_data', obj)

  send_obj: (objOrPromise) =>
    @info 'READY TO SEND_OBJ', objOrPromise
    Q.when(objOrPromise)
    .then (obj) =>
      @send_raw JSON.stringify( obj )

  send_raw: (data) =>
    Q.invoke(@senddeferred.promise, "call", @ws, data)
    .fail (error) =>
      @warn 'FAILED TO SEND. SHUTTING DOWN PROTOCOL'
      return Q.reject(error)
      #@disconnect() # we are already closed...

  disconnect: =>
    @info 'CLOSING'
    @ws.close()
