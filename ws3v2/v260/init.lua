-- Weather station #3 By (R)soft
-- 4.12.2022  v2.60
-- 15.11.2018 v2.1
-- 3.10.2019  v2.11
-- Require modules i2c, BME280, SNTP, RTC time, MQTT, U8G
-- NodeMCU 1.5.4.1 (most stable)
-- Two sensors on I2C bus: BMP280, Si7021
-- Two DS18B20 on OW bus
-- OLED SSD1306

print("\nWeather Station Module #3 v2.60\n")

dofile("wifi.lua")

page = 0 -- flag for OLED indication
minute = 0
hour = 0
ready = false -- for MQTT
sntp_flag = true -- if true then sntp must be synchronize
mqtt_cnt = 0

gpio.mode(4, gpio.OUTPUT) -- D4 LED onboard
gpio.write(4, gpio.HIGH) -- LED turn off

require("ds18b20")
ds18b20.setup(7) -- pin7 = D7 = DQ
address = ds18b20.addrs()
ds18b20.read(address[1]) -- dummy reads after first power on
ds18b20.read(address[2])

si7021 = require("si7021")

i2c.setup(0, 6, 5, i2c.SLOW)

bme280.init(6, 5)
si7021.init(6, 5)

dofile ("sntp.lua")

dofile("ssd1306.lua")
init_i2c_display()

dofile ("timer0.lua")
dofile ("timer1.lua")
dofile ("timer2.lua")
dofile ("timer3.lua")

invitation ()

tmr.start (0) -- 3 s display
tmr.start (1) -- 1 m check connectivity & sntp sync
tmr.start (2) -- 2 m send TS data
tmr.start (3) -- 30 s mqtt delay connect
