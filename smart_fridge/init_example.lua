-- Smart Fridge
-- By (R)soft 18.10.2016 v1.0
-- This project require modules 'adc', 'bit' & '1-wire' in the nodemcu-build.com
-- Two DS18B20 sensors & ACS712-05 Current sensor

pin = 7 -- pin7 = D7 = DQ

require('ds18b20')
ds18b20.setup(pin)

address = ds18b20.addrs() -- Table of addresses
if (address ~= nil) then n = table.getn(address)
                    else n = 0
end

uart.write(0, "Total DS18B20 sensors: " .. n .. "\n")

if (n ~= 0) then
  for i=1, n do 
    uart.write(0, "Addr #" .. i .. ": ")
    for b=1, 8 do
      uart.write(0, string.format("%X", string.byte(address[i], b)) )
    end
    uart.write(0, "\n")
  end
end

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

t = {} -- Объявление массива

tmr.alarm(0, 5000, 1, function()
  if (n ~= 0) then
    for i=1, n do 
      t[i] = ds18b20.read(address[i])
      uart.write(0, "Temperature #" .. i .. ": ")
      uart.write(0, string.format("%.3f", t[i]) .. " C\n")
    end
  else uart.write(0, "No sensors found!\n")
  end
  c = getCurrent()
  c = (c - 694) -- minus zero point
  if c < 0 then c = 0 end
  cur = c * 0.0128
  uart.write(0, string.format("Current: %.2f", cur) .. " A\n")

end)
