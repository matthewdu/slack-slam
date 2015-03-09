# slack-slam

A key-value store for Slack

### Setup
To use, add an outgoing webhook in Slack integrations pointing to `slack-slam.herokuapp.com/message` and make the trigger word `slam`
![Imgur](http://i.imgur.com/wlQILQC.png)

Then, just visit [slack-slam.herokuapp.com](slack-slam.herokuapp.com) and authorize yourself.

### Usage
Basic Commands
```
slam help # shows your user info
slam add <key> <value> # assign a new value to a key
slam <key> # references a key
slam list # lists all your key-value pairs
slam save <key> # saves either the last posted .gif or the last message a user other than yourself
```

Bonus stuff
```
slam weather <city> # weather for a specific city
slam trivia # a random trivia question
slam trivia-ans # answers to the last trivia question in the channel
slam yoda <phrase> # converts the phrase to yoda speak
slam joke # a random chuck norris joke
slam quote # a random movie quote
```

Example usage
```
# assign the key 'uwaterloo' the value 'is an awesome university'
slam add uwaterloo is an awesome university

# reference a previously stored key
slam uwaterloo #=> is an awesome university
```

### Contributors
* [Angel Gao](https://github.com/angelgao)
* [Jason Loo](https://github.com/nosajool)
* [Matthew Du](https://github.com/matthewdu)
