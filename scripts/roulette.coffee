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
      msg.send 'http://blog-imgs-42.fc2.com/c/a/t/cateriam/201304161641119e0.jpg'
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

