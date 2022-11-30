function write_oled() -- Write Display
  if (page == 0) then
    val = adc.read(0)
    raw = val
    val = val - 176
    if (val < 0) then val = 0 end
    x = val/1024
    x = x * 10
    if (x > 99) then x = 99 end
    if (x > max) then max = x end -- calc max value per minute

    display_gas_content (x)
    if (ready == true) then 
      mqtt:publish ("gas_sensor/raw", raw, 0, 0)
      mqtt:publish ("gas_sensor/content", x, 0, 0)
    end
  end

  if (page == 1) then
    t = ds18b20.read()
--    t = ds_read(7)
    display_temp (t)
    if (ready == true) then 
      mqtt:publish ("gas_sensor/temp", t, 0, 0) 
    end
  end

  if (page == 2) then
    tm = rtctime.epoch2cal(rtctime.get())
    display_time (tm)
  end

  if (page > 2) then page = 0
                else page = page + 1
  end
end

-- every 3 sec call OLED function
tmr.register(0, 3000, tmr.ALARM_AUTO, function() write_oled() end )
