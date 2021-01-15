-- (R)soft 19.2.2020 v2.0
-- RXD & TXD connected to PZEM via mux
-- D0 MAX CS
-- D1 OLED DC
-- D2 - UART2 & power enable
-- D3 Button
-- D4 - OW & LED onboard
-- D8 OLED CS

function ds_read(pin)
  ow.setup(pin)
  addr = ow.reset_search(pin)
  addr = ow.search(pin)

  if addr == nil then   t = -255
  else
    crc = ow.crc8(string.sub(addr,1,7))
    if crc == addr:byte(8) then
      ow.reset(pin)
      ow.select(pin, addr)
      ow.write(pin,0x44,1) -- Convert T
      ow.reset(pin)
      ow.select(pin, addr)
      ow.write(pin,0xBE,1) -- Read Scratchpad
      data = nil
      data = string.char(ow.read(pin))
      for i = 1, 8 do
        data = data .. string.char(ow.read(pin))
      end
      crc = ow.crc8(string.sub(data,1,8))
      if crc == data:byte(9) then
         t = (data:byte(1) + data:byte(2) * 256) * 625
         t = t / 10000
      end
    else  t = -255
    end
  end
  return t
end

function sendData()
  minute = minute + 1
  if (minute == 60) then
    minute = 0
    hour = hour + 1
  end
  -- close enduser_setup portal
  if (minute == 8) and (hour == 0) then
    enduser_setup.stop()
    wifi.setmode(wifi.STATION)
  end
  if (flag==1) then -- flag that last packet have been received
    flag = nil
    -- conection to thingspeak.com
    conn = net.createConnection(net.TCP, 0) 
    conn:connect (80,'184.106.153.149')
    -- start connection section
    conn:on("connection",
      function(conn)
        conn:send('GET /update?key=91G1CGU4GQ2IG1AHG' ..
        '&field1=' .. string.format("%.1f", v) ..
        '&field2=' .. string.format("%.3f", cur) ..
        '&field3=' .. string.format("%.1f", p) ..
        '&field4=' .. e ..
        '&field5=' .. string.format("%.1f", t) ..
        '&field6=' .. string.format("%.2f", pf) ..
        '&field7=' .. string.format("%s.%02s", hour, minute) ..
        '&field8=' .. node.heap() ..
        ' HTTP/1.1\r\n' ..
        'Host: api.thingspeak.com\r\n' ..
        'Accept: */*\r\n' ..
        'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
        '\r\n')
      end)
    -- end connection section
    conn:on("sent",
    function(conn)
      conn:close()    -- You can disable this row for recieve thingspeak.com answer
    end)
    conn:on("receive",
    function(conn, payload)
      conn:close()
    end)
    conn:on("disconnection", 
    function(conn) 
    end)
  end
end

function crc_16(array)
  local crc = 0xFFFF
  for i = 1, #array do
    crc = bit.bxor(crc, array[i])
    for k = 0, 7 do
      local j = bit.band(crc, 1)
      crc = bit.rshift(crc, 1)
      if j > 0 then crc = bit.bxor(crc, 0xA001) end
    end
  end
  return crc
end

function uart_send(paket)
  for i = 1, #paket do  
    uart.write(0, paket[i])
    tmr.delay(1042)
  end
end

function info7seg ()
  if Key==1 then write7seg(string.format("%.1f", v),1); sendByte(8, 0x3E) end
  if Key==2 then write7seg(string.format("%.03f", cur),1); sendByte(8, 0x30) end
  if Key==3 then write7seg(string.format("%.1f", p),1); sendByte(8, 0x67) end
  if Key==4 then write7seg(string.format("%.3f", e),1); sendByte(8, 0x4F) end
  if Key==5 then write7seg(string.format("%.1f", t),1); sendByte(8, 0x0F) end
  if Key==6 then write7seg(string.format("%.02f", pf),1); sendByte(8, 0x67); sendByte(7, 0x47) end
  if Key==7 then 
    sendByte(8, 0x05)
    sendByte(7, 0x4F)
    sendByte(6, 0x5B)
    sendByte(5, 0x4F)
    sendByte(4, 0x0F)
    sendByte(1, 0)
  end
end

function getData()
  if Key==7 then 
    info7seg()
    pkt = {1,0x42} -- modbus rtu packet - reset energy dev#1
    crc = crc_16(pkt)
    pkt[#pkt+1] = bit.band(crc, 0xff)
    pkt[#pkt+1] = bit.rshift(crc, 8)
    uart_send(pkt)
    Key=1
    buff = {}
    flag = nil
  else  
    pkt = {1,4,0,0,0,10} -- modbus rtu packet - read 10 registers from dev#1
    crc = crc_16(pkt)
    pkt[#pkt+1] = bit.band(crc, 0xff) -- inject a crc low byte
    pkt[#pkt+1] = bit.rshift(crc, 8) -- crc high byte

    uart_send(pkt)

    if (#buff==25) then -- receive 25 bytes
      crc = crc_16(buff)
      if crc==0 then
        counter = counter + 1
        v = (buff[4]*256 + buff[5])/10
        cur = (buff[6]*256 + buff[7])/1000
        p = (buff[10]*256 + buff[11])/10
        e = buff[16]*16777216 + buff[17]*65536 + buff[14]*256 + buff[15]  -- energy calc fixed
        e = e/1000
        f = (buff[18]*256 + buff[19])/10
        pf = (buff[20]*256 + buff[21])/100
        t = ds_read(4)
      
        disp:clearScreen()
        disp:setColor(0, 255, 0)
        disp:drawFrame(0,0,128,128)
        disp:setPrintPos(4, 16)
        disp:setColor(255, 255, 255)
        disp:print(string.format('1.U=%.1f V', v))
        disp:setPrintPos(4, 32)
        disp:print(string.format('2.I=%.03f A', cur))
        disp:setPrintPos(4, 48)
        disp:print(string.format('3.P=%.1f W', p))
        disp:setPrintPos(4, 64)
        disp:print(string.format('4.E=%.3f kWh', e))
        disp:setPrintPos(4, 80)
        disp:print(string.format('5.T=%.1f C', t))
        disp:setPrintPos(4, 96)
        disp:print(string.format('6.PF=%.02f', pf))
        disp:setPrintPos(4, 110)
        disp:print('7.Res E')
        disp:setPrintPos(4, 125)
        disp:setColor(255, 255, 0)
        tm = rtctime.epoch2cal(rtctime.get())
        disp:print(string.format("%02d-%02d-%02d %02d:%02d", tm["day"], tm["mon"], tm["year"]-2000, tm["hour"], tm["min"]))
        info7seg()
        flag = 1 -- all data have been received
      end
      buff = {}
    else 
      buff = {}
      flag = nil
    end
  end  
end

-- MAIN

hour = 0
minute = 0
counter = 0
flag = nil
Key=1

gpio.mode(2, gpio.OUTPUT)
gpio.write(2, gpio.HIGH) -- UART mux &  PZEM Power ON

-- UART setup
node.output(function(str) end, 0) -- no serial output
uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)

buff = {} -- Buffer of receive

uart.on("data", 1, function(data) 
  buff[#buff+1] = string.byte(data,1)
  if (#buff > 255) then buff = {} end
end, 0)

tmr1 = tmr.create()
tmr2 = tmr.create()

-- get data every 7 s
tmr1:register(7000, tmr.ALARM_AUTO, function()  getData() end )
-- send data every 1 minute to thing speak
tmr2:register(60000, tmr.ALARM_AUTO, function() sendData() end )

tmr1:start()
tmr2:start()

