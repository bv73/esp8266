mpl3115a2 = require('mpl3115a2')

id = 0  -- Software I2
scl = 5 -- connect to pin GPIO14
sda = 6 -- connect to pin GPIO12
mpl3115a2.init()

function run()
	p, t = mpl3115a2.read()
	print(string.format("Pressure: %.3f mmHg", p/133.3))
	print(string.format("Temperature: %.3f C", t))

end

run()
