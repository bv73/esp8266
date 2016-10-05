wifi.setmode(wifi.SOFTAP)

cfg={}
cfg.ssid="esp_srv"
cfg.pwd="12345678"

cfg.ip="192.168.0.1"
cfg.netmask="255.255.255.0"
cfg.gateway="192.168.0.1"

port = 9876

wifi.ap.setip(cfg)
wifi.ap.config(cfg)

function stringStarts(a,b)
    return string.sub(a,1,string.len(b))==b
end

function stringEnds(a,b)
   return b=='' or string.sub(a,-string.len(b))==b
end

servo = {}
servo.pin = 4 --this is GPIO2
servo.value = 1500
servo.id = "servo"


cmd = ""

gpio.mode(servo.pin,gpio.OUTPUT)
gpio.write(servo.pin,gpio.LOW)

tmr.alarm(0, 20, 1, function() -- 50Hz 
    if servo.value then -- generate pulse
        gpio.write(servo.pin, gpio.HIGH)
        tmr.delay(servo.value)
        gpio.write(servo.pin, gpio.LOW)
    end
end)
    
-- servo value from 10 to 18000
function exeCmd(st) -- example: "servo 1500"
    if stringStarts(st, servo.id.." ") then -- value comes after id + space
        servo.value = tonumber( string.sub(st,1+string.len(servo.id.." "),string.len(st)) )
    end
end


function receiveData(conn, data)
    cmd = cmd .. data

    local a, b = string.find(cmd, "\n", 1, true)   
    while a do
        exeCmd( string.sub(cmd, 1, a-1) )
        cmd = string.sub(cmd, a+1, string.len(cmd))
        a, b = string.find(cmd, "\n", 1, true)
    end 
end


srv=net.createServer(net.TCP, 28800) 
srv:listen(port,function(conn)
    print("RoboRemo connected")
    conn:send("dbg connected ok\n")
     
    conn:on("receive",receiveData)  
    
    conn:on("disconnection",function(c) 
        print("RoboRemo disconnected")
    end)
    
end)
