cfg = {}
cfg.ssid = "Gas Sensor v2.21"
cfg.pwd = "gassensorpass"

--wifi.setmode(wifi.STATIONAP)
wifi.ap.config(cfg)


wifi.setmode(wifi.STATION)

--[[
enduser_setup.manual(true)
enduser_setup.start(
  function ()
    print("Enduser portal connected to wifi as:" .. wifi.sta.getip())
  end,
  function(err, str)
    print("enduser_setup: Err #" .. err .. ": " .. str)
  end)
--]]

