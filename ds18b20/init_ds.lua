-- DS18b20 Read

--pin = 4 -- D4
ow.setup(4)
addr = ow.reset_search(4)
addr = ow.search(4)

if addr == nil then
  t = -255
--  print("No more addresses.")
else
  crc = ow.crc8(string.sub(addr,1,7))
  if crc == addr:byte(8) then
    ow.reset(4)
    ow.select(4, addr)
    ow.write(4, 0x44, 1) -- Convert T
    ow.reset(4)
    ow.select(4, addr)
    ow.write(4,0xBE,1) -- Read Scratchpad
    data = nil
    data = string.char(ow.read(4))
    for i = 1, 8 do
      data = data .. string.char(ow.read(4))
    end
    crc = ow.crc8(string.sub(data,1,8))
    if crc == data:byte(9) then
       t = (data:byte(1) + data:byte(2) * 256) * 625
       t = t / 10000
       print("T="..t.." C")
    end
  else
    t = -255
--    print("CRC is not valid!")
  end
end
