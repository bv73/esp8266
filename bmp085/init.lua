-- By (R)soft 19.09.2016 v1.0
-- Tested on nodemcu_float_1.5.4.1 only!
-- Tested with BMP180 sensor

tmr.alarm(0, 5000, 1, function()

   OSS = 1 -- oversampling setting (0...3)
   SDA_PIN = 6 -- sda pin, GPIO12
   SCL_PIN = 5 -- scl pin, GPIO14

   bmp085.init(SDA_PIN, SCL_PIN)

   t = bmp085.temperature()
   p = bmp085.pressure(OSS)

   -- temperature & remperature
   print("Temperature: "..(t/10).." C")
   print("Pressure: "..(p * 75 / 10000).." mmHg")
   print()

end)
