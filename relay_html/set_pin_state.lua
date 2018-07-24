function set_pin_state(pin, state)
    if state == "INPUT" then
        gpio.mode(pin, gpio.INPUT)
    elseif state == "INPUT_PULLUP" then
        gpio.mode(pin, gpio.INPUT, gpio.PULLUP)
    elseif state == "OUTPUT_0" then
        gpio.mode(pin, gpio.OUTPUT)
        gpio.write(pin, 0)
    elseif state == "OUTPUT_1" then
        gpio.mode(pin, gpio.OUTPUT)
        gpio.write(pin, 1)
    end
end
