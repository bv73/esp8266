-- pin3 = D3 (GPIO0)
-- pin4 = D4 (GPIO2) LED onboard
-- pin5 = D5 (GPIO14)

pin = 5
gpio.mode(pin,gpio.OUTPUT)

lighton = 0
tmr.alarm(0,500,1,function()
if lighton==0 then
    lighton=1
    gpio.write(pin,gpio.HIGH)
else
    lighton=0
    gpio.write(pin,gpio.LOW)
end
end)
