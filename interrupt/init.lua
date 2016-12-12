-- Interrupt handler example v1.0
-- (R)soft 12/12/2016
-- Test with Texecom Reflex

pin_int = 5 -- interrupt pin
pulse = 0
minute_counter = 0   -- counter per minute

gpio.mode(pin_int, gpio.INT)
--gpio.mode(pin_int, gpio.INT, gpio.PULLUP)

-- interrupt function
gpio.trig(pin_int, "up", function()
  pulse = pulse + 1
  print("pulse")
  end)

function minute_handler()
  minute_counter = pulse
  print("Counter per minute=" .. minute_counter)
  pulse = 0
end

tmr.alarm(0, 60000, 1, function()
	minute_handler()
	end)
