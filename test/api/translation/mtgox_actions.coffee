Adaptor = require '../../../lib/api/mtgox/adaptor'
Router = require '../../../lib/api/translation/mtgox_queries'

test_api_key = "534ae7aea872406cbbae6ba2dd5ec515" # 16-bytes
test_api_secret = "SEKRET-MESSAGE-KEY"

describe 'MtGoxQueriesTranslator', ->
  aid = undefined

  beforeEach ->
    auth_provider = {}
    auth_provider[test_api_key] = test_api_secret
    @adaptor = new Adaptor(auth_provider)
    aid = "afaflkjlk123123123131"

  # Submit an Order
  # type (bid|ask) (easier to remember: bid == buy, ask == sell)
  # amount_int <amount as int>
  # price_int <price as int> (can be omitted to place market order)
  describe 'create orders', ->
    mtgox_params = undefined
    request = undefined
    translator = undefined
    a_int = undefined
    p_int = undefined

    beforeEach ->
      a_int = 8720121
      p_int = 8840055
      request =
        url: '/api/1/BTCUSD/private/order/add'

      mtgox_params =
        amount_int: a_int
        price_int: p_int

      translator = Router.route(request)
  
    it 'should be able to find a router for an existing route', ->
      expect(translator).to.be.ok
      translator.constructor.name.should.equal "CreateOrderTranslator"

    it 'should translate ask create order method from MtGox to ButterCoin', ->
      mtgox_params['type'] = 'ask'
      bc_request = translator.translate(mtgox_params)

      expect(bc_request).to.be.ok
      bc_request.operation.should.equal 'CREATE_LIMIT_ORDER'
      #bc_request.account.should.equal aid
      bc_request.offered_amount.should.equal a_int
      bc_request.offered_currency.should.equal 'BTC'
      bc_request.received_amount.should.equal p_int
      bc_request.received_currency.should.equal 'USD'

    it.only 'should translate bid create order method from MtGox to ButterCoin', ->
      mtgox_params['type'] = 'bid'
      bc_request = translator.translate(mtgox_params)

      expect(bc_request).to.be.ok
      bc_request.operation.should.equal 'CREATE_LIMIT_ORDER'
      # bc_request.account.should.equal aid
      bc_request.offered_amount.should.equal p_int
      bc_request.offered_currency.should.equal 'USD'
      bc_request.received_amount.should.equal a_int
      bc_request.received_currency.should.equal 'BTC'

  # Cancel an order
  # oid <the order ID>
  #it 'should translate cancel order method from MtGox to ButterCoin', ->
    #oid = "lkjhadfasdf2341234134"
    
    #request_url = '/api/1/BTCUSD/private/order/cancel'
    #mtgox_request =
      #oid: oid
      #account: aid

    #bc_request = Translator.CancelOrder.translate_inbound(request_url, mtgox_request)
    
    #bc_request.operation.should.equal "CANCEL_LIMIT_ORDER"
    #bc_request.account.should.equal aid
    #bc_request.order_id.should.equal oid
    
  ## Withdraw bitcoins
  ## address <string> required
  ## amount_int <amount as int> required
  ## fee_int <fee as int> not required
  ## no_instant <bool> not required
  ## green <bool> not required
  #it 'should translate send bitcoins method from MtGox to ButterCoin', ->
    #address = 'asdaf'
    #a_int = 8720121
    #f_int = 8840055
    #no_instant = off
    #green = on

    #request_url = 'api/1/generic/bitcoin/send_simple'
    #mtgox_request =
      #address: address
      #amount_int: a_int
      #fee_int: f_int
      #no_instant: no_instant
      #green: green
    
    #bc_request = Translator.SendBitCoins.translate_inbound(request_url, mtgox_request)
    
    #bc_request.operation.should.equal "SEND_BITCOINS"
    #bc_request.account.should.equal aid
    #bc_request.address.should.equal address
    #bc_request.amount.should.equal amount_int
  
