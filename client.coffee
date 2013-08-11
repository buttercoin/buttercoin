stump = require('stump')

if process.argv[2] is 'client'
  stump.stumpify(this, "[TEST]Client")
  WebSocket = require('ws')

  id = "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"
  query = new WebSocket("ws://localhost:9001/api/v1/query")
  engine = new WebSocket("ws://localhost:9001/engine")
  engine.on 'open', =>
    #@error "sending"
    ops = ->
      engine.send(JSON.stringify
        operation: "INITIATE_DEPOSIT"
        amount: {currency: "BTC", amount: "1500.00000"})

      engine.send(JSON.stringify
        operation: "INITIATE_DEPOSIT"
        amount: {currency: "USD", amount: "1500.00000"})

      #engine.send(JSON.stringify
        #operation: "CREATE_LIMIT_ORDER"
        #offered: {currency: "BTC", amount: "1"}
        #received: {currency: "USD", amount: "105.12"})

      #engine.send(JSON.stringify
        #operation: "CREATE_LIMIT_ORDER"
        #offered: {currency: "USD", amount: "104.86"}
        #received: {currency: "BTC", amount: "1"})

      #engine.send(JSON.stringify
        #operation: "CREATE_LIMIT_ORDER"
        #offered: {currency: "BTC", amount: "1"}
        #received: {currency: "USD", amount: "105.02"})

      #engine.send(JSON.stringify
        #operation: "CREATE_LIMIT_ORDER"
        #offered: {currency: "BTC", amount: "3"}
        #received: {currency: "USD", amount: "315.06"})

      engine.send(JSON.stringify
        operation: "CREATE_LIMIT_ORDER"
        offered: {currency: "USD", amount: "105.02"}
        received: {currency: "BTC", amount: "1"})

    engine.send(JSON.stringify
      operation: "AUTHENTICATE"
      credentials:
        type: "bearer-token"
        evidence: "Bearer 1a44ab8f7823382aaceb4eff03001637a09fe7431d993e9189121beadf4fd2fefb2f3cac3caab847f91fd4b54aa2399f1d1e72f5438fa8fccebcfdddb3bc2798e108f4787475adce0e62e38bca933e70bbe46a62bca023567fd82751479af5e4dcc9a0dc7dc1c9e3335084b7192c50ca741833abdebf227f3e779feec10efa51b32ffb794a0c0322bb60eb47271f8a43582604fac83291bbbdd83cdff79863e6fd57a76b78f4be98e71a18d1b0b7eb0b28a6db885147fa58551378b3bc55a6cdbb98f158f7d0f83ccf0b1cf7f0882b620c2a50e8688ffc679b003e3d1121873f47633b1674bbb9b21da4ab65e06ebec471896105d50af1abb5a3f623a3de9ff3")

    setTimeout(ops, 1000)

  query.on 'open', =>
    #query.send(JSON.stringify
      #query: "TICKER"
      #currencies: ["BTC", "USD"])

    ##query.send(JSON.stringify
      ##query: "TICKER"
      ##currencies: ["USD", "BTC"])

    query.send(JSON.stringify
      query: "BALANCES"
      account_id: "ddb3fe2b-4363-472a-9700-377a9090b140")

    ##query.send(JSON.stringify
      ##query: "OPEN_ORDERS"
      ##account_id: id)

  engine.on 'message', (message) =>
    @error message
  query.on 'message', (message) =>
    @warn message
  
else
  fork = require('child_process').fork

  fork('./client.coffee', ['client'])

