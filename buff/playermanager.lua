	
Hooks:PostHook(PlayerManager,"check_skills","playermanager_checkskills_kinetictrackers",function(self,...)
	Hooks:Call("PlayerManager_OnCheckSkills",self,...)
end)

Hooks:PostHook(PlayerManager,"set_property","noblehud_set_property",function(self,name,value)
	local buff_id = KineticTrackerCore:GetBuffIdFromProperty(name)
	if buff_id then 
		KineticTrackerCore:AddBuff(buff_id,{value=value})
	else
		KineticTrackerCore:Log("PlayerManager:set_property(" .. tostring(name) .. "," .. tostring(value) .. ")",{color=Color.yellow})
	end
end)


Hooks:PostHook(PlayerManager,"remove_property","noblehud_remove_property",function(self,name)
	local buff_id = KineticTrackerCore:GetBuffIdFromProperty(name)
	if buff_id then 
		KineticTrackerCore:RemoveBuff(buff_id)
	else
		KineticTrackerCore:Log("PlayerManager:remove_property(" .. tostring(name) .. ")",{color=Color.yellow})
	end
end)

Hooks:PostHook(PlayerManager,"activate_temporary_upgrade","noblehud_activate_temporary_upgrade",function(self,category, upgrade)
	local buff_id = KineticTrackerCore:GetBuffIdFromTemporaryUpgrade(category,upgrade)
	local end_t,value
	if buff_id then 
		end_t = self:get_activate_temporary_expire_time(category,upgrade)
		value = self:temporary_upgrade_value(category,upgrade)
		KineticTrackerCore:AddBuff(buff_id,{end_t = end_t,value = value}) --i'd have to re-calculate stuff or overwrite the function to use duration instead of end_t. i'd rather risk having desynced end times
	else
		KineticTrackerCore:Log("PlayerManager:activate_temporary_upgrade(" .. KineticTrackerCore.concat_tbl_with_keys({category=category,upgrade=upgrade,end_t=end_t,value=value},",","=") .. ")",{color=Color.yellow})
	end
end)

Hooks:PostHook(PlayerManager,"activate_temporary_property","noblehud_activate_temporary_property",function(self,name, time, value)
	local buff_id = KineticTrackerCore:GetBuffIdFromTemporaryProperty(name)
	if buff_id then 
		KineticTrackerCore:AddBuff(buff_id,{duration=time,value=value})
	else
		KineticTrackerCore:Log("PlayerManager:activate_temporary_property(" .. KineticTrackerCore.concat_tbl_with_keys({name=name,time=time,value=value},",","=") .. ")",{color=Color.yellow})
	end
end)

Hooks:PostHook(PlayerManager,"activate_temporary_upgrade_by_level","noblehud_activate_temporary_upgrade_by_level",function(self,category, upgrade, level)
	local buff_id = KineticTrackerCore:GetBuffIdFromTemporaryUpgrade(category,upgrade)
	local end_t,value
	if buff_id then 
		end_t = self:get_activate_temporary_expire_time(category,upgrade)
		value = self:temporary_upgrade_value(category,upgrade,0)
		KineticTrackerCore:AddBuff(buff_id,{end_t = end_t,value = value})
	else
		KineticTrackerCore:Log("PlayerManager:activate_temporary_upgrade_by_level(" .. KineticTrackerCore.concat_tbl_with_keys({category=category,upgrade=upgrade,level=level,end_t=end_t,value=value},",","=") .. ")",{color=Color.yellow})
	end
end)

Hooks:PostHook(PlayerManager,"add_to_temporary_property","noblehud_add_temporary_property",function(self,name, time, value)
	local buff_id = KineticTrackerCore:GetBuffIdFromTemporaryProperty(name)
	if buff_id then 
		KineticTrackerCore:AddBuff(buff_id,{duration = time,value=value})
	else
		KineticTrackerCore:Log("PlayerManager:add_to_temporary_property(" .. KineticTrackerCore.concat_tbl_with_keys({name=name,time=time,value=value},",","=") .. ")",{color=Color.yellow})
	end
end)
Hooks:PostHook(PlayerManager,"aquire_cooldown_upgrade","noblehud_aquire_cooldown_upgrade",function(self,upgrade)
--upgrade is a table. whoops.
	local name = upgrade.upgrade
	local upgrade_value = self:upgrade_value(upgrade.category,name)
	
	KineticTrackerCore:Log("PlayerManager:aquire_cooldown_upgrade(upgrade=" .. tostring(upgrade) .. ")")
end)

Hooks:PostHook(PlayerManager,"disable_cooldown_upgrade","noblehud_disable_cooldown_upgrade",function(self,category,upgrade)
	local upgrade_value = self:upgrade_value(category, upgrade)
	KineticTrackerCore:Log("PlayerManager:disable_cooldown_upgrade(" .. KineticTrackerCore.concat_tbl_with_keys({category=category,upgrade=upgrade},",","=") .. "), upgrade_value=" .. tostring(upgrade_value))
	if upgrade_value == 0 then
		return
	end

	local t = upgrade_value[2]

--	KineticTrackerCore:AddBuff(upgrade,{duration = t})
end)

do return end



--[[
Hooks:PreHook(PlayerManager,"_change_player_state","noblehud_on_game_state_changed",function(self)
	if not (NobleHUD and game_state_machine) then
		return 
	end
	local previous_state = game_state_machine:last_queued_state_name()
	local state = self._player_states[self._current_state]
	NobleHUD:OnGameStateChanged(previous_state,state)
end)
--]]


--[[
Hooks:PostHook(PlayerManager,"sync_tag_team","noblehud_buff_tag_team",function(self,tagged,owner,end_time)
	
end)
--]]

Hooks:PreHook(PlayerManager,"on_headshot_dealt","noblehud_buff_bullseye",function(self)
	if not self:player_unit() then return end

	if self._on_headshot_dealt_t and Application:time() < self._on_headshot_dealt_t then
		return
	end

	if self:upgrade_value("player", "headshot_regen_armor_bonus", 0) > 0 then 
		if self._on_headshot_dealt_t then 
			NobleHUD:AddBuff("bullseye",{end_t = self._on_headshot_dealt_t})
		else --just in case
			NobleHUD:AddBuff("bullseye",{duration = (tweak_data.upgrades.on_headshot_dealt_cooldown or 0)})
		end
	end
end)

Hooks:PreHook(PlayerManager,"_on_enemy_killed_bloodthirst","noblehud_buff_bloodthirst",function(self,equipped_unit,variant,killed_unit)
	if variant == "melee" then
		local data = self:upgrade_value("player", "melee_kill_increase_reload_speed", 0)
		if data ~= 0 then 
--			NobleHUD:log("bloodthirst [1] = " .. tostring(data[1]) .. ",[2] = " .. tostring(data[2]))
			NobleHUD:AddBuff("bloodthirst_reload_speed",{duration=data[2]})
		end
	end	
--	managers.player:has_active_temporary_property("melee_kill_increase_reload_speed")
end)

Hooks:PostHook(PlayerManager,"reset_melee_dmg_multiplier","noblehud_buff_bloodthirst_melee_remove",function(self)
	NobleHUD:RemoveBuff("bloodthirst_melee")
end)

Hooks:PostHook(PlayerManager,"set_melee_dmg_multiplier","noblehud_buff_bloodthirst_melee",function(self,value)
	NobleHUD:AddBuff("bloodthirst_melee",{value=value})
end)

Hooks:PreHook(PlayerManager,"_on_expert_handling_event","noblehud_buff_desperado",function(self,unit, attack_data)
	local attacker_unit = attack_data.attacker_unit
	local variant = attack_data.variant

	if attacker_unit == self:player_unit() and self:is_current_weapon_of_category("pistol") and variant == "bullet" and not self._coroutine_mgr:is_running(PlayerAction.ExpertHandling) then
		local data = self:upgrade_value("pistol", "stacked_accuracy_bonus", nil)

		if data and type(data) ~= "number" then
			NobleHUD:AddBuff("desperado",{end_t = Application:time() + data.max_time,value = data.max_stacks})
		end
	end
end)

Hooks:PreHook(PlayerManager,"_on_enter_trigger_happy_event","noblehud_buff_trigger_happy",function(self,unit, attack_data)
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
end)

Hooks:PreHook(PlayerManager,"_on_enter_shock_and_awe_event","noblehud_buff_lock_n_load",function(self)
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
	
end)

Hooks:PostHook(PlayerManager,"_on_messiah_recharge_event","noblehud_buff_messiah",function(self)
	local count = self._messiah_charges
	if count > 0 then 
		NobleHUD:AddBuff("messiah_charge",{value = count})
	else
		NobleHUD:RemoveBuff("messiah_charge")
	end
end)

Hooks:PreHook(PlayerManager,"_on_messiah_event","noblehud_buff_messiah_event",function(self)
	if self._messiah_charges > 0 and self._current_state == "bleed_out" and not self._coroutine_mgr:is_running("get_up_messiah") then
		NobleHUD:AddBuff("messiah_ready")
	end
end)

Hooks:PostHook(PlayerManager,"use_messiah_charge","noblehud_buff_messiah_remove",function(self)
	NobleHUD:RemoveBuff("messiah_ready")
	local count = self._messiah_charges
	if count > 0 then 
		NobleHUD:AddBuff("messiah_charge",{value = count})
	else
		NobleHUD:RemoveBuff("messiah_charge")
	end
end)

Hooks:PostHook(PlayerManager,"chk_wild_kill_counter","noblehud_buff_biker",function(self,killed_unit,variant)
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
end)