-- PZEM 004T & setup Wi-Fi through enduser_setup
-- (R)soft 8.10.2019 v1.0

function init_display()
  i2c.setup(0, 6, 5, i2c.SLOW)
  disp = u8g.sh1106_128x64_i2c(0x3c)
  disp:setFont(u8g.font_9x18B) -- font_osb26; font_timB24; font_9x18B
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
end

function greetings_wifi()
  disp:firstPage()
  repeat
    disp:drawStr(0, 10, "PZEM 004T" )
    disp:drawStr(0, 23, "v1.0 9/10/19" )
    disp:drawStr(0, 36, "Setting Wi-Fi")
    disp:drawStr(0, 49, "Enduser setup")
    disp:drawStr(0, 62, "enable...")
  until disp:nextPage() == false
end

function display_done()
  disp:firstPage()
  repeat
    disp:drawStr(0, 10, "Config Done!" )
    disp:drawStr(0, 23, "IP address is:")
    disp:drawStr(0, 36,  wifi.sta.getip())
    disp:drawStr(0, 49, "Please plug")
    disp:drawStr(0, 62, "the device...")
  until disp:nextPage() == false
end

init_display()
greetings_wifi()

print("Setting up Wi-Fi...")
wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid='PZEM 004T v1.0', pwd='12345678'})

enduser_setup.manual(true)
enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end)

tmr.alarm(1, 5000, 1, function() 
if wifi.sta.getip()== nil then 
  print("IP unavaiable, Waiting...") 
else 
  tmr.stop(1)
  print("Config done, IP is " .. wifi.sta.getip())
  display_done()
  if file.exists("pzem.lua") then
    dofile("pzem.lua")
  else 
    print("pzem.lua file exists")
  end
end
end)
