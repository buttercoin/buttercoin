module.exports = (account, callback) ->
  if(account.id is "Marak" and account.password is "foo")
    callback null, true
  else
    callback null, false
