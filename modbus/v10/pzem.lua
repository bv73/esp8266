-- (R)soft 8.10.2019 v1.0
-- D7=RXD2 connected to TX PZEM
-- D8=TXD2 connected to RX PZEM
-- D2 - UART2 power enable
-- D4 - LED onboard

len = 0
receive = 0
e = nil

function init_display()
  i2c.setup(0, 6, 5, i2c.SLOW)
  disp = u8g.sh1106_128x64_i2c(0x3c)
  disp:setFont(u8g.font_9x18B) -- font_osb26; font_timB24; font_9x18B
  disp:setFontRefHeightExtendedText()
  disp:setDefaultForegroundColor()
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
  ByteTransmitTimeUs = 1000000 / 960
end

function uart_send(paket)
  for i = 1, #paket do  
    uart.write(0, paket[i])
    tmr.delay(1042)
  end
end

function debug_info()
  disp:firstPage()
  repeat
    disp:drawStr(0, 10, string.format('%04X', crc) )
    disp:drawStr(0, 23, string.format('Low byte=%02X', bit.band(crc, 0xff)) )
    disp:drawStr(0, 36, string.format('High byte=%02X', bit.rshift(crc, 8)) )
    disp:drawStr(0, 49, string.format('Len=%02X', len) )
--    disp:drawStr(0, 62, "enable...")
  until disp:nextPage() == false
end

function sendData()

  pkt = {1,4,0,0,0,10} -- modbus rtu packet - read 10 registers from dev#1
  crc = crc_16(pkt)
  pkt[#pkt+1] = bit.band(crc, 0xff) -- crc low byte
  pkt[#pkt+1] = bit.rshift(crc, 8) -- crc high byte

  gpio.write(4, gpio.LOW) -- LED on
  uart_send(pkt)
  gpio.write(4, gpio.HIGH) -- LED off

  if (#buff==25) then -- receive 25 bytes
    receive = receive + 1
    crc = crc_16(buff)
    if crc==0 then
      v = (buff[4]*256 + buff[5])/10
      cur = (buff[6]*256 + buff[7])/1000
      p = (buff[10]*256 + buff[11])/10
      e = buff[16]*65536 + buff[14]*256 + buff[15]
      f = (buff[18]*256 + buff[19])/10
      pf = (buff[20]*256 + buff[21])/100
      disp:firstPage()
      repeat
--        disp:drawStr(0, 10, string.format('%02X', #buff) )
--        disp:drawStr(0, 10, string.format('send=%d', receive) )
        disp:drawStr(0, 10, string.format('V=%.1f V', v) )
        disp:drawStr(0, 23, string.format('I=%.03f A', cur) )
--        disp:drawStr(0, 36, string.format('f=%.1f Hz', f) )
        disp:drawStr(0, 36, string.format('P=%.1f W', p) )
        disp:drawStr(0, 49, string.format('Energy=%d W', e) )
        disp:drawStr(0, 62, string.format('PF=%.02f', pf) )
      until disp:nextPage() == false
    end
    buff = {}
  else buff = {}
  end
    
end

init_display()
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


-- sendData()

-- send data every X ms
tmr.alarm(0, 1000, 1, function() sendData() end )
