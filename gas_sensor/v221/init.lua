-- Gas Sensor by (R)soft 
-- v1.1 2/12/2016 add use in hours function
-- v2.1 10/08/2018 Add power switch for MQ-5 on pin D2
-- v2.11 05.10.2019 
-- v2.21 19.11.2022 show connection status & work without connection 
--   & add sntp RTC & mqtt & change of fonts & some rebuild & skip EUP to minimize memory usage

dofile ("wifi.lua")

max = 0
page = 0
raw = 0
minute = 0
hour = 0
ready = false

-- setup LED pin (Indication of data send)
gpio.mode (4, gpio.OUTPUT) -- D4 LED onboard
gpio.write (4, gpio.HIGH) -- LED turn off

-- setup Power Switch Pin for MQ-5
gpio.mode (2, gpio.OUTPUT) -- D2 Power switch
gpio.write (2, gpio.HIGH) -- Power turn ON

require ('ds18b20')
ds18b20.setup (7) -- DQ setup on the D7 pin
t = ds18b20.read () -- dummy read after power on

--dofile ("ds18b21.lua")
--t = ds_read(7)

dofile ("sntp.lua") -- sntp event
dofile ("ssd1306.lua")
init_i2c_display ()

dofile ("timer0.lua") -- setup timer0 event
dofile ("timer1.lua")
dofile ("timer2.lua")
dofile ("timer3.lua")

invitation ()

tmr.start (0) -- 3 s display
tmr.start (1) -- 1 m check connectivity & sntp sync
tmr.start (2) -- 2 m send TS data
tmr.start (3) -- 40 s mqtt delay connect
