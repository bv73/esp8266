function data_table()
    return {
        ADC0 = 0,  -- 0.94 is a correction factor
        D0 = gpio.read(0),
        D1 = gpio.read(1),
        D2 = gpio.read(2),
        D3 = gpio.read(3),
        D4 = gpio.read(4),
        D5 = gpio.read(5),
        D6 = gpio.read(6),
        D7 = gpio.read(7),
        D8 = gpio.read(8),
        D9 = gpio.read(9),
        D10 = gpio.read(10),
        D11 = gpio.read(11),
        D12 = gpio.read(12),
        heap = node.heap()
    }
end

function tojson(t)
    local ret = '{'
    local sep = ''
    for k, v in pairs(t) do
        local v2
        if type(v) == "string" then v2 = "\"" .. v .. "\"" else v2 = v end
        ret = ret .. sep .. '"' .. k .. '"' .. " : " .. v2
        sep = ', '
    end
    ret = ret .. '}'
    return ret
end

function data_json()
    return tojson(data_table())
end
