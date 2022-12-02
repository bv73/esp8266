-- Weather station #1 By (R)soft 
-- 4.10.2019 v2.11
-- 2.12.2022 v2.50
-- Require modules i2c, BME280, RTC time, SNTP, MQTT, U8G
-- Based on nodemcu SDK 1.5.4.1
-- Two sensors on I2C bus: BMP280, Si7021
-- Two DS18B20 on OW bus

print("\nWeather Station Module #1 v2.50\n")

dofile("wifi.lua")

page = 0 -- flag for OLED indication
minute = 0
hour = 0 -- hours in use
ready = false -- for MQTT

gpio.mode(4, gpio.OUTPUT) -- D4 LED onboard
gpio.write(4, gpio.HIGH) -- LED turn off

require("ds18b20")
ds18b20.setup(7) -- pin7 = D7 = DQ
address = ds18b20.addrs()
ds18b20.read(address[1]) -- dummy reads after first power on
ds18b20.read(address[2])

si7021 = require("si7021")

i2c.setup(0, 6, 5, i2c.SLOW)

bme280.init(6, 5) -- in v1 SDK
si7021.init(6, 5)

dofile ("sntp.lua") -- sntp event

dofile("sh1106.lua")
init_i2c_display()

dofile ("timer0.lua") -- setup timer0 event
dofile ("timer1.lua")
dofile ("timer2.lua")
dofile ("timer3.lua")

invitation ()

tmr.start (0) -- 3 s display
tmr.start (1) -- 1 m check connectivity & sntp sync
tmr.start (2) -- 2 m send TS data
tmr.start (3) -- 40 s mqtt delay connect
