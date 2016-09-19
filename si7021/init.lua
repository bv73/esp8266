-- By (R)soft 19.09.2016 v1.0

tmr.alarm(0, 5000, 1, function()

   SDA_PIN = 6 -- sda pin, GPIO12
   SCL_PIN = 5 -- scl pin, GPIO14

   si7021 = require("si7021")
   si7021.init(SDA_PIN, SCL_PIN)
   si7021.read(OSS)
   h = si7021.getHumidity()
   t = si7021.getTemperature()

   -- pressure in differents units
   print("Humidity: "..(h / 100).." %")

   -- temperature in degrees Celsius  and Farenheit
   print("Temperature: "..(t/100).." C")
   print()

   -- release module
   si7021 = nil
   package.loaded["si7021"]=nil

end)
