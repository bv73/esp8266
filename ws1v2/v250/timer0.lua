function write_oled() -- Write Display
  si7021.read()

  if (page == 0) then
    t1 = ds18b20.read(address[2])
    t2 = si7021.getTemperature()
    t2 = t2/100
    display_page0(t1, t2)
    if (ready == true) then 
      mqtt:publish("ws1/t_out", string.format("%.1f", t1), 0, 0)
      mqtt:publish("ws1/t_in", string.format("%.1f", t2), 0, 0)
    end
  end

  if (page == 1) then
    h = si7021.getHumidity()
    h = h/100
    if (h>100) then h = 100 end
    if (h<0) then h = 0 end
    p = bme280.baro()
    p = p/1333.22365 -- fixed
    display_page1(h, p)
    if (ready == true) then 
      mqtt:publish("ws1/humi", string.format("%.1f", h), 0, 0)
      mqtt:publish("ws1/pressure", string.format("%.1f", p), 0, 0)
    end
  end

  if (page == 2) then
    t3 = ds18b20.read(address[1])
    display_page2(t3)
    if (ready == true) then 
      mqtt:publish("ws1/t_heat", string.format("%.1f", t3), 0, 0)
    end
  end

  if (page == 3) then
    tm = rtctime.epoch2cal(rtctime.get())
    display_time (tm)
  end

  if (page>3) then page = 0
              else page = page + 1
  end
end

-- every 3 sec call OLED function
tmr.register(0, 3000, tmr.ALARM_AUTO, function() write_oled() end )
