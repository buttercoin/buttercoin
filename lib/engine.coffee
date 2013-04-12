
Dequeue = require('deque').Dequeue

DataStore = require('./datastore')

TransactionLog = require('./transactionlog')

module.exports = class Engine
  constructor: ->
    @transaction_log = new TransactionLog()
    @datastore = new DataStore()
    @dequeue = new Dequeue()

  read_log: (cb) =>
    @transaction_log.read(cb)

  receive_message: (message) =>
    # journal + replicate

    @transaction_log.record( JSON.stringify(message) )

    # deserialize (skipping this for now)

    # execute business logic
    @dequeue.push( message )

  process_message: (message) =>
    if message[0] == 'ADD_DEPOSIT'
      @datastore.add_deposit( message[1] )
      if message[1].callback
        setTimeout message[1].callback, 0
    else
      throw Error('Unknown Message Type')

  process_loop: =>
    while not @dequeue.isEmpty()
      @process_message( @dequeue.shift() )
    setTimeout @process_loop, 200
