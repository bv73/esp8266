-- Weather station 003 By (R)soft 3.11.2016 v1.0
-- This example require modules 'i2c' & 'BME280' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1
-- One sensor on I2C bus: BME280
-- Two sensors on 1-Wire bus: DS18B20
-- v1.1 at 30.11.2016 Add use in hour
-- v1.2 at 29.12.2016 Add second DS18B20 after halfdead of BME280
-- v1.3 21/01/2017 close enduser_setup portal & delay to first send
print("\nWeather Station Module #3\n")
scl = 5 -- scl pin, D5=GPIO14
sda = 6 -- sda pin, D6=GPIO12

-- setup LED pin (Indication of data send)
gpio.mode(4, gpio.OUTPUT) -- D4 LED onboard
gpio.write(4, gpio.HIGH) -- LED turn off

require('ds18b20')
ds18b20.setup(7) -- pin7 = D7 = DQ
-- Search all sensors on OW bus & store to table of addresses DS18B20
address = ds18b20.addrs()
t1 = ds18b20.read(address[1]) -- dummy reads after first power on
t2 = ds18b20.read(address[2])
t1 = ds18b20.read(address[1])
t2 = ds18b20.read(address[2])
t1 = ds18b20.read(address[1])
t2 = ds18b20.read(address[2])

minute = 0
hour = 0 -- hours in use
flaghour = 1 -- set for first sending of hour=0

bme280.init(sda, scl)

function sendData()
  t1 = ds18b20.read(address[1])
  t2 = ds18b20.read(address[2])
  p = bme280.baro()
  p = p/1330.322365
--  h, t2 = bme280.humi()
--  if (h == nil) then h = 1000 end
--  if (t2 == nil) then t2 = 100 end
--  h = h/1000
--  t2 = t2/100
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
  print("Temperature #1: " .. string.format("%.1f", t1) .. " C")
  print("Temperature #2: " .. string.format("%.1f", t2) .. " C")  
  print("Pressure: " .. string.format("%.1f", p) .. " mmHg")
--  print("Humidity: " .. string.format("%.1f", h) .. " %")
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
--      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. hour ..      
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
--      '&field4=' .. string.format("%.1f", h) ..
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
-- delay 6 sec for first send
for z=1, 6 do
  tmr.delay(1000000)
  print("Delay 1 sec")
end
-- send data every 1 minute to thing speak
tmr.alarm(0, 60000, 1, function() sendData() end )
