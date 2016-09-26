-- By (R)soft 26.09.2016 v1.0
-- Tested with NodeMCU 1.5.4.1

function init_i2c_display()
     -- SDA and SCL can be assigned freely to available GPIOs
     local sda = 6
     local scl = 5
     local sla = 0x3c
     i2c.setup(0, sda, scl, i2c.SLOW)
     disp = u8g.ssd1306_128x64_i2c(sla)
     disp:setFont(u8g.font_chikita) -- font_chikita font_6x10
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor()
     disp:setFontPosTop()
     --disp:setRot180() 
end

function write_OLED() -- Write Display
   disp:firstPage()
   repeat
     disp:drawFrame(0, 0, 128, 64)
     disp:drawStr(2, 0, "BEGIN")
--     disp:drawStr(35, 30,  string.format("%02d:%02d:%02d",hd,m,s)..meridies)
     disp:drawStr(2, 6, "NEXT")
     disp:drawCircle(18, 47, 14)
     disp:drawBox(70,30,10,10)
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
