-- Gas Sensor by (R)soft 5.10.2019 v2.11 NodeMCU 1.5.4.1
-- v1.1 2/12/2016  add use in hours function
-- v1.2 21/01/2017 close enduser_setup portal & delay to first send
-- v2.0 13/02/2017 Tested with NodeMCU 2.0.0
-- v2.1 10/08/2018 Add power switch for MQ-5 on pin D2

minute = 0 -- counter of minutes
hour = 0 -- use in hours
   
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
  minute = minute + 2    -- Calc time
  if (minute == 60) then
    minute = 0
    hour = hour + 1
  end
  -- close enduser_setup portal & station mode after 6 minutes
  if (minute == 6) and (hour == 0) then
    print("\n= Portal closed =\n")
    enduser_setup.stop()
    wifi.setmode(wifi.STATION)
  end
  print("T DS18B20: " .. string.format("%.1f", t) .. " C")
  print("Gas concentration: " .. string.format("%.1f", max) .. " %")
  print(string.format("Hour: %s Minute: %02s", hour, minute))
  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0)
  conn:connect(80,'184.106.153.149')
  -- start connection section

  conn:on("connection",
   function(conn) print("Connected")
   conn:send('GET /update?key=BDGCG2G2G23'..
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
