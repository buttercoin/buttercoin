Q = require 'q'
DataStore = require './datastore/datastore'
Operations = require './operations'

module.exports = class ProcessingChainEntrance
  constructor: (@engine, @tlog, @replication) ->
    # @replication = new ReplicationThing

  start: =>
    Q.all [
      @tlog.start(@forward_message).then =>
        console.log 'INITIALIZED/REPLAYED LOG'
      @replication.start()
    ]

  forward_message: (message) =>
    Q.all( [
      @tlog.record(message)
      # replicate
      @replication.send(message)
    ])
    .then =>
      # all complete -> put on queue
      @businessQueue.push({
        message: message
        uid: undefined
        success: undefined
        error: undefined
      })

