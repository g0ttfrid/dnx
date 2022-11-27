import net, strutils, asyncnet, asyncdispatch
from base64 import decode

let withSize = 256
var socket = newAsyncSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
socket.bindAddr(port = Port 53)

echo "[+] Listening..."

var query: string
while true:
    let 
        req = waitfor socket.recvFrom(withSize)
        data = $req.data
        x = data.toHex[26 .. ^1]
    
    if x.contains("71756974"):
        break
    elif x.contains("016103"):
        query.add(parseHexStr(x[0 .. ^61]))
        
try:
    let file = decode(query)
    writeFile("new.file", $file)
    echo "[+] Received: new.file (Sorry, rename it!)"
    #echo file
except CatchableError as e:
    echo "[!] Error: ", e.msg
