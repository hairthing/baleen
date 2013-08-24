Meteor.Router.add
  "/songs": ->
    if Meteor.userId()
      "songs"
    else
      "signin"

  "*": "not_found"




Meteor.Router.filters isSignedIn: (page) ->
  if Meteor.loggingIn()
    "loading"
  else if Meteor.user()
    page
  else
    "signin"



Meteor.Router.filter('isSignedIn', {except: 'signin'})





# iron router version
# Router.map ->
# @route 'home', path: '/'
# @route 'about'
# @route 'songs',
# waitOn: songsSub
# data: ()->
# songs: Songs.find({},{limit:10})# {artist:{$regex: 'Big', $options: 'i'}})


# Router.configure layout: 'layout'
# songsSub = Meteor.subscribe("songs")
# Songs = new Meteor.Collection("song")

# class @SongsController extends RouteController
# template: 'songs'

# renderTemplates:
# 'header': to: 'header'
# 'footer': to: 'footer'

# data: ->
# songs: Songs.find({},{limit:10})# {artist:{$regex: 'Big', $options: 'i'}})

# run: ->
# console.log 'running'#, @data()
# super

