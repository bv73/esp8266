-- By (R)soft 6.10.2016 v1.1
-- This example version for NodeMCU firmware with 'pwm' module
-- Use servo_interface3 for RoboRemo App
-- Accelerometer via pwm

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
servo.value = 10 -- Initial value from 0 to 1023
servo.id = "servo"

cmd = ""

pwm.setup(servo.pin, 50, 10) -- 50 Hz, Initial value=10
pwm.start(servo.pin)
    
-- servo value from 0 to 1023
function exeCmd(st) -- example: "servo 500"
    if stringStarts(st, servo.id.." ") then -- value comes after id + space
        servo.value = tonumber( string.sub(st,1+string.len(servo.id.." "),string.len(st)) )
        pwm.setduty(servo.pin, servo.value) -- set pwm after get value
        connection:send("back " .. servo.value .. "\n") -- send back
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

print("ESP8266 servo controller")
print("SSID: " .. cfg.ssid .. "  PASS: " .. cfg.pwd)
print("RoboRemo app must connect to " .. cfg.ip .. ":" .. port)

srv=net.createServer(net.TCP, 28800) 
srv:listen(port,function(conn)
    print("RoboRemo connected")

    connection = conn
    conn:send("dbg connected ok\n")
     
    conn:on("receive",receiveData)  
    
    conn:on("disconnection",function(c) 
        print("RoboRemo disconnected")
    end)
    
end)
