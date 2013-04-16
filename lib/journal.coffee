Q = require('q')
QFS = require("q-io/fs")
fs = require("fs")
jspack = require('jspack').jspack
logger = require('../lib/logger')

# Journal: You start it, it either reads the journal, or creates a new one.
# You pass it a function execute_operation, which receives replayed operations.
# It returns a promise that's ready when the journal has replayed everything and can .record()

module.exports = class Journal
  constructor: (@filename) ->
    @filename = @filename or 'journal.log'
    @readstream = null
    @writefd = null

  start: (execute_operation) =>
    return QFS.exists(@filename).then (retval) =>
      if retval
        console.log 'LOG EXISTS'
        Q.fcall =>
          @replay_log(execute_operation).then =>
            console.log 'DONE REPLAYING'
            # This is dangerous
            @initialize_log("a")
      else
        console.log 'LOG DOES NOT EXIST'
        Q.fcall =>
          @initialize_log().then =>
            return null

  shutdown: =>
    logger.info 'SHUTTING DOWN JOURNAL'

    promise = Q.when(null)
    if @writefd != null
      promise = Q.nfcall(fs.fsync, @writefd).then =>
        Q.nfcall(fs.close, @writefd).then =>
          @writefd = null
    return promise

  initialize_log: (flags) =>
    if not flags
      flags = "w"
    console.log 'INITIALIZING LOG'
    Q.nfcall(fs.open, @filename, flags).then (writefd) =>
      console.log 'GOT FD', writefd
      @writefd = writefd

  replay_log: (execute_operation) =>
    # XXX: This code is basically guaranteed to have chunking problems right now.
    # Fix and then test rigorously!!!

    @readstream = fs.createReadStream(@filename, {flags: "r"})

    console.log 'GOT READSTREAM'

    deferred = Q.defer()

    parts = []
    console.log 'REGISTERING HANDLERS'
    @readstream.on 'end', =>
      console.log 'done reading'

    @readstream.on 'error', (error) =>
      logger.error('Error on readstream', error)

    @readstream.on 'close', (close) =>
      logger.info 'closed readstream'
      deferred.resolve()

    @readstream.on 'readable', =>
      console.log 'READABLE EVENT'
      data = @readstream.read()
      console.log 'READ', data, data.isEncoding

      lenbin = data.slice(0,4)
      if lenbin.length != 4
        throw Error("Didn't read 4 bytes for length prefix")
      
      lenprefix = jspack.Unpack('I', (c.charCodeAt(0) for c in lenbin.toString('binary').split('')), 0 )[0]

      console.log 'lenprefix', lenprefix

      chunk = data.slice(4, 4 + lenprefix)

      if data.length > 4 + lenprefix
        rest = data.slice(4 + lenprefix)
      else
        rest = ''

      console.log 'LENS', data.length, chunk.length, rest.length
      console.log 'CHUNK', chunk.toString()

      console.log 'rest', rest


      if chunk.length == lenprefix
        operation = JSON.parse(chunk.toString())
        console.log 'operation', operation
        execute_operation(operation)
        @readstream.unshift(rest)
      else
        @readstream.unshift(data)
    console.log 'registered handlers'

    return deferred.promise

  record: (message) =>
    console.log 'RECORDING', message
    if @writefd == null
      console.log 'NO WRITEFD AVAILABLE'
      return Q.when(null)

    # message = JSON.stringify(operation)

    l = message.length

    part = jspack.Pack('I', [l])

    buf = Buffer.concat [ Buffer(part), Buffer(message) ]

    writeq = Q.nfcall(fs.write, @writefd, buf, 0, buf.length, null)
    console.log 'DONE WRITING', writeq, buf
    return writeq

  flush: =>
    Q.nfcall(fs.fsync, @writefd).then =>
      console.log 'FLUSHED'
