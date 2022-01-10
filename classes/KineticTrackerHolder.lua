
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
	local fadeout_time = 0.5
	local dx = 0
	local dy = -100
	
	self:Animate(item._panel,"animate_fadeout",function(o) o:parent():remove(o) end,fadeout_time,item._panel:alpha(),dx,dy)
end

function KineticTrackerHolder:SetBuff(id,params,buff_data)
	for k,v in pairs(params) do 
		buff_data[k] = v
	end
	--refresh visually
end

function KineticTrackerHolder:AddBuff(id,params)
	local sort_by_priority = true
	
	local buff_tweakdata = id and self.tweak_data[id]
	if buff_tweakdata.disabled then 
		--todo replace with user setting buff disabled
--		return
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
		priority = 1
	end
	
--	local buff_panel = self:CreateBuff(id,buff_tweakdata)
	local new_item = KineticTrackerItem:new({
		id = id,
		parent_panel = self._panel,
		icon_data = buff_tweakdata.icon_data,
		primary_label = "000",
		secondary_label = "123",
		color = Color.red
	})
	
	--do animate buff name w/indicator
	
	local buff_data = {
		value = params.value,
		start_t = params.start_t,
		end_t = params.end_t,
		duration = params.duration,
		item = new_item
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

function KineticTrackerHolder:_RemoveBuff(i)
	for i,buff_data in pairs(self._buffs) do 
		if buff_data.id == id then 
			return table.remove(self._buffs,i)
		end
	end
end

function KineticTrackerHolder:RemoveBuff(id)
	local buff_data = self:_RemoveBuff(i)
	local item = buff_data.item
	item:Remove()
end


function KineticTrackerHolder:GetBuff(id)
	for i,buff_data in pairs(self._buffs) do 
		if buff_data.id == id then 
			return buff_data,i
		end
	end
end

function KineticTrackerHolder:Update(t,dt)
	for i=#self._buffs,1,-1 do 
		local buff_data = self._buffs[i]
		local end_t = buff_data.end_t
		if end_t and end_t <= t then 
--			local item = buff_data.item
			--animate out
			self:AnimateFadeoutItem(buff_data.item)
			self._buffs[i] = nil
		else
			local panel = buff_data.item._panel
			
			local align = "horizontal"
			if align == "horizontal" then 
				local w = 100
				local offset = 200
				panel:set_x(offset + (w * i))
				panel:set_y(300)
			else
				local h = 100
				local offset = 200
				panel:set_x(300)
				panel:set_y(offset + (h * i))
			end
		end
	end
end

--KineticTrackerHolder:AddBuff("")