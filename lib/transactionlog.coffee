Q = require('q')
QFS = require("q-io/fs")
fs = require("fs")
jspack = require('jspack').jspack

module.exports = class TransactionLog
  constructor: (@filename = 'transaction.log') ->

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
    Q.nfcall(fs.open, @filename, "a").then (writefd, err) =>
      console.log 'GOT FD', writefd
      if (err)
        console.log 'File open error: ', err
      @writefd = writefd

  replay_log: =>
    # XXX: This code is basically guaranteed to have chunking problems right now.
    # Fix and then test rigorously!!!

    deferred = Q.defer()

    Q.fcall =>
      @readstream = fs.createReadStream(@filename, {flags: "r"})

      console.log 'GOT READSTREAM'

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

          deferred.notify(message)

          @readstream.unshift(rest)
        else
          @readstream.unshift(data)

    .fail (err) =>
      console.log 'Error reading transaction log: ', err
      deferred.reject(err)
    .done()

    return deferred.promise

  record: (message) =>
    if not @writefd
      console.log 'ERROR: transaction log not initialized.  Did not record
                   message ', message
      return
    record = JSON.stringify(message)
    console.log 'RECORDING', record
    l = record.length

    part = jspack.Pack('I', [l])

    buf = Buffer.concat [ Buffer(part), Buffer(record) ]

    writeq = Q.nfcall(fs.write, @writefd, buf, 0, buf.length, null)
    console.log 'DONE WRITING', writeq, buf
    return writeq

  flush: =>
    Q.nfcall(fs.fsync, @writefd).then =>
      console.log 'FLUSHED'

  shutdown: =>
    fs.closeSync(@writefd)
    @writefd = null
