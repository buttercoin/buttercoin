
Dequeue = require('deque').Dequeue

DataStore = require('./datastore')

TransactionLog = require('./transactionlog')

Q = require('q')

module.exports = class Engine
  constructor: ->
    @transaction_log = new TransactionLog()
    @datastore = new DataStore()

  start: =>
    return Q.fcall =>
      return @transaction_log.start()
    .then =>
      console.log 'STARTED ENGINE'

  receive_message: (message) =>
    # journal + replicate

    @transaction_log.record( JSON.stringify(message) )

    # deserialize (skipping this for now)

    # execute business logic
