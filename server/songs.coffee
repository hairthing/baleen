Songs = new Meteor.Collection("song")
Meteor.startup ->
  # @setUserId (if @userId then @userId else new Meteor.Collection.ObjectID()._str)
  if Songs.find().count() == 0
    songs = [
      {
        title: "Ada"
        artist: "The National"
        album: "Sky Violet"
      },
      {
        title: "When Doves Cry"
        artist: "Prince"
        album: "Purple Rain"
      }
    ]
    for s in songs
      Songs.insert(s)



Meteor.publish "allsongs", ()->
  if @userId
    return Songs.find({}) # {artist:{$regex: 'Big', $options: 'i'}})
  else
    return false


Meteor.publish "usersongs", (id) ->
  if @userId
    users = Meteor.users.find({}, {
      transform: (user)->
        user.now = new Date()
        console.log "transform user", user
        return user
        # Songs.find({})

      })
    return users
  else
    return false
