-- By (R)soft 12.10.2016 v1.0
-- This example require modules 'bit' & '1-wire' in the nodemcu-build.com
-- Two or more sensors

pin = 5 -- pin5 = D5 (GPIO14)

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
end)
