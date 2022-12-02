  -- init mqtt client with keepalive timer 120sec
  mqtt = mqtt.Client("ws1", 120, "", "")

  mqtt:on("connect", function (client) print ("* connected *") end) -- ? hez
  mqtt:on("offline", function (client) 
    print ("* offline *")
    ready = false
    tmr.start (3)
  end)

  mqtt:on("message", function (client, topic, data) 
    print (topic .. ":" ) 
    if data ~= nil then
      print(data)
    end
  end)

function mqtt_connect ()
  mqtt:connect ("192.168.5.28", 1883, 0, 
    function(client) 
      print ("MQTT connect")
      -- publish a message with data, QoS = 0, retain = 0
      mqtt:publish("ws1/t_out", t1, 0, 0)
      mqtt:publish("ws1/t_in", t2, 0, 0)
      mqtt:publish("ws1/t_heat", t3, 0, 0)
      mqtt:publish("ws1/pressure", p, 0, 0)
      mqtt:publish("ws1/humi", h, 0, 0)
      ready = true -- MQTT is ready
    end, 
    function (client, reason) 
      print ("failed reason:" .. reason)
      if (reason == -1) then node.restart() end
      ready = false
      tmr.start (3)
    end )
end

tmr.register(3, 30000, tmr.ALARM_SEMI, function() mqtt_connect() end)
