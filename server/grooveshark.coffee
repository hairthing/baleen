# require = Npm.require
Grooveshark = Meteor.require("grooveshark")
# events = require('events')
# Meteor.startup ->

grooveshark = new Grooveshark(share.config.grooveshark.key, share.config.grooveshark.secret)
# grooveshark.events = new events.EventEmitter()

grooveshark.authenticate share.config.grooveshark.user, share.config.grooveshark.pass, (err) ->
  throw err if err
  # grooveshark.events.emit('ready')
  # @authenticated = true

grooveshark.getCountry = (ip, next)->
  params = {}
  params.ip = ip  if ip
  grooveshark.request "getCountry", params, (err, status, country) ->
    return next(err) if err
    next(null, country)

grooveshark.getStreamKey = (songID, country, next)-> # get a stream key for a single song for a single browser play
  grooveshark.request "getStreamKeyStreamServer",
    songID: songID
    country: country
  , (err, status, body) ->
    return next(err) if err
    grooveshark.streamServerID = body.StreamServerID
    next(null, body)

grooveshark.markStreamKeyOver30Secs = (streamKey, next)->
  grooveshark.request "markStreamKeyOver30Secs",
    streamKey: streamKey
    streamServerID: grooveshark.streamServerID
  , (err, status, body) ->
    return next(err) if err
    next(null, body)

grooveshark.markSongComplete = (songID, streamKey, next)->
  grooveshark.request "markSongComplete",
    songID: songID
    streamKey: streamKey
    streamServerID: grooveshark.streamServerID
  , (err, status, body) ->
    return next(err) if err
    next(null, body)

grooveshark.findSong = (query, country, next)->
  grooveshark.request "getSongSearchResults",
    query: query
    country: country
    limit: 1
    offset: 0
  , (err, status, body) ->
    return next(err) if err
    song = if body.songs?[0] then body.songs[0] else false
    next(null, song)

grooveshark.doesSongExist = (songID, next)->
  grooveshark.request "getDoesSongExist",
    songID: songID
  , (err, status, doesExist) ->
    return next(err) if err
    next(null, doesExist)

grooveshark.getUrlFromSongName = (song, ip, next)-> # song: {id, title, artist}
  grooveshark.getCountry ip, (err, country)->
    grooveshark.findSong "#{song.artist} #{song.title}", country, (err, song2)->
      # console.log "findSong ERR", err, song2
      grooveshark.getStreamKey song2.SongID, country, (err, streamKey)->
        next(null, streamKey.url)

grooveshark.getUrlFromSong = (song, ip, next)-> # song: {id, title, artist}
  if song.id
    grooveshark.getCountry ip, (err, country)->
      grooveshark.doesSongExist song.id, (err, doesExist)->
        if doesExist
          grooveshark.getStreamKey song.id, country, (err, streamKey)->
            next(streamKey.url)
        else
          grooveshark.getUrlFromSongName song, ip, (err, url)->
            next null, url
  else
    grooveshark.getUrlFromSongName song, ip, (err, url)->
      next null, url

Meteor.methods
  getSong: (song)->
    ip = share.getIP(Meteor.userId())
    Future = Meteor.require('fibers/future')
    future = new Future()
    grooveshark.getUrlFromSong song, ip, (err, url)->
      future.return url

    return future.wait()

    # console.log('on server, getSong called',song)
    # return new Date()




# share.grooveshark = grooveshark