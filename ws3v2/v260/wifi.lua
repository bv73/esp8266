station_cfg = {}
station_cfg.ssid = "ssid"
station_cfg.pwd = "ap_password"
station_cfg.save = true
wifi.sta.config(station_cfg)
wifi.setmode(wifi.STATION)

ip_mqtt = "192.168.1.122"
ip_ts = "184.106.153.149"

