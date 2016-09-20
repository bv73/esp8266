-- By (R)soft 20.09.2016 v1.0
-- Worked with float binary SDK 1.5.4.1 
-- branch: dev
-- include modules: file, gpio, net,node,tmr,uart,wifi
-- SSL: false


-- send to https://api.thingspeak.com
function SendTS()
humi = 1.24567
temp = 12.345678
x = 9.987

conn = net.createConnection(net.TCP, 0)
conn:connect(80,'184.106.153.149')
conn:on("connection",
   function(conn) print("Connected")
   conn:send('GET /update?key=API_KEY' ..
   '&field1=' .. string.format("%.2f", humi) ..
   '&field2=' .. string.format("%.2f", temp) ..
   '&field3=' .. string.format("%.2f", x) ..
   ' HTTP/1.1\r\n' ..
   'Host: api.thingspeak.com\r\n' ..
   'Accept: */*\r\n' ..
   'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
   '\r\n')
   end)
conn:on("sent",
   function(conn)
   print("Data sent")
   conn:close() -- You can disable this row for recieve thingspeak.com answer
   end)
conn:on("receive",
   function(conn, payload)
   print(payload)
   conn:close()
   end)
conn:on("disconnection",
   function(conn)
   print("Disconnect")
   end)
end

-- send data every X ms to thing speak
tmr.alarm(0, 20000, 1, function() SendTS() end )
