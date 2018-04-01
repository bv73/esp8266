sda=6
scl=5

i2c.setup(0,sda,scl,i2c.SLOW)

for i=0,127 do
  i2c.start(0)
  resCode = i2c.address(0, i, i2c.TRANSMITTER)
  i2c.stop(0)
  if resCode == true then 
   print("We have a device on address 0x" .. string.format("%02x", i) .. " (" .. i ..")") 
  end
end
