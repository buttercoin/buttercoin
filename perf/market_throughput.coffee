hd = require('heapdump')
Market = require('../lib/datastore/market')
Order = require ('../lib/datastore/order')
DQ = require('deque')

randomInt = (lower, upper) ->
  Math.floor(Math.random() * (upper - lower + 1)) + lower

randomBool = -> randomInt(0, 1)

acctID = 1

makeRandomOrder = ->
  currencies = ['BTC', 'USD']
  currencies = currencies.reverse() if randomBool()
  new Order({name: "user-#{acctID++}"}, currencies[0], randomInt(1, 5000), currencies[1], randomInt(1, 5000))

makeMatchingOrder = (n) ->
  currencies = if (n % 5) then ['BTC', 'USD'] else ['USD', 'BTC']
  amt = if (n % 5) then 0.25 else 1
  new Order({name: "user-#{acctID++}"}, currencies[0], amt, currencies[1], amt)

mixAndMatch = (n) ->
  if (n % 10) >= 5
    makeRandomOrder()
  else
    makeMatchingOrder(n)

market = new Market('BTC', 'USD')

count = 1000000
block_size = 10000
iterations = Math.floor(count/block_size)

console.log "Generating #{block_size} random orders..."
#orders = (makeRandomOrder() for _ in [1..block_size])
orders = (makeMatchingOrder(n) for n in [1..block_size])
#orders = (mixAndMatch(n) for n in [1..block_size])

rl = require('readline').createInterface(process.stdin, process.stdout)
rl.setPrompt('', 0)
rl.clearLine = ->
  if process.platform is 'darwin'
    @output.write("\u001B[2K\r")
  else
    @write(null, {ctrl: true, name: 'u'})

rl.up = (n=1) ->
  @output.write("\u001B[#{n}A")

rl.down = (n=1) ->
  @output.write("\u001B[#{n}B")

rl.clearScreen = ->
  @output.write("\u001B[2J")
  @output.write("\u001B[H")

rl.on 'SIGINT', -> process.exit(1)

output_events = 0
startTime = process.hrtime()

[1..iterations].forEach (iterN) ->
  generation = iterN * block_size
  orders.forEach (x, blockIdx) ->
    idx = generation + blockIdx
    output_events += market.add_order(x).length
    if (idx % block_size) == 0
      elapsedTime = process.hrtime(startTime)
      elapsedTime = elapsedTime[0]*1000 + elapsedTime[1] / 1000000

      rl.clearScreen()
      rl.write("#{(elapsedTime/1000).toFixed(1)} seconds (#{(idx/count*100).toFixed(2)}%)")
      rl.down()
      rl.clearLine()
      rl.write("--> #{(idx/elapsedTime*1000).toFixed(0)} tx/sec")
      rl.down()
      rl.clearLine()
      rl.write("--> #{(output_events/elapsedTime*1000).toFixed(0)} events/sec")
      rl.resume()

elapsedTime = process.hrtime(startTime)
elapsedTime = elapsedTime[0]*1000 + elapsedTime[1] / 1000000

rl.clearScreen()
rl.resume()
rl.close()

console.log "#{count} transactions in #{elapsedTime.toFixed(3)} ms"
console.log "\t#{(count/elapsedTime*1000).toFixed(0)} tx/sec"
console.log "performed #{output_events} output events"
console.log "\t#{(output_events/elapsedTime*1000).toFixed(0)} events/sec"

