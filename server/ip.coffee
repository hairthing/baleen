share.getIP = (userId) ->
  ip = undefined
  for key, session of Meteor.default_server.sessions
    if session.userId == userId and session.socket != null
      if session.socket.headers['x-forwarded-for']
        ip = session.socket.headers['x-forwarded-for']
      else if session.socket.remoteAddress
        ip = session.socket.remoteAddress
      break
  ip