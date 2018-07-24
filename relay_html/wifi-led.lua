local ledPin = 4
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T)
    gpio.mode(ledPin, gpio.OUTPUT)
    gpio.write(ledPin, gpio.LOW)
end)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T)
    gpio.mode(ledPin, gpio.OUTPUT)
    gpio.write(ledPin, gpio.HIGH)
end)
