-- Relay over http
-- (R)soft 15.7.2018 v1.1
-- Simple Relay controller

--[[ This section uncomment if not use enduser_setup module
--   and connect through router
-- Configure station and connect
wifi.setmode(wifi.STATION)
wifi.sta.config("Router_SSID","Password")
wifi.sta.connect()
-- Waiting for connect
tmr.alarm(1, 1000, 1, function() 
if wifi.sta.getip()== nil then 
   print("IP unavaiable, Waiting...") 
else 
   tmr.stop(1)
   print("For switch relays, connect to IP " .. wifi.sta.getip())
end
end)
]]--

-- Save relay state to data file
function save_data ()
  file.open("relay.dat", "w")
  file.writeline(r1)
  file.writeline(r2)
  file.close()
end

-- http client
srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
    conn:on("receive", function(client,request)
        local buf = ""
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP")
        if(method == nil)then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
        end
--        print(r1)
--        print(r2)
--        print("----")
        local _GET = {}
        if (vars ~= nil)then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end
        if r1==0 then con1="white"
                        cof1="green"
                   else con1="red"
                        cof1="white" end
        if r2==0 then con2="white"
                        cof2="green"
                   else con2="red"
                        cof2="white" end
        --buf = buf.."<head> <meta http-equiv='refresh' content='2'>"
        buf = buf.."<head><meta name='viewport' content='width=200px, initial-scale=1.0'/>"
        buf = buf.."<style>body { background-image: none;background-color: #ffff99;"
        buf = buf.."background-repeat: no-repeat;background-position: 0px 150px;}</style>"
        buf = buf.."<font face='verdana'><h1>ESP8266 Wifi PowerSwitch</h1>"
        buf = buf.."<h2><p>Relay1 <a href=\"?pin=ON1\"><button style='font-size:16pt;color:black; background-color: ".. con1 ..";'> <font face='arial'>"
        buf = buf.."ON</font></button ></a>&nbsp;"
        buf = buf.."<a href=\"?pin=OFF1\"><button style='font-size:16pt;color:black; background-color: ".. cof1 ..";'> <font face='arial'>"
        buf = buf.."OFF</font></button></a></p>"
        buf = buf.."<p>Relay2 <a href=\"?pin=ON2\"><button style='font-size:16pt;color:black; background-color: ".. con2 ..";'> <font face='arial'>"
        buf = buf.."ON</font></button></a>&nbsp;"
        buf = buf.."<a href=\"?pin=OFF2\"><button style='font-size:16pt;color:black; background-color: ".. cof2 ..";'> <font face='arial'>"
        buf = buf.."OFF</font></button></a></p></font></head>"
        local _on,_off = "",""
        
        if(_GET.pin == "ON1")then
              gpio.write(relay1, gpio.HIGH)
              r1=1
              save_data()
        elseif(_GET.pin == "OFF1")then
              gpio.write(relay1, gpio.LOW)
              r1=0
              save_data()
        elseif(_GET.pin == "ON2")then
              gpio.write(relay2, gpio.HIGH)
              r2=1
              save_data()
        elseif(_GET.pin == "OFF2")then
              gpio.write(relay2, gpio.LOW)
              r2=0
              save_data()
        end
        client:send(buf)
        client:close()
        collectgarbage()
    end)
end)
