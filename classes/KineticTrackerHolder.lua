
Hooks:Register("KineticTrackers_OnBuffDataLoaded")


KineticTrackerHolder = KineticTrackerHolder or class()

KineticTrackerHolder.STYLES = {
	KineticTrackerItemDestiny,
	KineticTrackerItemWarframe
}

function KineticTrackerHolder.format_time(seconds,precision,show_minutes)

--	local style_index = 1
--	local item_styles = {
--		KineticTrackerItemDestiny,
--		KineticTrackerItemWarframe
--	}
--	self._item_style = item_styles[style_index]
--	self._item_style = self.STYLES[style_index]

	local str = ""
	local SECONDS_ABBREV_STR = "s"
	local seconds_format = "%02d"
	local minutes_format = "%02i"
	if precision > 0 then 
--		seconds_format = "%02." .. string.format("%i",precision) .. "f"
		seconds_format = seconds_format .. string.format(".%02i",(seconds - math.floor(seconds)) * math.pow(10,precision))
	end
	
	if show_minutes then 
		local _minutes = math.min(seconds / 60,99)
		local _seconds = seconds % 60
		str = string.format(minutes_format .. ":" .. seconds_format,_minutes,_seconds)
	else
		str = string.format(seconds_format,seconds) .. SECONDS_ABBREV_STR
	end
	
	return str
end

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
	if params.value then 
--		self:Log( "SetBuff(" .. tostring(id) .. "): Replaced value " .. tostring(buff_data.values[1]) .. " with " .. tostring(params.value))
		buff_data.values[1] = params.value
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
	local primary_label_string = ""
	local secondary_label_string = ""
	local buff_label_string = managers.localization:text(buff_tweakdata.name_id or buff_tweakdata.text_id)
	local primary_label_format = buff_tweakdata.display_format or ""
	local end_t = params.end_t
	local duration = params.duration
	
	local timer_precision = buff_display_setting.timer_precision or 0
	local timer_minutes_display = buff_display_setting.timer_minutes_display == 1

	if show_timer then 
		local t = Application:time()
		if end_t then 
			duration = end_t - t
			if buff_tweakdata.modify_timer_func then 
				duration = buff_tweakdata.modify_timer_func(duration)
			end
		elseif duration then 
			end_t = t + duration
		end
		if duration then 
			primary_label_string = self.format_time(duration,timer_precision,timer_minutes_display) or primary_label_string
		end
	end
	local value
	local values = params.values or {
		params.value
	}
	
	--any buff that has more than 1 value must have a custom buff display format
	if buff_tweakdata.format_values_func then 
		secondary_label_string = buff_tweakdata.format_values_func(values,buff_display_setting) or "ERROR"
	else
		value = values[1]
		if type(value) == "number" then 
			if buff_tweakdata.modify_value_func then 
				value = buff_tweakdata.modify_value_func(value)
			end
			
			if buff_tweakdata.display_format then 
				secondary_label_string = string.format(buff_tweakdata.display_format,value) or "ERROR"
			end
		else
			--non-number value formatting (eg. boolean, string)
		end
	end
	
	local item_style_index = 2
	local new_item = KineticTrackerItem:new({
		id = id,
		parent_panel = self._panel,
		style_index = item_style_index,
		icon_data = buff_tweakdata.icon_data,
		buff_label_string = buff_label_string,
		primary_label_string = primary_label_string,
		secondary_label_string = secondary_label_string,
		color = color
	})
	
	--do animate buff name w/indicator
	
	local enabled = buff_display_setting.enabled
	
	new_item:SetVisible(enabled)
	
	local buff_data = {
		id = id,
		enabled = enabled,
		primary_label_format = primary_label_format,
--		secondary_label_format = secondary_label_format,
		value = value, --
		values = values,
		start_t = params.start_t, --not used
		end_t = end_t,
		duration = duration, --not used
		show_timer = show_timer,
		item = new_item,
		upd_func = buff_tweakdata.upd_func,
		format_values_func = buff_tweakdata.format_values_func,
		modify_value_func = buff_tweakdata.modify_value_func
	}
	
	table.insert(self._buffs,priority,buff_data)
end

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
		local style_data = KineticTrackerItem.STYLES[2]
		local buff_w = style_data.panel_width
		local buff_h = style_data.panel_height
		
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

				local hidden = false
				local below_threshold
				local disabled_by_user = not buff_data.enabled
				local values = buff_data.values
								
				local primary_text_string,secondary_text_string
				
				--calculate timer
				local end_t = buff_data.end_t
				local timer_value
				local timer_precision = buff_display_setting.timer_precision
				local timer_minutes_display = buff_display_setting.timer_minutes_display == 1
				if end_t then 
					timer_value = end_t - t
				end
				if timer_value then 
					if buff_data.modify_timer_func then 
						timer_value = buff_data.modify_timer_func(timer_value)
					end
					secondary_text_string = self.format_time(timer_value,timer_precision,timer_minutes_display)
				end
				
				if buff_data.upd_func then 
--					buff_data.upd_func(t,dt,values,buff_display_setting,buff_data)
					values = { buff_data.upd_func(t,dt,values,buff_display_setting,buff_data) } 

				end
				if buff_data.format_values_func then 
					primary_text_string = buff_data.format_values_func(values,buff_data,buff_display_setting)
				else
					local value = values[1]
					if type(value) == "number" then 
						if buff_data.modify_value_func then 
							value = buff_data.modify_value_func(value)
						end
						if (not buff_display_setting.value_threshold) or (value > buff_display_setting.value_threshold) then 
							if buff_data.primary_label_format then 
								primary_text_string = string.format(buff_data.primary_label_format,value) or "ERROR"
							end
						else
							below_threshold = true
						end
						

					else
						--non-number value formatting (eg. boolean, string)
					end
				end
				
				if primary_text_string then 
					item:SetPrimaryText(primary_text_string)
				else
--					item:SetPrimaryText("")
				end
				
				
				if buff_data.show_timer and buff_display_setting.timer_enabled and secondary_text_string then 
					item:SetSecondaryText(secondary_text_string)
				else
					item:SetSecondaryText("")
				end
				
				hidden = below_threshold or disabled_by_user

				if not hidden then
				
					--todo animate
					local align = "vertical"
					if align == "horizontal" then 
						local w = buff_w
						panel:set_x(start_x + (w * _i))
						panel:set_y(start_y)
					else
						local h = -buff_h
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