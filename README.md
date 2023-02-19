# hexa-blog

## Installation

```bash
npm install hexo-cli -g
git clone https://github.com/HeXA-UNIST/hexa-blog.git
cd hexa-blog
npm install
```

## Write a post

```bash
hexo new "Codegate 2015 systemshock"
vi source/_posts/Codegate-2015-systemshock.md
```


## Edit a post

```bash
vi source/_posts/filename-to-edit.md
```

## Check the website on local server

Type below command and go to http://0.0.0.0:4000/ to check your change.

```bash
hexo server
```

## Publish to web

Don't use `git add .` `git commit -m "blabla"` things. Just type,

```bash
make deploy
```

See [Makefile](https://github.com/HeXA-UNIST/hexa-blog/blob/master/Makefile) to see the details of this magic command.

## Copyright

Copyright :copyright: 2015 HeXA.

The MIT License (MIT)
