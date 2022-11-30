-- font_6x10r,font_9x15Br,font_ncenB18r,font_ncenB24r
function init_i2c_display()
  i2c.setup(0,6,5, i2c.SLOW)
  disp = u8g.ssd1306_128x64_i2c(0x3c)
  disp:setFont(u8g.font_ncenB18r)
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
  disp:setRot180() 
end

function invitation ()
  disp:firstPage()
  disp:setFont(u8g.font_ncenB18r)
  repeat
    disp:drawStr(26, 26, "GAS" )
    disp:drawStr(8, 56, "Sensor" )
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

function display_gas_content (value)
  disp:firstPage()
  repeat
    disp:setFont(u8g.font_9x15Br)
    disp:drawStr(8, 12, "GAS CONTENT:" )
    disp:setFont(u8g.font_ncenB24r)
    disp:drawStr(16, 54, string.format("%.1f%%", value) )
  until disp:nextPage() == false
end

function display_temp (value)
  disp:firstPage()
  repeat
    disp:setFont(u8g.font_9x15Br)
    disp:drawStr(6, 12, "TEMPERATURE:" )
    disp:setFont(u8g.font_ncenB24r)
    disp:drawStr(6, 50, string.format("%.1f C", value, 176) )
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
