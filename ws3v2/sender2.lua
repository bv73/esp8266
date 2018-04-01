-- Weather station #3 By (R)soft 30.3.2018 v2.0
-- This example require modules 'i2c' & 'BME280' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1 (most stable)
-- Two sensors on I2C bus: BMP280, Si7021
-- One sensor on 1-Wire bus: DS18B20
-- PIR sensor on interrupt pin D1

print("\nWeather Station Module #3 v2\n")

pir_pulse = 0
gpio.mode(1, gpio.INT) -- PIR sensor on D1 pin
-- interrupt function
gpio.trig(1, "up", function() -- D1
  pir_pulse = pir_pulse + 1
--  print ("pulses=".. pir_pulse)
  end)

page = 0 -- flag for OLED indication
-- setup LED pin (Indication of data send)
gpio.mode(4, gpio.OUTPUT) -- D4 LED onboard
gpio.write(4, gpio.HIGH) -- LED turn off

require('ds18b20')
ds18b20.setup(7) -- pin7 = D7 = DQ

local sda_pin, scl_pin = 6, 5
si7021 = require("si7021")
si7021.init(sda_pin, scl_pin)

t1 = ds18b20.read() -- dummy reads after first power on
t1 = ds18b20.read()
t1 = ds18b20.read()

minute = 0
hour = 0 -- hours in use
flaghour = 1 -- set for first sending of hour=0

bme280.init(sda_pin, scl_pin)

function sendData()
  pir_counter = pir_pulse
  t1 = ds18b20.read()
  p = bme280.baro()
  p = p/1330.322365
  si7021.read()
  h = si7021.getHumidity()
  h = h/100
  t2 = si7021.getTemperature()
  t2 = t2/100

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
  print("Humidity: " .. string.format("%.1f", h) .. " %")
  print("PIR counter: " .. pir_counter .. " counts")
  print(string.format("Hour: %s Minute: %02s", hour, minute))
  
  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  -- start connection section
  if (flaghour==1) then -- hour value sending one time per hour
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=WRITE_API_KEY' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. hour ..
      '&field6=' .. pir_counter ..
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
      conn:send('GET /update?key=WRITE_API_KEY' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field6=' .. pir_counter ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  end -- end of if
  pir_pulse = 0
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
--  tmr.delay(1000000)
  print("Delay 1 sec")
end

function invitation ()
  disp:firstPage()
  repeat
    disp:drawStr(8, 26, "WS #3" )
    disp:drawStr(0, 56, "v2 2018" )
  until disp:nextPage() == false
end

function write_OLED() -- Write Display
  si7021.read()
  if (page==0) then page = 1
    t1 = ds18b20.read()
    t2 = si7021.getTemperature()
    t2 = t2/100
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, string.format("%.1f", t1) )
      disp:drawStr(0, 56, string.format("%.1f", t2) )
    until disp:nextPage() == false
  else page = 0
    h = si7021.getHumidity()
    h = h/100
    p = bme280.baro()
    p = p/1330.322365
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, string.format("%02d%%", h) )
      disp:drawStr(0, 56, string.format("%.1f", p) )
      --disp:drawCircle(84, 30, 4)
    until disp:nextPage() == false
  end
end

invitation()
print("\nInvitation\n")
-- delay for first send 10 sec
for z=1, 10 do
--  tmr.delay(1000000)
  print("Delay 1 sec")
end

-- send data every 1 minute to thing speak
tmr.alarm(2, 60000, 1, function() sendData() end )
-- every 3 sec call OLED function
tmr.alarm(0, 3000, 1, function() write_OLED() end )
