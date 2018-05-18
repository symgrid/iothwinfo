local si = require 'utils.sysinfo'
local log = require 'utils.log'
local basexx = require 'basexx'

local _M = {}

_M["CPU_Temp"] = function()
    local cmd = "sysinfo temp|grep current:|awk '{print $2}'"
	local s, err = si.exec(cmd)
	if not s then
		return nil, err
	end
    return s
end


_M["CPU_Frq"] = function()
    local cmd = "sysinfo frq|grep current:|awk '{print $2}'"
	local s, err = si.exec(cmd)
	if not s then
		return nil, err
	end
    return s
end

_M["Mem_Total"] = function()
    local cmd = "free -m|grep Mem:|awk '{print $2}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)
	else
		return nil, err
	end
end

_M["Mem_Used"] = function()
    local cmd = "free -m|grep Mem:|awk '{print $3}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)
	else
		return nil, err
	end
end

_M["Mem_Free"] = function()
    local cmd = "free -m|grep Mem:|awk '{print $4}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)
	else
		return nil, err
	end
end

_M["Mem_Shared"] = function()
    local cmd = "free -m|grep Mem:|awk '{print $5}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)
	else
		return nil, err
	end
end

_M["Mem_Buffers"] = function()
    local cmd = "free -m|grep Mem:|awk '{print $6}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)
	else
		return nil, err
	end
end

_M["Mem_Cached"] = function()
    local cmd = "free -m|grep Mem:|awk '{print $7}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)
	else
		return nil, err
	end
end



_M["LAN_ip"] = function()
    local cmd = "uci show network.lan.ipaddr| awk -F= '{print $2}'"
	local s, err = si.exec(cmd)
	if not s then
		return nil, err
	end
	return string.sub(string.gsub(s, "^%s*(.-)%s*$", "%1"), 2, -2)
end

_M["LAN_netmask"] = function()
    local cmd = "uci show network.lan.netmask| awk -F= '{print $2}'"
	local s, err = si.exec(cmd)
	if not s then
		return nil, err
	end
	return string.sub(string.gsub(s, "^%s*(.-)%s*$", "%1"), 2, -2)
end

_M["LAN_byte_in"] = function()
    local cmd = "cat /tmp/lan_bandwidth.stat | awk '{print $2}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)
	else
		return nil, err
	end
end

_M["LAN_byte_out"] = function()
    local cmd = "cat /tmp/lan_bandwidth.stat | awk '{print $3}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)
	else
		return nil, err
	end
end

_M["LAN_byte_in_total"] = function()
    local cmd = "cat /proc/net/dev | grep br-lan | sed 's/:/ /g' | awk '{print $2}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)/1000/1000
	else
		return nil, err
	end
end

_M["LAN_byte_out_total"] = function()
    local cmd = "cat /proc/net/dev | grep br-lan | sed 's/:/ /g' | awk '{print $10}'"
	local s, err = si.exec(cmd)
	if not (#s == 0) then
		return tonumber(s)/1000/1000
	else
		return nil, err
	end
end

_M["WAN_byte_in"] = function()
    local cmd = "cat /tmp/wan_bandwidth.stat | awk '{print $2}'"
	local s, err = si.exec(cmd)
	-- log.info("1len:", #s)
	if not (#s == 0) then
		log.info("WAN_byte_in:", s)
		return tonumber(s)
	else
		return nil, err
	end
end

_M["WAN_byte_out"] = function()
    local cmd = "cat /tmp/wan_bandwidth.stat | awk '{print $3}'"
	local s, err = si.exec(cmd)
	-- log.info("1len:", #s)
	if not (#s == 0) then
		log.info("WAN_byte_out:", #s)
		return tonumber(s)
	else
		return nil, err
	end
	
end

_M["WAN_byte_in_total"] = function()
    local cmd = "cat /proc/net/dev | grep 3g-wan | sed 's/:/ /g' | awk '{print $2}'"
	local s, err = si.exec(cmd)
	-- log.info("1len:", #s)
	if not (#s == 0) then
		return tonumber(s)/1000/1000
	else
		return nil, err
	end
end

_M["WAN_byte_out_total"] = function()
    local cmd = "cat /proc/net/dev | grep 3g-wan | sed 's/:/ /g' | awk '{print $10}'"
	local s, err = si.exec(cmd)
	-- log.info("1len:", #s)
	if not (#s == 0) then
		return tonumber(s)/1000/1000
	else
		return nil, err
	end
end







function _M.get_cpu_temp()
	local cmd = "sysinfo temp|grep current:|awk '{print $2}'"
	local s, err = si.exec(cmd)
	if not s then
		return nil, err
	end
	return s
end


function _M.get_cpu_frq()
	local cmd = "sysinfo frq|grep current:|awk '{print $2}'"
	local s, err = si.exec(cmd)
	if not s then
		return nil, err
	end
	return s
end

function _M.get_lanip()
	local cmd = "uci show network.lan.ipaddr| awk -F= '{print $2}'|sed \"s/'//g/\""
	local s, err = si.exec(cmd)
	if not s then
		return nil, err
	end
	return s
end

return _M