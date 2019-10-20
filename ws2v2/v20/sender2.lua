-- Weather station #2 By (R)soft 5.8.2018 v2.0
-- This example require modules 'i2c' & 'BME280' in the nodemcu-build.com
-- Testing on the binary nodemcu SDK 2.2.1
-- Two sensors on I2C bus: BMP280, Si7021
-- One DS18B20 sensor on 1-Wire bus
-- PIR sensor on interrupt pin D1

print("\nWeather Station Module #2 v2\n")
pir_pulse = 0
gpio.mode(1, gpio.INT) -- PIR sensor on D1 pin
-- interrupt function
gpio.trig(1, "up", function() -- D1
  pir_pulse = pir_pulse + 1
--  print ("pulses=".. pir_pulse)
  end)

si7021 = require("si7021")
require('ds18b20')

local sda = 6 -- sda pin, GPIO12
local scl = 5 -- scl pin, GPIO14
i2c.setup(0, sda, scl, i2c.SLOW)

page = 0 -- flag for OLED indication
-- setup LED pin (Indication of data send)
gpio.mode(4, gpio.OUTPUT) -- D4 LED onboard
gpio.write(4, gpio.HIGH) -- LED turn off

bme280.init(sda, scl) -- in v1 SDK
--bme280.setup() -- in v2 SDK
si7021.init(sda, scl)

ds18b20.setup(7) -- pin7 = D7 = DQ
t3 = ds18b20.read() -- dummy read
t3 = ds18b20.read()
t3 = ds18b20.read()

minute = 0
hour = 0 -- hours in use
flaghour = 1 -- set for first sending of hour=0

function sendData()
  pir_cnt = pir_pulse
  gpio.write(4, gpio.LOW) -- LED on
  t1 = bme280.temp()
  t1 = t1/100
  p = bme280.baro()
  p = p/1330.322365
  si7021.read()
  h = si7021.getHumidity()
  h = h/100
  t2 = si7021.getTemperature()
  t2 = t2/100
  t3 = ds18b20.read()
  -- Calc time
  minute = minute + 2
  if (minute == 60) then -- one hour
    minute = 0
    hour = hour + 1
    flaghour = 1 -- flag for sending one time per hour
  end
  -- close enduser_setup portal after 4 minutes
  if (minute == 4) and (hour == 0) then
    print("\n=== Portal closed ===\n")
    enduser_setup.stop()
    wifi.setmode(wifi.STATION)
  end
  print("Temperature BMP180: " .. string.format("%.1f", t1) .. " C")
  print("Temperature Si7021: " .. string.format("%.1f", t2) .. " C")
  print("Temperature DS18B20: " .. string.format("%.1f", t3) .. " C")
  print("Pressure: " .. string.format("%.1f", p) .. " mmHg")
  print("Humidity: " .. string.format("%.1f", h) .. " %")
  print("PIR counter: " .. pir_cnt .. " counts")
  print(string.format("Hour: %s Minute: %02s", hour, minute))
  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  -- start connection section
  if (flaghour==1) then -- hour value sending one time per hour
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=Z0ZFCZCNZZZBUREZ' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. string.format("%.1f", t3) ..
      '&field6=' .. hour ..
      '&field7=' .. pir_cnt ..
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
      conn:send('GET /update?key=Z0ZFCZCNZZZBUREZ' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. string.format("%.1f", t3) ..
      '&field7=' .. pir_cnt ..
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
    print("Data sent")
    gpio.write(4, gpio.HIGH) -- LED off
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
  end)
end

function invitation ()
  disp:firstPage()
  repeat
    disp:drawStr(8, 26, "WS #2" )
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
      disp:drawStr(0, 26, string.format("%.1f%cC %c", t1, 176, 185) )
      disp:drawStr(0, 56, string.format("%.1f%cC %c", t2, 176, 178) )
    until disp:nextPage() == false
  else page = 0
    h = si7021.getHumidity()
    h = h/100
    if (h>100) then h = 100 end
    if (h<0) then h = 0 end
    p = bme280.baro() -- read from BMP180
    p = p/1330.322365
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, string.format("%d%% %c", h, 178) )
      disp:drawStr(0, 56, string.format("%.1f %c", p, 179) )
      --disp:drawCircle(84, 30, 4)
    until disp:nextPage() == false
  end
end

invitation()
print("\nInvitation\n")
-- delay 1 sec for first send
tmr.delay(1000000)
print("Delay 1 sec")

-- send data every 2 minute to thing speak
tmr.alarm(2, 120000, 1, function() sendData() end )
-- every 3 sec call OLED function
tmr.alarm(0, 3000, 1, function() write_OLED() end )
