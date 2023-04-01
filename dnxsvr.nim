import net, strutils, asyncnet, asyncdispatch, random
randomize()

let withSize = 256
var socket = newAsyncSocket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)
socket.bindAddr(port = Port 53)

echo "[+] Listening..."

var
    query: string
    name: string
while true:
    let 
        req = waitfor socket.recvFrom(withSize)
        data = $req.data
        x = data.toHex[26 .. ^1]
    #echo "[DEBUG] ", x
    if x.contains("71756974"):
        break
    elif x.contains("02626211"):
        #echo "[DEBUG] ", parseHexStr(x[0 .. ^61])
        name.add(parseHexStr(x[0 .. ^61]))
    elif x.contains("016103"):
        #echo "[DEBUG] ", parseHexStr(x[0 .. ^61])
        query.add(parseHexStr(x[0 .. ^61]))
       
try:
    let 
        content = parseHexStr(query)
        filename = $rand(10000) & parseHexStr(name)
    writeFile(filename, $content)
    echo "[+] Received: ", filename, " [lengh: ", content.len, "]"
except CatchableError as e:
    echo "[!] Error: ", e.msg
