  -- init mqtt client with keepalive timer 120sec
  mqtt = mqtt.Client("gas_sensor", 120, "", "")

  mqtt:on("connect", function (client) print ("*** connected ***") end) -- ? hez
  mqtt:on("offline", function (client) 
    print ("*** offline ***")
    ready = false
    tmr.start (3)
  end)

  mqtt:on("message", function (client, topic, data) 
    print (topic .. ":" ) 
    if data ~= nil then
      print(data)
      if(topic == "gas_sensor/power") then
        if (data == "off") then gpio.write(2, gpio.LOW) end
        if (data == "on") then gpio.write(2, gpio.HIGH) end -- Power ON
      end
    end
  end)

function mqtt_connect ()
  mqtt:connect ("192.168.0.15", 1883, 0, 
    function(client) 
      print ("MQTT connect")
      mqtt:subscribe("gas_sensor/power",0)
      -- publish a message with data, QoS = 0, retain = 1
      mqtt:publish("gas_sensor/temp", t, 0, 0)
      mqtt:publish("gas_sensor/raw", raw, 0, 0)
      mqtt:publish("gas_sensor/content", x, 0, 0)
      ready = true
    end, 
    function (client, reason) 
      print ("failed reason:" .. reason)
      if (reason == -1) then node.restart() end
      ready = false
      tmr.start (3)
    end )
end

tmr.register(3, 30000, tmr.ALARM_SEMI, function() mqtt_connect() end)
