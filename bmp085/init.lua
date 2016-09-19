-- By (R)soft 19.09.2016 v1.0
-- Tested on nodemcu_float_0.9.6-dev_20150704.bin only!
-- Tested with BMP180 sensor

tmr.alarm(0, 5000, 1, function()

   OSS = 1 -- oversampling setting (0-3)
   SDA_PIN = 6 -- sda pin, GPIO12
   SCL_PIN = 5 -- scl pin, GPIO14

   bmp085 = require("bmp085")
   bmp085.init(SDA_PIN, SCL_PIN)
--   bmp085.read(OSS)
   t = bmp085.getTemperature(true)
   p = bmp085.getPressure(OSS)

   -- temperature & remperature
   print("Temperature: "..(t/10).." C")
   print("Pressure: "..(p * 75 / 10000).." mmHg")
   print()

   -- release module
   bmp085 = nil
   package.loaded["bmp085"]=nil

end)
