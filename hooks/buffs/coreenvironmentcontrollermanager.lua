Hooks:PostHook(CoreEnvironmentControllerManager,"set_flashbang","kt_coreenv_onflashbanged",function(self,flashbang_pos, line_of_sight, travel_dis, linear_dis, duration)
	managers.kinetictracker:AddBuff("flashbang",{end_t = Application:time() + self._current_flashbang,total_t = self._current_flashbang})
end)