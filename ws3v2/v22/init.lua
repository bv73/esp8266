-- Weather Station #3 init & setup Wi-Fi through enduser_setup
-- By (R)soft 07-12-2021 v2.2
-- Got rid of the PIR sensor

function init_i2c_display()
  -- SDA and SCL can be assigned freely to available GPIOs
  i2c.setup(0, 6, 5, i2c.SLOW)
  disp = u8g.ssd1306_128x64_i2c(0x3c)
  -- font_timB24 font_osb26 font_9x18B
  disp:setFont(u8g.font_timB24)
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
wifi.ap.config({ssid="Weather Station #3 v2.2", pwd="password"})

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
  if file.exists("sender22.lua") then
    dofile("sender22.lua")
  else 
    print("sender22.lua file does not exists")
  end
end
end)
