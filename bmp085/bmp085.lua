-- BMP085 module v1.0
-- Compatible with BMP180 sensor
-- MIT license, http://opensource.org/licenses/MIT
    
local moduleName = ...
local M = {}
_G[moduleName] = M
local id=0
local oss = 0
local CO = {}

local function read_reg(dev_addr, reg_addr)
  i2c.start(id)
  i2c.address(id, dev_addr ,i2c.TRANSMITTER)
  i2c.write(id,reg_addr)
  i2c.stop(id)
  i2c.start(id)
  i2c.address(id, dev_addr,i2c.RECEIVER)
  local c=i2c.read(id,1)
  i2c.stop(id)
  return c
end

local function write_reg(dev_addr, reg_addr, reg_val)
  i2c.start(id)
  i2c.address(id, dev_addr, i2c.TRANSMITTER)
  i2c.write(id, reg_addr)
  i2c.write(id, reg_val)
  i2c.stop(id)
end

local function getShort(reg_addr, signed)
  local tH = string.byte(read_reg(0x77, reg_addr))
  local tL = string.byte(read_reg(0x77, (reg_addr + 1)))
  local temp = tH*256 + tL
  if (temp > 32767) and (signed == true) then
     temp = temp - 65536
  end
  return temp
end

-- initialize module
function M.init(d, l)
  if (d ~= nil) and (l ~= nil) and (d >= 0) and (d <= 11) and (l >= 0) and ( l <= 11) and (d ~= l) then
        sda = d
        scl = l
  else
        print("iic config failed!") return nil
  end
  i2c.setup(id, sda, scl, i2c.SLOW)
  CO.AC1 = getShort(0xAA, true)
  CO.AC2 = getShort(0xAC, true)
  CO.AC3 = getShort(0xAE, true)
  CO.AC4 = getShort(0xB0)
  CO.AC5 = getShort(0xB2)
  CO.AC6 = getShort(0xB4)
  CO.B1  = getShort(0xB6, true)
  CO.B2  = getShort(0xB8, true)
  CO.MB  = getShort(0xBA, true)
  CO.MC  = getShort(0xBC, true)
  CO.MD  = getShort(0xBE, true)
end

-- read temperature from BMP085
function M.getTemperature(num_10x)
  write_reg(0x77, 0xF4, 0x2E);
  tmr.delay(10000);
  local temp = getShort(0xF6)
  local X1 = (temp - CO.AC6) * CO.AC5 / 32768
  local X2 = CO.MC * 2048/(X1 + CO.MD)
  local r = (X2 + X1 + 8)/16
  if(num_10x == true) then
     return r
  else
     return ((r/10).."."..(r%10))
  end
end

function M.getPressure_raw(oss)
  local os = 0
  if ((oss == 0) or (oss == 1) or (oss == 2) or (oss == 3)) and (oss ~= nil) then
     os = oss
  end
  local ov = os * 64
  write_reg(0x77, 0xF4, (0x34 + ov));
  tmr.delay(30000);
  local MSB = string.byte(read_reg(0x77, 0xF6))
  local LSB = string.byte(read_reg(0x77, 0xF7))
  local XLSB = string.byte(read_reg(0x77, 0xF8))
  local up_raw = (MSB*65536 + LSB *256 + XLSB)/2^(8 - os)
  return up_raw
end

function M.getPressure(oss)
  local os = 0
  if ((oss == 0) or (oss == 1) or (oss == 2) or (oss == 3)) and (oss ~= nil) then
     os = oss
  end
  local raw = M.getPressure_raw(os)
  local B5 = M.getTemperature(true) * 16 - 8;
  local B6 = B5 - 4000
  local X1 = CO.B2 * (B6 * B6 /4096)/2048
  local X2 = CO.AC2 * B6 / 2048
  local X3 = X1 + X2
  local B3 = ((CO.AC1*4 + X3)*2^os + 2)/4
  X1 = CO.AC3 * B6 /8192
  X2 = (CO.B1 * (B6 * B6 / 4096))/65536
  X3 = (X1 + X2 + 2)/4
  local B4 = CO.AC4 * (X3 + 32768) / 32768
  local B7 = (raw -B3) * (50000/2^os)
  local p = B7/B4 * 2
  X1 = (p/256)^2
  X1 = (X1 *3038)/65536
  X2 = (-7357 *p)/65536
  p = p +(X1 + X2 + 3791)/16
  return p
end

function M.getAL(oss)
  return (M.getUP(oss) - 101325)*843/10000
end

return M
 
