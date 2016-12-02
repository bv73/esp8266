-- By (R)soft 6.10.2016 v1.2
-- v1.4 2.12.2016 add ads1110 battery voltage monitoring
-- Use iface7 example for roboremo app
-- This example version for NodeMCU firmware with 'pwm' module
-- Use servo_iface4 for RoboRemo App
-- Accelerometer via pwm
-- For MG90S servo set acc. in RoboRemo to 28...128

wifi.setmode(wifi.SOFTAP)

cfg={}
cfg.ssid="esp_servo"
cfg.pwd="12345678"

cfg.ip="192.168.0.1"
cfg.netmask="255.255.255.0"
cfg.gateway="192.168.0.1"

port = 9876

wifi.ap.setip(cfg)
wifi.ap.config(cfg)

scl = 5 -- D5 pin (standart for my PCB)
sda = 6 -- D6 pin

i2c.setup(0, sda, scl, i2c.SLOW)

function read_ads1110 ()
  i2c.start(0)
  a = i2c.address(0, 0x48, i2c.RECEIVER)
  if a ~= true then  print("Connection Error")  end
  b = i2c.read(0, 2) -- read two bytes
  i2c.stop(0)
  c = b:byte(1) * 256 + b:byte(2)
  return c
end


function stringStarts(a,b)
  return string.sub(a,1,string.len(b))==b
end

function stringEnds(a,b)
  return b=='' or string.sub(a,-string.len(b))==b
end

-- in servo acc. x config: id=servo gain=1.0 min=68 max=82
servo = {}
servo.pin = 8 -- D8
servo.value = 69 -- 75-6 Initial value from 0 to 1023
servo.id = "servo"

-- in slider: id=motor min=1023 max=0, send when moved,
--             auto return, return value=min
motor = {}
motor.pinA = 1 -- D1 pin
motor.pinB = 2 -- D2 pin
motor.reverse = 0
motor.value = 1023
motor.id = "motor"

cmd = ""

pwm.setup(servo.pin, 50, 75-6) -- 50 Hz, Initial value=10
pwm.start(servo.pin)
pwm.setup(motor.pinA, 50, 1023) -- 50 Hz, Initial value=1023
pwm.setup(motor.pinB, 50, 1023)
pwm.start(motor.pinA)
pwm.start(motor.pinB)
    
-- servo value from 0 to 1023
function exeCmd(st) -- example: "servo 500" or "led1"
  if stringStarts(st, servo.id.." ") then -- value comes after id + space
    servo.value = tonumber( string.sub(st,1+string.len(servo.id.." "),string.len(st)) )
    -- set pwm after get value
    pwm.setduty(servo.pin, servo.value-6)
    tmp = read_ads1110()
    volt = tmp*1.279e-4
    -- send back to RoboRemo of value for monitoring
    -- in level indicators for voltage & servo values set:
    -- id=volt label: #*1.0 & id=back label: #*1.0
    -- and set min & max
    connection:send("back " .. servo.value .. 
    "\nvolt " .. string.format("%.1f", volt) ..     "\n")
--    print(string.format("volt %.1f", volt))
  elseif stringStarts(st, motor.id.." ") then -- value comes after id + space
    motor.value = tonumber( string.sub(st,1+string.len(motor.id.." "),string.len(st)) )
    -- set pwm after get value
    if (motor.reverse == 0) then
--      print("frw=" .. motor.value)
      pwm.setduty(motor.pinA, motor.value)
      pwm.setduty(motor.pinB, 1023)
      else
--      print("bck=" .. motor.value)
      pwm.setduty(motor.pinB, motor.value)
      pwm.setduty(motor.pinA, 1023)
      end
  elseif stringStarts(st, "rev0") then
--    print("rev0")
    motor.reverse = 0
    pwm.setduty(motor.pinA, motor.value)
    pwm.setduty(motor.pinB, 1023)
  elseif stringStarts(st, "rev1") then
--    print("rev1")
    motor.reverse = 1 -- REVerse on
    pwm.setduty(motor.pinB, motor.value)
    pwm.setduty(motor.pinA, 1023)
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

print("ESP8266 servo controller")
print("SSID: " .. cfg.ssid .. "  PASS: " .. cfg.pwd)
print("RoboRemo app must connect to " .. cfg.ip .. ":" .. port)

srv = net.createServer(net.TCP, 28800) 
srv:listen(port,function(conn)
  print("RoboRemo connected")

  connection = conn
  conn:send("dbg connected ok\n")
     
  conn:on("receive",receiveData)  
    
  conn:on("disconnection",function(c) 
    print("RoboRemo disconnected")
    end)
    
end)
