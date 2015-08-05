title: XSS subdomain escape wirte up (on Dropbox)
date: 2015-08-04 22:57:30
tags:
---
## Beginning

First, I think many people know that a html file uploaded on dropbox shows with rendering, and without any escaping.
It means that, if we write down a JavaScript code to the html file, we can easily execute a JavaScript code on the html page without any problem.
But, the script is executed on a sandbox domain, dl-web.dropbox.com.
The important session is a httponly cookie, so we can't easily steal the user session.

<p align="center"> <img src="/img/dropbox1.png" style="width: 60%;"/> </p>

In this situation, I can set any cookie on dropbox.com domain (not www.dropbox.com).
It means that it may be able to influence on www.dropbox.com.
If main dropbox page do something using the cookie on dropbox.com, then maybe I can do something on www.dropbox.com 

## Vulnerability

I found a some nice thing, Flash. After cookies, "flash" and "bang", are given, dropbox page draws a pop-up box which is containing a text in "flash". But, "bang" was a problem. It seems like a hmac of "flash". So, I need to find "bang" value of my custom "flash"

I also found a function which unlinks device in security setting page. If I unlink a some device, then it shows me a flash message, which is containing device name. So, I set the device name (iphone name) to a XSS text, and I unlinked it. 

## Attack

![](/img/dropbox2.png)

Now, I can set "flash" and "bang" value to any text.

![](/img/dropbox3.png)

Then, set the malicious cookie in a html. After that, make victim to move page to www.dropbox.com (trigger flash message).

```javascript
<script>
document.cookie="bang=QUFEZGthYS1CaTNfWUpYcDUwdjNxemVHSHlhSHJkU3BEdnhKRUxOZVZ3b2ZoUQ%3D%3D;
Domain=dropbox.com; Path=/;";
document.cookie="flash=b2s6PGltZyBzcmM9eCBvbmVycm9yPWFsZXJ0KGRvY3VtZW50LmRvbWFpbik%2BIHVubGlua
2VkIHN1Y2Nlc3NmdWxseS4%3D; Domain=dropbox.com; Path=/";
location.href="https://dropbox.com/forgot";
</script>
```

There is a CSP.
But, the script is executed on IE or Safari.

<p align="center"> <img src="/img/dropbox4.png" style="width: 80%;"/> </p>

+) Currently, common XSS on dl-web.dropbox.com is out of scope for bounty.
+) Now, I think a flash depends on only one session. 

2015/05/02 Fixed, A bounty of $1,331

Author: [tunz](http://blog.tunz.kr/)
