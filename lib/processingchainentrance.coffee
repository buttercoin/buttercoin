Q = require 'q'
DataStore = require './datastore/datastore'
Operations = require './operations'

module.exports = class ProcessingChainEntrance
  constructor: (@engine, @tlog, @replication) ->

  start: =>
    Q.all [
      @tlog.start(@forward_message).then =>
        console.log 'INITIALIZED/REPLAYED LOG'
      @replication.start()
    ]

  forward_message: (message) =>
    Q.all([
      @tlog.record(JSON.stringify(message))
      @replication.send(message)
    ]).then =>
        @engine.execute_operation({
          message: message
          uid: undefined
          success: undefined
          error: undefined
        })

