-- Relay over http
-- (R)soft 7.7.2018 v1.0
-- Simple Relay controller

relay1 = 3
relay2 = 4
-- Init new data file or read relay states
if file.exists("relay.dat")
then
  file.open("relay.dat","r")
  state1=file.readline()
  state2=file.readline()
  file.close()
  if state1~=nil then r1=string.sub(state1,1,#state1-1) end
  if state2~=nil then r2=string.sub(state2,1,#state2-1) end
  print("Relay1 state:" .. r1)
  print("Relay2 state:" .. r2)
else
  file.open("relay.dat", "w")
  r1 = 0
  r2 = 0
  file.writeline(r1)
  file.writeline(r2)
  file.close()
  print("Create relay.dat")
end
-- Init and set pins
gpio.mode(relay1, gpio.OUTPUT)
gpio.mode(relay2, gpio.OUTPUT)

if r1=="0" then gpio.write(relay1, gpio.LOW)
           else gpio.write(relay1, gpio.HIGH) end
if r2=="0" then gpio.write(relay2, gpio.LOW)
           else gpio.write(relay2, gpio.HIGH) end

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
		
		buf = buf.."<head><meta name='viewport' content='width=200px, initial-scale=1.5'/>"
        buf = buf.."<style>body { background-image: url('GIVE IMAGE URL');background-repeat: no-repeat;background-position: 0px 150px;}</style>"
        buf = buf.."<font face='verdana'><h1>ESP8266 Wifi PowerSwitch</h1>"
        buf = buf.."<h2><p>Relay1 <a href=\"?pin=ON1\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF1\"><button>OFF</button></a></p>"
        buf = buf.."<p>Relay2 <a href=\"?pin=ON2\"><button>ON</button></a>&nbsp;<a href=\"?pin=OFF2\"><button>OFF</button></a></p></font></head>"
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
