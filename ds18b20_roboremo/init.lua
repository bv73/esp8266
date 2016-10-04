-- ESP8266 reading ds18b20 sensor
-- RoboRemo app used to plot the temperature and log to file
-- www.roboremo.com
-- Use Custom build NodeMCU. 1-Wire does not work in v0.9.6 !

-- code for ds18b20 was inspired from:
-- ds18b20 one wire example for NODEMCU (Integer firmware only)
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Vowstar <vowstar@nodemcu.com> 
-- link: https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/onewire-ds18b20.lua
-- *********************************************************************
-- Some edited by (R)soft 4.10.2016 with external module 'ds18b20.lua'
--            with NodeMCU SDK version 1.5.4.1

require('ds18b20')

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

ds18b20_pin = 5

cmd = ""
connection = nil

function exeCmd(st) 
    if st=="request" then
      temp = ds18b20.read()
      connection:send("temp " .. temp .. "\n")
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

print("ESP8266 reading ds18b20 sensor")
print("SSID: " .. cfg.ssid .. "  PASS: " .. cfg.pwd)
print("RoboRemo app must connect to " .. cfg.ip .. ":" .. port)

srv=net.createServer(net.TCP, 28800) 
srv:listen(port, function(conn)
    print("RoboRemo connected")

    connection = conn
    ds18b20.setup(ds18b20_pin)
     
    conn:on("receive",receiveData)  
    
    conn:on("disconnection",function(c) 
        print("RoboRemo disconnected")
    end)

end)

