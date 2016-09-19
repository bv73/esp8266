-- By (R)soft 19.09.2016 v1.0
-- Tested on nodemcu_float_0.9.6-dev_20150704.bin only!

SDA_PIN = 4 -- sda pin, GPIO2
SCL_PIN = 3 -- scl pin, GPIO0

ds3231 = require("ds3231")
ds3231.init(SDA_PIN, SCL_PIN)

tmr.alarm(0, 10000, 1, function()

--   ds3231.setTime(0,33,19,2,19,9,16)
   second, minute, hour, day, date, month, year = ds3231.getTime()

   print(string.format("Time & Date: %02s:%02s:%02s %02s/%02s/%s", hour, minute, second, date, month, year))

end)
