

Hooks:Register("KineticTrackers_OnMenuLoaded")


Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_KineticTrackers", function( loc )
	if not BeardLib then
		local localization_path = KineticTrackerCore._default_localization_path
		loc:load_localization_file( localization_path )
	end
end)

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_KineticTrackers", function(menu_manager, nodes)
	--init menu objects by name here
	for shortname,data in pairs(KineticTrackerCore.menu_data.menus) do 
		local new_menu = MenuHelper:NewMenu(data.id)
		data.menu_object = new_menu
	end
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_KineticTrackers", function(menu_manager, nodes)
	for buff_name,buff_data in pairs(KineticTrackerCore.tweak_data) do 
		local source = buff_data.source
		local parent_menu_id
		if source == "skill" then 
			local skilltree_index = buff_data.icon_data.tree
			local shortname = skilltree_index and KineticTrackerCore.menu_data.skilltree_lookup[skilltree_index]
			local parent_menu_data = shortname and KineticTrackerCore.menu_data.menus[shortname]
			parent_menu_id = parent_menu_data and parent_menu_data.id
		elseif source == "perk" then 
			local perkdeck_index = buff_data.icon_data.tree
			local shortname = perkdeck_index and KineticTrackerCore.menu_data.perkdeck_lookup[perkdeck_index]
			local parent_menu_data = shortname and KineticTrackerCore.menu_data.menus[shortname]
			parent_menu_id = parent_menu_data and parent_menu_data.id
		elseif KineticTrackerCore.menu_data.menus[source] then 
			parent_menu_id = KineticTrackerCore.menu_data.menus[source].id
		else
			KineticTrackerCore:Log("ERROR: No parent menu found for buff " .. tostring(buff_name) .. " during MenuManagerPopulateCustomMenus 1")
			break
		end
		
-----------TODO create a new submenu for each buff		
		
		if parent_menu_id and not (KineticTrackerCore.menu_data.menus[parent_menu_id] and KineticTrackerCore.menu_data.menus[parent_menu_id].disabled) then 
				
			local callback_name = "callback_kitr_set_buff_" .. buff_name .."_time_display_mode"
			MenuCallbackHandler[callback_name] = function(self,item)
				log("callback " .. buff_name .. " " .. tostring(item:value()))
			end
			
			local default_multiplechoice_value = 1
			
			local item_id = "kitr_set_buff_" .. buff_name .. "_time_display_mode"
			MenuHelper:AddMultipleChoice({
				id = item_id,
				title = "menu_kitr_set_buff_generic_time_display_mode_title",
				desc = "menu_kitr_set_buff_generic_time_display_mode_desc",
				callback = callback_name,
				items = {
					"menu_kitr_time_display_seconds",
					"menu_kitr_time_display_minutes"
				},
				value = default_multiplechoice_value,
				menu_id = parent_menu_id,
				priority = 1
			})
		else
			KineticTrackerCore:Log("ERROR: No parent menu found for buff " .. tostring(buff_name) .. " during MenuManagerPopulateCustomMenus 2")
		end
		
	end
	--add items to menus here
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_KineticTrackers", function(menu_manager, nodes)
	--build menus here
	--AddMenuItem calls here
	
	local function create_menu(index,data)
		if not data.disabled then 
			local menu_name = data.id
			nodes[menu_name] = MenuHelper:BuildMenu(
				menu_name,
				{
					area_bg = data.area_bg,
					back_callback = data.back_callback_name and MenuCallbackHandler[data.back_callback_name],
					focus_changed_callback = data.focus_changed_callback_name
				}
			)
			if not data.skip_add_menu_item then
				local parent_menu_name = data.parent
				local parent_menu = KineticTrackerCore.menu_data.menus[parent_menu_name] and KineticTrackerCore.menu_data.menus[parent_menu_name].menu_object or MenuHelper:GetMenu(parent_menu_name)
				MenuHelper:AddMenuItem(parent_menu,menu_name,data.title,data.desc,data.menu_position or index,data.subposition)
			end
		end
	end
	
	create_menu(nil,KineticTrackerCore.menu_data.menus.main)
	create_menu(nil,KineticTrackerCore.menu_data.menus.buffs)
	create_menu(nil,KineticTrackerCore.menu_data.menus.general)
	create_menu(nil,KineticTrackerCore.menu_data.menus.perk)
	create_menu(nil,KineticTrackerCore.menu_data.menus.skill)
	
	for index,shortname in ipairs(KineticTrackerCore.menu_data.perkdeck_lookup) do 
		local data = KineticTrackerCore.menu_data.menus[shortname]
		if data then 
			create_menu(index,data)
		end
	end
	
	for index,shortname in ipairs(KineticTrackerCore.menu_data.skilltree_lookup) do 
		local data = KineticTrackerCore.menu_data.menus[shortname]
		if data then 
			create_menu(index,data)
		end
	end
	
	
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
	MenuHelper:LoadFromJsonFile(KineticTrackerCore._options_path, KineticTrackerCore, KineticTrackerCore.settings)
end)
