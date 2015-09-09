# Description
# A Hubot script that select your life
#
# Dependencies:
# - moment
# - fs
# - step
#
# Configuration:
#
# Commands:
#
# Author:
# MaxMEllon
# https://github.com/MaxMEllon/ZinseiKimerukun/

moment  = require 'moment'
Fs      = require 'fs'
step    = require 'step'

config =
  path: process.env.HUBOT_FILE_BRAIN_PATH

module.exports = (robot) ->
  unless config.path?
    robot.logger.error 'process.env.HUBOT_FILE_BRAIN_PATH is not defined'
    return

  robot.brain.setAutoSave false

  load = ->
    if Fs.existsSync config.path
      data = JSON.parse Fs.readFileSync config.path, encoding: 'utf-8'
      robot.brain.mergeData data
    robot.brain.setAutoSave true


  save = (data) ->
    Fs.writeFileSync config.path, JSON.stringify data

  robot.brain.on 'save', save

  load()

  robot.respond /(.*) or (.*)$/i, (msg) ->
    words = []
    words.push msg.match[1]
    words.push msg.match[2]
    question = robot.brain.get('question')
    question = [null, null] if question == null
    if  ! (words.indexOf(question[0]) == -1) && ! (words.indexOf(question[1]) == -1)
      imageMe msg, '激おこスティック', (url) ->
        msg.send url
    else
      step(
        ()->
          msg.send '3'
          setTimeout @, 1000
          return
        ()->
          msg.send '2'
          setTimeout @, 1000
          return
        ()->
          msg.send '1'
          setTimeout @, 1000
          return
        ()->
          msg.send words[parseInt(Math.random()*2, 10)]
          return
      )
      robot.brain.set 'question', words

imageMe = (msg, query, animated, faces, cb) ->
  cb = animated if typeof animated == 'function'
  cb = faces if typeof faces == 'function'
  googleCseId = process.env.HUBOT_GOOGLE_CSE_ID
  if googleCseId
    # Using Google Custom Search API
    googleApiKey = process.env.HUBOT_GOOGLE_CSE_KEY
    if !googleApiKey
      msg.robot.logger.error "Missing environment variable HUBOT_GOOGLE_CSE_KEY"
      msg.send "Missing server environment variable HUBOT_GOOGLE_CSE_KEY."
      return
    q =
      q: query,
      searchType:'image',
      safe:'high',
      fields:'items(link)',
      cx: googleCseId,
      key: googleApiKey
    if animated is true
      q.fileType = 'gif'
      q.hq = 'animated'
    if faces is true
      q.imgType = 'face'
    url = 'https://www.googleapis.com/customsearch/v1'
    msg.http(url)
      .query(q)
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :( #{err}"
          return
        if res.statusCode isnt 200
          msg.send "Bad HTTP response :( #{res.statusCode}"
          return
        response = JSON.parse(body)
        if response?.items
          image = msg.random response.items
          cb ensureImageExtension image.link
        else
          msg.send "Oops. I had trouble searching '#{query}'. Try later."
          ((error) ->
            msg.robot.logger.error error.message
            msg.robot.logger
              .error "(see #{error.extendedHelp})" if error.extendedHelp
          ) error for error in response.error.errors if response.error?.errors
  else
    # Using deprecated Google image search API
    q = v: '1.0', rsz: '8', q: query, safe: 'active'
    q.imgtype = 'animated' if typeof animated is 'boolean' and animated is true
    q.imgtype = 'face' if typeof faces is 'boolean' and faces is true
    msg.http('https://ajax.googleapis.com/ajax/services/search/images')
      .query(q)
      .get() (err, res, body) ->
        if err
          msg.send "Encountered an error :( #{err}"
          return
        if res.statusCode isnt 200
          msg.send "Bad HTTP response :( #{res.statusCode}"
          return
        images = JSON.parse(body)
        images = images.responseData?.results
        if images?.length > 0
          image = msg.random images
          cb ensureImageExtension image.unescapedUrl
        else
          msg.send "Sorry, I found no results for '#{query}'."

ensureImageExtension = (url) ->
  ext = url.split('.').pop()
  if /(png|jpe?g|gif)/i.test(ext)
    url
  else
    "#{url}#.png"
