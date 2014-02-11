# Hook-To-Trello

It allows you to manage or reference your [Trello](https://trello.com) board through commits to Github or Bitbucket.  
This is simple web app, which handle _POST_ request and work with [Trello API](https://trello.com/docs/api). It writen in [node.js](http://nodejs.org) and [LiveScript](http://livescript.net).  
For more information about webhooks you can read at [github](https://help.github.com/articles/post-receive-hooks) and [bitbucket](https://confluence.atlassian.com/display/BITBUCKET/POST+Service+Management) examples.

### Example

```
$ git commit -m 'Finalized details  --move 124 --to finish'
```

It will update `card #124`: add commit message + link as comment and move it to a list `finish`. Also you can specify `noco=1` if you don't want to write a comment.  
The message and commands shold be spareted by two spaces, by default. You can change it.

### Config

Below is script for heroku cloud. But you can host at any hosting for node.js.  

```
$ git clone https://github.com/olebedev/hook-to-trello.git myhooks
$ cd myhooks
```

All that you need to setup is specify `token` & `key` if you want to use it for your own. Or path(http or local) for _JSON_-encoded file, which contain one or more username for matching and `token` & `key` for each of them. It will be fetch or read in the moment of _POST_ request handling. How to get `token` & `key` see [below](#key--token).   
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
By default the file name is `./users.json`. Of course you can change it in `USERS` environ variable.
For example you can host `users.json` in your dropbox, it very useful if you want to change users dynamically.

### Deploy

```
$ heroku create
$ git push heroku <current branch>:master
```
If deploy was good, you can find application url in stdout. Usual it look like this: `https://sheltered-brook-4402.herokuapp.com`. This _URL_ to be useful in the next step.  
After that you need setup you repo for webhook. Read about it [here](https://help.github.com/articles/post-receive-hooks) or [here](https://confluence.atlassian.com/display/BITBUCKET/POST+Service+Management).  

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
- simplify command notations.