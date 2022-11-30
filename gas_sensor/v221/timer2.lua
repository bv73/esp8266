-- send to https://api.thingspeak.com
function send_ts()
  minute = minute + 2
  if (minute == 60) then
    minute = 0
    hour = hour + 1
  end
  -- close enduser_setup portal & set station mode after 6 minutes
--[[
  if (minute == 6) and (hour == 0) then
    print("\n= Portal closed =\n")
    enduser_setup.stop()
    wifi.setmode(wifi.STATION)
  end
--]]

  print("T DS18B20: " .. string.format("%.1f", t) .. " C")
  print("Gas concentration: " .. string.format("%.1f", max) .. " %")
  print(string.format("Hour: %s Minute: %02s", hour, minute))

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0)
  conn:connect(80,'184.106.153.149')

  -- start connection section
  conn:on("connection", function(conn) 
   print("TS connected")
   conn:send('GET /update?key=GDGC3fetGF345'..
   '&field1=' .. string.format("%.2f", max) ..
   '&field2=' .. string.format("%.1f", t) ..
   '&field3=' .. string.format("%s.%02s", hour, minute) .. 
   '&field4=' .. raw ..
   ' HTTP/1.1\r\n' ..
   'Host: api.thingspeak.com\r\n' ..
   'Accept: */*\r\n' ..
   'User-Agent: Mozilla/4.0 (compatible; ' ..
   'esp8266 Lua; Windows NT 5.1)\r\n\r\n')
  end)
  -- end connection section

  conn:on("sent", function(conn)
   -- Indication of data sent
   gpio.write(4, gpio.LOW) -- LED on
   print("TS data sent")
--   conn:close() -- You can disable this row for recieve thingspeak.com answer
  end)

  conn:on("receive", function(conn, payload)
--   print(payload)
   conn:close()
   gpio.write(4, gpio.HIGH) -- LED off
   print("Zero point=" .. raw)
   max = 0
  end)

   conn:on("disconnection", function(conn)
     print("TS disconnect")
   end)
end

-- send data to thingspeak every 2 minute
tmr.register(2, 120000, tmr.ALARM_AUTO, function() send_ts() end)
