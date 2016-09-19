-- By (R)soft 19.09.2016 v1.0
-- Tested on nodemcu_float_0.9.6-dev_20150704.bin only!

tmr.alarm(0, 5000, 1, function()

   OSS = 1 -- oversampling setting (0-3)
   SDA_PIN = 6 -- sda pin, GPIO12
   SCL_PIN = 5 -- scl pin, GPIO14

   bmp180 = require("bmp180")
   bmp180.init(SDA_PIN, SCL_PIN)
   bmp180.read(OSS)
   t = bmp180.getTemperature()
   p = bmp180.getPressure()

   -- temperature in degrees Celsius  and Farenheit
   print("Temperature: "..(t/10).." C")

   -- pressure in differents units
   print("Pressure: "..(p * 75 / 10000).." mmHg")
   print()

   -- release module
   bmp180 = nil
   package.loaded["bmp180"]=nil

end)
