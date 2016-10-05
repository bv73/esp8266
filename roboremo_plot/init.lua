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



on=0
val=0
cmd=""

function exeCmd(st) 
    if stringStarts(st, "on") then on=1 end  
    if stringStarts(st, "off") then on=0 end   
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


print("ESP8266 to RoboRemo plot")
print("SSID: " .. cfg.ssid .. "  PASS: " .. cfg.pwd)
print("RoboRemo app must connect to " .. cfg.ip .. ":" .. port)

srv=net.createServer(net.TCP, 28800) 
srv:listen(port,function(conn)
    print("RoboRemo connected")
     
    conn:on("receive",receiveData)  
    
    conn:on("disconnection",function(c) 
        print("RoboRemo disconnected")
    end)
    
    tmr.stop(1)
    tmr.alarm(1, 50, 1, function() -- send to plot every 50 ms
        if on==1 then
          conn:send("val " .. val .. "\n")
          val=val+1
          if val==20 then val=0 end
        end
    end)

end)
