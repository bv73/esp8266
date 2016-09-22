-- By (R)soft 22.09.2016 v1.0
-- This example require modules 'i2c' & 'BMP085' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1
-- Four sensors on I2C bus: MPL3115A2, BMP180, Si7021, BH1750

require('mpl3115a2')
si7021 = require("si7021")
bh1750 = require("bh1750")

oss = 1
id = 0  -- Software I2C
sda = 6 -- sda pin, GPIO12
scl = 5 -- scl pin, GPIO14
mpl3115a2.init()
bmp085.init(sda, scl)
si7021.init(sda, scl)
bh1750.init(sda, scl)

function sendData()
  p1, t1 = mpl3115a2.read()
  p1 = p1/133.3 -- Convert from Pa to mmHg
  t2 = bmp085.temperature()
  t2 = t2/10
  p2 = bmp085.pressure(oss)
  p2 = p2/133.3
  si7021.read()
  h = si7021.getHumidity()
  t3 = si7021.getTemperature()
  h = h/100
  t3 = t3/100
  bh1750.read()
  x = bh1750.getlux()
  x = x/100

  print("Temperature#1:" .. string.format("%.1f", t1) .. " C")
  print("Temperature#2:" .. string.format("%.1f", t2) .. " C")  
  print("Temperature#3:" .. string.format("%.1f", t3) .. " C")
  print("Pressure#1:" .. string.format("%.1f", p1) .. " mmHg")
  print("Pressure#2:" .. string.format("%.1f", p2) .. " mmHg")
  print("Humidity:" .. string.format("%.1f", h) .. " %")
  print("Luminance:" .. string.format("%.1f", x) .. " lx")

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=API_KEY' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", p1) ..
      '&field3=' .. string.format("%.1f", t2) ..
      '&field4=' .. string.format("%.1f", p2) ..
      '&field5=' .. string.format("%.1f", t3) ..
      '&field6=' .. string.format("%.1f", h) ..
      '&field7=' .. string.format("%.1f", x) ..
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
