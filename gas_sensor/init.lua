-- Gas Sensor init & setup Wi-Fi through enduser_setup
-- By (R)soft 10.11.2016 v1.0

function init_i2c_display()
  -- SDA and SCL can be assigned freely to available GPIOs
  local sda = 6
  local scl = 5
  local sla = 0x3c
  i2c.setup(0, sda, scl, i2c.SLOW)
  disp = u8g.ssd1306_128x64_i2c(sla)
  -- font_gdb30r font_osb35r font_chikita font_6x10
  -- font_osb26r
  disp:setFont(u8g.font_osb26r)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
--  disp:setFontPosTop()
  disp:setRot180() 
end

init_i2c_display()
print("Setting up Wi-Fi...")
disp:firstPage()
disp:setFont(u8g.font_osb26r)
repeat
  disp:drawStr(2, 26, "Setting" )
  disp:drawStr(8, 56, "Wi-Fi" )
until disp:nextPage() == false

wifi.setmode(wifi.STATIONAP)
-- password consist from number combination & serial number
wifi.ap.config({ssid="gas_sensor", pwd="password_for_sensor"})

enduser_setup.manual(true)
enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end)

tmr.alarm(1, 2000, 1, function() 
if wifi.sta.getip()== nil then 
  print("IP unavaiable, Waiting...") 
else 
  tmr.stop(1)
  print("Config done, IP is "..wifi.sta.getip())
  disp:firstPage()
  disp:setFont(u8g.font_osb26r)
  repeat
    disp:drawStr(2, 26, "Config" )
    disp:drawStr(8, 56, "Done!" )
  until disp:nextPage() == false
  dofile("sender.lua")
end
end)

function write_OLED() -- Write Display
  if (flag==0) then
    flag = 1
    val = adc.read(0)
    x = val/1023
    x = x * 100
    if (x > 99) then x = 99 end
    disp:firstPage()
    repeat
      disp:setFont(u8g.font_6x10)
      disp:drawStr(28, 11, "GAS CONTENT:" )
      disp:setFont(u8g.font_osb35r)
      disp:drawStr(16, 54, string.format("%02d%%", x) )
    until disp:nextPage() == false
  else
    flag = 0
    t = ds18b20.read()
    disp:firstPage()

    repeat
      disp:setFont(u8g.font_6x10)
      disp:drawStr(26, 11, "TEMPERATURE:" )
      disp:setFont(u8g.font_osb26r)
      disp:drawStr(6, 50, string.format("%.1f C", t, 176) )
      --disp:drawCircle(84, 30, 4)
    until disp:nextPage() == false
  end
end

flag = 0

-- setup LED pin (Indication of data send)
led = 4 -- D4 LED onboard
gpio.mode(led, gpio.OUTPUT)
gpio.write(led, gpio.HIGH) -- LED turn off

require('ds18b20')
ds18b20.setup(7) -- DQ setup on the D7 pin
ds18b20.read() -- dummy read after power on
ds18b20.read()
ds18b20.read()

tmr.alarm(0, 3000, 1, function() write_OLED() end )
