-- Smart Fridge init & setup Wi-Fi through enduser_setup
-- By (R)soft 22.10.2016 v1.0

print("Setting up Wi-Fi...")
wifi.setmode(wifi.STATIONAP)
-- password consist from number combination & serial number
wifi.ap.config({ssid="smart_termometer002", pwd="123456789002"})

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
  dofile("sender.lua")
end
end)
