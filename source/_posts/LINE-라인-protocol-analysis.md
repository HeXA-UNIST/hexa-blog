title: LINE(라인) protocol analysis
date: 2013-09-05 10:10:26
tags:
- reverse engineering
- carpedm20
---
*If you need a python code right away, then please keep in touch with https://github.com/carpedm20/LINE*

After I analyzed [LOCO protocol](http://carpedm20.blogspot.kr/2013/08/python-wrapper-for-loco-protocol.html) of KakaoTalk, I've been curious about the operation of other messaging applications. Like KakaoTalk, [LINE](http://line.naver.jp/) is the instant messaging application on smartphones and PCs. LINE is not popular in Korea, but media currently said that LINE is one of the most popular messaging app in Japan. So, I decided to analyze the protocol of LINE and I'll record the steps that I followed in this post. My final goal is to implement the LINE protocol in python, especially sending and receiving messages.

<p align="center"> <img src="/img/line1.png" style="width: 40%;"/> </p>

## 1. Download xap file

First of all, I needed a xap file of LINE windows mobile application, so I searched it on Google.

<p align="center"> <img src="/img/line2.png" style="width: 80%;"/> </p>

Finally, I found the old version of LINE xap file (version : 1.7.0.71). The latest version of windows LINE application is [2.7.0.155](http://www.windowsphone.com/en-us/store/app/line/a18daaa9-9a1c-4064-91dd-794644cd88e7).

## 2. Unzip xap file

<p align="center"> <img src="/img/line3.png" style="width: 80%;"/> </p>

The first thing that attracted me was 'Line.dll' file and I guessed it may have core functions for the chat protocol. And also, I could see 'Thrift.dll' which is the library for [Thrift framework](http://thrift.apache.org/). After I searched Google for a moment, I found that Thrift is an open source project for cross-language service built by [Apache](http://apache.org/).

Now, I knew LINE uses Thrift library for network communication, which is not their own protocol, so I thought it might be easy to implement LINE chat system (compare to LOCO protocol).


## 3. Packet Analysis

Before I did the static analysis, I used [Windows mobile phone emulator](https://www.microsoft.com/en-us/download/details.aspx?id=43719) for the packet analysis. Of course, the network between application and server was encrypted using `https`. There were some packets which seem to be TCP protocol but I focused on the HTTP communication. After looked over the packet, I used [.Net reflector](http://www.red-gate.com/products/dotnet-development/reflector/) to see the real decompiled source code of applications.

<p align="center"> <img src="/img/line4.png" style="width: 80%;"/> </p>

I searched `https` as a string, changed them to `http`, and re-zipped the `xap` file. At this point, I found out that the DNS of main server for chat communication was `gm.line.naver.jp`. Especially, `gm.line.naver.jp/S3` is used for authorization and chat service for LINE.

    http://gm.line.naver.jp/api/v3/TalkService.do for talkSession

Then, I could see the plain chat communication between server and client in the packets.

<p align="center"> <img src="/img/line5.png" style="width: 80%;"/> </p>

I'm not sure that HTTP is LINE's main protocol, because LOCO protocol of KakaoTalk used their own packet structure which was encrypted with AES. As you can see, LINE doesn't encrypt any messages, so I can see the **plain message from packet**. Also, `X-Line-Access`, which was included in the header, seems like a session key, so I was wonder whether the previous session can be used for communication or not. So I quickly wrote a dirty python code which send the exactly same packet to the server...

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'carpedm20'

import urllib2

def send():
    url = 'http://gm.line.naver.jp/S3'

    headers = { 'POST' : '/S3',
        'X-Line-Application' : 'WINPHONE.1.7.0.71.WindowsPhone.7.10.7720',
        'Referer' : 'file:///Applications/Install/???/Install/',
        'Accept-Encoding' : 'identity',
        'Content-Type' : 'application/x-thrift',
        'Accept' : 'application/x-thrift',
        'X-Line-Access' : '???',
        'Connection' : 'Keep-Alive',
        'User-Agent' : 'WindowsPhone 1.7.0.71',
        'HOST' : 'gm.line.naver.jp',
        'Cache-Control' : 'no-cache'}

    data='\x80\x01\x00\x01\x00\x00\x00\x0b\x73\x65\x6e\x64\x4d\x65\x73\x73\x61\x67\x65\x00\x00\x00\x00\x08\x00\x01\x00\x00\x00\x00\x0c\x00\x02\x0b\x00\x02\x00\x00\x00\x21\x75\x30\x33\x39\x61\x31\x64\x39\x62\x33\x34\x35\x37\x61\x64\x39\x39\x35\x61\x66\x36\x36\x62\x34\x64\x64\x64\x30\x38\x30\x65\x36\x38\x0b\x00\x0a\x00\x00\x00\x06\x51\x77\x65\x71\x77\x65\x02\x00\x0e\x00\x00\x00'

    request = urllib2.Request(url, data, headers)
    response = urllib2.urlopen(request)

    print "[*] Result "
    data = response.read()
    print data
    #data = json.loads(data ,encoding='utf-8')

send()
```

It worked pretty well!

<p align="center"> <img src="/img/line6.png" style="width: 80%;"/> </p>

Author: [carpedm20](http://carpedm20.github.io/)
