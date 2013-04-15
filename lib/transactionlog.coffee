Q = require('q')
QFS = require("q-io/fs")
fs = require("fs")
jspack = require('jspack').jspack

module.exports = class TransactionLog
  constructor: (@engine) ->
    @filename = 'transaction.log'

  start: =>
    return QFS.exists(@filename).then (retval) =>
      if retval
        console.log 'LOG EXISTS'
        Q.fcall =>
          @replay_log().then =>
            # This is dangerous
            @initialize_log()
      else
        console.log 'LOG DOES NOT EXIST'
        Q.fcall =>
          @initialize_log().then =>
            return null

  initialize_log: =>
    console.log 'INITIALIZING LOG'
    Q.nfcall(fs.open, @filename, "w").then (writefd) =>
      console.log 'GOT FD', writefd
      @writefd = writefd

  replay_log: =>
    # XXX: This code is basically guaranteed to have chunking problems right now.
    # Fix and then test rigorously!!!

    @readstream = fs.createReadStream(@filename, {flags: "r"})

    console.log 'GOT READSTREAM'

    deferred = Q.defer()

    Q.fcall =>
      parts = []
      @readstream.on 'end', =>
        console.log 'done reading'
        # Had to comment out this line since it was causing errors
        # @readstream.close()
        deferred.resolve()

      @readstream.on 'readable', =>
        data = @readstream.read()
        console.log 'READ', data, data.isEncoding
        lenprefix = jspack.Unpack('I', (c.charCodeAt(0) for c in data.slice(0,4).toString('binary').split('')), 0 )[0]

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
          message = JSON.parse(chunk.toString())
          console.log 'message', message
          @engine.replay_message(message)
          @readstream.unshift(rest)
        else
          @readstream.unshift(data)

    .fail =>
      console.log 'ERROR'
    .done()

    return deferred.promise

  record: (message) =>
    console.log 'RECORDING', message
    l = message.length

    part = jspack.Pack('I', [l])

    buf = Buffer.concat [ Buffer(part), Buffer(message) ]

    writeq = Q.nfcall(fs.write, @writefd, buf, 0, buf.length, null)
    console.log 'DONE WRITING', writeq, buf
    return writeq

  flush: =>
    Q.nfcall(fs.fsync, @writefd).then =>
      console.log 'FLUSHED'
