-- Weather station #3 By (R)soft 7-12-2021 v2.2
-- This example require modules 'i2c' & 'BME280' in the nodemcu-build.com
-- Testing on the binary nodemcu 1.5.4.1 (most stable)
-- Two sensors on I2C bus: BMP280, Si7021
-- Two sensors on 1-Wire bus: DS18B20

print("\nWeather Station Module #3 v2.2\n")

page = 0 -- for OLED indication
-- setup LED pin (Indication of data send)
gpio.mode(4, gpio.OUTPUT) -- D4 LED onboard
gpio.write(4, gpio.HIGH) -- LED turn off

require('ds18b20')
ds18b20.setup(7) -- pin7 = D7 = DQ
-- Search all sensors on OW bus & store to table of addresses DS18B20
address = ds18b20.addrs()
ds18b20.read(address[1]) -- dummy reads
ds18b20.read(address[2])
ds18b20.read(address[1])
ds18b20.read(address[2])

si7021 = require("si7021")
si7021.init(6,5)

minute = 0
hour = 0

bme280.init(6,5)

function sendData()
  t1 = ds18b20.read(address[2])
  t3 = ds18b20.read(address[1])
  p = bme280.baro()
  p = p/1330.322365
  si7021.read()
  h = si7021.getHumidity()
  h = h/100
  t2 = si7021.getTemperature()
  t2 = t2/100

  minute = minute + 2
  if (minute == 60) then
    minute = 0
    hour = hour + 1
  end
  -- close enduser_setup portal after n minutes
  if (minute == 6) and (hour == 0) then 
    print("\n=== Portal closed ===\n")
    enduser_setup.stop()
    wifi.setmode(wifi.STATION)
  end
  print("T DS18B20 #1: " .. string.format("%.1f", t1) .. " C")
  print("T Si7021 #2: " .. string.format("%.1f", t2) .. " C")
  print("T DS18B20 #3: " .. string.format("%.1f", t3) .. " C")
  print("P: " .. string.format("%.1f", p) .. " mmHg")
  print("Humi: " .. string.format("%.1f", h) .. " %")
  print(string.format("Hour: %s Minute: %02s", hour, minute))
  
  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  -- start connection section
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=A21828EJSXX6SSLB' ..
      '&field1=' .. string.format("%.1f", t1) ..
      '&field2=' .. string.format("%.1f", t2) ..
      '&field3=' .. string.format("%.1f", p) ..
      '&field4=' .. string.format("%.1f", h) ..
      '&field5=' .. string.format("%s.%02s", hour, minute) ..
      '&field7=' .. string.format("%.1f", t3) ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  -- end connection section

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

function invitation ()
  disp:firstPage()
  repeat
    disp:drawStr(18, 26, "WS #3" )
    disp:drawStr(0, 56, "v2.2 2021" )
  until disp:nextPage() == false
end

function write_OLED() -- Write Display
  si7021.read()
  if (page==0) then
    t1 = ds18b20.read(address[2])
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
    t3 = ds18b20.read(address[1])
    disp:firstPage()
    repeat
      disp:drawStr(0, 26, "HEAT" )
      disp:drawStr(0, 56, string.format("%.1f%cC", t3, 176) )
    until disp:nextPage() == false
  end
  if (page>3) then page = 0
              else page = page + 1
  end
end

invitation()
print("\nInvitation\n")

-- send data every 2 minute to thing speak
tmr.alarm(2, 120000, 1, function() sendData() end )
-- every 3 sec call OLED function
tmr.alarm(0, 3000, 1, function() write_OLED() end )
