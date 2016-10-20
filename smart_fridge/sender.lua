-- Smart Fridge
-- By (R)soft 18.10.2016 v1.0
-- This project require modules 'adc', 'bit' & '1-wire' in the nodemcu-build.com
-- Three DS18B20 sensors & ACS712-05 Current sensor
-- Testing on the binary nodemcu 1.5.4.1

pin = 7 -- pin7 = D7 = DQ

require('ds18b20')
ds18b20.setup(pin)
address = ds18b20.addrs() -- Table of addresses DS18B20

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
  if c < 9 then c = 0 end -- Отсечка дрожания нуля
  cur = c * 0.0128

  print("Temperature#3: " .. string.format("%.2f", t3) .. " C")
  print("Temperature#2: " .. string.format("%.2f", t2) .. " C")
  print("Temperature#1: " .. string.format("%.2f", t1) .. " C")
  print("Current: " .. string.format("%.2f", cur) .. " A")

  -- conection to thingspeak.com
  conn = net.createConnection(net.TCP, 0) 
  conn:connect (80,'184.106.153.149')
  conn:on("connection",
    function(conn) print("Connected")
      conn:send('GET /update?key=9L4MJ7SP5PRLR9HS' ..
      '&field1=' .. string.format("%.2f", t3) ..
      '&field2=' .. string.format("%.2f", t2) ..
      '&field3=' .. string.format("%.2f", t1) ..
      '&field4=' .. string.format("%.2f", cur) ..
      ' HTTP/1.1\r\n' ..
      'Host: api.thingspeak.com\r\n' ..
      'Accept: */*\r\n' ..
      'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
      '\r\n')
    end)
  conn:on("sent",function(conn)
                    print("Data sent")
                    conn:close()    -- You can disable this row for recieve thingspeak.com answer
                 end)
  conn:on("receive",
     function(conn, payload)
       print(payload)
       conn:close()
     end)
  conn:on("disconnection", function(conn)
                              print("Disconnect")
                           end)
end

  -- send data every X ms to thing speak
  tmr.alarm(0, 30000, 1, function() sendData() end )
