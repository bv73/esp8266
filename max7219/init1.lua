a = { 0x20, 0x74, 0x54, 0x54, 0x3C, 0x78, 0x40, 0x00 }
b = { 0x41, 0x7F, 0x3F, 0x48, 0x48, 0x78, 0x30, 0x00 }
c = { 0x38, 0x7C, 0x44, 0x44, 0x6C, 0x28, 0x00, 0x00 }
d = { 0x30, 0x78, 0x48, 0x49, 0x3F, 0x7F, 0x40, 0x00 }
max7219 = require("max7219")
max7219.setup({ debug = true, numberOfModules = 4, slaveSelectPin = 8, intensity = 6 })
max7219.write({a, b, c, d}, { rotate = "left" })
  
-- Clear the module(s):
max7219.clear()
  
-- Turn the module(s) off without loosing the text:
max7219.shutdown(true)

-- Turn the module(s) on:
max7219.shutdown(false)

-- Set minimum brightness:
max7219.setIntensity(0)

-- Set maximum brightness:
max7219.setIntensity(15)

-- Write to a 7-Segment module (these characters are not supported: kmwxKMWX):
max7219.write7segment("HELLO")

-- The decimal point is supported as well:
max7219.write7segment("32.5°C")

-- Write to a 7-Segment module and right-align the text:
max7219.write7segment("HELLO", true)
