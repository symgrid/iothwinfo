local class = require 'middleclass'
--- 加载自定义库文件
local hw = require 'userlib.hwinfo'
local si = require 'utils.sysinfo'

--- 注册对象(请尽量使用唯一的标识字符串)
local app = class("my_hwinfo_test")
--- 设定应用最小运行接口版本(目前版本为1,为了以后的接口兼容性)
app.API_VER = 1

---
-- 应用对象初始化函数
-- @param name: 应用本地安装名称。 如modbus_com_1
-- @param sys: 系统sys接口对象。参考API文档中的sys接口说明
-- @param conf: 应用配置参数。由安装配置中的json数据转换出来的数据对象
function app:initialize(name, sys, conf)
	self._name = name
	self._sys = sys
	self._conf = conf
	--- 获取数据接口
	self._api = self._sys:data_api()
	--- 获取日志接口
	self._log = sys:logger()
	--- 设备实例
	self._devs = {}

	self._log:debug("my_hwinfo_test Application initlized")
end

--- 应用启动函数
function app:start()
	self._api:set_handler({
		--[[
		--- 处理设备输入项数值变更消息，当需要监控其他设备时才需要此接口，并在set_handler函数传入监控标识
		on_input = function(app, sn, input, prop, value, timestamp, quality)
		end,
		]]
		on_output = function(app, sn, output, prop, value)
		end,
		on_command = function(app, sn, command, param)
		end,	
		on_ctrl = function(app, command, param, ...)
		end,
	})

	--- 生成设备唯一序列号
	local sys_id = self._sys:id()
	local sn = sys_id.."."..self._sys:gen_sn('my_hwinfo_test')

	--- 增加设备实例
	local inputs = {
		{ name = "CPU_Temp", desc = "CPU Temp ℃", vt = "real", calc = 1, ratio = 0.001 },
		{ name = "CPU_Frq", desc = "CPU frequency Mhz", vt = "real", calc= 1, ratio = 0.001 },
		{ name = "Mem_Total", desc = "Mem_Total KB", vt = "real"},
		{ name = "Mem_Used", desc = "Mem_Used KB", vt = "real"},		
		{ name = "Mem_Free", desc = "Mem_Free KB", vt = "real"},
		{ name = "Mem_Shared", desc = "Mem_Shared KB", vt = "real"},
		{ name = "Mem_Buffers", desc = "Mem_Buffers KB", vt = "real"},
		{ name = "Mem_Cached", desc = "Mem_Cached KB", vt = "real"},
		{ name = "LAN_ip", desc = "br-lan ip address", vt = "string"},
		{ name = "LAN_netmask", desc = "br-lan netmask", vt = "string"},
		{ name = "LAN_byte_in", desc = "br-lan byte_in KB/s", vt = "real"},
		{ name = "LAN_byte_out", desc = "br-lan byte_out KB/s", vt = "real"},
		{ name = "LAN_byte_in_total", desc = "br-lan byte_in_total MB", vt = "real"},
		{ name = "LAN_byte_out_total", desc = "br-lan byte_out_total MB", vt = "real"},
		{ name = "WAN_byte_in", desc = "3g-wan byte_in KB/s", vt = "real"},
		{ name = "WAN_byte_out", desc = "3g-wan byte_out KB/s", vt = "real"},
		{ name = "WAN_byte_in_total", desc = "3g-wan byte_in_total MB", vt = "real"},
		{ name = "WAN_byte_out_total", desc = "3g-wan byte_out_total MB", vt = "real"}
	}
	local meta = self._api:default_meta()
	meta.name = "my_hwinfo_test"
	meta.description = "my_hwinfo_test"
	local dev = self._api:add_device(sn, meta, inputs)
	self._devs[#self._devs + 1] = dev
	self._inputs = inputs

	for m, n in ipairs(inputs) do
		dev:set_input_prop(n.name, "value", 0, self._sys:time(), 99)
	end


	self._LAN_byte_in_time = self._sys:time()
	local cmd = "cat /proc/net/dev | grep br-lan | sed 's/:/ /g' | awk '{print $2}'"
	local s, err = si.exec(cmd)
	self._LAN_byte_in = s
	
	self._LAN_byte_out_time = self._sys:time()
	local cmd = "cat /proc/net/dev | grep br-lan | sed 's/:/ /g' | awk '{print $10}'"
	local s, err = si.exec(cmd)
	self._LAN_byte_out = s

	self._WAN_byte_in_time = self._sys:time()
	local cmd = "cat /proc/net/dev | grep 3g-wan | sed 's/:/ /g' | awk '{print $2}'"
	local s, err = si.exec(cmd)
	self._WAN_byte_in = s
	
	self._WAN_byte_out_time = self._sys:time()
	local cmd = "cat /proc/net/dev | grep 3g-wan | sed 's/:/ /g' | awk '{print $10}'"
	local s, err = si.exec(cmd)
	self._WAN_byte_out = s

	self._log:info("my_hwinfo_test app start")
	return true
end

--- 应用退出函数
function app:close(reason)
	--print(self._name, reason)
end

--- 应用运行入口
function app:run(tms)
	-- local cmd1 = "get_eth_bandwidth.sh br-lan > /tmp/br-lan.stat"
	-- local s1, cmd1err = si.exec(cmd1)
	-- local cmd2 = "get_eth_bandwidth.sh 3g-wan > /tmp/3g-wan.stat"
	-- local s1, cmd1err = si.exec(cmd2)
	for _, dev in ipairs(self._devs) do
		local now = self._sys:time()
		for p, q in ipairs(self._inputs) do
			local value = nil
			-- local value = hw[q.name]()
			if q.name == "LAN_byte_in" then
				-- self._log:info("LAN_byte_in")
				local t = self._sys:time()
				local cmd = "cat /proc/net/dev | grep br-lan | sed 's/:/ /g' | awk '{print $2}'"
				local s, err = si.exec(cmd)
				if not (#s == 0) then
					local last_s = self._LAN_byte_in
					local last_t = self._LAN_byte_in_time
					value = (s - last_s)/((t - last_t)*1000)
					-- self._log:info(value)
					self._LAN_byte_in_time = t
					self._LAN_byte_in = s
				end
			elseif q.name == "LAN_byte_out" then
				-- self._log:info("LAN_byte_out")
				local t = self._sys:time()
				local cmd = "cat /proc/net/dev | grep br-lan | sed 's/:/ /g' | awk '{print $10}'"
				local s, err = si.exec(cmd)
				if not (#s == 0) then
					local last_s = self._LAN_byte_out
					local last_t = self._LAN_byte_out_time
					value = (s - last_s)/((t - last_t)*1000)
					-- self._log:info(value)
					self._LAN_byte_out_time = t
					self._LAN_byte_out = s
				end
			elseif q.name == "WAN_byte_in" then
				-- self._log:info("LAN_byte_in")
				local t = self._sys:time()
				local cmd = "cat /proc/net/dev | grep 3g-wan | sed 's/:/ /g' | awk '{print $10}'"
				local s, err = si.exec(cmd)
				if not (#s == 0) then
					local last_s = self._WAN_byte_in
					local last_t = self._WAN_byte_in_time
					value = (s - last_s)/((t - last_t)*1000)
					-- self._log:info(value)
					self._WAN_byte_in_time = t
					self._WAN_byte_in = s
				end
			elseif q.name == "WAN_byte_out" then
				-- self._log:info("LAN_byte_out")
				local t = self._sys:time()
				local cmd = "cat /proc/net/dev | grep 3g-wan | sed 's/:/ /g' | awk '{print $10}'"
				local s, err = si.exec(cmd)
				if not (#s == 0) then
					local last_s = self._WAN_byte_out
					local last_t = self._WAN_byte_out_time
					value = (s - last_s)/((t - last_t)*1000)
					-- self._log:info(value)
					self._WAN_byte_out_time = t
					self._WAN_byte_out = s
				end
			else
				value = hw[q.name]()
			end
			-- self._log:info(q.name, value)
			if value then
				if q.calc then
					value=value*q.ratio
				end
				
				dev:set_input_prop(q.name, "value", value, now, 0)	
			end

		end
	end

	return 1000 --下一采集周期为10秒
end

--- 返回应用对象
return app
