title: XSS subdomain escape wirte up (on Dropbox)
date: 2015-08-04 22:57:30
tags:
---
First, I think many people found that any html file is rendered in the event menu or the mobile web page.
(I think Dropbox team won't fix this problem)
if we write down a JavaScript code to the html file, we can easily execute a JavaScript code on the html page.
But, the script is executed on dl-web.dropbox.com.
The session is a httponly cookie, so we can't easily steal the session.

![](/img/dropbox1.png)

In this situation, I can set any cookie on dropbox.com domain.
It means that it may be able to influence on www.dropbox.com.
If main dropbox page do something using cookie, then maybe I can do something on www.dropbox.com 

I found a some nice thing, flash.
After cookies, "flash" and "bang", are given, dropbox page draws a pop-up box which containing a text in "flash".
But, "bang" was a problem. It seems like hmac of "flash".
So, I need to find "bang" value of custom "flash"


I found a function which unlinks device in security setting page.
If I unlink a some device, then it shows me a flash message, which is containing device name.
So, I set the device name (iphone name) to malicious name, and I unlinked it. 

![](/img/dropbox2.png)

Now, I can get "flash" and "bang" value of any text.
(It is self-XSS. But, it can be combined with other attacks.)

![](/img/dropbox3.png)

Then, set the cookie in html, and make victim to move page to www.dropbox.com.

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
But, on IE or safari, script is executed.

![](/img/dropbox4.png)

+) Currently, common XSS on dl-web.dropbox.com is out of scope for bounty.
+) Now, I think a flash depends on only one session. 

2015/05/02 Fixed, A bounty of $1,331

Author: [tunz](http://blog.tunz.kr/)