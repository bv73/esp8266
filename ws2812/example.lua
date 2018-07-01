-- WS2812 Example
-- INPUT pin connect to D4 (GPIO2)

-- init the ws2812 module
ws2812.init(ws2812.MODE_SINGLE)
-- create a buffer, 16 LEDs with 3 color bytes
strip_buffer = ws2812.newBuffer(16, 3)
-- init the effects module, set color to red and start blinking
ws2812_effects.init(strip_buffer)
ws2812_effects.set_speed(240)
ws2812_effects.set_brightness(5) -- 0 to 255
ws2812_effects.set_color(0,255,0)

--ws2812_effects.set_mode("flicker", 150)
--ws2812_effects.set_mode("fire", 150)

-- rainbow cycle with 1 repetitions
ws2812_effects.set_mode("rainbow_cycle", 1)

-- gradient from red to yellow to red
--ws2812_effects.set_mode("gradient", string.char(0,200,0,200,200,0,0,200,0))

-- random dots with fading
--ws2812_effects.set_mode("random_dot",1) -- 1 random dot

ws2812_effects.start()

