-- By (R)soft 18.09.2016 v1.1
-- This example require modules 'bit' & '1-wire' in the nodemcu-build.com

pin = 5 -- pin5 = D5 (GPIO14)

require('ds18b20')
ds18b20.setup(pin)

function sendData()
  t=ds18b20.read()
  print("Temperature:" .. string.format("%.3f", t) .. " C\n")

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=API_KEY' ..
      '&field1=' .. string.format("%.3f", t) ..
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
  tmr.alarm(0, 20000, 1, function() sendData() end )
