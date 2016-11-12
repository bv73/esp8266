-- Weather station 001 By (R)soft 1.11.2016 v1.0
-- This example require modules 'i2c' & 'BMP085' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1
-- Two sensors on I2C bus: BMP180, Si7021

si7021 = require("si7021")

oss = 1
sda = 6 -- sda pin, GPIO12
scl = 5 -- scl pin, GPIO14

-- setup LED pin (Indication of data send)
led = 4 -- D4 LED onboard
gpio.mode(led, gpio.OUTPUT)
gpio.write(led, gpio.HIGH) -- LED turn off

bmp085.init(sda, scl)
si7021.init(sda, scl)

function sendData()
  t1 = bmp085.temperature()
  t1 = t1/10
  p = bmp085.pressure(oss)
  p = p/133.3
  si7021.read()
  h = si7021.getHumidity()
  h = h/100
  t2 = si7021.getTemperature()
  t2 = t2/100

  print("Temperature inside #1: " .. string.format("%.1f", t1) .. " C")
  print("Temperature outside #2: " .. string.format("%.1f", t2) .. " C")  
  print("Pressure: " .. string.format("%.1f", p) .. " mmHg")
  print("Humidity: " .. string.format("%.1f", h) .. " %")

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=API_KEY' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field4=' .. string.format("%.1f", t2) ..
      '&field5=' .. string.format("%.1f", p) ..
      '&field6=' .. string.format("%.1f", h) ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  conn:on("sent",
  function(conn)
    -- Indication of data send
    gpio.write(led, gpio.LOW) -- LED on
    print("Data sent")
    conn:close()    -- You can disable this row for recieve thingspeak.com answer
  end)
  conn:on("receive",
  function(conn, payload)
    print(payload)
    conn:close()
  end)
  conn:on("disconnection", 
  function(conn)
    print("Disconnect")
    gpio.write(led, gpio.HIGH) -- LED off
  end)
end

  -- send data every 1 minute to thing speak
  tmr.alarm(0, 60000, 1, function() sendData() end )
