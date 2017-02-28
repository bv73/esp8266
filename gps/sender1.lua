-- By (R)soft 28.02.2017 v1.0
-- GPS module EB500 parsing $GPRMC line
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
  if (string.sub(data, 1, 6) == "$GPRMC") then
      uart.alt(0) -- enable debug interface
      lat1 = tonumber(string.sub(data, 21, 22)) 
      lat2 = tonumber(string.sub(data, 23, 31)) / 60
      print("\n")
      if (string.sub(data, 33, 33) == "N") then latitude=lat1+lat2
      else latitude=0-lat1-lat2
      end
      long1 = tonumber(string.sub(data, 35, 37))
      long2 = tonumber(string.sub(data, 38, 46)) / 60
      if (string.sub(data, 48, 48) == "E") then longitude=long1+long2
      else longitude=0-long1-long2
      end
      h = tonumber(string.sub(data, 8, 9))
      m = tonumber(string.sub(data, 10, 11))
      s = tonumber(string.sub(data, 12, 13))
      speed = tonumber(string.sub(data, 50, 53))
      speed = speed * 1.852 -- convert to km/h
      n=0
      course = tonumber(string.sub(data, 55, 60))
      if (course == nil) then
        n=1
        course = tonumber(string.sub(data, 55, 59))
        if (course == nil) then
          n=2
          course = tonumber(string.sub(data, 55, 58))
        end
      end
      day = tonumber(string.sub(data, 62-n, 63-n))
      month = tonumber(string.sub(data, 64-n, 65-n))
      year = tonumber(string.sub(data, 66-n, 67-n))
      if (string.sub(data, 19, 19) == "A") then print("Data valid") end
      print("Latitude=" .. latitude)
      print("Longitude=" .. longitude)
      print("Speed=" .. speed .. " km/h")
      print("Course=" .. course)
      print("Date:" .. day .. "." .. month .. "." .. 2000+year)
      print("Time:" .. h+2 .. ":" .. m .. ":" .. s) -- timezone = +02
      print("------")
      uart.alt(1) -- disable debug interface
  end
end, 0)

function sendData()
--  print("Latitude=" .. string.format("%.8f", latitude) .. "\n")
--  print("Longitude=" .. string.format("%.8f", longitude) .. "\n")

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'api.thingspeak.com')
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=API_KEY' ..
      '&field1=' .. string.format("%.8f", latitude) ..
      '&field2=' .. string.format("%.8f", longitude) ..
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
