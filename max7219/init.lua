-- Code by marcelstoer
-- Connections:
-- VCC to VU (5V)
-- GND to GND
-- DIN to D7
-- CS  to D8
-- CLK to D5


a = { 0x20, 0x74, 0x54, 0x54, 0x3C, 0x78, 0x40, 0x00 }
b = { 0x41, 0x7F, 0x3F, 0x48, 0x48, 0x78, 0x30, 0x00 }
c = { 0x38, 0x7C, 0x44, 0x44, 0x6C, 0x28, 0x00, 0x00 }
d = { 0x30, 0x78, 0x48, 0x49, 0x3F, 0x7F, 0x40, 0x00 }
max7219 = require("max7219")
max7219.setup({ debug = true, numberOfModules = 4, slaveSelectPin = 8, intensity = 0 })
max7219.write({a, b, c, d}, { rotate = "left" })
  
-- Clear the module(s):
--max7219.clear()

-- The decimal point is supported as well:
--max7219.write7segment("32.5°C")

-- Set minimum brightness:
--max7219.setIntensity(0)

-- Write to a 7-Segment module and right-align the text:
--max7219.write7segment("HELLO", true)
