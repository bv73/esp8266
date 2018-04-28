-- 1.3" I2C OLED SH1106
-- By (R)soft 28.04.2018 v1.0
-- Tested with NodeMCU 1.5.4.1 & u8g SH1106 i2c
-- Fonts: font_osb26; font_timB24; font_9x18B

function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     local sda = 6
     local scl = 5
     local sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.sh1106_128x64_i2c(sla)
     -- font_osb26 font_timB24
     disp:setFont(u8g.font_9x18B) -- font_9x18B
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     --disp:setRot180() 
end

function write_OLED() -- Write Display
   disp:firstPage()
   repeat
     disp:drawFrame(0, 0, 128, 64)
     disp:setFont(u8g.font_timB24)
     t = 10.4
     disp:drawStr(2, 26, string.format("%.1f%cC", t, 176) )
--     disp:drawStr(2, 26, "timB24")
--     disp:setFont(u8g.font_osb26)
--     disp:drawStr(2, 28, "osb26")
--     disp:drawStr(35, 30,  string.format("%02d:%02d:%02d",hd,m,s)..meridies)
     disp:setFont(u8g.font_9x18B)
     disp:drawStr(42, 55, "9x18B")
     for z=1, 10 do disp:drawCircle(18, 47, z) end
     disp:drawBox(100,20,15,15)
   until disp:nextPage() == false   
end

function aaa()
  init_i2c_display()

  disp:firstPage()
  disp:drawStr(5, 1, "XBM picture")
  disp:drawBox(0,0,10,10)
end

init_i2c_display()
write_OLED()

--tmr.alarm(0, 3000, 1, function() write_OLED() end )
