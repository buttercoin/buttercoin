Q = require('q')
WebSocket = require('ws')

module.exports = class EngineClient
  constructor: (url) ->
    @url = url ? 'http://localhost:8080/'
    console.log 'Backend URL set: ', @url

  set_account_info: (name) ->
    if not name
      throw new Error('Need to specify name')
    @account = name
    console.log 'Account name set: ', name

  add_deposit: (currency, amount) ->
    if not @account
      throw new Error('Set account information before executing transaction')

    transaction = {
      kind: 'ADD_DEPOSIT',
      account: @account,
      currency: currency,
      amount: amount
    }

    message = JSON.stringify(transaction)

    deferred = Q.defer()
    ws = new WebSocket(@url)

    ws.onmessage = (message) ->
      console.log 'Received message: ', message.data
      deferred.resolve()
      ws.close()

    ws.onopen = ->
      if ws.readyState is WebSocket.OPEN
        ws.send message
      else
        console.log 'WTF? ', ws

    return deferred.promise
    
