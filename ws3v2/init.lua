-- Weather Station #3 init & setup Wi-Fi through enduser_setup
-- By (R)soft 30.03.2018 v2.0
-- Add OLED display

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
--  disp:setRot180() 
end

init_i2c_display()
disp:firstPage()
repeat
  disp:drawStr(2, 26, "Setting" )
  disp:drawStr(8, 56, "Wi-Fi" )
until disp:nextPage() == false

print("Setting up Wi-Fi...")
wifi.setmode(wifi.STATIONAP)
-- password consist from number combination & serial number
wifi.ap.config({ssid="ws3_v2", pwd="WS3password"})

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
  repeat
    disp:drawStr(2, 26, "Config" )
    disp:drawStr(8, 56, "Done!" )
  until disp:nextPage() == false
--  tmr.delay(1000000)
  if file.exists("sender2.lua") then
    dofile("sender2.lua")
  else 
    print("sender2.lua file exists")
  end
end
end)
