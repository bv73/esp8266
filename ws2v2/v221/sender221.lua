-- Weather station #2 By (R)soft 4.10.2019 v2.21
-- Require modules i2c & BME280 & TSL2561
-- Three sensors on I2C bus: BMP280, Si7021, TSL2561
-- Two DS18B20 sensors on 1-Wire bus
-- PIR sensor on interrupt pin D1
print("\nWeather Station Module #2 v2.21\n")
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
tsl2561.init(6, 5)

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
  ch0, ch1 = tsl2561.getrawchannels()
  -- Calc time
  minute = minute + 2
  if (minute == 60) then
    minute = 0
    hour = hour + 1
  end
  -- close enduser_setup portal after 4 minutes
  if (minute == 4) and (hour == 0) then
    print("\n= Portal closed =\n")
    enduser_setup.stop()
    wifi.setmode(wifi.STATION)
  end
  print("T DS18B20 #1: " .. string.format("%.1f", t1) .. " C")
  print("T Si7021: " .. string.format("%.1f", t2) .. " C")
  print("T DS18B20 #2: " .. string.format("%.1f", t3) .. " C")
  print("P: " .. string.format("%.1f", p) .. " mmHg")
  print("Humi: " .. string.format("%.1f", h) .. " %")
  print("PIR cnt: " .. pir_cnt )
  print("Illuminance: " .. x .. " lx")
  print("Broad spectrum & IR:" .. ch0, ch1)
  print(string.format("Hour: %s Minute: %02s", hour, minute))
  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  -- start connection section
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=Z0ZFCZCNZZZBUREZ' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. string.format("%.1f", t3) ..
      '&field6=' .. string.format("%s.%02s", hour, minute) ..
      '&field7=' .. pir_cnt ..
      '&field8=' .. ch0 ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  -- end connection section
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
      disp:drawStr(0, 26, string.format("o:%.1f%cC", t1, 176) )
      disp:drawStr(0, 56, string.format("i:%.1f%cC", t2, 176) )
    until disp:nextPage() == false
  end
  if (page==1) then
    h = si7021.getHumidity()
    h = h/100
    if (h>100) then h = 100 end
    if (h<0) then h = 0 end
    p = bme280.baro()
    p = p/1330.322365
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, string.format("Hm:%d%%", h) )
      disp:drawStr(0, 56, string.format("P:%.1f", p) )
    until disp:nextPage() == false
  end
  if (page==3) then
    t3 = ds18b20.read(address[2])
    ch0, ch1 = tsl2561.getrawchannels()
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, string.format("BS:%d", ch0) )
      disp:drawStr(0, 56, string.format("h:%.1f%cC", t3, 176) )
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
