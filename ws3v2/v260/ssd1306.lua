-- font_6x10r,font_9x15Br,font_ncenB18r,font_ncenB24r
function init_i2c_display()
  i2c.setup(0,6,5, i2c.SLOW)
  disp = u8g.ssd1306_128x64_i2c(0x3c)
  disp:setFont(u8g.font_ncenB18r)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
--  disp:setRot180() 
end

function display_page0(t1, t2)
  disp:firstPage()
  disp:setFont(u8g.font_ncenB24r)
  repeat
    disp:drawStr(0, 26, string.format("o:%.1f c", t1) )
    disp:drawStr(0, 56, string.format("i:%.1f c", t2) )
  until disp:nextPage() == false
end

function display_page1(v1, v2)
  disp:firstPage()
  disp:setFont(u8g.font_ncenB24r)
  repeat
    disp:drawStr(0, 26, string.format("h:%d%%", v1) )
    disp:drawStr(0, 56, string.format("P:%.1f", v2) )
  until disp:nextPage() == false
end

function display_page2(value)
  disp:firstPage()
  repeat
    disp:setFont(u8g.font_ncenB18r)
    disp:drawStr(0, 22, "Heat")
    disp:setFont(u8g.font_ncenB24r)
    disp:drawStr(0, 56, string.format("%.1f c", value) )
  until disp:nextPage() == false
end

function invitation ()
  disp:firstPage()
  disp:setFont(u8g.font_ncenB18r)
  repeat
    disp:setFont(u8g.font_ncenB24r)
    disp:drawStr(8, 26, "WS #3")
    disp:setFont(u8g.font_ncenB18r)
    disp:drawStr(0, 56, "v2.60 2022")
  until disp:nextPage() == false
end

function display_done ()
  disp:firstPage()
  disp:setFont(u8g.font_ncenB18r)
  repeat
    disp:drawStr(2, 26, "Config" )
    disp:drawStr(8, 56, "Done!" )
  until disp:nextPage() == false
end

function display_wifi_set ()
  disp:firstPage()
  repeat
--    disp:setFont(u8g.font_font_9x15Br)
--    disp:drawStr(0, 8, string.format("PSW:%s", cfg.pwd) )
    disp:setFont(u8g.font_ncenB18r)
    disp:drawStr(2, 36, "Setting" )
    disp:drawStr(8, 64, "Wi-Fi" )
  until disp:nextPage() == false
end

function display_time (value)
  disp:firstPage()
  disp:setFont(u8g.font_ncenB18r)
  repeat
    disp:drawStr(0, 26, string.format("%02d.%02d.%02d", value["day"], value["mon"], value["year"]) )
    disp:drawStr(0, 56, string.format("%02d:%02d:%02d", value["hour"], value["min"], value["sec"]) )
  until disp:nextPage() == false
end
