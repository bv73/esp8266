-- Weather station #1 By (R)soft 1.11.2016 v1.0
-- This example require modules 'i2c' & 'BMP085' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1
-- Two sensors on I2C bus: BMP180, Si7021
-- One DS18B20 sensor on 1-Wire bus
-- v1.1 2/12/2016  add use in hours function
-- v1.2 21/01/2017 close enduser_setup portal & delay to first send
print("\nWeather Station Module #1\n")
si7021 = require("si7021")
require('ds18b20')

oss = 1
sda = 6 -- sda pin, GPIO12
scl = 5 -- scl pin, GPIO14

-- setup LED pin (Indication of data send)
gpio.mode(4, gpio.OUTPUT) -- D4 LED onboard
gpio.write(4, gpio.HIGH) -- LED turn off

bmp085.init(sda, scl)
si7021.init(sda, scl)

ds18b20.setup(7) -- pin7 = D7 = DQ
t3 = ds18b20.read() -- dummy read
t3 = ds18b20.read()
t3 = ds18b20.read()

minute = 0
hour = 0 -- hours in use
flaghour = 1 -- set for first sending of hour=0

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
  t3 = ds18b20.read()
  -- Calc time
  minute = minute + 1
  if (minute == 60) then -- one hour
    minute = 0
    hour = hour + 1
    flaghour = 1 -- flag for sending one time per hour
  end
  -- close enduser_setup portal after 5 minutes
  if (minute == 5) and (hour == 0) then
    print("\n=== Portal closed ===\n")
    enduser_setup.stop()
    wifi.setmode(wifi.STATION)
  end
  print("Temperature BMP180: " .. string.format("%.1f", t1) .. " C")
  print("Temperature outside: " .. string.format("%.1f", t2) .. " C")
  print("Temperature DS18B20: " .. string.format("%.1f", t3) .. " C")
  print("Pressure: " .. string.format("%.1f", p) .. " mmHg")
  print("Humidity: " .. string.format("%.1f", h) .. " %")
  print(string.format("Hour: %s Minute: %02s", hour, minute))
  
  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  -- start connection section
  if (flaghour==1) then -- hour value sending one time per hour
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=API_KEY' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. string.format("%.1f", t3) ..
      '&field6=' .. hour ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  flaghour = 0 -- reset flaghour after sending
  -- end connection section
  else
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=API_KEY' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. string.format("%.1f", t3) ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  end -- end of if    
  conn:on("sent",
  function(conn)
    -- Indication of data send
    gpio.write(4, gpio.LOW) -- LED on
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
    gpio.write(4, gpio.HIGH) -- LED off
  end)
end
-- delay 1 sec for first send
tmr.delay(1000000)
print("Delay 1 sec")
-- send data every 1 minute to thing speak
tmr.alarm(0, 60000, 1, function() sendData() end )
