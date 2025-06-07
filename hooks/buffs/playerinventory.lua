Hooks:PostHook(PlayerInventory,"_start_jammer_effect","kt_plinv_startjammer",function(self,end_time)
	managers.kinetictrackers:on_start_pocket_ecm_jammer(self,end_time)
end)

Hooks:PostHook(PlayerInventory,"_stop_jammer_effect","kt_plinv_stopjammer",function(self)
	managers.kinetictrackers:on_stop_pocket_ecm_jammer(self)
end)

Hooks:PostHook(PlayerInventory,"_start_feedback_effect","kt_plinv_startfeedback",function(self,end_time)
	managers.kinetictrackers:on_start_pocket_ecm_feedback(self,end_time)
end)

Hooks:PostHook(PlayerInventory,"_stop_feedback_effect","kt_plinv_stopfeedback",function(self)
	managers.kinetictrackers:on_stop_pocket_ecm_feedback(self)
end)

Hooks:PostHook(PlayerInventory,"_do_feedback","kt_plinv_dofeedback",function(self)
	managers.kinetictrackers:on_pocket_ecm_feedback_tick(self)
end)
