-- By (R)soft 19.09.2016 v1.0
-- Tested on nodemcu_float_0.9.6-dev_20150704.bin only!

tmr.alarm(0, 5000, 1, function()

   SDA_PIN = 6 -- sda pin, GPIO12
   SCL_PIN = 5 -- scl pin, GPIO14

   bh1750 = require("bh1750")
   bh1750.init(SDA_PIN, SCL_PIN)
   bh1750.read(OSS)
   x = bh1750.getlux()

   print("Lux: " .. (x/100) .. " lx")

   -- release module
   bh1750 = nil
   package.loaded["bh1750"]=nil

end)
