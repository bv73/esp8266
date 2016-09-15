gpio = 5
require('ds18b20')
ds18b20.setup(gpio)

function sendData()
t=ds18b20.read()
print("Temp:"..t.." C\n")
-- conection to thingspeak.com
print("Sending data to thingspeak.com")
conn=net.createConnection(net.TCP, 0) 
conn:on("receive", function(conn, payload) print(payload) end)
-- api.thingspeak.com 52.7.53.111 (old 184.106.153.149)
conn:connect(80,'52.7.53.111') 
conn:send("GET /update?key=APIKEY&field1="..t.." HTTP/1.1\r\n") 
conn:send("Host: api.thingspeak.com\r\n") 
conn:send("Accept: */*\r\n") 
conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
conn:send("\r\n")
conn:on("sent",function(conn)
                      print("Closing connection")
                      conn:close()
                  end)
conn:on("disconnection", function(conn)
                                print("Got disconnection...")
  end)
end

-- send data every X ms to thing speak
tmr.alarm(0, 60000, 1, function() sendData() end )
