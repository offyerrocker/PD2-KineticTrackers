
Hooks:PostHook(PlayerInventory,"_start_feedback_effect","noblehud_buff_pocket_ecm_jammer_feedback",function(self,end_time,interval,range)
	NobleHUD:AddBuff("pocket_ecm_jammer_feedback",{end_t = end_time or (TimerManager:game():time() + self:get_jammer_time()),timer_source = "game"})
end)

Hooks:PostHook(PlayerInventory,"_start_jammer_effect","noblehud_buff_pocket_ecm_jammer",function(self,end_time)
	NobleHUD:AddBuff("pocket_ecm_jammer",{end_t = end_time or (TimerManager:game():time() + self:get_jammer_time()),timer_source = "game"})
end)

Hooks:PostHook(PlayerInventory,"_stop_jammer_effect","noblehud_buff_pocket_ecm_jammer_remove",function(self,end_time)
--	NobleHUD:RemoveBuff("pocket_ecm_jammer")
end)
--NobleHUD:AddBuff("pocket_ecm_jammer",{end_t = (TimerManager:game():time() + 6),timer_source = "game"})