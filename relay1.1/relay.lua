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
        c1=r1*16646400+65280
      --  print(string.format("%06x",c1))
        c2=r2*16646400+65280
      --  print(string.format("%06x",c2))
        if r1==0 then con1=16777215 -- white
                        cof1=c1
                   else con1=c1
                        cof1=16777215 end
        if r2==0 then con2=16777215
                        cof2=c2
                   else con2=c2
                        cof2=16777215 end
        --buf = buf.."<head> <meta http-equiv='refresh' content='2'>"
        buf=buf.."<html>"
        buf=buf.."<head><meta name='viewport' content='width=device-width, initial-scale=1'>"
        buf=buf.."<style>body {background-color: #ffff99;}</style>"
        buf=buf.."</head><body>"
        buf=buf.."<font face='verdana'>"
        buf=buf.."<h1>ESP8266 Wifi PowerSwitch</h1>"
        buf=buf.."<h2><p>Relay1 <a href=\"?pin=ON1\"><button onclick='myfu()' style='font-size:16pt;color:black;background-color: #".. string.format("%06x", con1) ..";'> <font face='arial'>"
        buf=buf.."ON</font></button ></a>&nbsp;"
        buf=buf.."<a href=\"?pin=OFF1\"><button style='font-size:16pt;color:black;background-color: #".. string.format("%06x", cof1) ..";'> <font face='arial'>"
        buf=buf.."OFF</font></button></a></p>"
        buf=buf.."<p>Relay2 <a href=\"?pin=ON2\"><button style='font-size:16pt;color:black; background-color: #".. string.format("%06x", con2) ..";'> <font face='arial'>"
        buf=buf.."ON</font></button></a>&nbsp;"
        buf=buf.."<a href=\"?pin=OFF2\"><button style='font-size:16pt;color:black; background-color: #".. string.format("%06x", cof2) ..";'> <font face='arial'>"
        buf=buf.."OFF</font></button></a></p></h2></font>"
        buf=buf.."<script type='text/javascript'> function myfu(){location.reload(true); console.log('ON1');}</script>"
--        buf=buf.."<script type='text/javascript'> function myfu() { setTimeout(function() { console.log('ON1'); }, 2000) }; </script>"
        buf=buf.."</body></html>"
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
