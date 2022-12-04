function check_wifi () 
  if wifi.sta.getip() == nil then 
    print("Setting up Wi-Fi! IP unavaiable, Waiting...") 
    display_wifi_set ()
  else 
    print("Config done, IP is "..wifi.sta.getip())
    display_done ()
    if (sntp_flag == true) then sntp_sync () end
  end
end

-- every 1 minute check & display wifi connection
tmr.register(1, 60000, tmr.ALARM_AUTO,  function () check_wifi () end )
