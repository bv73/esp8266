-- By (R)soft 27.02.2017 v1.0
-- GPS module EB500 parsing $GPGLL line
-- Testing on the binary nodemcu 2.0.0
-- D7=GPIO13=RXD2 connected to TX0 of EB500 GPS module

latitude=0
longitude=0
uart.write(0, "GPS test")
tmr.delay(100)
uart.alt(1) -- D7=GPIO13=RXD2
--uart.setup(0, 115200, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0 ) -- 115200 bauds, 8 bits, no parity
print (uart.getconfig(0))
uart.on("data", "\n", function (data)
  if (string.sub(data, 1, 6) == "$GPGLL") then
    uart.alt(0) -- enable debug interface
    lat1 = tonumber(string.sub(data, 8, 9)) 
    lat2 = tonumber(string.sub(data, 10, 18)) / 60
    print("\n")
    if (string.sub(data, 20, 20) == "N") then latitude=lat1+lat2
    else latitude=0-lat1-lat2
    end
    long1 = tonumber(string.sub(data, 22, 24))
    long2 = tonumber(string.sub(data, 25, 33)) / 60
    if (string.sub(data, 35, 35) == "E") then longitude=long1+long2
    else longitude=0-long1-long2
    end
    h = tonumber(string.sub(data, 37, 38))
    m = tonumber(string.sub(data, 39, 40))
    s = tonumber(string.sub(data, 41, 42))
    if (string.sub(data, 48, 48) == "A") then print("Data valid") end
    print(latitude)
    print(longitude)
    print(h+2 .. ":" .. m .. ":" .. s) -- timezone = +02
    print("------")
    uart.alt(1) -- disable debug interface
  end
end, 0)

function sendData()
--  print("Latitude=" .. string.format("%.6f", latitude) .. "\n")
--  print("Longitude=" .. string.format("%.6f", longitude) .. "\n")

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'api.thingspeak.com')
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=API_KEY' ..
      '&field1=' .. string.format("%.6f", latitude) ..
      '&field2=' .. string.format("%.6f", longitude) ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  conn:on("sent",function(conn)
                    print("Data sent")
                    conn:close()    -- You can disable this row for recieve thingspeak.com answer
                 end)
  conn:on("receive",
     function(conn, payload)
       print(payload)
       conn:close()
     end)
  conn:on("disconnection", function(conn)
                              print("Disconnect")
                           end)
end

-- send data every X ms to thing speak
tmr.alarm(0, 60000, 1, function() sendData() end )
