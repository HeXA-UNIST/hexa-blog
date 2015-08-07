title: LINE(라인) protocol analysis
date: 2013-09-05 10:10:26
tags:
- reverse engineering
- carpedm20
---

# Let's send a message

*If you need a python code right away, then please keep in touch with https://github.com/carpedm20/LINE*

After I analyzed [LOCO protocol](http://carpedm20.blogspot.kr/2013/08/python-wrapper-for-loco-protocol.html) of KakaoTalk, I've been curious about the operation of other messaging applications. Like KakaoTalk, [LINE](http://line.naver.jp/) is the instant messaging application on smartphones and PCs. LINE is not popular in Korea, but media currently said that LINE is one of the most popular messaging app in Japan. So, I decided to analyze the protocol of LINE and I'll record the steps that I followed in this post. My final goal is to implement the LINE protocol in python, especially sending and receiving messages.

<p align="center"> <img src="/img/line1.jpg" style="width: 20%;"/> </p>

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

    headers = {
        'POST' : '/S3',
        'X-Line-Application' : 'WINPHONE.1.7.0.71.WindowsPhone.7.10.7720',
        'Referer' : 'file:///Applications/Install/???/Install/',
        'Accept-Encoding' : 'identity',
        'Content-Type' : 'application/x-thrift',
        'Accept' : 'application/x-thrift',
        'X-Line-Access' : '???',
        'Connection' : 'Keep-Alive',
        'User-Agent' : 'WindowsPhone 1.7.0.71',
        'HOST' : 'gm.line.naver.jp',
        'Cache-Control' : 'no-cache'
    }

    data='\x80\x01\x00\x01\x00\x00\x00\x0b\x73\x65\x6e\x64\x4d\x65' + \
         '\x73\x73\x61\x67\x65\x00\x00\x00\x00\x08\x00\x01\x00\x00' + \
         '\x00\x00\x0c\x00\x02\x0b\x00\x02\x00\x00\x00\x21\x75\x30' + \
         '\x33\x39\x61\x31\x64\x39\x62\x33\x34\x35\x37\x61\x64\x39' + \
         '\x39\x35\x61\x66\x36\x36\x62\x34\x64\x64\x64\x30\x38\x30' + \
         '\x65\x36\x38\x0b\x00\x0a\x00\x00\x00\x06\x51\x77\x65\x71' + \
         '\x77\x65\x02\x00\x0e\x00\x00\x00'

    request = urllib2.Request(url, data, headers)
    response = urllib2.urlopen(request)

    print "[*] Result "
    data = response.read()
    print data
    #data = json.loads(data ,encoding='utf-8')

if __name__ == '__main__':
    send()
```

It worked pretty well!

<p align="center"> <img src="/img/line6.png" style="width: 90%;"/> </p>


# HTTP(S) data

Now, I decide to analyze the LINE protocol in more detail.

## 4. HTTP(S) Analysis

<p align="center"> <img src="/img/line7.png" style="width: 80%;"/> </p>

There are two particular headers, one is `X-Line-Application` and the other is `X-Line-Access`. The first header, `X-Line-Application`, specify the kind of mobile phone, which is not that interesting one ;(

However, the second header `X-Line-Access` seems like a session key and part of the key is encrypted by Base64. I'll talk about this later. Anyway, after I decode the encrypted data, I can get `iat: 1378973334524` (string data) and `��" [���<Z� � 5wxwO�` (byte[] data)

<p align="center"> <img src="/img/line8.png" style="width: 90%;"/> </p>

The format of POST data seems like 'bson' string which is used in LOCO protocol but it isn't. To find out how the application deals with the session key and what kind of data type is used for POST data, I used .NET Reflector again and find out some interesting functions like `send_sendMessage(int seq, Message message)`.

<p align="center"> <img src="/img/line9.png" style="width: 90%;"/> </p>

As you can see in this picture, there is a string `sendMessage` which also can be found in the POST data. Therefore, I guess that this `sendMessage` function makes the POST data. I also figure out that WriteMessageBegin() and WriteMessageEnd() are the functions for **Thrift platform**. I keep read some posts and decompiled codes to find out how Thrift works, but I can't figure out the exact structure of Thrift HTTP protocol.

```python
## VERSION of Thrift protocol ##
# TBinaryProtocol.VERSION_1 | type
data = '\x80\x01\x00\x01'

## Function ##
# \x00\x00\x00\x0b : sendMessage
# \x00\x00\x00\x0f : fetchOperations, for read message
data += '\x00\x00\x00\x0b' # length of function
data += 'sendMessage'

## Message information for static message ##
## (not include sticker information) ##
data += '\x00\x00\x00\x00'
data += '\x08\x00\x01\x00'
data += '\x00\x00\x00\x0c'
data += '\x00\x02\x0b\x00'

# \x01\x00\x00\x00 : from
# \x02\x00\x00\x00 : to
data += '\x02\x00\x00\x00' # to
data += '????' # chat id to send message
data += '\x0b\x00\x0a' # ChatId footer

## User input : not included in Thift protocol ##
message = raw_input(">> ")

## Length of message ##
#data += '\x00\x00\x00\x10' # \x06 : length
data += struct.pack('>I',len(message))

## Message ##
#for i in range(16):
#    data += chr(49 + i) # 65 : A, 49 : 1
data += message

## Message footer ##
#data += '\x0a\x02\x00\x0e\x00\x00\x00'
data += '\x02\x00\x0e\x00\x00\x00'
```

The bellow picture is the structure of Thrift packet based on the packet analysis that I took. (which may include some errors)

<p align="center"> <img src="/img/line10.png" style="width: 50%;"/> </p>

And the bellow code is a short python code which can be used to send message to someone (not me).

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-
__author__ = 'carpedm20'
import urllib2
import struct

url = 'http://gm.line.naver.jp/S3'
headers = { 'POST' : '/S3',
    'X-Line-Application' : 'WINPHONE.1.7.0.71.WindowsPhone.7.10.7720',
    'Referer' : 'file:///Applications/Install/A18DAAA9-9A1C-4064-91DD-794644CD88E7/Install/',
    'Accept-Encoding' : 'identity',
    'Content-Type' : 'application/x-thrift',
    'Accept' : 'application/x-thrift',
    'X-Line-Access' : '????';
    'Connection' : 'Keep-Alive',
    'User-Agent' : 'WindowsPhone 1.7.0.71',
    'HOST' : 'gm.line.naver.jp',
    'Cache-Control' : 'no-cache'}

def send():
    data = '\x80\x01\x00\x01\x00\x00\x00\x0b'
    data += 'sendMessage'
    data += '\x00\x00\x00\x00\x08\x00\x01\x00\x00\x00\x00\x0c\x00\x02\x0b\x00\x02\x00\x00\x00'
    data += '????' # chat id to send message
    data += '\x0b\x00\x0a'
    message = raw_input(">> ")
    data += struct.pack('>I',len(message))
    data += message
    data += '\x02\x00\x0e\x00\x00\x00'

    request = urllib2.Request(url, data, headers)
    response = urllib2.urlopen(request)

    print "[*] Result "

    data = response.read()
    for d in data:
        print "%#x" % ord(d),
    print

def read():
    data = '\x80\x01\x00\x01' # TBinaryProtocol.VERSION_1 | type
    data += '\x00\x00\x00\x0f'

    data += 'fetchOperations'
    data += '\x00\x00\x00\x00\x0a'
    data += '\x00\x02\x00\x00\x00\x00\x00\x00\x00\xf9\x08\x00\x03\x00\x00\x00\x14\x00'

    request = urllib2.Request(url, data, headers)
    response = urllib2.urlopen(request)

    print "[*] Result "

   
    data = response.read()
    for d in data:
        print "%#x" % ord(d),
    print
    print data

while 1:
    send()
```

I can also figure out how to send an emoticon message through LINE. I wish I can send some emoticons, which I have to buy to use them, but it doesn't worked with an error message **"current user does not have this sticker"** :(

ps. you can send some charged emoticons in LOCO protocol for nothing :)

<p align="center"> <img src="/img/line11.png" style="width: 90%;"/> </p>


# Session key

Finally, I want to talk about session key  and auth key.


## 5. Session key

At first, I tried to follow UpdateAuthToken() function because this function adds the `X-Line-Access` header to the HTTP protocol. As I followed this function, I finally arrived to create() function which updates the old session key. It wasn't hard to understand how this function updates authKey, but I couldn't figure out when LINE change an auth key.

It seems like LINE's session key is changed when a user change his/her mobile phone or re-install the application. In other words, the session key **won't be changed** if you don't erase or change your mobile phone. This can cause security problems if someone change the code of LINE application and distribute it to the internet...but I don't think it will happen :)

Bellow is the list of functions that I followed to find out how LINE update their authorization key.

```csharp
public void UpdateAuthToken(string authKey)
{
    if (authKey != null)
    {
        this._transport.AddRequestHeader("X-Line-Access", AccessTokenHelper.GetAccessToken(authKey)); // add "X-Line-Access" header to HTTP(s) protocol
    }
}

public void UpdateAuthToken(string authKey)
{
    try
    {
        if (authKey != null)
        {
            this._transport.AddRequestHeader("X-Line-Access", AccessTokenHelper.GetAccessToken(authKey)); // add "X-Line-Access" header to HTTP(s) protocol
        }
    }
    catch (Exception)
    {
    }
}

private void _addCustomHeader(HttpWebRequest httpWebRequest)
{
    Profile current = ProfileViewModel.GetInstance().Current;
    httpWebRequest.get_Headers().set_Item("X-Line-Access", AccessTokenHelper.GetAccessToken(current.AuthKey)); // add "X-Line-Access" header to HTTP(s) protocol
    httpWebRequest.get_Headers().set_Item("X-Line-Application", DeviceUtility.GetLineApplicationString());
    httpWebRequest.get_Headers().set_Item("Cache-Control", "no-cache");
    httpWebRequest.get_Headers().set_Item("Pragma", "no-cache");
}

public static string GetAccessToken(string authKey)
{
    long timestamp = (DateTime.get_UtcNow() - new DateTime(0x7b2, 1, 1, 0, 0, 0, 1)).get_TotalMilliseconds(); // use time stamp for making access token
    return GetAccessToken(timestamp, authKey);
}

public static string GetAccessToken(long timestamp, string authKey)
{
    if (((_accessToken == "") || !_accessToken.Equals(_lastAuthToken)) || (timestamp > (_lastUpdated + 0x5265c00L)))
    {
        lock (_thisLock)
        {
            _accessToken = Generate(authKey, timestamp);
            _lastUpdated = timestamp;
            _lastAuthToken = authKey;
        }
    }
    return _accessToken;
}

public static string Generate(string authToken, long timestamp)
{
    string[] strArray = authToken.Split(new char[] { ':' });
    if (strArray.Length != 2)
    {
        throw new ArgumentException("authToken");
    }
    string issueTo = strArray[0]; // use previous authToken for the new authToken
    string encodedSecretKey = strArray[1]; // use previous authToken for the new authToken
    string str3 = YamlWebToken.Create(issueTo, timestamp, encodedSecretKey);
    return (issueTo + ":" + str3);
}

public class YamlWebToken
{
    // Fields
    public static HmacAlgorithm DEFAULT_ALOGORITHM; // use Hmac algorith for generating token
    // Methods
    static YamlWebToken();
    public YamlWebToken();
    public static string Create(string issueTo, long timestamp, string encodedSecretKey);
    public static string Create(string issuedTo, long timestamp, string encodedSecretKey, HmacAlgorithm algorithm);
    // Nested Types
    public class HmacAlgorithm
    {
        // Methods
        public HmacAlgorithm(string name);
        public static HMAC CreateInstance(string name, byte[] key);
        // Properties
        public string Name { get; set; }
    }
}

public static string Create(string issueTo, long timestamp, string encodedSecretKey)
{
    return Create(issueTo, timestamp, encodedSecretKey, DEFAULT_ALOGORITHM);
}

public static string Create(string issuedTo, long timestamp, string encodedSecretKey, HmacAlgorithm algorithm)
{
    string str = "";
    try
    {
        // core algorithm to make new session key
        string str2 = string.Format("iat: {1}\n", issuedTo, timestamp); 
        string str3 = Convert.ToBase64String(Encoding.get_UTF8().GetBytes(str2));
        string str4 = string.Empty;
        string str5 = str3 + "." + str4;
        byte[] key = Convert.FromBase64String(encodedSecretKey);
        string str6 = Convert.ToBase64String(HmacAlgorithm.CreateInstance(algorithm.Name, key).ComputeHash(Encoding.get_UTF8().GetBytes(str5)));
        str = str5 + "." + str6; // base64(issuedTo) + '..' + Hmac(SecretKey)
    }
    catch (Exception)
    {
    }
    return str;
}
```

Anyway, I wrote an C# code that make updated session key... 

```csharp
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ConsoleApplication1
{
    class Program
    {
        static void Main(string[] args)
        {
            String issuedTo = "1" ;
            DateTime l = DateTime .UtcNow;
            long timestamp = (long )((l - new DateTime(1970, 1, 1, 0, 0, 0, 1)).TotalMilliseconds);
            String authToken = "????" // your old session key

            string[] strArray = authToken.Split(new char[] { ':' });
            string issueTo = strArray[0];
            string encodedSecretKey = strArray[1];

            string str2 = string .Format("iat: {1}\n", issuedTo, timestamp);
            string str3 = Convert .ToBase64String(Encoding.UTF8.GetBytes(str2));
            string str4 = string .Empty;
            string str5 = str3 + "." + str4;

            byte[] key = Convert .FromBase64String(encodedSecretKey);

            string str6 = Convert.ToBase64String(LINE.Service.YamlWebToken .HmacAlgorithm.CreateInstance(LINE.Service.YamlWebToken.DEFAULT_ALOGORITHM.Name, key).ComputeHash(Encoding.UTF8.GetBytes(str5)));

            String str = str5 + "." + str6;  // base64(issuedTo) + '..' + Hmac(SecretKey)
        }
    }
}
```

Author: [carpedm20](http://carpedm20.github.io/)
