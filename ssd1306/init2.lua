-- By (R)soft 26.09.2016 v1.0
-- Tested with NodeMCU 1.5.4.1

wifi.setmode(wifi.STATION) --Set mode to STATION so he chip can receive the SSID broadcast

function init_OLED(sda,scl) --Set up the u8glib lib
     sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_6x10)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
end

init_OLED(6,5) --Run setting up

disp:firstPage()

repeat
  disp:drawStr(0,0,"ESP8266 Info") -- Starting on line 0
  disp:drawStr(0,11*2,"IP Address:")
  disp:drawStr(0,11*3,wifi.sta.getip())
  disp:drawStr(0,11*4,"MAC Address:")
  disp:drawStr(0,11*5,wifi.sta.getmac())
until disp:nextPage() == false

tmr.delay(7000000) -- 7 second delay

tmr.alarm(0,3000,1,function()
    wifi.sta.getap(function(t) 
         disp:firstPage()
         repeat
         disp:drawStr(0,0,"WiFi AP Search") -- Starting on line 0
            lines = 2
            for k,v in pairs(t) do
                disp:drawStr(0,lines * 11,k.." "..v:sub(3,5).."dbi")
                lines = lines + 1
            end
        until disp:nextPage() == false
    end)
end)
