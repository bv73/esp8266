-- Relay init & setup Wi-Fi through enduser_setup
-- By (R)soft 15.7.2018 v1.1

print("Init & Set Relays")
relay1 = 4 -- D4 (Blue LED)
relay2 = 3
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
  r1, r2 = 0
  file.writeline(r1)
  file.writeline(r2)
  file.close()
  print("Create relay.dat")
end
-- Init and set pins
gpio.mode(relay1, gpio.OUTPUT)
gpio.mode(relay2, gpio.OUTPUT)
if r1=="0" then gpio.write(relay1, gpio.LOW)
                r1=0
           else gpio.write(relay1, gpio.HIGH)
                r1=1
end
if r2=="0" then gpio.write(relay2, gpio.LOW)
                r2=0
           else gpio.write(relay2, gpio.HIGH)
                r1=1
end

print("Setting up Wi-Fi...")
wifi.setmode(wifi.STATIONAP)
-- password consist from number combination & serial number
wifi.ap.config({ssid="SmartRelay", pwd="12345678000"})

enduser_setup.manual(true)
enduser_setup.start(
  function()
    print("Connected to wifi as:" .. wifi.sta.getip())
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end)

tmr.alarm(1, 2000, 1, function() 
if wifi.sta.getip()== nil then 
  print("IP unavaiable, Waiting...") 
else 
  tmr.stop(1)
  print("Config done, IP is "..wifi.sta.getip())
  if file.exists("relay.lua") then
    print("\n=== Portal closed ===\n")
  enduser_setup.stop()
--  wifi.setmode(wifi.STATION)
    dofile("relay.lua")
  else 
    print("relay.lua file exists")
  end
end
end)
