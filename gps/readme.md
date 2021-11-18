EB500 GPS Module & ESP8266
==========================

Simple connection EB500 to ESP8266 for GPS geocoding from Google Maps. Output (TX0) of EB500 connected to D7 (GPIO13) pin ESP8266. Baudrate of EB500=ESP8266=115200 Bit/s.

Sender1.lua - Get coordinates from GPS EB500 module & make geocoding by Google Maps. CJSON module use for extract name of street. Use switching UART between debug interface and GPS module for visualization. Parsing $GPRMC line. Printing name of street (& house number), coordinates, speed, course, date & time. 

![Geocoding](https://github.com/VladimirBakum/esp8266/blob/master/gps/pictures/1ckxjb005fi2q.png)

---

Sender2.lua - Parsing $GPGLL line. Printing coordinates & time. Send coordinates to api.thingspeak.com
