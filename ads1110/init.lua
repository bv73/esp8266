-- ADS1110 ADC simple init & read v1.0
-- Li-Ion Battery Voltage Monitoring
-- Drop voltage between battery terminals & connectors is ~ 0.2 V
-- By (R)soft 2/12/2016
-- Config register:
--   7   6 5 4   3   2   1    0
-- STart 0 0 SC DR1 DR0 PGA1 PGA0
-- 0x8C by default (Data Rate 15 SPS, continuous conversion, Gain=1)
-- SC = 1 - single conversion; 0 - continuous conversion.
-- After power on just read ADC values

scl = 5
sda = 6

i2c.setup(id, sda, scl, i2c.SLOW)

-- 0x90 For ED0 slave address (0x48 without low bit)

function read_ads1110 ()
  i2c.start(0)
  a = i2c.address(0, 0x48, i2c.RECEIVER)
  if a ~= true then  print("Connection Error")  end
  b = i2c.read(0, 2) -- read two bytes
  i2c.stop(0)
  c = b:byte(1) * 256 + b:byte(2)
  return c
end

print(read_ads1110())

tmr.alarm(0, 5000, 1, function() 
  val = read_ads1110()
  print("---------------------")
  print("Raw code " .. val)
  u = val*1.279e-4
  print("Battery Voltage = " .. string.format("%.3f", u) .. " V")
end)
