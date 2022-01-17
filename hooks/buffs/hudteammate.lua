
Hooks:PostHook(HUDTeammate,"set_absorb_active","noblehud_buff_hysteria",function(self,absorb_amount)
	if self._main_player then 
		if absorb_amount > 0 then
			NobleHUD:AddBuff("hysteria",{value = absorb_amount})
		else 
			NobleHUD:RemoveBuff("hysteria")
		end
	end
end)

Hooks:PostHook(HUDTeammate,"set_delayed_damage","noblehud_buff_stoic",function(self,damage)
	if self._main_player then 
		if damage > 0 then 
			NobleHUD:AddBuff("delayed_damage",{value = damage})
		else
			NobleHUD:RemoveBuff("delayed_damage")
		end
	end
end)


Hooks:PostHook(HUDTeammate,"set_stored_health","noblehud_buff_expresident",function(self,stored_health)
	if self._main_player then 
		if stored_health > 0 then 
			NobleHUD:AddBuff("expresident",{value = stored_health})
		else
			NobleHUD:RemoveBuff("expresident")
		end
	end
end)

Hooks:PostHook(HUDTeammate,"activate_ability_radial","noblehud_buff_throwables",function(self,time_left,time_total)
--	NobleHUD:log("doing buff activate_ability_radial(" .. tostring(time_left) .. "," .. tostring(time_total)..")")
	if self._main_player then 			
		if time_left then
			local ability,amount = managers.blackmarket:equipped_grenade()
			if ability then 
				NobleHUD:AddBuff(ability,{duration = time_left})
			else
				NobleHUD:log("activate_ability_radial(" .. tostring(time_left) .. "," .. tostring(time_total)..") No ability found!")
			end
		end
	end
end)