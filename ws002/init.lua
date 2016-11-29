-- Weather Station 002 init & setup Wi-Fi through enduser_setup
-- By (R)soft 29.11.2016 v1.0

print("Setting up Wi-Fi...")
wifi.setmode(wifi.STATIONAP)

wifi.ap.config({ssid="termometer", pwd="YourPassword"})

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
