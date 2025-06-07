-- this should be called regardless 
Hooks:PostHook(GroupAIStateBesiege,"set_phalanx_damage_reduction_buff","kt_groupaistatebesiege_setcptwinters",function(self,damage_reduction)
	local law1team = self:_get_law1_team()
	local _damage_reduction = law1team.damage_reduction
	if _damage_reduction and _damage_reduction > 0 then
		managers.kinetictrackers:AddBuff("winters_resistance",{value=_damage_reduction})
	else
		managers.kinetictrackers:RemoveBuff("winters_resistance")
	end
end)