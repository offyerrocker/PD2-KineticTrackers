local KineticTrackerHandler = blt_class()

-- event handler/listener for various buff procs;
-- receives buff data, parses it, and gives the processed buff data to the buff holder


function KineticTrackerHandler:init(_settings,_tweakdata,_holder)
	self._settings = _settings
	self._tweakdata = _tweakdata
	self._holder = _holder
end

function KineticTrackerHandler:Log(...)
	if _G.Console then
		Console:Log(...)
	end
end

function KineticTrackerHandler:Print(...)
	if _G.Console then
		Console:Print(...)
	end
end

-- Buff ID getters

function KineticTrackerHandler:GetBuffIdFromProperty(name)
	return self._tweakdata.buff_id_lookups.property[name]
end

function KineticTrackerHandler:GetBuffIdFromTemporaryProperty(name)
	return self._tweakdata.buff_id_lookups.temporary_property[name]
end

function KineticTrackerHandler:GetBuffIdFromTemporaryUpgrade(category,upgrade)
	return self._tweakdata.buff_id_lookups.temporary_upgrade[category] and self._tweakdata.buff_id_lookups.temporary_upgrade[category][upgrade]
end

function KineticTrackerHandler:GetBuffIdFromCooldownUpgrade(category,upgrade)
	return self._tweakdata.buff_id_lookups.cooldown_upgrade[category] and self._tweakdata.buff_id_lookups.cooldown_upgrade[category][upgrade]
end

function KineticTrackerHandler:GetBuffIdFromAssaultBuff(name) -- was used for winters/hudassault buff but not anymore
	return self._tweakdata.buff_id_lookups.assault[name]
end


-- there's no getter for temp property time in vanilla
function KineticTrackerHandler.get_temporary_property_time(pm,prop,default)
	local time = Application:time()

	if pm._properties[prop] and time <= pm._properties[prop][2] then
		return pm._properties[prop][2]
--	elseif pm._properties[prop] then
--		pm._properties[prop] = nil
	end

	return default
end


-- Property events

function KineticTrackerHandler:on_set_property(pm,name,value)
	local buff_id = self:GetBuffIdFromProperty(name)
	if buff_id then
		self._holder:AddBuff(buff_id,{value=value})
	else
		self:Print("on_set_property() Bad buff_id for property",name)
	end
end

function KineticTrackerHandler:on_add_to_property(pm,name,value)
	local buff_id = self:GetBuffIdFromProperty(name)
	if buff_id then
		local _value = pm:get_property(name)
		self._holder:AddBuff(buff_id,{value=_value,add=value})
	else
		self:Print("on_add_to_property() Bad buff_id for property",name)
	end
end

function KineticTrackerHandler:on_mul_to_property(pm,name,value)
	local buff_id = self:GetBuffIdFromProperty(name)
	if buff_id then
		local _value = pm:get_property(name)
		self._holder:AddBuff(buff_id,{value=_value,mul=value})
	else
		self:Print("on_mul_to_property() Bad buff_id for property",name)
	end
end

function KineticTrackerHandler:on_remove_property(pm,name)
	local buff_id = self:GetBuffIdFromProperty(name)
	if buff_id then
		self._holder:RemoveBuff(buff_id)
	else
		self:Print("on_remove_property() Bad buff_id for property",name)
	end
end


-- Temporary property events

function KineticTrackerHandler:on_activate_temporary_property(pm,name,time,value)
	local buff_id = self:GetBuffIdFromTemporaryProperty(name)
	if buff_id then
		self._holder:AddBuff(buff_id,{value=value,end_t = time + Application:time(),total_t = time})
	end
end

function KineticTrackerHandler:on_add_to_temporary_property(pm,name,time,value)
	local buff_id = self:GetBuffIdFromTemporaryProperty(name)
	if buff_id then
		self._holder:AddBuff(buff_id,{value=value,end_t = time + Application:time()})
	end
end

function KineticTrackerHandler:on_remove_temporary_property(pm,name)
	local buff_id = self:GetBuffIdFromTemporaryProperty(name)
	if buff_id then
		self._holder:RemoveBuff(buff_id)
	end
end


-- Temporary upgrade events

function KineticTrackerHandler:on_activate_temporary_upgrade(pm,category,upgrade)
	local buff_id = self:GetBuffIdFromTemporaryUpgrade(category,upgrade)
	local expire_t = pm:get_activate_temporary_expire_time(category,upgrade)
	if buff_id then
		local value = 1
		-- needs a link to value
		self._holder:AddBuff(buff_id,{value=value,end_t = expire_t,total_t = expire_t})
	end
end

function KineticTrackerHandler:on_deactivate_temporary_upgrade(pm,category,upgrade)
	local buff_id = self:GetBuffIdFromTemporaryUpgrade(category,upgrade)
	if buff_id then
		self._holder:RemoveBuff(buff_id)
	end
end

function KineticTrackerHandler:on_activate_temporary_upgrade_by_level(pm,category,upgrade,level)
	local buff_id = self:GetBuffIdFromTemporaryUpgrade(category,upgrade)
	local expire_t = pm:get_activate_temporary_expire_time(category,upgrade)
	if buff_id then
		local value = 1
		self._holder:AddBuff(buff_id,{value=value,end_t = expire_t,total_t = expire_t})
	end
end


-- Cooldown upgrade events

function KineticTrackerHandler:on_aquire_cooldown_upgrade(pm,upgrade) -- upgrade is a table
	local buff_id = self:GetBuffIdFromCooldownUpgrade(upgrade.category,upgrade.upgrade)
	if buff_id then
		local value = 1
		self._holder:AddBuff(buff_id,{value=value,end_t = expire_t,total_t = expire_t})
	end
end

function KineticTrackerHandler:on_unaquire_cooldown_upgrade(pm,upgrade) -- upgrade is a table
--	local buff_id = self:GetBuffIdFromCooldownUpgrade(upgrade.category,upgrade.upgrade)
end

function KineticTrackerHandler:on_disable_cooldown_upgrade(pm,category,upgrade)
	local buff_id = self:GetBuffIdFromCooldownUpgrade(category,upgrade)
	local expire_t = pm:get_disabled_cooldown_time(category,upgrade)
	if buff_id then
		local value = 1
		self._holder:AddBuff(buff_id,{value=value,end_t = expire_t,total_t = expire_t})
	end
end



-- Pocket ECM Jammer events

function KineticTrackerHandler:on_start_pocket_ecm_jammer(inv_ext,end_time)
	local session = managers.network:session()
	local peer = session and session:peer_by_unit(inv_ext._unit)
	local peer_id = peer and peer:id() or 1
	
	--if not peer_id then
	--	self:Print("ERROR: KineticTrackerHandler:on_start_pocket_jammer() Bad peer/peer_id for inventory extension",inv_ext)
	--	return
	--end
	
	end_time = end_time or inv_ext:get_jammer_time()
	self._holder:AddBuff("pocket_ecm_jammer",
		{
			value = true, -- filler
			end_t = TimerManager:game():time() + end_time,
			total_t = end_time
		},
		false,
		peer_id
	)
end

function KineticTrackerHandler:on_stop_pocket_ecm_jammer(inv_ext)
	local session = managers.network:session()
	local peer = session and session:peer_by_unit(inv_ext._unit)
	local peer_id = peer and peer:id() or 1
	
	--if not peer_id then
	--	self:Print("ERROR: KineticTrackerHandler:on_stop_pocket_jammer() Bad peer/peer_id for inventory extension",inv_ext)
	--	return
	--end
	
	self._holder:RemoveBuff("pocket_ecm_jammer",peer_id)
end

function KineticTrackerHandler:on_start_pocket_ecm_feedback(inv_ext,end_time)
	local session = managers.network:session()
	local peer = session and session:peer_by_unit(inv_ext._unit)
	local peer_id = peer and peer:id() or 1
	
	--if not peer_id then
	--	self:Print("ERROR: KineticTrackerHandler:on_start_pocket_ecm_feedback() Bad peer/peer_id for inventory extension",inv_ext)
	--	return
	--end
	
	end_time = end_time or inv_ext:get_jammer_time()
	
	local interval,range = inv_ext:get_feedback_values()
	if interval == 0 or range == 0 then
		return false
	end
	local nr_ticks = math.max(1, math.floor(end_time / interval))
	
	self._holder:AddBuff("pocket_ecm_feedback",
		{
			value = nr_ticks,
			end_t = TimerManager:game():time() + end_time,
			total_t = end_time
		},
		false,
		peer_id
	)
end

function KineticTrackerHandler:on_stop_pocket_ecm_feedback(inv_ext)
	local session = managers.network:session()
	local peer = session and session:peer_by_unit(inv_ext._unit)
	local peer_id = peer and peer:id() or 1
	
	--if not peer_id then
	--	self:Print("ERROR: KineticTrackerHandler:on_stop_pocket_ecm_feedback() Bad peer/peer_id for inventory extension",inv_ext)
	--	return
	--end
	
	self._holder:RemoveBuff("pocket_ecm_feedback",peer_id)
end

function KineticTrackerHandler:on_pocket_ecm_feedback_tick(inv_ext)
	local session = managers.network:session()
	local peer = session and session:peer_by_unit(inv_ext._unit)
	local peer_id = peer and peer:id() or 1
	
	--if not peer_id then
	--	self:Print("ERROR: KineticTrackerHandler:on_pocket_ecm_feedback_tick() Bad peer/peer_id for inventory extension",inv_ext)
	--	return
	--end
	
	local jammer_data = inv_ext._jammer_data
	if not jammer_data then
		return
	end
	
	self._holder:SetBuff("pocket_ecm_feedback",
		{
			value = jammer_data.nr_ticks
		},
		false,
		peer_id
	)
end





-- from here onward, buff-specific events

function KineticTrackerHandler:on_headshot_dealt(pm)
	
	-- bullseye
	if pm._on_headshot_dealt_t then
		if pm:has_category_upgrade("player", "headshot_regen_armor_bonus", 0) then
			self._holder:AddBuff("bullseye",{value=value,end_t = pm._on_headshot_dealt_t,total_t = tweak_data.upgrades.on_headshot_dealt_cooldown})
		end
	end
end

-- for some reason this is called directly from the temporarypropertymanager and not through the playermanager wrapper
function KineticTrackerHandler:on_enemy_killed_bloodthirst(pm,equipped_unit,variant,killed_unit)	
	--local data = pm:upgrade_value("player", "melee_kill_increase_reload_speed", 0)
	local temp_prop = pm._temporary_properties._properties.bloodthirst_reload_speed
	if temp_prop then
		self:on_activate_temporary_property(pm,"bloodthirst_reload_speed",temp_prop[2],temp_prop[1])
	end
end

function KineticTrackerHandler:on_reset_melee_dmg_multiplier(pm)
	self._holder:RemoveBuff("bloodthirst_melee")
end

function KineticTrackerHandler:on_set_melee_dmg_multiplier(pm,value)
	self._holder:AddBuff("bloodthirst_melee",{value=pm._melee_dmg_mul})
end

-- may need to modify the coroutine for true accuracy
function KineticTrackerHandler:on_expert_handling_event(pm,unit,attack_data)
--[[
	local attacker_unit = attack_data.attacker_unit
	local variant = attack_data.variant

	if attacker_unit == pm:player_unit() and pm:is_current_weapon_of_category("pistol") and variant == "bullet" and not pm._coroutine_mgr:is_running(PlayerAction.ExpertHandling) then
		local data = pm:upgrade_value("pistol", "stacked_accuracy_bonus", nil)

		if data and type(data) ~= "number" then
			self._holder:AddBuff("desperado",{value = pm:get_property("desperado"),end_t = Application:time() + data.max_time,total_t = data.max_time})
		end
	end
--]]
end

-- may need to modify the coroutine for true accuracy
function KineticTrackerHandler:on_enter_trigger_happy_event(pm,unit,attack_data)
--[[
	local attacker_unit = attack_data.attacker_unit
	local variant = attack_data.variant

	if attacker_unit == self:player_unit() and variant == "bullet" and not self._coroutine_mgr:is_running("trigger_happy") and self:is_current_weapon_of_category("pistol") then
		local data = self:upgrade_value("pistol", "stacking_hit_damage_multiplier", 0)

		if data ~= 0 then
			NobleHUD:AddBuff("trigger_happy",{end_t = Application:time() + data.max_time,value = data.damage_bonus})
--			NobleHUD:log("_on_enter_trigger_happy_event(" .. NobleHUD.table_concat({damage_bonus = data.damage_bonus,max_stacks = data.max_stacks,end_t = ,time = Application:time()},",","="))
--			self._coroutine_mgr:add_coroutine("trigger_happy", PlayerAction.TriggerHappy, self, data.damage_bonus, data.max_stacks, Application:time() + data.max_time)
		end
	end
--]]
end

-- may need to modify the coroutine for true accuracy
function KineticTrackerHandler:on_enter_shock_and_awe_event(pm)
--[[
	if NobleHUD:IsBuffEnabled("shock_and_awe_reload_multiplier") and not self._coroutine_mgr:is_running("automatic_faster_reload") then
		local equipped_unit = self:get_current_state()._equipped_unit
		local data = self:upgrade_value("player", "automatic_faster_reload", nil)
		local is_grenade_launcher = equipped_unit:base():is_category("grenade_launcher")

		if data and equipped_unit and not is_grenade_launcher and (equipped_unit:base():fire_mode() == "auto" or equipped_unit:base():is_category("bow", "flamethrower")) then

			local reload_multiplier = data.max_reload_increase
			local ammo = equipped_unit:base():get_ammo_max_per_clip()
			if self:has_category_upgrade("player", "automatic_mag_increase") and equipped_unit:base():is_category("smg", "assault_rifle", "lmg") then
				ammo = ammo - self:upgrade_value("player", "automatic_mag_increase", 0)
			end
			
			local min_bullets = data.min_bullets
			if min_bullets < ammo then 
				local num_bullets = ammo - min_bullets
				for i = 1, num_bullets, 1 do
					reload_multiplier = math.max(data.min_reload_increase, reload_multiplier * data.penalty)
				end
			end
			
			NobleHUD:AddBuff("shock_and_awe_reload_multiplier",{value = string.format("%.1f",reload_multiplier)})

		end
	end
	
--]]
end

function KineticTrackerHandler:on_messiah_recharge_event(pm)
	local count = pm._messiah_charges
	if count > 0 then 
		self._holder:AddBuff("messiah_charge",{value = count})
	else
		self._holder:RemoveBuff("messiah_charge")
	end
end

-- should be posthooked to the coroutine
function KineticTrackerHandler:on_messiah_event(pm)
	if pm._messiah_charges > 0 and pm._current_state == "bleed_out" and not pm._coroutine_mgr:is_running("get_up_messiah") then
		pm._holder:AddBuff("messiah_ready",{value=true})
	end
end

function KineticTrackerHandler:on_use_messiah_charge(pm)
	self._holder:RemoveBuff("messiah_ready")
	local count = pm._messiah_charges
	if count > 0 then 
		self._holder:AddBuff("messiah_charge",{value = count})
	else
		self._holder:RemoveBuff("messiah_charge")
	end
end

function KineticTrackerHandler:on_set_damage_absorption(absorption)
	
end

-- need to rethink how to measure biker stacks
function KineticTrackerHandler:on_chk_wild_kill_counter()
--[[
	local player = self:local_player()
	if not player then 
		return
	end
	if not (self:has_category_upgrade("player", "wild_health_amount") or self:has_category_upgrade("player", "wild_armor_amount")) then
		return
	end
	
--	local max_trigger_time
	local wild_kill_triggers = self._wild_kill_triggers or {}
	local triggers_count = #wild_kill_triggers
	local triggers_left = tweak_data.upgrades.wild_max_triggers_per_time - triggers_count
	if triggers_left > 0 then 
		for i,trigger_time in pairs(wild_kill_triggers) do 
			--NobleHUD:log("Triggered wild kill counter: " .. tostring(i) .. ": " .. tostring(trigger_time),{color=Color.green})
--			max_trigger_time = 
		end
		NobleHUD:AddBuff("wild_kill_counter",{value=triggers_left,start_t = Application:time(),end_t=wild_kill_triggers[#wild_kill_triggers]})
	end
--]]
end




return KineticTrackerHandler