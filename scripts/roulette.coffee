# Description
# A Hubot script that display the latest ranking and movie info in nicovideo.
#
# Dependencies:
# - moment
# - sleep
# - fs
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
sleeper = require 'sleep'

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
      msg.send '3'
      sleeper.sleep(1)
      msg.send '2'
      sleeper.sleep(1)
      msg.send '1'
      sleeper.sleep(1)
      msg.send words[parseInt(Math.random()*2, 10)]
    robot.brain.set 'question', words

