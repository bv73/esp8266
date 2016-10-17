-- By (R)soft 17.10.2016 v1.0
-- Tested on nodemcu float SDK 1.5.4.1
-- This example require modules 'bme280' & 'i2c' in the nodemcu-build.com

SCL_PIN = 5 -- scl pin, GPIO14
SDA_PIN = 6 -- sda pin, GPIO12
alt = 80 -- altitude of measurement place


bme280.init(SDA_PIN, SCL_PIN)

tmr.alarm(0, 5000, 1, function()

  p = bme280.baro()
  -- convert measure air pressure to sea level pressure
  QNH = bme280.qfe2qnh(p, alt)

  h, t = bme280.humi()
  d = bme280.dewpoint(h, t)
  
  print(string.format("Station Pressure: %.3f mmHg", p/1330.322365))
  print(string.format("Sea Level Pressure: %.3f mmHg", QNH/1330.322365))
  print(string.format("Temperature: %.2f C", t/100))
  print(string.format("Humidity: %.2f %%", h/1000))
  print(string.format("Dew Point: %.2f C", d/100))

  -- altimeter function - calculate altitude based on current sea level pressure (QNH) and measure pressure
  p = bme280.baro()
  a = bme280.altitude(p, QNH)
  print(string.format("Altitude: %.1f m", a/100))
  
  print()

end)
