-- PZEM 004T & setup Wi-Fi through enduser_setup
-- (R)soft 19.2.2020 v2.0
digits = {0x7e, 0x30, 0x6d, 0x79, 0x33, 0x5b, 0x5f, 0x70, 0x7f, 0x7b}

wifi.setmode(wifi.STATIONAP)
wifi.ap.config({ssid='PZEM_004T', auth=wifi.OPEN})

function sendByte(reg, data)
  gpio.write(0, gpio.LOW)
  spi.send(1, reg)
  spi.send(1, data)
  gpio.write(0, gpio.HIGH)
end

function clear7seg()
  for i = 1, 8 do sendByte(i, 0) end
end

function init7seg()
  spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, spi.DATABITS_8, 8)
  gpio.mode(0, gpio.OUTPUT)
  gpio.write(0, gpio.HIGH)
  sendByte(0x0B, 7)
  sendByte(0x09, 0)
  sendByte(0x0F, 0)
  sendByte(0x0A, 15) -- intensity
  sendByte(0x0C, 1)
  clear7seg()
end

function write7seg(text, align)
  local lenDig = text:gsub("%.", ""):len()

  if (lenDig < 8 ) then
    if (align) then text = string.rep(" ", 8  - lenDig) .. text
               else text = text .. string.rep(" ", 8 - lenDig)
    end
  end

  local dotFlag = false

  local r = 1
  local d = 0

  for i = #text, 1, -1 do
    local c = text:sub(i,i)

    if (c == ".") then dotFlag = true
    else
      if (dotFlag) then
        dotFlag = false
        d = digits[tonumber(c)+1] + 0x80
      else
        if c == " " then d = 0 else d = digits[tonumber(c)+1] end
      end
      sendByte(r, d)
      r = r + 1
    end
  end
end

function init_spi_display()
  spi.setup(1, spi.MASTER, spi.CPOL_LOW, spi.CPHA_LOW, 8, 8)
  disp = ucg.ssd1351_18x128x128_hw_spi(8, 1) -- cs dc
  disp:begin(ucg.FONT_MODE_TRANSPARENT)
  disp:clearScreen()
  disp:setFont(ucg.font_ncenR12_tr)
end

function greetings_wifi()
  disp:setPrintPos(0, 25)
  disp:setColor(255, 0, 0)
  disp:print("PZEM 004T")
  disp:setPrintPos(0, 45)
  disp:setColor(255, 255, 255)
  disp:print("v2.1 19/2/2020" )
  disp:setPrintPos(0, 65)
  disp:print("Setting Wi-Fi...")
end

function display_done()
  disp:setPrintPos(0, 25)
  disp:setColor(255, 255, 255)
  disp:print("Config Done!")
  disp:setPrintPos(0, 45)
  disp:setColor(255, 255, 255)
  disp:print("IP address is:" )
  disp:setPrintPos(0, 65)
  disp:setColor(255, 255, 0)
  disp:print(wifi.sta.getip())
  disp:setPrintPos(0, 85)
  disp:setColor(0, 255, 255)
  disp:print("Please plug")
  disp:setPrintPos(0, 105)
  disp:print("the device...")
end

init_spi_display()
init7seg()
greetings_wifi()

gpio.mode(3, gpio.INPUT, gpio.PULLUP) -- key
KeyCnt = 0
Key = 1

keyscan = tmr.create()
keyscan:register(50, tmr.ALARM_AUTO, function()
  if gpio.read(3) == 0 then KeyCnt = KeyCnt + 1 end
  if KeyCnt == 5 then 
    KeyCnt = 0 
    Key = Key + 1
    if Key>7 then Key=1 end
    write7seg(string.format("%d", Key),1)
  end
end)

keyscan:start()

timer1 = tmr.create()
mytimer = tmr.create()

mytimer:register(10000, tmr.ALARM_SINGLE, function (t)
  if Key > 1 then 
    print("Setting up Wi-Fi...")
    sendByte(8, 0x4F)
    sendByte(7, 0x67)
    sendByte(6, 0x4F)
    disp:setPrintPos(0, 85)
    disp:setColor(0, 255, 255)
    disp:print("Enduser portal")
    disp:setPrintPos(0, 105)
    disp:print("enable...")
    enduser_setup.manual(true)
    enduser_setup.start( 
     function()
       print("Connected to wifi as:" .. wifi.sta.getip())
     end,
     function(err, str)
       print("enduser_setup: Err #" .. err .. ": " .. str)
     end)
  end
  t:unregister() 
end)

timer1:register(2000, tmr.ALARM_AUTO, function() 
if wifi.sta.getip()== nil then 
  disp:setPrintPos(0, 65)
  disp:setColor(math.random()*205, math.random()*255, math.random()*180)
  disp:print("Setting Wi-Fi...")
else
  timer1:stop()
  if Key==1 then
    print("Config done, IP is " .. wifi.sta.getip())
    print ("SNTP Sync...")
    sntp.sync({ '1.pool.ntp.org', '2.pool.ntp.org', '3.pool.ntp.org' },
    function(sec, usec, server, info)
      print('sync done', sec, usec, server)
      rtctime.set(sec + 7200, usec)
      tm = rtctime.epoch2cal(rtctime.get())
      disp:setPrintPos(0, 125)
      disp:setColor(0, 200, 0)
      disp:print(string.format("%02d/%02d/%04d %02d:%02d", tm["day"], tm["mon"], tm["year"], tm["hour"], tm["min"])) 
    end,
    function()
     print('failed!')
    end
    )
    disp:clearScreen()
    display_done()
    if file.exists("pzem21.lua") then dofile("pzem21.lua")
                                 else print("pzem21.lua file exists")
    end
  end
end
end)

mytimer:start()
timer1:start()
