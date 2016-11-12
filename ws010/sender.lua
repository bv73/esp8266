-- Weather station 010 By (R)soft 3.11.2016 v1.0
-- This example require modules 'i2c' & 'BME280' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1
-- One sensor on I2C bus: BME280
-- One sensor on 1-Wire bus: DS18B20

scl = 5 -- scl pin, GPIO14
sda = 6 -- sda pin, GPIO12
dq = 7 -- pin7 = D7 = DQ

-- setup LED pin (Indication of data send)
led = 4 -- D4 LED onboard
gpio.mode(led, gpio.OUTPUT)
gpio.write(led, gpio.HIGH) -- LED turn off

require('ds18b20')
ds18b20.setup(dq)
t1 = ds18b20.read() -- dummy read
t1 = ds18b20.read()
t1 = ds18b20.read()

bme280.init(sda, scl)

function sendData()
  t1 = ds18b20.read()
  p = bme280.baro()
  p = p/1330.322365
  h, t2 = bme280.humi()
  h = h/1000
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
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
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
