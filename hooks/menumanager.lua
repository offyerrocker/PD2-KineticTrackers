

Hooks:Register("KineticTrackers_OnMenuLoaded")


Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_KineticTrackers", function( loc )
	if not BeardLib then
		local localization_path = KineticTrackerCore._default_localization_path
		loc:load_localization_file( localization_path )
	end
end)

Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenus_KineticTrackers", function(menu_manager, nodes)
	KineticTrackerCore:LoadSettings() --load earlier than usual for menu generation reasons?
	KineticTrackerCore:InitColorPicker()

	--init menu objects by name here
	
	
	--generate submenus for each buff here
	--including data for later, further menu generation, such as localization and callbacks
	for buff_name,buff_data in pairs(KineticTrackerCore.tweak_data) do 
		
		--check for valid settings for this buff
		local buff_display_setting = KineticTrackerCore.settings.buffs[buff_name] 
		if buff_display_setting then
			if not KineticTrackerCore.default_settings.buffs[buff_name] then 
				KineticTrackerCore:Log("ERROR: MenuManagerSetupCustomMenus: No default settings found for buff " .. tostring(buff_name))
			else
				for k,v in pairs(KineticTrackerCore.default_settings.buffs[buff_name]) do 
					if buff_display_setting[k] == nil then 
						buff_display_setting[k] = v
					end
				end
			end
		else
			KineticTrackerCore.settings.buffs[buff_name] = table.deep_map_copy(KineticTrackerCore.default_settings.buffs[buff_name] or {})
			buff_display_setting = KineticTrackerCore.settings.buffs[buff_name]
		end
	
		local shortname = "buff_" .. tostring(buff_name)
		local menu_id = "menu_kitr_buff_entry_" .. tostring(buff_name)
		local title = buff_data.text_id
		local desc = "menu_kitr_buff_entry_generic_desc"
		local area_bg = "full"
		local back_callback_name = nil
		local focus_changed_callback = nil
		local menu_position = nil
		local subposition = nil
		
		local menu_data = {
			id = menu_id,
			title = title,
			desc = desc,
			area_bg = area_bg,
			back_callback_name = back_callback_name,
			focus_changed_callback = focus_changed_callback,
			menu_position = menu_position,
			subposition = subposition
		}
		KineticTrackerCore.menu_data.buffs_lookup[buff_name] = shortname
		KineticTrackerCore.menu_data.menus[shortname] = menu_data
		
		local parent_menu_id
		local source = buff_data.source
		if source == "skill" then 
			local skilltree_index = buff_data.icon_data.tree
			local parent_shortname = skilltree_index and KineticTrackerCore.menu_data.skilltree_lookup[skilltree_index]
			local parent_menu_data = parent_shortname and KineticTrackerCore.menu_data.menus[parent_shortname]
			parent_menu_id = parent_menu_data and parent_menu_data.id
		elseif source == "perk" then 
			local perkdeck_index = buff_data.icon_data.tree
			local parent_shortname = perkdeck_index and KineticTrackerCore.menu_data.perkdeck_lookup[perkdeck_index]
			local parent_menu_data = parent_shortname and KineticTrackerCore.menu_data.menus[parent_shortname]
			parent_menu_id = parent_menu_data and parent_menu_data.id
		elseif source and KineticTrackerCore.menu_data.menus[source] then 
			KineticTrackerCore:Log("ERROR: No parent menu found for buff " .. tostring(buff_name) .. ". Using fallback " .. tostring(source))
			parent_menu_data = KineticTrackerCore.menu_data.menus[source]
			parent_menu_id = parent_menu_data and parent_menu_data.id
		else
			KineticTrackerCore:Log("ERROR: No parent menu found for buff " .. tostring(buff_name) .. " with source " .. tostring(source) ..  " during MenuManagerSetupCustomMenus 1")
			break
		end
		
		menu_data.parent = parent_menu_id
		
	end
	
	for shortname,data in pairs(KineticTrackerCore.menu_data.menus) do 
		local new_menu = MenuHelper:NewMenu(data.id)
		data.menu_object = new_menu
	end
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenus_KineticTrackers", function(menu_manager, nodes)
	for buff_name,buff_data in pairs(KineticTrackerCore.tweak_data) do 
		local shortname = KineticTrackerCore.menu_data.buffs_lookup[buff_name]
		local menu_data = KineticTrackerCore.menu_data.menus[shortname]
		if menu_data then 
			if not menu_data.disabled then 
				local menu_id = menu_data.id --template menu id for all options in this buff's submenu
				local parent_menu_id = menu_id --the parent of this buff's submenu
				
				local buff_display_setting = KineticTrackerCore.settings.buffs[buff_name]
				
--				local default_buff_options = buff_data.menu_options or {}
				
				local submenu_option_items = {}
				
				
				--insert "text" via disabled button
				do
					local option_id = menu_id .. "_header_label"
					table.insert(submenu_option_items,1,{
						type = "button",
						id = option_id,
						title = buff_data.text_id,
						desc = "menu_kitr_buff_entry_generic_desc",
						disabled = true,
						menu_id = parent_menu_id
					})
					--callback not necessary
				end
				
				--insert buff main enabled toggle
				do 
					local var_name = "enabled"
					local option_id = menu_id .. "_toggle_enabled"
					local callback_name = "callback_" .. option_id
					MenuCallbackHandler[callback_name] = function(self,item)
						local item_value = item:value() == "on"
						KineticTrackerCore.settings.buffs[buff_name][var_name] = item_value
						if buff_data.upd_func then 
							KineticTrackerCore:AddBuff(buff_name,{enabled=item_value})
						end
						
						KineticTrackerCore:SaveSettings()
					end
					table.insert(submenu_option_items,1,{
						type = "toggle",
						id = option_id,
						title = "menu_kitr_buff_option_generic_toggle_enabled_title",
						desc = "menu_kitr_buff_option_generic_toggle_enabled_desc",
						callback = callback_name,
						value = buff_display_setting[var_name],
						menu_id = parent_menu_id
					})
				end

				--insert value threshold check
				if buff_data.display_format and buff_data.display_format ~= "" then 
					--todo this needs a better indication of when there is a display value
					local var_name = "value_threshold"
					local option_id = menu_id .. "_value_threshold"
					local callback_name = "callback_" .. option_id
					MenuCallbackHandler[callback_name] = function(self,item)
						local item_value = tonumber(item:value())
						KineticTrackerCore.settings.buffs[buff_name][var_name] = item_value
						KineticTrackerCore:SaveSettings()
					end
					
					table.insert(submenu_option_items,1,{
						type = "slider",
						id = option_id,
						title = "menu_kitr_buff_option_generic_slider_value_threshold_title",
						desc = "menu_kitr_buff_option_generic_slider_value_threshold_desc",
						callback = callback_name,
						value = buff_display_setting[var_name],
						min = -100,
						max = 100,
						step = 1,
						show_value = true,
						menu_id = parent_menu_id
					})
					--insert value display options?
					--stack, mul, or other
				end
				
				
				if buff_data.show_timer then 
					--insert timer display options
					--insert flashing option?

					
					--insert timer enabled toggle
					do 
						local var_name = "timer_enabled"
						local option_id = menu_id .. "_timer_enabled"
						local callback_name = "callback_" .. option_id
						MenuCallbackHandler[callback_name] = function(self,item)
							local item_value = item:value() == "on"
							KineticTrackerCore.settings.buffs[buff_name][var_name] = item_value
							KineticTrackerCore:SaveSettings()
						end
						table.insert(submenu_option_items,1,{
							type = "toggle",
							id = option_id,
							title = "menu_kitr_buff_option_generic_toggle_timer_title",
							desc = "menu_kitr_buff_option_generic_toggle_timer_desc",
							callback = callback_name,
							value = buff_display_setting[var_name],
							menu_id = parent_menu_id
						})
					end
					
					table.insert(submenu_option_items,1,{
						type = "divider",
						id = menu_id .. "_divider_1",
						size = 16,
						menu_id = parent_menu_id
					})
					
					--insert timer format
					do 
						local var_name = "timer_minutes_display" 
						local option_id = menu_id .. "_timer_minutes_display"
						local callback_name = "callback_" .. option_id
						MenuCallbackHandler[callback_name] = function(self,item)
							local item_value = tonumber(item:value())
							KineticTrackerCore.settings.buffs[buff_name][var_name] = item_value
							KineticTrackerCore:SaveSettings()
						end
					
						table.insert(submenu_option_items,1,{
							type = "multiple_choice",
							id = option_id,
							title = "menu_kitr_buff_option_generic_multiplechoice_timer_display_minutes_title",
							desc = "menu_kitr_buff_option_generic_multiplechoice_timer_display_minutes_desc",
							callback = callback_name,
							items = {
								"menu_kitr_timer_display_minutes",
								"menu_kitr_timer_display_seconds"
							},
							value = buff_display_setting[var_name] or 1,
							menu_id = parent_menu_id
						})
					end

					--insert timer precision
					do 
						local var_name = "timer_precision"
						local option_id = menu_id .. "_timer_precision"
						local callback_name = "callback_" .. option_id
						MenuCallbackHandler[callback_name] = function(self,item)
							local item_value = math.round(tonumber(item:value()))
							KineticTrackerCore.settings.buffs[buff_name][var_name] = item_value
							KineticTrackerCore:SaveSettings()
						end
						
						table.insert(submenu_option_items,1,{
							type = "slider",
							id = option_id,
							title = "menu_kitr_buff_option_generic_slider_timer_precision_title",
							desc = "menu_kitr_buff_option_generic_slider_timer_precision_desc",
							callback = callback_name,
							value = buff_display_setting[var_name] or 2,
							min = 0,
							max = 3,
							step = 1,
							show_value = true,
							menu_id = parent_menu_id
						})
					end
					
					--insert flashing multiplechoice
					do 
						local var_name = "timer_flashing_mode"
						local option_id = menu_id .. "_timer_flashing_mode"
						local callback_name = "callback_" .. option_id
						MenuCallbackHandler[callback_name] = function(self,item)
							local item_value = tonumber(item:value())
							KineticTrackerCore.settings.buff[buff_name][var_name] = item_value
							KineticTrackerCore:SaveSettings()
						end
						
						table.insert(submenu_option_items,1,{
							type = "multiple_choice",
							id = option_id,
							title = "menu_kitr_buff_option_generic_multiplechoice_timer_flashing_mode_title",
							desc = "menu_kitr_buff_option_generic_multiplechoice_timer_flashing_mode_desc",
							callback = callback_name,
							items = {
								"menu_kitr_timer_flashing_mode_below_threshold",
								"menu_kitr_timer_flashing_mode_always",
								"menu_kitr_timer_flashing_mode_never"
							},
							value = buff_display_setting[var_name],
							menu_id = parent_menu_id
						})
					end
					
					--insert flashing threshold (flash when timer is below x seconds)
					do 
						local var_name = "timer_flashing_threshold"
						local option_id = menu_id .. "_timer_flashing_threshold"
						local callback_name = "callback_" .. option_id
						MenuCallbackHandler[callback_name] = function(self,item)
							local item_value = tonumber(item:value())
							KineticTrackerCore.settings.buff[buff_name][var_name] = item_value
							KineticTrackerCore:SaveSettings()
						end
						
						table.insert(submenu_option_items,1,{
							type = "slider",
							id = option_id,
							title = "menu_kitr_buff_option_generic_multiplechoice_timer_flashing_threshold_title",
							desc = "menu_kitr_buff_option_generic_multiplechoice_timer_flashing_threshold_desc",
							callback = callback_name,
							value = buff_display_setting[var_name],
							min = 0,
							max = 10,
							step = 1,
							show_value = true,
							menu_id = parent_menu_id
						})
					end
					
					
					--insert flashing speed (cycle at which flashing pulses)
					do 
						local var_name = "timer_flashing_speed"
						local option_id = menu_id .. "_timer_flashing_speed"
						local callback_name = "callback_" .. option_id
						MenuCallbackHandler[callback_name] = function(self,item)
							local item_value = tonumber(item:value())
							KineticTrackerCore.settings.buff[buff_name][var_name] = item_value
							KineticTrackerCore:SaveSettings()
						end
						
						table.insert(submenu_option_items,1,{
							type = "slider",
							id = option_id,
							title = "menu_kitr_buff_option_generic_multiplechoice_timer_flashing_speed_title",
							desc = "menu_kitr_buff_option_generic_multiplechoice_timer_flashing_speed_desc",
							callback = callback_name,
							value = buff_display_setting[var_name],
							min = 0,
							max = 10,
							step = 1,
							show_value = true,
							menu_id = parent_menu_id
						})
					end
					
					do 
						local var_name = "color"
						local option_id = menu_id .. "_set_color"
						local callback_name = "callback_" .. option_id
						MenuCallbackHandler[callback_name] = function(self,item)
							if ColorPicker then 
								if KineticTrackerCore._colorpicker then 
									ColorPicker:Show({
--										current_color = Color(),
--										done_callback = function() end,
--										changed_callback = function() end
									})
								end
							else
								KineticTrackerCore:callback_show_dialogue_missing_colorpicker()
							end
							KineticTrackerCore:SaveSettings()
						end
						
						table.insert(submenu_option_items,1,{
							type = "button",
							id = option_id,
							title = "menu_kitr_buff_option_generic_button_set_color_title",
							desc = "menu_kitr_buff_option_generic_button_set_color_desc",
							callback = callback_name,
							menu_id = parent_menu_id
						})
					end
					
					
				end
				
				
				
				for i,submenu_option_data in ipairs(submenu_option_items) do 
					submenu_option_data.priority = submenu_option_data.priority or i
					local option_type = submenu_option_data.type
					if option_type == "toggle" then 
						MenuHelper:AddToggle(submenu_option_data)
					elseif option_type == "multiple_choice" then 
						MenuHelper:AddMultipleChoice(submenu_option_data)
					elseif option_type == "slider" then 
						MenuHelper:AddSlider(submenu_option_data)
					elseif option_type == "button" then 
						MenuHelper:AddButton(submenu_option_data)
					elseif option_type == "divider" then
						MenuHelper:AddDivider(submenu_option_data)
					end
				end
			end
		else
			KineticTrackerCore:Log("ERROR: No menu data found for buff " .. tostring(buff_name) .. " during MenuManagerPopulateCustomMenus 1")
		end
		
		
--		local source = buff_data.source

		
-----------TODO create a new submenu for each buff		
		--[[
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
		end
		--]]
	end
	--add items to menus here
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_KineticTrackers", function(menu_manager, nodes)
	--build menus here using AddMenuItem()
	
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
--				KineticTrackerCore:Log("Building menu " .. tostring(menu_name) .. " from parent " .. tostring(parent_menu_name))
			else
--				KineticTrackerCore:Log("Building menu " .. tostring(menu_name))
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
	
	for buff_name,shortname in pairs(KineticTrackerCore.menu_data.buffs_lookup) do 
--		KineticTrackerCore:Log("Building buff menu " .. tostring(buff_name) .. ", shortname " .. tostring(shortname))
		local data = KineticTrackerCore.menu_data.menus[shortname]
		if data then 
			create_menu(nil,data)
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
	MenuHelper:LoadFromJsonFile(KineticTrackerCore._options_path, KineticTrackerCore, KineticTrackerCore.settings)
end)
