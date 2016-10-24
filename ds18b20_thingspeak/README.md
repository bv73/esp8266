Measure temperature with DS18B20 sensor and post data to thingspeak.com
==========================================================================

init.lua - set up WIFI station and wait for ip then do sender.lua;

ds18b20.lua - library for DS18B20 sensor;

sender.lua - get data from DS18B20 sensor and post them to Thinkspeak.com

Please remember change your thingspeak API key and WIFI settings...

By (R)soft 15.09.2016

Update 24.10.2016: 

in last version use enduser_setup module for easy

setup Wi-Fi connection. Short instruction: After starting of module

connect to "smart_termometer002" and type in brouser 192.168.4.1

for open enduser_setup page, then enter SSID and password of your

home router, wait until module connecting to the router & internet.

Enjoy.
