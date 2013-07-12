Adaptor = require '../../../lib/api/mtgox/adaptor'
Translator = require '../../../lib/api/translation/mtgox_queries'

test_api_key = "534ae7aea872406cbbae6ba2dd5ec515" # 16-bytes
test_api_secret = "SEKRET-MESSAGE-KEY"

describe 'MtGoxQueriesTranslator', ->
  beforeEach ->
    auth_provider = {}
    auth_provider[test_api_key] = test_api_secret
    @adaptor = new Adaptor(auth_provider)

  it 'should translate create order method from MtGox to ButterCoin'
    # Submit an Order
    # type (bid|ask) (easier to remember: bid == buy, ask == sell)
    # amount_int <amount as int>
    # price_int <price as int> (can be omitted to place market order)

    request_url = '/api/1/BTCUSD/private/order/add'

  it 'should translate cancel order method from MtGox to ButterCoin'
    # Cancel an order
    # oid <the order ID>

    request_url = '/api/1/BTCUSD/private/order/cancel'

    request = {oid: "lkjhadfasdf2341234134"}
    
    # TODO: 

    bc = Translator.CancelOrder.translate_inbound(request, request_url)
        



  it 'should translate sign-in method from MtGox to ButterCoin'
    # no MtGox analog 


  it 'should translate sign-out method from MtGox to ButterCoin'
    # no MtGox analog 


  it 'should translate update user method from MtGox to ButterCoin'
    # no MtGox analog 


  it 'should translate add bank acct method from MtGox to ButterCoin'
    # no MtGox analog 


  it 'should translate remove bank account method from MtGox to ButterCoin'
    # no MtGox analog 


  it 'should translate send bitcoins method from MtGox to ButterCoin'
    # Withdraw bitcoins
    # address <string> required
    # amount_int <amount as int> required
    # fee_int <fee as int> not required
    # no_instant <bool> not required
    # green <bool> not required
    
    request_url = 'api/1/generic/bitcoin/send_simple'
  
  it 'should translate generate wallet address method from MtGox to ButterCoin'
    # NOT IMPLEMENTED
