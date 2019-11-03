-- ssd1351_128x128_hicolor_hw_spi
-- Simple test SSD1351 SPI color OLED display module
-- U8G module
-- NodeMCU 1.5.4.1
-- by (R)soft 30.10.2019


-- setup SPI and connect display
function init_spi_display()
     -- Hardware SPI CLK  = D5 (YELLOW)
     -- Hardware SPI MOSI = DIN = D7 (BLUE)
     -- CS, D/C, and RES can be assigned freely to available GPIOs
     cs  = 8 -- D8 (ORANGE), pull-down 10k to GND
     dc  = 4 -- D4 (GREEN)
     res = 0 -- D0 (WHITE) GPIO16

     spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 2)
     disp = u8g.ssd1351_128x128_332_hw_spi(cs, dc, res)
end


-- graphic test components
function prepare()
     disp:setFont(u8g.font_9x18B)
     disp:setFontRefHeightExtendedText()
     disp:setDefaultForegroundColor(5)
--     disp:setDefaultBackgroundColor()
     disp:setFontPosTop()
     disp:setRGB(1,50,50)
end


init_spi_display()

