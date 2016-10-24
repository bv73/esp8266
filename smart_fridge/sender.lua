-- Smart Fridge
-- By (R)soft 18.10.2016 v1.0
-- This project require modules 'adc', 'bit', 'user_setup' 
--   & '1-wire' in the nodemcu-build.com
-- Three DS18B20 sensors & ACS712-05 Current sensor
-- Testing on the binary nodemcu 1.5.4.1

half = 0
minute = 0
hour = 0
day = 0
wh = 0 -- Power: Watt * hour
wd = 0 -- Power: Watt * day
summ = 0 -- summa for watt*hour counter

pin = 7 -- pin7 = D7 = DQ

-- setup LED pin (Indication of data send)
led = 4 -- D4 LED onboard
gpio.mode(led, gpio.OUTPUT)
gpio.write(led, gpio.HIGH) -- LED turn off

require('ds18b20')
ds18b20.setup(pin)
-- Search all sensors on OW bus & store to table of addresses DS18B20
address = ds18b20.addrs()

-- search maximum from sinewave signal
function getCurrent()
  max = 0
  min = 1024
  for z=1, 1000 do -- 1k samples
    val = adc.read(0)
    if (val > max) then max = val end
    if (val < min) then min = val end
  end
  return max
end

function sendData()

  t1 = ds18b20.read(address[1])
  t2 = ds18b20.read(address[2])
  t3 = ds18b20.read(address[3])
  c = getCurrent()
  c = (c - 694) -- minus zero point
  print("Debug zero point=" .. c) -- debug info
  if c < 7 then c = 0 end -- Отсечка дрожания нуля
  cur = c * 0.0128 -- line function of current
  p = cur * 220 -- Power [Watt]

  half = half + 1
  summ = summ + p
  if (half == 2) then 
    half = 0 
    minute = minute + 1
    if (minute == 60) then -- one hour
      minute = 0
      wh = summ / 120 -- two samples per minute
      wd = wd + wh -- add per hour
      summ = 0
      hour = hour + 1
      if (hour == 24) then -- one day
        hour = 0
        day = day + 1
        wd = 0
      end
    end
  end

  print("Temperature#3: " .. string.format("%.1f", t3) .. " C")
  print("Temperature#2: " .. string.format("%.1f", t2) .. " C")
  print("Temperature#1: " .. string.format("%.1f", t1) .. " C")
  print("Current: " .. string.format("%.2f", cur) .. " A")
  print("Power: " .. string.format("%.1f", p) .. " W")
  print("Watt*Hour: " .. string.format("%.1f", wh) .. " Wh")
  print("Power per Day: " .. string.format("%.1f", wd) .. " Wh")
  print(string.format("Hour: %02s Minute: %02s Day: %02s", hour, minute, day))

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  conn:on("connection",
  function(conn) 
    print("Connected")
    conn:send('GET /update?key=9L4MJ7SP5PRLR9HS' ..
    '&field1=' .. string.format("%.1f", t3) ..
    '&field2=' .. string.format("%.1f", t2) ..
    '&field3=' .. string.format("%.1f", t1) ..
    '&field4=' .. string.format("%.2f", cur) ..
    '&field5=' .. string.format("%.1f", p) ..
    '&field6=' .. string.format("%.1f", wh) ..
    '&field7=' .. string.format("%.1f", wd) ..
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

  -- send data every 30 s to thing speak
  tmr.alarm(0, 30000, 1, function() sendData() end )
