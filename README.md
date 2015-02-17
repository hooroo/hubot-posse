# Hubot Posse

A hubot plugin deal with Hooroo posses.

## Installation

In hubot project repo, run:

```
npm install hubot-posse
```

Then add this line:

```
hubot-posse
```

to your `external-scripts.json`

Furthermore, you need an environment variable `HUBOT_POSSE_DB_LOCATION` with the location of a json endpoint that provides information about the posses in the following format:

```json
[
  {
    "name": "Posse Name",
    "slug": "posse-name",
    "description": "A brief description of your posse",
    "members": [
      {
        "name": "A member",
        "regex": "a regex string to find the member by",
        "slack": "slack-nickname",
        "img": "http://i.imgur.com/an-image.jpg",
        "thumb": "http://i.imgur.com/a-thumbnail.jpg",
        "team": "his/her team"
      },
      {...}
    ]
  },
  {...}
]
```

## Hubot Commands
```
posse (me) update: Updates posse database
posse (me) - displays all existing posses
posse (me) info <posse name or slug> - displays posse's name, total number of members, number of members per team
(posse me) members <posse name or slug> - lists the members for each posse
(posse me) (squid(s)|support) (for) <posse name or slug>  - shows you which members are squids for that posse
(posse me) my posse - tells you which posse you're on
(posse me) member [team member]: Displays information about that team member
```

![Posse for real](http://i.imgur.com/C6h3ZB0.jpg)

