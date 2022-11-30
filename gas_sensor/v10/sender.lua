-- Gas Sensor (sender.lua)
-- By (R)soft 10.11.2016 v1.0 with NodeMCU 1.5.4.1
-- v1.1 2/12/2016  add use in hours function
-- v1.2 21/01/2017 close enduser_setup portal & delay to first send
-- v2.0 13/02/2017 Tested with NodeMCU 2.0.0
-- v2.1 10/08/2018 Add power switch for MQ-5 on pin D2

minute = 0 -- counter of minutes
hour = 0 -- use in hours
flaghour = 1 -- set for first sending of hour=0
   
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
  -- Calc time
  minute = minute + 2
  if (minute == 60) then -- one hour
    minute = 0
    hour = hour + 1
    flaghour = 1 -- flag for sending one time per hour
  end
  -- close enduser_setup portal & station mode after 5 minutes
  if (minute == 4) and (hour == 0) then
    print("\n=== Portal closed ===\n")
    enduser_setup.stop()
    wifi.setmode(wifi.STATION)
  end
  print("Temperature DS18B20: " .. string.format("%.1f", t) .. " C")
  print("Gas concentration: " .. string.format("%.1f", max) .. " %")
  print(string.format("Hour: %s Minute: %02s", hour, minute))
  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0)
  conn:connect(80,'184.106.153.149')
  -- start connection section
  if (flaghour==1) then -- hour value sending one time per hour
  conn:on("connection",
   function(conn) print("Connected")
   conn:send('GET /update?key=2DGCG2G2G23G3PGD'..
   '&field1=' .. string.format("%.2f", max) ..
   '&field2=' .. string.format("%.1f", t) ..
   '&field3=' .. hour .. 
   '&field4=' .. raw ..
   ' HTTP/1.1\r\n' ..
   'Host: api.thingspeak.com\r\n' ..
   'Accept: */*\r\n' ..
   'User-Agent: Mozilla/4.0 (compatible; ' ..
   'esp8266 Lua; Windows NT 5.1)\r\n\r\n')
   end)
  flaghour = 0 -- reset flaghour after sending
  -- end connection section
  else
  conn:on("connection",
   function(conn) print("Connected")
   conn:send('GET /update?key=LDDC02C2J23X3PYL'..
   '&field1=' .. string.format("%.2f", max) ..
   '&field2=' .. string.format("%.1f", t) ..
   '&field4=' .. raw ..
   ' HTTP/1.1\r\n' ..
   'Host: api.thingspeak.com\r\n' ..
   'Accept: */*\r\n' ..
   'User-Agent: Mozilla/4.0 (compatible; ' ..
   'esp8266 Lua; Windows NT 5.1)\r\n\r\n')
   end)
  end -- end of if   
  conn:on("sent",
   function(conn)
   -- Indication of data send
   gpio.write(4, gpio.LOW) -- LED on
   print("Data sent")
--   conn:close() -- You can disable this row for recieve thingspeak.com answer
   end)
conn:on("receive",
   function(conn, payload)
--   print(payload)
   conn:close()
   gpio.write(4, gpio.HIGH) -- LED off
   print("Zero point=" .. raw)
   max = 0
   end)
-- conn:on("disconnection",
--   function(conn)
--   print("Disconnect")
--   gpio.write(4, gpio.HIGH) -- LED off
--   print("Zero point=" .. raw)
--   max = 0
--   end)
end

invitation()
print("\nInvitation\n")
-- delay for first send 10 sec
for z=1, 10 do
  tmr.delay(1000000)
  print("Delay ".. z .." sec")
end

-- send data to thingspeak every 2 minute
tmr.alarm(2, 120000, 1, function() send_ts() end)
-- every 3 sec call OLED function
tmr.alarm(0, 3000, 1, function() write_OLED() end )
