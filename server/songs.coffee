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

Meteor.publish "songs", ()->
  if @userId
    return Songs.find({}) # {artist:{$regex: 'Big', $options: 'i'}})
  else
    return undefined
