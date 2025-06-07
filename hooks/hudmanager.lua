Hooks:PostHook(HUDManager,"_setup_workspaces","kt_hudmanager_setup_ws",function(self)
	KineticTrackerCore._holder:CreatePanel(self._fullscreen_workspace:panel())
end)