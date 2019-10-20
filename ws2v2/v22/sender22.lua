-- Weather station #2 By (R)soft 9.7.2019 v2.2
-- This example require modules i2c & BME280 & TSL2561
-- Three sensors on I2C bus: BMP280, Si7021, TSL2561
-- Two DS18B20 sensors on 1-Wire bus
-- PIR sensor on interrupt pin D1

print("\nWeather Station Module #2 v2.2\n")
pir_pulse = 0
gpio.mode(1, gpio.INT) -- PIR sensor on D1 pin
-- interrupt function
gpio.trig(1, "up", function() -- D1
  pir_pulse = pir_pulse + 1
--  print ("pulses=".. pir_pulse)
  end)

si7021 = require("si7021")
require('ds18b20')

i2c.setup(0, 6, 5, i2c.SLOW)

page = 0 -- flag for OLED indication
-- setup LED pin (Indication of data send)
gpio.mode(4, gpio.OUTPUT) -- D4 LED onboard
gpio.write(4, gpio.HIGH) -- LED turn off

bme280.init(6, 5) -- in v1 SDK
si7021.init(6, 5)
status = tsl2561.init(6, 5, tsl2561.ADDRESS_FLOAT, tsl2561.PACKAGE_T_FN_CL)
tsl2561.settiming(tsl2561.INTEGRATIONTIME_402MS, tsl2561.GAIN_16X)

ds18b20.setup(7) -- pin7 = D7 = DQ
-- Search all sensors on OW bus & store to table of addresses DS18B20
address = ds18b20.addrs()
ds18b20.read(address[1]) -- dummy reads after first power on
ds18b20.read(address[2])
ds18b20.read(address[1])
ds18b20.read(address[2])
ds18b20.read(address[1])
ds18b20.read(address[2])

minute = 0
hour = 0 -- hours in use
flaghour = 1 -- set for first sending of hour=0

function sendData()
  pir_cnt = pir_pulse
  gpio.write(4, gpio.LOW) -- LED on
  t1 = ds18b20.read(address[1])
  t3 = ds18b20.read(address[2])
  p = bme280.baro()
  p = p/1330.322365
  si7021.read()
  h = si7021.getHumidity()
  h = h/100
  t2 = si7021.getTemperature()
  t2 = t2/100
  x = tsl2561.getlux()
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
  print("Temperature DS18B20 #1: " .. string.format("%.1f", t1) .. " C")
  print("Temperature Si7021: " .. string.format("%.1f", t2) .. " C")
  print("Temperature DS18B20 #2: " .. string.format("%.1f", t3) .. " C")
  print("Pressure: " .. string.format("%.1f", p) .. " mmHg")
  print("Humidity: " .. string.format("%.1f", h) .. " %")
  print("PIR counter: " .. pir_cnt .. " counts")
  print("Illuminance: " .. x .. " lx")
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
      '&field8=' .. x ..
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
      '&field8=' .. x ..
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
    disp:drawStr(0, 56, "v2.2 2019" )
  until disp:nextPage() == false
end

function write_OLED() -- Write Display
  si7021.read()
  if (page==0) then
    t1 = ds18b20.read(address[1])
    t2 = si7021.getTemperature()
    t2 = t2/100
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, string.format("%.1f%cC", t1, 176) )
      disp:drawStr(0, 56, string.format("%.1f%cC", t2, 176) )
    until disp:nextPage() == false
  end
  if (page==1) then
    h = si7021.getHumidity()
    h = h/100
    if (h>100) then h = 100 end
    if (h<0) then h = 0 end
    p = bme280.baro() -- read from BMP180
    p = p/1330.322365
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, string.format("%d%%", h) )
      disp:drawStr(0, 56, string.format("%.1f", p) )
      --disp:drawCircle(84, 30, 4)
    until disp:nextPage() == false
  end
  if (page==3) then
    t3 = ds18b20.read(address[2])
    x = tsl2561.getlux()
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, string.format("Lx:%d", x) )
      disp:drawStr(0, 56, string.format("%.1f%cC", t3, 176) )
    until disp:nextPage() == false
  end
  if (page>3) then page = 0
              else page = page + 1
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
