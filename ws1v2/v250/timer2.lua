function send_ts()
  gpio.write(4, gpio.LOW) -- LED on
  t1 = ds18b20.read(address[2])
  p = bme280.baro()
  p = p/1333.22365 -- fixed!
  si7021.read()
  h = si7021.getHumidity()
  h = h/100
  t2 = si7021.getTemperature()
  t2 = t2/100
  t3 = ds18b20.read(address[1])
  -- Calc time
  minute = minute + 2
  if (minute == 60) then -- one hour
    minute = 0
    hour = hour + 1
  end

  print("T DS18B20#1: " .. string.format("%.1f", t1) .. " C")
  print("T Si7021: " .. string.format("%.1f", t2) .. " C")
  print("T DS18B20#2: " .. string.format("%.1f", t3) .. " C")
  print("P: " .. string.format("%.1f", p) .. " mmHg")
  print("Humi: " .. string.format("%.1f", h) .. " %")
  print(string.format("Hour: %s Minute: %02s", hour, minute))
  
  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  -- start connection section
  conn:on("connection",
    function(conn) print("TS connected")
      conn:send('GET /update?key=KEY***' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. string.format("%.1f", t3) ..
      '&field6=' .. string.format("%s.%02s", hour, minute) ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  -- end connection section
  conn:on("sent", function(conn)
    print("TS data sent")
    gpio.write(4, gpio.HIGH) -- LED off
--    conn:close()    -- You can disable this row for recieve thingspeak.com answer
  end)
  conn:on("receive", function(conn, payload)
--    print(payload)
    conn:close()
  end)
  conn:on("disconnection", function(conn) 
    print("TS disconnect") 
  end)
end

-- send data to thingspeak every 2 minute
tmr.register(2, 120000, tmr.ALARM_AUTO, function() send_ts() end)
