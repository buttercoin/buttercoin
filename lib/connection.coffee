Q = require('q')
helpers = require('enkihelpers')
wrap_error = helpers.wrap_error

stump = require('stump')
EventEmitter = require('chained-emitter').EventEmitter

module.exports = class Connection extends EventEmitter
  @conncounter = 0
  constructor: (@parent) ->
    @conncounter = Connection.conncounter
    @parent.stumpify(this, "#{@constructor.name} ##{@conncounter}")
    Connection.conncounter += 1

    @senddeferred = Q.defer()

  handle_accept: (@transport) =>
    send_callback = @prepare_transport()
    @senddeferred.resolve(send_callback)
    wrap_error(@handle_open, @uncaught_exception)()

  connect: (config) =>
    @info 'CREATING CONNECTION:', config
    @transport = @create_transport(config)
    send_callback = @prepare_transport()

    @once 'open', (connection) =>
      @info 'ONCEOPEN'
      @senddeferred.resolve(send_callback)

    @once 'close', =>
      @info 'ONCECLOSE'
      @senddeferred.reject( "Connection closed" )

  send_obj: (objOrPromise) =>
    Q.when(objOrPromise)
    .then (obj) =>
      @send_raw JSON.stringify( obj )

  send_raw: (data) =>
    Q.invoke(@senddeferred.promise, "call", @transport, data)
    .fail (error) =>
      @warn 'FAILED TO SEND. SHUTTING DOWN PROTOCOL'
      return Q.reject(error)
      #@disconnect() # we are already closed...

  uncaught_exception: (exc) => throw exc

  handle_error: (error) =>
    @error error
    throw error

  handle_open: =>
    @info 'handle_open'
    @emit('open', @, )

  handle_close: =>
    @info 'Connection Closed'
    @emit('close')

  handle_data: (data, flags) =>
    obj = @parse_data(data)
    @emit('parsed_data', obj)

  disconnect: =>
    @info 'CLOSING'
    deferred = Q.defer()
    @shutdown_transport(deferred.resolve)
    return deferred.promise
