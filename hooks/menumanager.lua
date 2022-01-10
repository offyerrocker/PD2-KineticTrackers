

Hooks:Register("KineticTrackers_OnMenuLoaded")


Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_KineticTrackers", function( loc )
	if not BeardLib then
		local localization_path = KineticTrackerCore._default_localization_path
		loc:load_localization_file( localization_path )
	end
end)

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_KineticTrackers", function(menu_manager, nodes)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_KineticTrackers", function(menu_manager, nodes)
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_KineticTrackers", function(menu_manager, nodes)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_KineticTrackers", function(menu_manager)
--[[
	MenuCallbackHandler.callback_modtemplate_toggle = function(self,item)
		local value = item:value() == "on"
		MyNewModGlobal.settings.toggle_setting = value
		MyNewModGlobal:Save()
	end

	MenuCallbackHandler.callback_modtemplate_slider = function(self,item)
		MyNewModGlobal.settings.slider_setting = tonumber(item:value())
		MyNewModGlobal:Save()
	end

	MenuCallbackHandler.callback_modtemplate_multiplechoice = function(self,item)
		MyNewModGlobal.settings.multiplechoice_setting = tonumber(item:value())
		MyNewModGlobal:Save()
	end

	MenuCallbackHandler.callback_modtemplate_button = function(self,item)
		--on menu button click: do nothing in particular
	end
	
	MenuCallbackHandler.callback_modtemplate_keybind_2 = function(self)
		--on keybind press: do nothing in particular
	end	
	
	MenuCallbackHandler.callback_modtemplate_back = function(this)
		--on menu exit: do nothing in particular
	end
	--]]
	KineticTrackerCore:LoadSettings()
--	MenuHelper:LoadFromJsonFile(KineticTrackerCore._options_path, KineticTrackerCore, KineticTrackerCore.settings)
end)
