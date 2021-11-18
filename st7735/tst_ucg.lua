-- st7735_18x128x160_hw_spi
-- Simple test ST7735 SPI color 1.8" TFT display module
-- UCG module
-- NodeMCU 1.5.4.1
-- by (R)soft 18.11.2021

function init_spi_display()
  -- Hardware HSPI CLK  = D5 (YELLOW)
  -- Hardware HSPI MOSI = D7 (ORANGE)
  -- CS, D/C, and RES can be assigned freely to available GPIOs

  cs  = 8 -- D8 (WHITE)
  dc  = 4 -- D4 (GREEN)
  res = 0 -- D0 (GREY) GPIO16
  clock_div = 8

  spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, clock_div)
  disp = ucg.st7735_18x128x160_hw_spi(cs, dc, res)
end


init_spi_display()


disp:begin(ucg.FONT_MODE_TRANSPARENT) -- FONT_MODE_SOLID
--ucg.setFontMode(ucg.FONT_MODE_TRANSPARENT)
disp:clearScreen()

--disp:setFont(ucg.font_7x13B_tr)
--disp:setFont(ucg.font_helvB08_hr)
--disp:setFont(ucg.font_helvB10_hr)
--disp:setFont(ucg.font_helvB12_hr)
--disp:setFont(ucg.font_helvB18_hr)
disp:setFont(ucg.font_ncenB24_tr) -- transparent maybe
--disp:setFont(ucg.font_ncenR12_tr)
--disp:setFont(ucg.font_ncenR14_hr)
--disp:setFont(ucg.font_ncenR12_tr)

-- disp:setPrintDir(1)

--disp:setScale2x2()
--disp:undoScale()

--disp:setClipRange(10, 10, 60, 60) -- x,y, windowX, windowY
--disp:undoClipRange()

--disp:setRotate90()
--disp:setRotate180()
--disp:setRotate270()

--disp:setFontPosTop()
--disp:setFontPosCenter()
--disp:setFontPosBottom()
--disp:setFontPosBaseline()

disp:setColor(0, 255, 255) -- Cyan
disp:setPrintPos(0, 25)
disp:print("Hello World!")

disp:setColor(0, 255, 0) -- Red green Blue
disp:setPrintPos(0, 45)
disp:print("Hello World!")

disp:setColor(255, 0, 0) -- Red green Blue
disp:setPrintPos(0, 65)
disp:print("Hello World!")

disp:setColor(0, 0, 255) -- Red green Blue
disp:setPrintPos(0, 85)
disp:print("Hello World!")

disp:setFont(ucg.font_helvB18_hr)
disp:setFontMode(ucg.FONT_MODE_SOLID)
disp:setPrintPos(0, 110)
disp:setColor(0, 0, 0, 0)       -- black color for the text
disp:setColor(1, 100, 220, 255) -- light blue for the background
disp:print("Hello")

