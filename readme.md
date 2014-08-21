# Hook-To-Trello

It allows you to manage or reference your [Trello](https://trello.com) board through commits to Github or Bitbucket.  
This is simple web app, which handle _POST_ request and work with [Trello API](https://trello.com/docs/api). It writen in [node.js](http://nodejs.org) and [LiveScript](http://livescript.net).  
For more information about webhooks you can read at [github](https://help.github.com/articles/post-receive-hooks) and [bitbucket](https://confluence.atlassian.com/display/BITBUCKET/POST+Service+Management) examples.

### Example

```
$ git commit -m 'Finalized details done #124'
```

It will update `card #124`: add commit message + link as comment and move it to a list `done`.  

### Deploy

Below is script for heroku cloud. But you can host at any hosting for node.js.

```
$ git clone https://github.com/olebedev/hook-to-trello.git myhooks
$ cd myhooks
$ heroku create
$ # Set configuration variables now. See Config App.
$ git push heroku <current branch>:master
```
If deploy was good, you can find application url in stdout. Usual it look like this: `https://sheltered-brook-4402.herokuapp.com`. This _URL_ to be useful in the next step.  
After that you need setup you repo for webhook. Read about it [here](https://help.github.com/articles/post-receive-hooks) or [here](https://confluence.atlassian.com/display/BITBUCKET/POST+Service+Management).  

### Config App

The app needs at least one Trello key/token pair. How to get `token` & `key` see [below](#key--token).

#### Basic Configuration

Set the `TOKEN` and `KEY` environment variables. This uses the same Trello token and key for every commit. On Heroku:
```
$ heroku config:set KEY <your admin board key>
$ heroku config:set TOKEN <your admin board token>
```

#### Per-User Tokens

Put a file called `users.json` in the application root.

The file structure should look like this:

```json
{
  "olebedev":{
    "key":"<key>",
    "token":"<token>",
    "aliases": ["olebedev", "olebedev <mail@olebedev.ru>"]
  },
  "john":{
    "key":"<key>",
    "token":"<token>",
    "aliases": ["john", "john <mail@john.com>"]
  }
}
```

If aliases is not specified, application will be use each key of object as alias.

The location of this file can be customized by setting the `USERS` environment variable. This can also be set to a remote HTTP-accessible location and read on each POST hook run. For example you can host `users.json` in your dropbox, it very useful if you want to change users dynamically.

```
$ heroku config:set USERS <your JSON file (https://dl.dropboxusercontent.com/s/a1nwtlzdpf/users.json)>
```

### Setup repo
For setup the repo simply add your heroku app _URL_ + "/`<prefix>`/`<board_id>`" as a webhook url under "admin" for your repository. Where `<prefix>` is `g` for github or `b` for bitbucket. And `<board_id>` you can get from the Trello board _URL_, for example https://trello.com/board/trello-development/4d5ea62fd76aa1136000000c the board id is 4d5ea62fd76aa1136000000ca  

Example:  
  * for github: `https://sheltered-brook-4402.herokuapp.com/g/4d5ea62fd76aa1136000000ca`
  * for bitbucket: `https://sheltered-brook-4402.herokuapp.com/b/4d5ea62fd76aa1136000000ca`

### Key & Token 

This is a one-time operation for each user:  
  - `key` - generate it here [https://trello.com/1/appKey/generate](https://trello.com/1/appKey/generate)
  - `token` - generate it here https://trello.com/1/authorize?response_type=token&name=Trello+Github+BitBucket+Integration&scope=read,write&expiration=never&key=[your-key-here] replacing __[your-key-here]__ with the `key` from above. Authorize the request and get the token.


### TODO

- actions for checklists;
- ~~simplify command notations~~.