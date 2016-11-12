-- Gas Sensor
-- By (R)soft 10.11.2016 v1.0
-- Tested with NodeMCU 1.5.4.1

function invitation ()
  disp:firstPage()
  disp:setFont(u8g.font_osb26r)
  repeat
    disp:drawStr(26, 26, "GAS" )
    disp:drawStr(8, 56, "Sensor" )
  until disp:nextPage() == false
end

-- send to https://api.thingspeak.com
function send_ts()
conn = net.createConnection(net.TCP, 0)
conn:connect(80,'184.106.153.149')
conn:on("connection",
   function(conn) print("Connected")
   conn:send('GET /update?key=API_KEY_FOR_WRITE' ..
   '&field7=' .. string.format("%02d", x) ..
   '&field8=' .. string.format("%.1f", t) ..
   ' HTTP/1.1\r\n' ..
   'Host: api.thingspeak.com\r\n' ..
   'Accept: */*\r\n' ..
   'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
   '\r\n')
   end)
conn:on("sent",
   function(conn)
   -- Indication of data send
   gpio.write(led, gpio.LOW) -- LED on
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
   gpio.write(led, gpio.HIGH) -- LED off
   end)
end

invitation()

tmr.alarm(2, 60000, 1, function() send_ts() end)
