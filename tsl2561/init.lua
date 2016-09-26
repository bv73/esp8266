-- By (R)soft 26.09.2016 v1.0
-- Tested with NodeMCU 1.5.4.1

sda = 6
scl = 5

status = tsl2561.init(sda, scl, tsl2561.ADDRESS_FLOAT, tsl2561.PACKAGE_T_FN_CL)
tsl2561.settiming(tsl2561.INTEGRATIONTIME_402MS, tsl2561.GAIN_16X)

tmr.alarm(0, 5000, 1, function()
  ch0, ch1 = tsl2561.getrawchannels()
  print("Raw values: "..ch0, ch1)
  x = tsl2561.getlux()
  print("Luminance: " .. x .. " lx")
end)
