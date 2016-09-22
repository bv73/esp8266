-- By (R)soft 22.09.2016 v1.2
-- This example require module 'i2c' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1

require('mpl3115a2')               

id = 0  -- Software I2C
sda = 6 -- sda pin, GPIO12
scl = 5 -- scl pin, GPIO14
mpl3115a2.init()

function sendData()
  p, t = mpl3115a2.read()
  p = p/133.3 -- Convert from Pa to mmHg

  print("Temperature:" .. string.format("%.3f", t) .. " C")
  print("Pressure:" .. string.format("%.3f", p) .. " mmHg")

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=API_KEY' ..
      '&field1=' .. string.format("%.3f", t) ..
      '&field2=' .. string.format("%.3f", p) ..
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
