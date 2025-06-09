-- holds a record of all current buffs


local KineticTrackerHolder = blt_class()

KineticTrackerHolder.ALIGNMENT = {
	TOP_LEFT = 1, -- anchored top, left aligned (fill left to right)
	TOP_CENTER = 2, -- anchored top, center aligned (fill left to right)
	TOP_RIGHT = 3, -- anchored top, right aligned (fill right to left)
	BOTTOM_LEFT = 4, -- anchored bottom, left aligned (fill left to right)
	BOTTOM_CENTER = 5, -- anchored bottom, center aligned (fill left to right)
	BOTTOM_RIGHT = 6, -- anchored bottom, right aligned (fill right to left)
	LEFT_TOP = 7, -- anchored left, top aligned (fill top to bottom)
	LEFT_CENTER = 8, -- anchored left, vertical center aligned (fill top to bottom)
	LEFT_BOTTOM = 9, -- anchored left, bottom aligned (fill bottom to top)
	RIGHT_TOP = 10, -- anchored right, top aligned (fill top to bottom)
	RIGHT_CENTER = 11, -- anchored right, vertical center aligned (fill top to bottom)
	RIGHT_BOTTOM = 12 -- anchored right, bottom aligned (fill bottom to top)
}

KineticTrackerHolder._format_timer_funcs = {
	-- flashbang = function
}

function KineticTrackerHolder:init(_settings,_buff_settings,_tweak_data,panel)
	self._settings = _settings
	self._tweak_data = _tweak_data
	self._buff_settings = _buff_settings
	--managers.hud:add_updator("kinetictracker_update",callback(self,self,"Update"))
	
	if _settings.buff_style == 2 then
		self._gui_class = KineticTrackerCore:require("classes/KineticTrackerItemBase")
	else
		self._gui_class = KineticTrackerCore:require("classes/KineticTrackerItemBase")
	end
	
	-- list of all active buffs (sorted);
	-- this list will be iterated through
	self._buffs = {}
	
	-- for manually updating buffs that need to be checked every frame
	-- (like biker)
	self._updaters = {}
	
--	self._panel = nil
	
--	self._display = KineticTrackerDisplay:new()
	--hooks:add(on_hud_hidden,callback_hide_display) --check settings to see if buffs should be hidden on hud hide?
	
	self:CreatePanel(panel)
end

function KineticTrackerHolder:CreatePanel(panel)
	if panel and alive(panel) and not alive(self._panel) then
		self._panel = panel:panel({
			name = "tracker_display_panel"
		})
	end
end

function KineticTrackerHolder:AddBuff(id,params,skip_sort,peer_id)

	local new_buff,priority = self:_AddBuff(id,params,skip_sort,peer_id)
	if not new_buff then
		return
	end
	
	self._format_timer_funcs[id] = self._format_timer_funcs[id] or self.get_format_time_func(self._buff_settings[id],self._settings)
	
	table.insert(self._buffs,priority,new_buff)
	
	if not skip_sort then
		self:SortBuffs()
	end
end

function KineticTrackerHolder:_AddBuff(id,params,skip_sort,peer_id)
	--Print("KineticTrackerHolder:AddBuff()",id,params.value)
	
	--if not Utils:IsInHeist() then
	--	return
	--end
	if not alive(self._panel) then
		return
	end
	
	local settings = self._settings
	local sort_by_priority = settings.sort_by_priority
	
	local buff_tweakdata = id and self._tweak_data.buffs[id]
	local buff_display_setting = self._buff_settings[id]
	
	if buff_tweakdata.disabled then 
		--don't keep track of hard-disabled buffs;
		--unlike soft-disabled buffs, these have no possibility of being re-enabled in a session
		return
	end
	
	local existing_buff = self:GetBuff(id,peer_id)
	if existing_buff then 
		self:_SetBuff(existing_buff,params)
		return
	end
	
	local icon_data = buff_tweakdata.icon_data
	
	local priority
	if sort_by_priority then 
		priority = buff_tweakdata.priority or 1
	else
		priority = #self._buffs + 1
	end
	
	local value_color
	if false then -- if value is full
		value_color = Color(buff_display_setting.buff_color_value_full)
	else
		value_color = Color(buff_display_setting.buff_color_value_normal)
	end
	
	local timer_color
	if buff_tweakdata.is_cooldown then
		timer_color = Color(buff_display_setting.buff_color_timer_cooldown)
	else	
		timer_color = Color(buff_display_setting.buff_color_timer_normal)
	end
	
	local texture_data = {}
	if icon_data.source == "skill" then 
		texture_data.texture = "guis/textures/pd2/skilltree_2/icons_atlas_2"
		local skill_icon_size = 80
		local x,y = unpack(tweak_data.skilltree.skills[icon_data.skill_id].icon_xy)
		texture_data.texture_rect = {x * skill_icon_size,y * skill_icon_size,skill_icon_size,skill_icon_size}
	elseif icon_data.source == "perk" then
		texture_data.texture,texture_data.texture_rect = self.get_specialization_icon_data_by_tier(icon_data.tree,icon_data.card,false)
	elseif icon_data.source == "hud_icon" then 
		texture_data.texture,texture_data.texture_rect = tweak_data.hud_icons:get_icon_data(icon_data.skill_id)
	elseif icon_data.texture then 
		texture_data.texture,texture_data.texture_rect = icon_data.texture,icon_data.texture_rect
	end
	
	local value_str = ""
	if buff_tweakdata.show_value and params.value then
		if buff_tweakdata.get_display_string then
			value_str = buff_tweakdata.get_display_string(buff_tweakdata,params.value)
		else
			value_str = tostring(params.value)
		end
	end
	
	local gui_item = self._gui_class:new(id,{
		name_text = buff_tweakdata.text_id and managers.localization:text(buff_tweakdata.text_id) or "ERROR",
		primary_text = value_str,
		secondary_text = "", -- timer text
		buff_data = buff_tweakdata,
		name_color = nil,
		primary_color = value_color,
		secondary_color = Color(buff_display_setting.buff_color_timer_normal),
		texture_data = texture_data
	},self._panel)
	
	local get_xy = self:get_align_callbacks(self._settings.orientation)
	
	local panel = gui_item._panel
	
	local panel_w,panel_h = self._panel:size()
	local w,h = panel:size()
	local num_buffs = #self._buffs+1
	local x2,y2 = get_xy(num_buffs,num_buffs,w,h,panel_w,panel_h)
	panel:set_position(x2,y2)
	
	-- fadein
	gui_item:animate(gui_item._panel,"panel_fadein",gui_item._animate_fade,0,1,0.15)
	
	local new_buff = {
		id = id,
		value = params.value, -- O/nil, standard. whatever value represents the buff
		end_t = params.end_t, -- float/nil, standard. remaining duration of the timer
		total_t = params.total_t or (params.end_t and (params.end_t - Application:time())), -- float/nil, standard. default maximum of the timer
		peer_id = peer_id,
		user_data = params.user_data, -- table/nil, nonstandard
		gui_item = gui_item
	}
	
	
	return new_buff,priority
end

function KineticTrackerHolder.get_format_time_func(buff_settings,global_settings)
	
	local precision,precision_threshold,show_minutes
	
	if buff_settings.timer_inherit_global then
		precision = KineticTrackerCore.TIMER_SETTING_PRECISION_PLACES_LOOKUP[global_settings.timer_precision_places or 0] or 0
		precision_threshold = KineticTrackerCore.TIMER_SETTING_PRECISION_THRESHOLD_LOOKUP[global_settings.timer_precision_threshold or 0] or 0
		show_minutes = global_settings.timer_minutes_display == 2
	else
		precision = KineticTrackerCore.TIMER_SETTING_PRECISION_PLACES_LOOKUP[buff_settings.timer_precision_places or 0] or 0
		precision_threshold = KineticTrackerCore.TIMER_SETTING_PRECISION_THRESHOLD_LOOKUP[buff_settings.timer_precision_threshold or 0] or 0
		show_minutes = buff_settings.timer_minutes_display == 2
	end
	
	local _seconds_format = ".%0" .. string.format("%i",precision) .."i"
	local precision_pow = math.pow(10,precision)
	
	local SECONDS_ABBREV_STR = "s"
	local SECONDS_FORMAT_TEMPLATE
	if show_minutes then
		SECONDS_FORMAT_TEMPLATE = "%02d"
	else
		SECONDS_FORMAT_TEMPLATE = "%d"
	end
	local MINUTES_FORMAT = "%01i:"
	
	return function(seconds)
		local str = ""
		local seconds_format = SECONDS_FORMAT_TEMPLATE
		if precision >= 1 and seconds < precision_threshold then 
	--		seconds_format = "%02." .. string.format("%i",precision) .. "f"
			seconds_format = seconds_format .. string.format(_seconds_format,(seconds - math.floor(seconds)) * precision_pow)
		end
		
		if show_minutes then 
			local _minutes = math.min(seconds / 60,99)
			local _seconds = seconds % 60
			str = string.format(MINUTES_FORMAT .. seconds_format,_minutes,_seconds)
		else
			str = string.format(seconds_format,seconds) .. SECONDS_ABBREV_STR
		end
		return str
	end
end

function KineticTrackerHolder.get_specialization_icon_data_by_tier(spec,tier,no_fallback)
	local sm = managers.skilltree
	local st = tweak_data.skilltree
	
	spec = spec or sm:get_specialization_value("current_specialization")

	local data = st.specializations[spec]
	local max_tier = sm:get_specialization_value(spec, "tiers", "max_tier")
	local tier_data = data and data[tier or max_tier] --this and the arg tier are the only things changed

	if not tier_data then
		if no_fallback then
			return
		else
			return tweak_data.hud_icons:get_icon_data("fallback")
		end
	end

	local guis_catalog = "guis/" .. (tier_data.texture_bundle_folder and "dlcs/" .. tostring(tier_data.texture_bundle_folder) .. "/" or "")
	local x = tier_data.icon_xy and tier_data.icon_xy[1] or 0
	local y = tier_data.icon_xy and tier_data.icon_xy[2] or 0

	return guis_catalog .. "textures/pd2/specialization/icons_atlas", {
		x * 64,
		y * 64,
		64,
		64
	}
end

function KineticTrackerHolder:get_align_callbacks(index)
	index = index or 1
	
	if 		index == self.ALIGNMENT.TOP_LEFT		then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_row = math.floor(panel_w / w)
			local j = i-1
			local x = (j % num_per_row) * w
			local y = math.floor(j / num_per_row) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.TOP_CENTER		then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_row = math.floor(panel_w / w)
			local j = i-1
			local x = panel_w/2 - (w * (j-(num_per_row/2)))
			local y = math.floor(j / num_per_row) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.TOP_RIGHT		then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_row = math.floor(panel_w / w)
			local j = i-1
			local x = panel_w - (j % num_per_row) * w
			local y = math.floor(j / num_per_row) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.BOTTOM_LEFT		then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_row = math.floor(panel_w / w)
			local j = i-1
			local x = (j % num_per_row) * w
			local y = math.ceil(j / num_per_row) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.BOTTOM_CENTER	then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_row = math.floor(panel_w / w)
			local j = i-1
			local x = panel_w/2 - (w * ((j % num_per_row)-(num_per_row/2)))
			local y = panel_h - math.ceil(j / num_per_row) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.BOTTOM_RIGHT	then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_row = math.floor(panel_w / w)
			local j = i-1
			local x = (j % num_per_row) * w
			local y = math.ceil(j / num_per_row) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.LEFT_TOP		then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_column = math.floor(panel_h / h)
			local j = i-1
			local x = math.floor(j / num_per_column) * w
			local y = (j % num_per_column) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.LEFT_CENTER		then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_column = math.floor(panel_h / h)
			local j = i-1
			local x = math.floor(j / num_per_column) * w
			local y = panel_h/2 - (h * ((j % num_per_column)-(num_per_column/2)))
			return x,y
		end
	elseif	index == self.ALIGNMENT.LEFT_BOTTOM		then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_column = math.floor(panel_h / h)
			local j = i-1
			local x = math.floor(j / num_per_column) * w
			local y = panel_h - (j % num_per_column) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.RIGHT_TOP		then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_column = math.floor(panel_h / h)
			local j = i-1
			local x = panel_w - math.ceil(j / num_per_column) * w
			local y = (j % num_per_column) * h
			return x,y
		end
	elseif	index == self.ALIGNMENT.RIGHT_CENTER	then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_column = math.floor(panel_h / h)
			local j = i-1
			local x = panel_w - math.ceil(j / num_per_column) * w
			local y = panel_h/2 - (h * ((j % num_per_column)-(num_per_column/2)))
			return x,y
		end
	elseif	index == self.ALIGNMENT.RIGHT_BOTTOM	then
		return function(i,total,w,h,panel_w,panel_h)
			local num_per_column = math.floor(panel_h / h)
			local j = i-1
			local x = panel_w - math.ceil(j / num_per_column) * w
			local y = panel_h - (j % num_per_column) * h
			return x,y
		end
	end
	error("Unknown alignment index:" .. tostring(index))
end

function KineticTrackerHolder:SortBuffs()
	local get_xy = self:get_align_callbacks(self._settings.orientation)
	local anim_sort_duration_long = 1
	local anim_sort_duration_short = 0.5
	local panel_w,panel_h = self._panel:size()
	local num_buffs = #self._buffs
	local j = 1
	for i,buff in ipairs(self._buffs) do 
		local gui_item = buff.gui_item
		if gui_item then
			local panel = gui_item._panel
			
			local w,h = panel:size()
			local x2,y2 = get_xy(j,num_buffs,w,h,panel_w,panel_h)
			
			local x1,y1 = panel:position()
			local dx,dy = x2-x1,y2-y1
			
			if gui_item._animthread_sort then
				panel:stop(gui_item._animthread_sort)
				gui_item._animthread_sort = nil
				-- sort at full speed instead of sin
				gui_item._animthread_sort = panel:animate(function(o)
					over(anim_sort_duration_long,function(lerp)
						local n = math.sin(lerp * 90)
						o:set_position(x1+dx*n,y1+dy*n)
					end)
					o:set_position(x2,y2)
					gui_item._animthread_sort = nil
				end)
			else
				gui_item._animthread_sort = panel:animate(function(o)
					over(anim_sort_duration_long,function(lerp)
						local n = math.sin(lerp * 90) ^ 2
						o:set_position(x1+dx*n,y1+dy*n)
					end)
					o:set_position(x2,y2)
					gui_item._animthread_sort = nil
				end)
			end
			
			j = j + 1
		end
	end
end

-- this needs work
function KineticTrackerHolder:_SetBuff(buff,params,skip_sort)
	for k,v in pairs(params) do 
		if type(v) ~= "table" then
			buff[k] = v
		end
	end
	buff.user_data = params.user_data or buff.user_data
	
	local buff_tweakdata = self._tweak_data.buffs[buff.id]
	
	if buff.gui_item then
		if buff_tweakdata.get_display_string and params.value then
			local value_str = buff_tweakdata.get_display_string(buff_tweakdata,params.value) or ""
			if value_str then
				buff.gui_item:set_primary_text(value_str)
			end
		end
		-- timer text (assuming it's a normal timer) will be handled in the update func
		-- special timers (eg timers that count upwards or otherwise behave irregularly) should be handled on a casewise basis
	end
	
	if not skip_sort then
		self:SortBuffs()
	end
	
	return buff
end

function KineticTrackerHolder:SetBuff(id,params)
	local buff = self:GetBuff(id)
	if not buff then
		return --self:AddBuff(id,params)
	end
	return self:_SetBuff(buff,params)
end

function KineticTrackerHolder:GetBuff(id,peer_id)
	local check_peer_id = peer_id ~= nil
	for i,buff_data in pairs(self._buffs) do 
		if buff_data.id == id and (not check_peer_id or peer_id == buff_data.peer_id) then 
			return buff_data,i
		end
	end
end

function KineticTrackerHolder:RemoveBuff(id,peer_id,skip_sort)
	local check_peer_id = peer_id ~= nil
	for i,buff_data in pairs(self._buffs) do 
		if buff_data.id == id and (not check_peer_id or peer_id == buff_data.peer_id) then 
			self:_RemoveBuff(buff_data)
			table.remove(self._buffs,i)
			if not skip_sort then
				self:SortBuffs()
			end
			return buff_data
		end
	end
end

function KineticTrackerHolder:_RemoveBuff(buff_data)
	if buff_data.gui_item then
		buff_data.gui_item:destroy()
	end
end

function KineticTrackerHolder:Update(t,dt)
	for i,data in ipairs(self._updaters) do 
		data.callback(t,dt)
	end
	local do_sort = false
	for i=#self._buffs,1,-1 do 
		local buff = self._buffs[i]
		if buff.end_t then
			local buff_setting = self._buff_settings[buff.id]
			if buff.end_t <= t then
				table.remove(self._buffs,i)
				self:_RemoveBuff(buff)
				do_sort = true
			else
				if buff.gui_item then
					local time_rem = math.max(buff.end_t - t,0)

					local flash_mode = buff_setting.timer_flashing_mode
					local timer_flashing_threshold = buff_setting.timer_flashing_threshold or 0
					if flash_mode == 2 or flash_mode == 1 and timer_flashing_threshold < time_rem then
						buff.gui_item:set_primary_text_flash(buff_setting.timer_flashing_speed)
					end
					
					if buff.total_t then
						-- feed visual progress
						buff.gui_item:set_progress(time_rem / buff.total_t)
					end
					local time_format_func = self._format_timer_funcs[buff.id] or self.get_format_time_func(buff_setting,self._settings)
					buff.gui_item:set_secondary_text(time_format_func(time_rem))
				end
			end
		end
	end
	if do_sort then
		self:SortBuffs()
	end
end

-- higher priority runs first
function KineticTrackerHolder:AddUpdater(id,callback,priority)
	if not id then return end
	priority = priority or 1
	table.insert(self._updaters,{id=id,callback=callback,priority=priority})
	table.sort(self._updaters,function(a,b) 
		return a.priority > b.priority
	end)
end

function KineticTrackerHolder:RemoveUpdater(id)
	if not id then return end
	
	for i,updater in pairs(self._updaters) do 
		if updater.id == id then
			return table.remove(self._updaters,i)
		end
	end
end



do return KineticTrackerHolder end

------------------------------------------------------

local KineticTrackerItemDestiny = {}
local KineticTrackerItemWarframe = {}

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
	
	local buff_tweakdata = id and self.tweak_data.buffs[id]
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
	
	local item_style_index = 1
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

function KineticTrackerHolder:RemoveBuff(id,skip_sort)
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
		local kcore = self._core
		local start_x,start_y = kcore:GetHUDPosition()
		local style_data = KineticTrackerItem.STYLES[1]
		local buff_w = style_data.panel_width
		local buff_h = style_data.panel_height
		
		local halign = kcore:GetHUDHAlign()
		local valign = kcore:GetHUDVAlign()
		local vdir = kcore:GetHUDVDirection()
		local hdir = kcore:GetHUDHDirection()
		
		local di,_i
		if true then
			_i = #self._buffs
			di = -1
		else
			_i = 1
			di = 1
		end
		
		local w,h
		if hdir == 2 then 
			w = -buff_w
		else
			w = buff_w
		end
		if vdir == 2 then 
			h = -buff_h
		else
			h = buff_h
		end
		
		local align = "vertical"
		
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
				local buff_display_setting = kcore:GetBuffDisplaySettings(id)

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
					if align == "horizontal" then 
						panel:set_x(start_x + (w * _i))
						panel:set_y(start_y)
					else
						panel:set_x(start_x)
						panel:set_y(start_y + (h * _i))
					end
					_i = _i + di
				end
				item:SetVisible(not hidden)
			end
		end
	end
end