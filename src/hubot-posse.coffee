# Description:
#   A hubot plugin that provides information about Hooroo posses.
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_POSSE_DB_LOCATION - a JSON Endpoint to query the posse database.
#
# Commands:
# posse (me) update: Updates posse database
# posse (me) - displays all existing posses
# posse (me) info <posse name or slug> - displays posse's name, total number of members, number of members per team
# (posse me) members <posse name or slug> - lists the members for each posse
# (posse me) (squid(s)|support) (for) <posse name or slug>  - shows you which members are squids for that posse
# (posse me) my posse - tells you which posse you're on
# (posse me) member [team member]: Displays information about that team member

request       = require('request')
stringHelper  = require("underscore.string")

module.exports = (robot) ->

  posse =

    loadPosses: ->
      console.info "refreshing posse database"
      try
        request( process.env.HUBOT_POSSE_DB_LOCATION, (error, response, body) ->
          robot.brain.set('posses', JSON.parse(body))
        )
      catch error
        console.info "#{process.env.HUBOT_POSSE_DB_LOCATION}"
        console.warn "Couldn't load the posse database. Error: #{error}"

    allPosses: ->
      message = "There are #{@_posses().length} posses in Hooroo:"
      for group in @_posses()
        message += "\n`*#{group.name}* (#{group.members.length} members)`"
      return message

    posseInfo: (posseName) ->
      return "I don't know the posse #{posseName}" unless (group = @_parsePosse(posseName))
      depts = @_posseMembersByTeam(group)
      message = "The #{group.name} posse's purpose is to *#{group.description}*"
      message += "\nIt has #{group.members.length} members, of which "
      deptInfo = for deptName, deptMembers of depts
        "#{deptMembers.length} belong#{(if deptMembers.length == 1 then "s" else "")} to the #{deptName} team"
      message += deptInfo.join(', ')
      message

    posseMembers: (posseName) ->
      return "I don't know the posse #{posseName}" unless (group = @_parsePosse(posseName))
      message = "Members of the #{group.name} are:"
      deptInfo = for member in group.members
        "\n• #{member.name} (@#{member.slack}) #{member.thumb}"
      message += deptInfo.join('')
      message

    myPosse: (nick) ->
      possesBelongingTo = @_possesForMember(nick)
      return "Too bad! You don't seem to be in a posse!" unless possesBelongingTo.length
      "You are a member of the #{stringHelper.toSentence(possesBelongingTo)} posse(s)"

    squids: (posseName) ->
      return "I don't know the posse #{posseName}" unless (group = @_parsePosse(posseName))
      message = "Your friendly squids for #{group.name} are:"
      squids = for member in @_posseMembersByTeam(group)['development']
        "\n• #{member.name} (@#{member.slack}) #{member.thumb}"
      message += squids.join('')
      message

    member: (memberName) ->
      for key, data of @_allPeople()
        regex = new RegExp( "#{data.regex}|(@)?#{data.slack}", "i" )
        return @_memberInfo( data ) if memberName.match( regex )
      @_noClue()

    _posses: ->
      return robot.brain.get('posses') if robot.brain.get('posses')

    _parsePosse: (posseName) ->
      for group in @_posses()
        regex = new RegExp( "#{group.name}|#{stringHelper.words(group.slug, /-/).join('|')}", "i" )
        return group if posseName.match( regex )
      return false

    _possesForMember: (nick) ->
      possesBelongingTo = []
      for group in @_posses()
        possesBelongingTo.push(group.name) if @_inPosse(group, nick)
      possesBelongingTo

    _posseMembersByTeam: (group) ->
      teams = {}
      for dude in group.members
        teams[dude.team] = [] unless dude.team of teams
        teams[dude.team].push dude
      teams

    _inPosse: (group, nick) ->
      for member in group.members
        return true if member.slack == nick
      false

    _allPeople: ->
      members = []
      uniques = []
      for group in @_posses()
        for member in group.members
          if member.slack not in uniques
            uniques.push member.slack
            members.push member
      members

    _memberInfo: (data) ->
      "Name: *#{data.name}*\n
      Slack: *@#{data.slack}*\n
      Posses: *#{stringHelper.toSentence(@_possesForMember(data.slack))}*\n
      Team: *#{data.team}*\n
      #{data.img}"

    _noClue: ->
      "I don't know this person. Try again."

  #preload people on restart
  posse.loadPosses()

  robot.respond /posse( me)? update$/i, (msg) ->
    if posse.loadPosses()
      msg.send "I have updated the posse database"
    else
      msg.send "Something went wrong. I can't update the posse database"

  robot.respond /posse( me)?$/i, (msg) ->
    info = posse.allPosses()
    msg.send info

  robot.respond /posse( me)? info ([\w \-]+)$/i, (msg) ->
    msg.send(posse.posseInfo(msg.match[2]))

  robot.respond /posse( me)? members ([\w \-]+)$/i, (msg) ->
    msg.send(posse.posseMembers(msg.match[2]))

  robot.respond /(posse )?(me )?my posse$/i, (msg) ->
    msg.send(posse.myPosse(msg.message.user.name))

  robot.respond /(posse )?(me )?(squid|squids|support)( for)? ([\w \-]+)$/i, (msg) ->
    msg.send(posse.squids(msg.match[5]))

  robot.respond /(posse )?(me )?member ([\w \-]+)$/i, (msg) ->
    msg.send(posse.member(msg.match[3]))
