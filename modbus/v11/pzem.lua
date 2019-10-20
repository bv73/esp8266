-- (R)soft 8.10.2019 v1.1
-- D7=RXD2 connected to TX PZEM
-- D8=TXD2 connected to RX PZEM
-- D2 - UART2 power enable
-- D4 - LED onboard

function sendData()
  gpio.write(4, gpio.LOW) -- LED on
  -- Calc time
  minute = minute + 1
  if (minute == 60) then
    minute = 0
    hour = hour + 1
  end
  -- close enduser_setup portal after 8 minutes
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
      function(conn) print("Connected")
        conn:send('GET /update?key=ZTVPZ6MZ8VJ05Y3Z' ..
        '&field1=' .. string.format("%.1f", v) ..
        '&field2=' .. string.format("%.3f", cur) ..
        '&field3=' .. string.format("%.1f", p) ..
        '&field4=' .. e ..
        '&field5=' .. string.format("%.1f", f) ..
        '&field6=' .. string.format("%.2f", pf) ..
        '&field7=' .. string.format("%s.%02s", hour, minute) ..
        '&field8=' .. counter ..
        ' HTTP/1.1\r\n' ..
        'Host: api.thingspeak.com\r\n' ..
        'Accept: */*\r\n' ..
        'User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n' ..
        '\r\n')
      end)
    -- end connection section
    conn:on("sent",
    function(conn)
      print("Data sent")
      gpio.write(4, gpio.HIGH) -- LED off
      conn:close()    -- You can disable this row for recieve thingspeak.com answer
    end)
    conn:on("receive",
    function(conn, payload)
      print(payload)
      conn:close()
    end)
    conn:on("disconnection", 
    function(conn) 
      print("Disconnect") 
    end)
  end -- end of if
end

function crc_16(array)
  local crc = 0xFFFF
  for i = 1, #array do
    crc = bit.bxor(crc, array[i])
    for k = 0, 7 do
      local j = bit.band(crc, 1);
      crc = bit.rshift(crc, 1)
      if j > 0 then crc = bit.bxor(crc, 0xA001) end
    end
  end
  return crc
end

function uart_setup()
  node.output(function(str) end, 0) -- no serial output
  uart.alt(1)
  uart.setup(0, 9600, 8, uart.PARITY_NONE, uart.STOPBITS_1, 0)    
end

function uart_send(paket)
  for i = 1, #paket do  
    uart.write(0, paket[i])
    tmr.delay(1042)
  end
end

function getData()
  pkt = {1,4,0,0,0,10} -- modbus rtu packet - read 10 registers from dev#1
  crc = crc_16(pkt)
  pkt[#pkt+1] = bit.band(crc, 0xff) -- inject a crc low byte
  pkt[#pkt+1] = bit.rshift(crc, 8) -- crc high byte

--  gpio.write(4, gpio.LOW) -- LED on
  uart_send(pkt)
--  gpio.write(4, gpio.HIGH) -- LED off

  if (#buff==25) then -- receive 25 bytes
    crc = crc_16(buff)
    if crc==0 then
      counter = counter + 1
      v = (buff[4]*256 + buff[5])/10
      cur = (buff[6]*256 + buff[7])/1000
      p = (buff[10]*256 + buff[11])/10
      e = buff[16]*65536 + buff[14]*256 + buff[15]
      f = (buff[18]*256 + buff[19])/10
      pf = (buff[20]*256 + buff[21])/100
      flag = 1 -- all data have been received
      disp:firstPage()
      repeat
        disp:drawStr(0, 10, string.format('V=%.1f V', v) )
        disp:drawStr(0, 23, string.format('I=%.03f A', cur) )
        disp:drawStr(0, 36, string.format('P=%.1f W', p) )
        disp:drawStr(0, 49, string.format('Energy=%d W', e) )
        disp:drawStr(0, 62, string.format('PF=%.02f', pf) )
      until disp:nextPage() == false
    end
    buff = {}
  else buff = {}
    flag = nil
  end
    
end

hour = 0
minute = 0
counter = 0
flag = nil

gpio.mode(4, gpio.OUTPUT)
gpio.write(4, gpio.HIGH) -- LED turn off

gpio.mode(2, gpio.OUTPUT)
gpio.write(2, gpio.HIGH) -- UART2 Power ON

gpio.mode(7, gpio.INPUT, gpio.PULLUP)
gpio.mode(8, gpio.OUTPUT)
gpio.write(8, 1)

uart_setup()

buff = {} -- Buffer of receive

uart.on("data", 1, function(data) 
  buff[#buff+1] = string.byte(data,1)
  if (#buff > 255) then buff = {} end
end, 0)

-- get data every 5 s
tmr.alarm(0, 5000, 1, function() getData() end )
-- send data every 1 minute to thing speak
tmr.alarm(2, 60000, 1, function() sendData() end )
