-- By (R)soft 28.02.2017 v1.2
-- v1.1 fix panic error when GPS not connected to satellites
-- v1.2 TLS connection & some code optimization
-- GPS module EB500 parsing $GPRMC line
-- Testing on the binary nodemcu 2.0.0
-- D7=GPIO13=RXD2 connected to TX0 of EB500 GPS module

buf=""
street=""
key="AIzaSAT2UNyLQ_r4Drw4W4McqQB-KDdswY"
gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.HIGH) -- LED turn off
latitude=0
longitude=0
uart.write(0, "GPS test\n")
tmr.delay(1000)
uart.alt(1) -- switch to D7=GPIO13=RXD2
uart.on("data", "\n", function (data)
  if ( string.sub(data, 1, 6) == "$GPRMC" and
  string.sub(data, 19, 19) == "A" ) then
    uart.alt(0) -- enable debug interface
    tmp = tonumber(string.sub(data, 21, 22)) +
          tonumber(string.sub(data, 23, 31)) / 60
    print("\n")
    if (string.sub(data, 33, 33) == "N") then latitude=tmp
    else latitude=0-tmp end
    tmp = tonumber(string.sub(data, 35, 37)) +
          tonumber(string.sub(data, 38, 46)) / 60
    if (string.sub(data, 48, 48) == "E") then longitude=tmp
    else longitude=0-tmp end
    h = tonumber(string.sub(data, 8, 9))
    m = tonumber(string.sub(data, 10, 11))
    s = tonumber(string.sub(data, 12, 13))
    speed = tonumber(string.sub(data, 50, 53))
    speed = speed * 1.852 -- convert to km/h
    n=0
    course = tonumber(string.sub(data, 55, 60))
    if (course == nil) then n=1
      course = tonumber(string.sub(data, 55, 59))
      if (course == nil) then n=2
        course = tonumber(string.sub(data, 55, 58))
      end
    end
    day = tonumber(string.sub(data, 62-n, 63-n))
    month = tonumber(string.sub(data, 64-n, 65-n))
    year = tonumber(string.sub(data, 66-n, 67-n))
--    if (string.sub(data, 19, 19) == "A") then print("Data valid") end
    print("Street=" .. street)
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
  -- conection to maps.googleapis.com
  gpio.write(4, gpio.LOW) -- LED on
  conn = net.createConnection(net.TCP, 1) -- TLS connection
  conn:connect (443,'maps.googleapis.com') -- port 443 for TLS
  conn:on("connection",
    function(conn)
      conn:send('GET /maps/api/geocode/json?' ..
      'latlng=' .. string.format("%.8f", latitude) ..
      ',' .. string.format("%.8f", longitude) ..
      '&result_type=street_address' ..
      '&key=' .. key ..
      ' HTTP/1.1\r\n' ..
      'Host: maps.googleapis.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  conn:on("sent", function(conn)
  end)
  conn:on("receive", function(conn, payload)
    a = string.find(payload, "\r\n\r\n")
    if (a < 1000) then 
      b = string.find(payload, "{", a) -- find first {
      b = string.find(payload, "{", b+1) -- find second {
      buf = buf .. string.sub(payload, b)
    else 
      b = string.find(payload, "street_address", a-85)
      b = string.find(payload, "}", b+1)
      buf = buf .. string.sub(payload, 1, b)
      t = cjson.decode(buf)
      street = t.formatted_address
      gpio.write(4, gpio.HIGH) -- LED off
    end
  end)
--  conn:on("disconnection", function(conn)
--     print("Disconnect")
--  end)
end

-- send data every X ms to thing speak
tmr.alarm(0, 5000, 1, function() sendData() end )
