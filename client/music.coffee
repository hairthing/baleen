# Meteor.subscribe("songs");
# Songs = new Meteor.Collection("song")
# Meteor.startup ->
# Template.songList.songs = ()->
#   return Songs.find({},{limit:10})# {artist:{$regex: 'Big', $options: 'i'}})
Template.header.events = 
  'click #pause' : (ev)->
    soundManager.pauseAll()
    false
  'click #play' : (ev)->
    player.play()
    false
  'click #progress' : (ev)->
    player.progressClick(ev.layerX)
    false
Template.songList.events = 
  'click tr' : (ev)->
    song = 
      title: ev.currentTarget.getAttribute('data-title')
      artist: ev.currentTarget.getAttribute('data-artist')
    Meteor.call 'getSong', song, (err, url) ->
      song.url = url
      player.create song
      # console.log "return getsong", err, url
      # document.getElementById('player').setAttribute('src', url)
      # document.getElementById('player').play()
      # Session.set('serverSimpleResponse', response);
    false

soundManager.setup
  url: '/swf/'
  flashVersion: 9
  onready: ()->
    # // Ready to use; soundManager.createSound() etc. can now be called.

player = 
  list: []
  current: null
  pause: ()->
    soundManager.pause()
  play: ()->
    @current.play()
  progressClick: (prog)->
    position = @duration() * (prog / $("#progress").width())
    @current.setPosition(position)
  duration: ()->
    duration = if @current.bytesLoaded < @current.bytesTotal then @current.durationEstimate else @current.duration
    return duration
  create: (song)->
    sound = soundManager.createSound
      id: song.SongID
      url: song.url
      autoLoad: true
      autoPlay: true
      onload: ()->
        console.log('The sound '+@id+' loaded!', song)
      whileplaying: ()->
        duration = if @bytesLoaded < @bytesTotal then @durationEstimate else @duration
        width = (@position/duration)*100
        $("#progress-bar").width(width+"%")
      whileloading: ()->
        width = (@bytesLoaded / @bytesTotal)*100
        $("#loaded-bar").width(width+"%")


        # console.log('at pos: '+@position, @)
      volume: 50
    @list.push sound
    @current = sound