function sntp_sync ()
  print ("SNTP Sync...")
  sntp.sync('1.pool.ntp.org', function(sec, usec, server, info)
    print('sync done', sec, usec, server)
    sntp_flag = false
    rtctime.set(sec + 7200, usec)
    tm = rtctime.epoch2cal(rtctime.get())
  end,
  function() 
    print('SNTP failed!')
    sntp_flag = true
  end )
end
