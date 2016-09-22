-- Library for MPL3115A2 I2C Barometric/Altitude sensor
-- By (R)soft 22.09.2016 v1.3

local moduleName = "mpl3115a2"

local M = { MPL3115A2_ADDR = 0x60 }
_G[moduleName] = M

local id = 0 -- i2c bus id

local function read_reg(dev_addr, reg_addr)
     i2c.start(id)
     a = i2c.address(id, dev_addr, i2c.TRANSMITTER)
	 if a ~= true then 
		print("Connection Error")
	end
     i2c.write(id, reg_addr)
     -- i2c.stop(id) < Don't send a stop for this device
     i2c.start(id)
     a = i2c.address(id, dev_addr, i2c.RECEIVER)
	 if a ~= true then 
		print("Connection Error")
	end
     c = i2c.read(id, 1)
     i2c.stop(id)
     return string.byte(c)
end

local function write_reg(dev_addr, reg_addr, val)
    i2c.start(id)
    a = i2c.address(id, dev_addr ,i2c.TRANSMITTER)
	if a ~= true then 
		print("Connection Error")
	end
     c = i2c.write(id,reg_addr, val)
     i2c.stop(id)
end

local function getData(addr) -- Do the actual reading from the sensor
  i2c.setup(id, sda, scl, i2c.SLOW)
	 
  write_reg(addr, 0x26, 0x3B) -- set OST bit
  uart.write(0, "<") -- pause
  write_reg(addr, 0x26, 0x39)

  uart.write(0, "Waiting")
  repeat
    status = read_reg(addr, 0x00)
    uart.write(0, ".")
  until bit.band(status, 0x08) == 0x08 -- control TPDR bit

  local Pmsb = read_reg(addr, 0x01)
  local Pcsb = read_reg(addr, 0x02)
  local Plsb = read_reg(addr, 0x03)
  local Tmsb = read_reg(addr, 0x04)
  local Tlsb = read_reg(addr, 0x05)

  write_reg(addr, 0x26 ,0x3B) -- set OST bit
  uart.write(0, ">") -- pause
  write_reg(addr, 0x26, 0x39)
  print()

  local p = bit.lshift(Pmsb, 8)
  p = bit.bor(p, Pcsb)
  p = bit.lshift(p, 8)
  p = bit.bor(p, Plsb)
  p = bit.rshift(p, 4)
  p = p/4
	 
  local t = (Tmsb * 256) + Tlsb
  t = bit.rshift(t, 4)
  t = t/16.0

  return p, t
end

function M.init()
  i2c.setup(id, sda , scl, i2c.SLOW)
  -- Set Barometer Mode, SampleRate=0x07, SBYB=1
  write_reg(M.MPL3115A2_ADDR, 0x26, 0x39)
  -- enable Event Flags
  write_reg(M.MPL3115A2_ADDR, 0x13, 0x07)
end

function M.read()
	baro,temp = getData(M.MPL3115A2_ADDR)
	return baro,temp
end

return M
