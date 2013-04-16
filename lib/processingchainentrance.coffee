TransactionLog = require './transactionlog'
Q = require 'q'
DataStore = require './datastore/datastore'
Operations = require './operations'

module.exports = class ProcessingChainEntrance
  constructor: () ->
    @tlog = new TransactionLog
    # @replication = new ReplicationThing

  start: =>
    @tlog.start(@forward_message).then =>
      console.log 'INITIALIZED/REPLAYED LOG'

  forward_message: (message) =>
    Q.all( [
      @tlog.record(message)
      # replicate
      # package
    ])
    .then =>
      # all three complete -> put on queue
