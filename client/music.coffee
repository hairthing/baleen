Meteor.subscribe("allsongs")
Meteor.subscribe("usersongs")
Songs = new Meteor.Collection("song")
# Users = new Meteor.Collection("users")
console.log Meteor.users.find({},{limit:50})
Template.songs.songs = ()->
  return Songs.find({},{limit:50})# {artist:{$regex: 'Big', $options: 'i'}})
Template.songs.users = ()->
  return Meteor.users.find({},{limit:50,transform: (user)->
    user.sngs = Songs.find({user:user.services?.facebook?.email},{limit:5})
    # console.log "user.songs", user.sngs

    return user
  })# {artist:{$regex: 'Big', $options: 'i'}})
Template.songs.events = 
  'click #pause' : (ev)->
    soundManager.pauseAll()
    false
  'click #play' : (ev)->
    player.play()
    false
  'click #progress' : (ev)->
    player.progressClick(ev.layerX)
    false
  # Template.songs.events = 
  'click a.play-song' : (ev)->
    loading = $(ev.currentTarget).children(".loading-song")
    loading.css {opacity: 0.5}
    song = 
      title: ev.currentTarget.getAttribute('data-title')
      artist: ev.currentTarget.getAttribute('data-artist')
    Meteor.call 'getSong', song, (err, url) ->
      song.url = url
      player.create song
      loading.css {opacity: 0}
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