-- By (R)soft 20.09.2016 v1.1
-- Module 'bmp085' compatible with BMP180 sensor
-- This example require modules 'bmp085' & 'i2c' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1

OSS = 1 -- oversampling setting (0...3)
SDA_PIN = 6 -- sda pin, GPIO12
SCL_PIN = 5 -- scl pin, GPIO14


bmp085.init(SDA_PIN, SCL_PIN)

function sendData()
  t = bmp085.temperature()
  t = t/10
  p = bmp085.pressure(OSS)
  p = p/133.3

  print("Temperature:" .. string.format("%.3f", t) .. " C\n")
  print("Pressure:" .. string.format("%.3f", p) .. " mmHg\n")

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=80AFCACNYJ7AUREP' ..
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
  tmr.alarm(0, 20000, 1, function() sendData() end )
