--or "BeardLibSetupInitFinalize"

Hooks:PostHook(GameSetup,"init_finalize","setup_initfinalize_kinetictrackers",
callback(KineticTrackerCore,KineticTrackerCore,"InitHolder")
--[[
function(self)
	KineticTrackerHolder:new()
end
--]]
)