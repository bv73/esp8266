-- By (R)soft 4.10.2016 v1.0
-- This example require modules 'bit' & '1-wire' in the nodemcu-build.com

pin = 5 -- pin5 = D5 (GPIO14)

require('ds18b20')
ds18b20.setup(pin)

tmr.alarm(0, 5000, 1, function()
  t = ds18b20.read()
  print("Temperature:" .. string.format("%.3f", t) .. " C")
end)
