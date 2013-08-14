stump = require('stump')

if process.argv[2] is 'client'
  stump.stumpify(this, "[TEST]Client")
  WebSocket = require('ws')

  id = "f81d4fae-7dec-11d0-a765-00a0c91e6bf6"
  engine = new WebSocket("ws://localhost:8080/api/v1/websocket")
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

      #engine.send(JSON.stringify
        #operation: "CREATE_LIMIT_ORDER"
        #offered: {currency: "USD", amount: "105.02"}
        #received: {currency: "BTC", amount: "1"})

      #query.send(JSON.stringify
        #query: "TICKER"
        #currencies: ["BTC", "USD"])

      ##query.send(JSON.stringify
        ##query: "TICKER"
        ##currencies: ["USD", "BTC"])

      engine.send(JSON.stringify
        query: "BALANCES")

      engine.send(JSON.stringify
        operation: "VERIFY_ACCOUNT"
        first_name: "Ben"
        middle_name: null
        last_name: "Hoffman"
        date_of_birth: "1983-10-23"
        birth_country: "USA"
        address:
          line1: "Foo"
          line2: null
          city: "Bar"
          region: "CA"
          zip_code: "12345"
          country: "USA")

      engine.send(JSON.stringify
        operation: "ADD_BANK_ACCOUNT"
        full_name: "Ben Hoffman"
        routing_number: "42"
        account_number: "42"
        type: "CheckingAccount")

      ##query.send(JSON.stringify
        ##query: "OPEN_ORDERS"
        ##account_id: id)

    engine.send(JSON.stringify
      operation: "AUTHENTICATE"
      credentials:
        type: "bearer-token"
        evidence: "Bearer 6555cae5f8e6052be5d946753af3cc30823c2709f025fe96bf9a5c5e1e5691b4055f861a193eec98f5f56ba18945f7db7fca78af744a4497ac8c0e4bfa1fbcbcdccdd0a80949298dde68e2c3208b8780e21f6367661b2cd305b95dbc502ce922bf6545797b941f5b9c3535d1529cf2175f925137fc7df3f28b8f26e2f5f1071660ca0bc98e70a6adb62210b64bf1a56e1d68db61556a5addc0527993ec9e0880cd7abd36ecac9def7503962ce9ffc6ed59949e4fc4e559331a84f88ba5ae37594258191c4d24a7e6c32fc7a0c9fd1e49ff1449705ea9e724777cfaaf1cf679e304aa8767baf62ce813dc926785192055b523213795a7de2aaed7fd7e04473279")

    setTimeout(ops, 1000)

  engine.on 'message', (message) =>
    @error message
else
  fork = require('child_process').fork

  fork('./client.coffee', ['client'])

