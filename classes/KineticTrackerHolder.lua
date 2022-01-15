
Hooks:Register("KineticTrackers_OnBuffDataLoaded")


KineticTrackerHolder = KineticTrackerHolder or class()


function KineticTrackerHolder:init(core)
	self._core = core
	self.tweak_data = core.tweak_data
	managers.hud:add_updator("kinetictracker_update",callback(self,self,"Update"))
	
	self._buffs = {}
--	self._display = KineticTrackerDisplay:new()
	--hooks:add(on_hud_hidden,callback_hide_display) --check settings to see if buffs should be hidden on hud hide?
	
	self._panel = core._ws:panel():panel({
		name = "tracker_display_panel"
	})
	
end

function KineticTrackerHolder:Log(...)
	return self._core:Log(...)
end

function KineticTrackerHolder:Animate(...)
	return self._core:animate(...)
end

function KineticTrackerHolder:AnimateStop(...)
	return self._core:animate_stop(...)
end

function KineticTrackerHolder:IsAnimating(...)
	return self._core:is_animating(...)
end

function KineticTrackerHolder:AnimateFadeoutItem(item)
	local fadeout_time = 0.25
	local dx = 0
	local dy = -50
	
	self:Animate(item._panel,"animate_fadeout",function(o) o:parent():remove(o) end,fadeout_time,item._panel:alpha(),dx,dy)
end

function KineticTrackerHolder:SetBuff(id,params,buff_data)
	for k,v in pairs(params) do 
		if type(v) ~= "table" then 
			buff_data[k] = v
		else
			self:Log("Skipped params overwrite in SetBuff(" .. tostring(id) .. ") for param " .. tostring(k) .. "=" .. tostring(v) .. " (table value)")
		end
	end
	--refresh visually
end

function KineticTrackerHolder:AddBuff(id,params)
	local sort_by_priority = false
	
	local buff_tweakdata = id and self.tweak_data[id]
	local buff_display_setting = self._core:GetBuffDisplaySettings(id)
	if buff_tweakdata.disabled then 
		--don't keep track of hard-disabled buffs;
		--unlike soft-disabled buffs, these have no possibility of being re-enabled in a session
		return
	end
	
	local existing_buff_data = self:GetBuff(id)
	if existing_buff_data then 
		self:SetBuff(id,params,existing_buff_data)
		return
	end
	
	local icon_data = buff_tweakdata.icon_data
	
	local priority
	if sort_by_priority then 
		priority = buff_tweakdata.priority or 1
	else
		priority = #self._buffs + 1
	end
	local color = buff_display_setting.color
	local show_timer = buff_tweakdata.show_timer
	local primary_label = ""
	local secondary_label = ""
	local secondary_label_format = "%0.1f"
	local primary_label_format = buff_tweakdata.display_format or ""
	local buff_label = managers.localization:text(buff_tweakdata.text_id)
	local end_t = params.end_t
	local duration = params.duration
	if show_timer then 
		local t = Application:time()
		if end_t then 
			secondary_label = string.format(secondary_label_format,end_t - t)
		elseif duration then 
			end_t = t + duration
			secondary_label = string.format(secondary_label_format,duration)
		end
	end
	local value = params.value
	
	if type(value) == "number" then
		if buff_tweakdata.modify_value_func then 
			value = buff_tweakdata.modify_value_func(value)
		end
		primary_label = string.format(primary_label_format,value) or primary_label
	end
	
--	local buff_panel = self:CreateBuff(id,buff_tweakdata)
	
	local new_item = KineticTrackerItem:new({
		id = id,
		buff_label = buff_label,
		parent_panel = self._panel,
		icon_data = buff_tweakdata.icon_data,
		primary_label = primary_label,
		secondary_label = secondary_label,
		color = color
	})
	
	--do animate buff name w/indicator
	
	local enabled = buff_display_setting.enabled
	
	new_item:SetVisible(enabled)
	
	local buff_data = {
		id = id,
		enabled = enabled,
		primary_label_format = primary_label_format,
		secondary_label_format = secondary_label_format,
		value = params.value,
		start_t = params.start_t, --not used
		end_t = end_t,
		duration = duration, --not used
		show_timer = show_timer,
		item = new_item,
		upd_func = buff_tweakdata.upd_func,
		modify_value_func = buff_tweakdata.modify_value_func
	}
	
	table.insert(self._buffs,priority,buff_data)
end

--[[
function KineticTrackerHolder:RemoveBuff(id)
	for i,buff_data in pairs(self._buffs) do 
		if buff_data.id == id then 
			return table.remove(self._buffs,i)
		end
	end
end
--]]

function KineticTrackerHolder:_RemoveBuff(id)
	for i,buff_data in pairs(self._buffs) do 
		if buff_data.id == id then 
			return table.remove(self._buffs,i)
		end
	end
end

function KineticTrackerHolder:RemoveBuff(id)
	local buff_data = self:_RemoveBuff(id)
	if buff_data then 
		local item = buff_data.item
		item:Remove()
	end
end

function KineticTrackerHolder:GetBuff(id)
	for i,buff_data in pairs(self._buffs) do 
		if buff_data.id == id then 
			return buff_data,i
		end
	end
end

function KineticTrackerHolder:Update(t,dt)
	if alive(managers.player:local_player()) then 
		local start_x = 256
		local start_y = 650
		
		local _i = #self._buffs
		for i=#self._buffs,1,-1 do 
			local buff_data = self._buffs[i]
			local end_t = buff_data.end_t
			if end_t and end_t <= t then 
	--			local item = buff_data.item
				--animate out
				self:AnimateFadeoutItem(buff_data.item)
				table.remove(self._buffs,i)
			else
				local id = buff_data.id
				local item = buff_data.item
				local panel = item._panel
				local buff_display_setting = self._core:GetBuffDisplaySettings(id)
				
				local value = buff_data.value
				local end_t = buff_data.end_t
				local duration_remaining
				local timer_text
				if end_t then 
					timer_text = end_t - t
				end
				
				local hidden = false
				local below_threshold
				local disabled_by_user = not buff_data.enabled
				
				if buff_data.upd_func then 
					local _timer_text
					value,_timer_text = buff_data.upd_func(t,dt,buff_display_setting,buff_data)
					timer_text = _timer_text or timer_text
				end
				
				if type(value) == "number" then 
					if buff_data.modify_value_func then 
						value = buff_data.modify_value_func(value)
					end
					if (not buff_display_setting.value_threshold) or (value > buff_display_setting.value_threshold) then 
						item:SetPrimaryText(string.format(buff_data.primary_label_format,value))
					else
						below_threshold = true
					end
				else
					item:SetPrimaryText("")
				end
				
				if buff_data.show_timer and buff_display_setting.timer_enabled and timer_text then 
					item:SetSecondaryText(string.format(buff_data.secondary_label_format,timer_text))
				else
					item:SetSecondaryText("")
				end
				
				hidden = below_threshold or disabled_by_user

				if not hidden then
				
					--todo animate
					local align = "vertical"
					if align == "horizontal" then 
						local w = 256
						panel:set_x(start_x + (w * _i))
						panel:set_y(start_y)
					else
						local h = -32
						panel:set_x(start_x)
						panel:set_y(start_y + (h * _i))
					end
					_i = _i - 1
				end
				item:SetVisible(not hidden)
			end
		end
	end
end

--KineticTrackerHolder:AddBuff("")