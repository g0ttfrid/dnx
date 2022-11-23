import net, strutils, asyncnet, asyncdispatch

let withSize = 256
var socket = newAsyncSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
socket.bindAddr(port = Port 53)

echo "[+] Listening..."

var query: string
while true:
    let 
        req = waitfor socket.recvFrom(withSize)
        data = $req.data
        x = parseHexStr(data.toHex[24 .. ^1])[1 .. ^1]

    if x.contains("quit"):
        break
    elif x.contains("micrsoft"):
        query.add(x[0 .. ^26])

try:
    let file = parseHexStr(query)
    writeFile("new.file", $file)
    echo "[+] Received: new.file (Sorry, rename it!)"
except CatchableError as e:
    echo "[!] Error: ", e.msg
