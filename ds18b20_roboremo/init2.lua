-- ESP8266 reading ds18b20 sensor
-- RoboRemo app used to plot the temperature and log to file
-- www.roboremo.com
-- Use Custom build NodeMCU. 1-Wire does not work in v0.9.6 !

-- code for ds18b20 was inspired from:
-- ds18b20 one wire example for NODEMCU (Integer firmware only)
-- NODEMCU TEAM
-- LICENCE: http://opensource.org/licenses/MIT
-- Vowstar <vowstar@nodemcu.com> 
-- link: https://github.com/nodemcu/nodemcu-firmware/blob/master/lua_examples/onewire-ds18b20.lua



wifi.setmode(wifi.SOFTAP)

cfg={}
cfg.ssid="esp_srv"
cfg.pwd="12345678"

cfg.ip="192.168.0.1"
cfg.netmask="255.255.255.0"
cfg.gateway="192.168.0.1"

port = 9876

wifi.ap.setip(cfg)
wifi.ap.config(cfg)

ds18b20_pin = 5

function ds18b20_open(pin)
  ow.setup(pin)
  count = 0
  repeat
    count = count + 1
    addr = ow.reset_search(pin)
    addr = ow.search(pin)
    tmr.wdclr()
  until((addr ~= nil) or (count > 100))
  if (addr == nil) then return 1 -- err
  else
    crc = ow.crc8(string.sub(addr,1,7))
    if (crc == addr:byte(8)) then
      if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
        return 0 -- OK
      else
        return 1 -- err
      end
    else
      return 1 -- err
    end
  end
end

function ds18b20_read(pin, callback) -- uses tmr1 for 750ms delay
  
  ow.reset(pin)
  ow.select(pin, addr)
  ow.write(pin, 0x44, 1)

  tmr.stop(1)
  tmr.alarm(1,750,0,function() -- one time, after 750ms
    ow.reset(pin)
    ow.select(pin, addr)
    ow.write(pin,0xBE,1)
      
    data = nil
    data = string.char(ow.read(pin))
    for i = 1, 8 do
      data = data .. string.char(ow.read(pin))
    end
    
    crc = ow.crc8(string.sub(data,1,8))
    
    if (crc == data:byte(9)) then
       t = (data:byte(1) + data:byte(2) * 256)

       -- handle negative temperatures
       if (t > 0x7fff) then
          t = t - 0x10000
       end

       if (addr:byte(1) == 0x28) then
          t = t * 625  -- DS18B20, 4 fractional bits
       else
          t = t * 5000 -- DS18S20, 1 fractional bit
       end

       local sign = ""
       if (t < 0) then
           sign = "-"
           t = -1 * t
       end

       -- Separate integral and decimal portions, for integer firmware only
       local t1 = string.format("%d", t / 10000)
       local t2 = string.format("%04u", t % 10000)
       local temp = sign .. t1 .. "." .. t2
       callback(temp)
    end     
  end)

end

cmd = ""
connection = nil

function exeCmd(st) 
    if st=="request" then
      ds18b20_read(ds18b20_pin, function(temp)
        connection:send("temp " .. temp .. "\n")
      end)
    end
end

function receiveData(conn, data)
    cmd = cmd .. data

    local a, b = string.find(cmd, "\n", 1, true)   
    while a do
        exeCmd( string.sub(cmd, 1, a-1) )
        cmd = string.sub(cmd, a+1, string.len(cmd))
        a, b = string.find(cmd, "\n", 1, true)
    end
end

print("ESP8266 reading ds18b20 sensor")
print("SSID: " .. cfg.ssid .. "  PASS: " .. cfg.pwd)
print("RoboRemo app must connect to " .. cfg.ip .. ":" .. port)

srv=net.createServer(net.TCP, 28800) 
srv:listen(port, function(conn)
    print("RoboRemo connected")

    connection = conn
    ds18b20_open(ds18b20_pin)
     
    conn:on("receive",receiveData)  
    
    conn:on("disconnection",function(c) 
        print("RoboRemo disconnected")
    end)

end)

