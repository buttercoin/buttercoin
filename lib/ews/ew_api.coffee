_ = require('underscore')
stump = require('stump')
Q = require('q')

Initiator = require('./ws_initiator')
InitiatorProtocol = require('./i_protocol')
EventEmitter = require('chained-emitter').EventEmitter
BC = require('buttercoin-engine')

module.exports = class EngineWebsocketApi extends EventEmitter
  components = ['query', 'engine', 'auth']
  @default_options:
    engine: { port: 6150 }
    query: { port: 6151 }
    auth: {
      port: 6152
      path: "/authorize"
    }

  constructor: (options={}) ->
    @options = _.extend(EngineWebsocketApi.default_options, options)
    for x in components
      this[x] ||= new InitiatorProtocol({})
      @options[x].protocol = this[x]

    @engine.on 'data', @handle_engine_data
    @event_filters = {}

    stump.stumpify(this, @constructor.name)

  start: =>
    Q.all( @connect_to(@options[x]) for x in components ).then =>
      @info "API READY"
    .fail (error) =>
      @error "COULDN'T CONNECT:", error

  connect_to: (options) =>
    wsconfig = "#{options.scheme || "ws"}://#{options.host || "localhost"}:#{options.port || 80}#{options.path || ''}"
    ws_options =
      wsconfig: wsconfig
      protocol: options.protocol
    @info "CONNECTING TO", ws_options.wsconfig

    wsi = new Initiator( ws_options )
    wsi.connect()

  handle_engine_data: (data) =>
    filter = @event_filters[data?.operation?.kind]
    if filter
      for e in filter(data)
        @emit e.name, e.data
    else
      @emit 'data', data

