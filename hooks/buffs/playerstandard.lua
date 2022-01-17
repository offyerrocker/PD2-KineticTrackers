Hooks:PostHook(PlayerStandard,"_update_omniscience","noblehud_buff_sixth_sense",function(self,t,dt)
	if managers.player:has_category_upgrade("player", "standstill_omniscience") then 
		if self._state_data.omniscience_t then 
			NobleHUD:AddBuff("sixth_sense",{end_t = self._state_data.omniscience_t})
		else
			NobleHUD:RemoveBuff("sixth_sense")		
		end
--		if managers.player:current_state() == "civilian" or self:_interacting() or self._ext_movement:has_carry_restriction() or self:is_deploying() or self:_changing_weapon() or self:_is_throwing_projectile() or self:_is_meleeing() or self:_on_zipline() or self._moving or self:running() or self:_is_reloading() or self:in_air() or self:in_steelsight() or self:is_equipping() or self:shooting() or not managers.groupai:state():whisper_mode() or not tweak_data.player.omniscience then
--			NobleHUD:RemoveBuff("sixth_sense")
--		elseif self._state_data.omniscience_t then
--			NobleHUD:AddBuff("sixth_sense",{end_t = 1,persistent_timer = true})
--		end
	end
end)

Hooks:PostHook(PlayerStandard,"_do_melee_damage","noblehud_buff_overdog",function(self,t, bayonet_melee, melee_hit_ray, melee_entry, hand_id)
	if managers.player:has_category_upgrade("melee", "stacking_hit_damage_multiplier") then
		local state_data = self._state_data.stacking_dmg_mul or {}
		local stack = self._state_data.stacking_dmg_mul.melee or {
			nil,
			0
		}
		local dmg_multiplier = 1
		if stack[1] and t < stack[1] then
			dmg_multiplier = dmg_multiplier * (1 + managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier", 0) * stack[2])
		else
--			stack[2] = 0
		end
		if dmg_multiplier > 1 then 
			NobleHUD:AddBuff("overdog",{value = dmg_multiplier,duration = stack[2] or managers.player:upgrade_value("melee", "stacking_hit_expire_t", 1)})
		else
			NobleHUD:RemoveBuff("overdog")
		end
		
--		Console:SetTrackerValue("trackera","overdog: " .. tostring(dmg_multiplier) .. " " .. NobleHUD.random_character())
--		Console:SetTrackerValue("trackerb","stack1: " .. tostring(stack[1]) .. " " .. NobleHUD.random_character())
--		Console:SetTrackerValue("trackerc","stack2: " .. tostring(stack[2]) .. " " .. NobleHUD.random_character())
	end


end)