Hooks:PostHook(CoreEnvironmentControllerManager,"set_flashbang","kt_buff_flashbang",function(self,flashbang_pos, line_of_sight, travel_dis, linear_dis, duration)
	NobleHUD:AddBuff("flashbang",{duration = self._current_flashbang})
end)