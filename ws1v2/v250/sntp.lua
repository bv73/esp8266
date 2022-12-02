--tm = {year=1999, mon=1, day=1, hour=0, min=0, sec=0}

function sntp_sync ()
  print ("SNTP Sync...")
  sntp.sync('1.pool.ntp.org', function(sec, usec, server, info)
    print('sync done', sec, usec, server)
    rtctime.set(sec + 7200, usec)
    tm = rtctime.epoch2cal(rtctime.get())
  end,
  function() print('SNTP failed!') end )
end