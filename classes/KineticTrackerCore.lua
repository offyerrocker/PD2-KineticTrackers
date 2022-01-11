--[[
	todo: 
	 use user's per-buff show-timer setting and time format string
	
	separate entries for combat_medic property and timed buff to avoid possible conflicts (in practice it's fine but i'd prefer it to be more waterproof)
	
	change buff behavior to still add disabled buffs but not show them;
		this allows buffs to still be accurate if one was present while being enabled/disabled
	
	separate equipment trackers? (ecm timers, sentry ammo counts, num tripmines out)
	buff customization menus
	
--]]

KineticTrackerCore = _G.KineticTrackerCore or {}


KineticTrackerCore._path = ModPath
KineticTrackerCore._options_path = ModPath .. "menu/options.json"
KineticTrackerCore._default_localization_path = ModPath .. "loc/english.json"
KineticTrackerCore._save_path = SavePath .. "KineticTrackers.json"

KineticTrackerCore.default_settings = {
	logs_enabled = true,
	toggle_setting = false,
	slider_setting = 0,
	multiplechoice_setting = 1
}
KineticTrackerCore.settings = table.deep_map_copy(KineticTrackerCore.default_settings)
KineticTrackerCore.default_buff_settings = {
	--not used
}


-------------------------------------------------------------
--*********************    Utils   *********************--
-------------------------------------------------------------

function KineticTrackerCore:Log(s,...)
	if self:IsLoggingEnabled() then 
		if Console then 
			return Console:Log("KineticTrackerCore: " .. tostring(s), ...)
		else
			return log(s)
		end
	end
end

function KineticTrackerCore.get_specialization_icon_data_by_tier(spec,tier,no_fallback)
	local sm = managers.skilltree
	local st = tweak_data.skilltree
	
	spec = spec or sm:get_specialization_value("current_specialization")

	local data = st.specializations[spec]
	local max_tier = sm:get_specialization_value(spec, "tiers", "max_tier")
	local tier_data = data and data[tier or max_tier] --this and the arg tier are the only things changed

	if not tier_data then
		if no_fallback then
			return
		else
			return tweak_data.hud_icons:get_icon_data("fallback")
		end
	end

	local guis_catalog = "guis/" .. (tier_data.texture_bundle_folder and "dlcs/" .. tostring(tier_data.texture_bundle_folder) .. "/" or "")
	local x = tier_data.icon_xy and tier_data.icon_xy[1] or 0
	local y = tier_data.icon_xy and tier_data.icon_xy[2] or 0

	return guis_catalog .. "textures/pd2/specialization/icons_atlas", {
		x * 64,
		y * 64,
		64,
		64
	}
end

function KineticTrackerCore.concat_tbl_with_keys(a,pairsep,setsep,...)
	local s = ""
	if type(a) == "table" then 
		pairsep = pairsep or " = "
		setsetp = setsetp or ", "
		for k,v in pairs(a) do 
			if s ~= "" then 
				s = s .. setsetp
			end
			s = s .. tostring(k) .. pairsep .. tostring(v)
		end
	else
		return AdvancedCrosshair.concat_tbl(a,sep,sep2,...)
	end
	return s
end


-------------------------------------------------------------
--*********************    I/O    *********************--
-------------------------------------------------------------

function KineticTrackerCore:SaveSettings()
	local file = io.open(self._save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function KineticTrackerCore:LoadSettings()
	local file = io.open(self._save_path, "r")
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:SaveSettings()
	end
end




function KineticTrackerCore:ResetSettings(category,skip_save)
	if not category then 
		return
	end
	local default_settings = self.default_settings[category]
	if category == "all" then 
		self.settings = table.deep_map_copy(self.default_settings)
	elseif self.default_settings[category] then 
		self.settings[category] = self.default_settings[category]
	end
	if not skip_save then 
		self:SaveSettings()
	end
end




-------------------------------------------------------------
--*********************    Getters    *********************--
-------------------------------------------------------------

function KineticTrackerCore:IsLoggingEnabled()
	return self.settings.logs_enabled
end

function KineticTrackerCore:GetBuffDisplaySettings(id)
	
	local buff_options = {
		absorption = {
			disabled = false,
			color = Color.white,
			timer_enabled = false,
			value_threshold = 0
		},
		dodge_chance = {
			disabled = false,
			color = Color.white,
			timer_enabled = false,
			value_threshold = 0
		},
		crit_chance = {
			disabled = false,
			color = Color.white,
			timer_enabled = false,
			value_threshold = 0
		},
		damage_resistance = {
			disabled = false,
			color = Color.white,
			timer_enabled = false,
			value_threshold = 0
		},
		fixed_health_regen = {
			disabled = false,
			color = Color.white,
			timer_enabled = false,
			value_threshold = 0
		},
		health_regen = {
			disabled = false,
			color = Color.white,
			timer_enabled = false,
			value_threshold = 0
		},
		weapon_reload_speed = {
			disabled = true,
			color = Color.white,
			timer_enabled = false,
			value_threshold = 1
		},
		weapon_damage_bonus = {
			disabled = false,
			color = Color.white,
			timer_enabled = false,
			value_threshold = 1
		},
		
		running_from_death_basic_swap_speed = {
			disabled = true,
			color = Color.white,
			timer_enabled = true,
			value_threshold = 0
		},
		running_from_death_aced = {
			disabled = true,
			color = Color.white,
			timer_enabled = true,
			value_threshold = 0
		},
		combat_medic_steelsight_mul = {
			disabled = true,
			color = Color.white,
			timer_enabled = true,
			value_threshold = 0
		},
		combat_medic_damage_mul = {
			disabled = true,
			color = Color.white,
			timer_enabled = true,
			value_threshold = 0
		}
		
		
	}
	
	
	local default = {
		value_threshold = false,
		timer_enabled = true,
		color = Color.white
	} 
	return buff_options[id] or default
end


-------------------------------------------------------------
--*********************    Core functionality    *********************--
-------------------------------------------------------------

Hooks:Add("PlayerManager_OnCheckSkills","kinetictrackers_on_check_skills_add_listeners",function(pm)
	
end)

function KineticTrackerCore:AddGeneralBuffs()
	if self._holder then 
		self._holder:AddBuff("absorption",{})
		self._holder:AddBuff("dodge_chance",{})
		self._holder:AddBuff("crit_chance",{})
		self._holder:AddBuff("damage_resistance",{})
		self._holder:AddBuff("fixed_health_regen",{})
		self._holder:AddBuff("health_regen",{})
		self._holder:AddBuff("weapon_reload_speed",{})
		self._holder:AddBuff("weapon_damage_bonus",{})
	end
end

function KineticTrackerCore:InitHolder()
	self:InitBuffTweakData()
	
	self._animator = QuickAnimate:new("kinetictracker_animator",{parent = KineticTrackerCore,updater_type = QuickAnimate.updater_types.HUDManager,paused = false})

	self._ws = self._ws or managers.gui_data:create_fullscreen_workspace()
	self._holder = KineticTrackerHolder:new(self)
	
	self:AddGeneralBuffs()
end

function KineticTrackerCore:GetBuffIdFromProperty(name)
	return self.buff_id_lookups.property[name]
end

function KineticTrackerCore:GetBuffIdFromTemporaryProperty(name)
	return self.buff_id_lookups.temporary_property[name]
end

function KineticTrackerCore:GetBuffIdFromTemporaryUpgrade(category,upgrade)
	return self.buff_id_lookups.temporary_upgrade[category] and self.buff_id_lookups.temporary_upgrade[category][upgrade]
end

function KineticTrackerCore:GetBuffIdFromCooldownUpgrade(category,upgrade)
	return self.buff_id_lookups.cooldown_upgrade[category] and self.buff_id_lookups.cooldown_upgrade[category][upgrade]
end

function KineticTrackerCore:InitBuffTweakData(mode)
	self.buff_id_lookups = {
		property = {
			revive_damage_reduction = "combat_medic", --while reviving other player
			shock_and_awe_reload_multiplier = "lock_n_load"
		},
		temporary_property = {
			revive_damage_reduction = "painkillers" --needs testing
		},
		temporary_upgrade = {
			temporary = {
				revive_damage_reduction = "combat_medic", --on revive other player
				single_shot_fast_reload = "aggressive_reload",
				overkill_damage_multiplier = "overkill",
				dmg_multiplier_outnumbered = "underdog_basic",
				dmg_dampener_outnumbered = "underdog_aced",
				dmg_dampener_outnumbered_strong = "overdog",
				dmg_dampener_close_contact = "basic_close_combat", --crew chief marathon man/infiltrator basic close combat/sociopath clean hit
				loose_ammo_restore_health = "ammo_box_pickup_health",
				loose_ammo_give_team = "ammo_box_pickup_share",
				damage_speed_multiplier = "second_wind",
				combat_medic_enter_steelsight_speed_multiplier = "combat_medic_steelsight_mul", --hidden steelsight speed bonus after reviving a teammate
				combat_medic_damage_multiplier = "combat_medic_damage_mul", --hidden damage bonus after reviving a teammate
				first_aid_damage_reduction = "quick_fix",
				revived_damage_resist = "up_you_go",
				increased_movement_speed = "running_from_death_aced",
				swap_weapon_faster = "running_from_death_basic_swap_speed",
				reload_weapon_faster = "running_from_death_basic_reload_speed"
			}
		},
		cooldown_upgrade = {
			cooldown = {
				long_dis_revive = "inspire_aced_cooldown"
			}
		}
	}
	
	
	self.tweak_data = {
--[[
		example_skill = {
			disabled = false,
			text_id = "",
			icon_data = {
				source = "skill",
				skill_id = "sadfasdf",
				tree = 1
			},
			display_format = ""
		},
		example_perk = {
			disabled = false,
			text_id = "",
			icon_data = {
				source = "perk",
				skill_id = "sadfasdf",
				tree = 1,
				card = 1
			},
			display_format = ""
		},
--]]
		absorption = { --(general absorption)
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_damage_absorption_title",
			upd_func = function(t,dt,display_setting,buff_data)
				return managers.player:damage_absorption()
			end,
			modify_value_func = function(n)
				return n * 10
			end,
			icon_data = {
				source = "perk",
				tree = 14,
				card = 1
			},
			display_format = "%0.1f"
		},
		dodge_chance = { --(general dodge chance)
			disabled = false,
			source = "general",
--			text_id = "menu_jail_diet_beta",
			text_id = "menu_kitr_buff_dodge_chance_title",
			upd_func = function(t,dt,display_setting,buff_data)
				local pm = managers.player
				local player = pm:local_player()
				local movement_ext = player:movement()
				return pm:skill_dodge_chance(movement_ext:running(), movement_ext:crouching(), movement_ext:zipline_unit())
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "skill",
				skill_id = "jail_diet",
				tree = 4
			},
			display_format = "%i%%"
		},
		crit_chance = { --(general crit chance)
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_crit_chance_title",
--			text_id = "menu_backstab_beta",
			upd_func = function(t,dt,display_setting,buff_data)
				local pm = managers.player
				
				local detection_risk = math.round(managers.blackmarket:get_suspicion_offset_from_custom_data({
					armors = managers.blackmarket:equipped_armor(true,true)
				}, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75) * 100)
				return pm:critical_hit_chance(detection_risk)
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "skill",
				skill_id = "backstab",
				tree = 4
			},
			display_format = "%i%%"
		},
		damage_resistance = { --general damage resist
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_damage_resistance_title",
			upd_func = function(t,dt,display_setting,buff_data)
				return (1 - managers.player:damage_reduction_skill_multiplier())
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "skill",
				skill_id = "juggernaut"
			},
			display_format = "%i%%"
		},
		fixed_health_regen = { --general health regen (heal +specific amount)
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_fixed_health_regen_title",
			show_timer = true,
			upd_func = function(t,dt,display_setting,buff_data)
				local pm = managers.player
				local player = pm:local_player()
				local dmg_ext = player:character_damage()
				local time_left = dmg_ext._health_regen_update_timer or 0
				return pm:fixed_health_regen(),time_left
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "csb_health" --temp
			},
			display_format = "+%i%%"
		},
		health_regen = { --general fixed health regen (heal % of max health)
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_health_regen_title",
			show_timer = true,
			upd_func = function(t,dt,display_setting,buff_data)
				local pm = managers.player
				local player = pm:local_player()
				local dmg_ext = player:character_damage()
				local time_left = dmg_ext._health_regen_update_timer or 0
				return pm:health_regen(),time_left
			end,
			modify_value_func = function(n)
				return n * 10
			end,
			icon_data = {
				source = "perk",
				tree = 2,
				card = 9
			},
			display_format = "+%0.2f"
		},
		
		--todo weapon buffs
		weapon_reload_speed = {
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_weapon_reload_speed_multiplier",
			show_timer = false,
			upd_func = function(t,dt,display_setting,buff_data)
				local player = managers.player:local_player()
				local inv_ext = player:inventory()
				local equipped_unit = inv_ext:equipped_unit()
				if alive(equipped_unit) then 
					local base = equipped_unit:base()
					return base and base:reload_speed_multiplier()
				end
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "equipment_stapler"
			},
			display_format = "%0.2f%%"
		},
		weapon_damage_bonus = {
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_weapon_damage_multiplier",
			show_timer = false,
			upd_func = function(t,dt,display_setting,buff_data)
				local player = managers.player:local_player()
				local inv_ext = player:inventory()
				local equipped_unit = inv_ext:equipped_unit()
				if alive(equipped_unit) then 
					local base = equipped_unit:base()
					return base and base:damage_multiplier()
				end
			end,
			modify_value_func = function(n)
				return (n - 1) * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "equipment_stapler"
			},
			display_format = "+%0.2f%%"
		},
		weapon_accuracy_bonus = {
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_weapon_accuracy_multiplier",
			show_timer = false,
			upd_func = function(t,dt,display_setting,buff_data)
				return managers.player:get_accuracy_multiplier()
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "equipment_stapler"
			},
			display_format = "%0.2f%%"
		},
		melee_damage_bonus = {
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_melee_damage_multiplier",
			show_timer = false,
			upd_func = function(t,dt,display_setting,buff_data)
				return managers.player:get_melee_dmg_multiplier()
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "equipment_stapler"
			},
			display_format = "%0.2f%%"
		},
		
		
		ecm_jammer = { --(ecm jammer timer)
			disabled = true,
			source = "general",
			text_id = "menu_ecm_2x_beta",
			upd_func = function(t,dt,display_setting,buff_data)
				local threshold = display_setting.value_threshold
				local groupaistate = managers.groupai:state()
				local ecm_jammers = groupaistate._ecm_jammers
				for u_key,ecm_data in pairs(ecm_jammers) do
					local unit = ecm_data.unit
					local jam_settings = ecm_data.settings
--					if jam_settings.camera then 
					
--					end
				end
			end,
			icon_data = {
				source = "skill",
				skill_id = "ecm_2x",
				tree = 4
			},
			display_format = ""
		},
		ecm_feedback = { --(ecm feedback timer) 
			disabled = true,
			source = "general",
			text_id = "menu_ecm_booster_beta",
			icon_data = {
				source = "skill",
				skill_id = "ecm_booster",
				tree = 4
			},
			display_format = ""
		},
	
	
	
		combat_medic = { --combat medic (damage reduction during/after res)
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_combat_medic_beta",
			icon_data = {
				source = "skill",
				skill_id = "combat_medic",
				tree = 1
			},
			display_format = "%0.2f"
		},
		combat_medic_damage_mul = {
			disabled = true, --actually disabled
			show_timer = true,
			source = "skill",
			text_id = "menu_combat_medic_beta",
			icon_data = {
				source = "skill",
				skill_id = "combat_medic",
				tree = 1
			},
			display_format = "%0.2f"
		},
		combat_medic_steelsight_mul = {
			disabled = true, --actually disabled
			show_timer = true,
			source = "skill",
			text_id = "menu_combat_medic_beta",
			icon_data = {
				source = "skill",
				skill_id = "combat_medic",
				tree = 1
			},
			display_format = "%0.2f"
		},
		quick_fix = { --quick fix (damage reduction after using health kit)
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_tea_time_beta",
			icon_data = {
				source = "skill",
				skill_id = "tea_time",
				tree = 1
			},
			modify_value_func = function(n)
				return (n - 1) * 100
			end,
			display_format = "%0.2f%%"
		},
		painkillers = { --painkillers (damage reduction for teammates you revive)
			disabled = true, --needs testing
			show_timer = true,
			source = "skill",
			text_id = "menu_fast_learner_beta",
			icon_data = {
				source = "skill",
				skill_id = "fast_learner",
				tree = 1
			},
			display_format = "%0.2f%%"
		},
		inspire_basic = { --inspire basic (move speed + reload speed bonus for teammates you shout at);
			disabled = true, --not implemented; requires hooking to player movement ext
			show_timer = true,
			source = "skill",
			text_id = "menu_inspire_beta",
			icon_data = {
				source = "skill",
				skill_id = "inspire",
				tree = 1
			},
			display_format = "%0.2f"
		},
		inspire_basic_cooldown = {
			disabled = true, --not implemented; requires checking var :rally_skill_data().morale_boost_delay_t in player movement ext
			show_timer = true,
			source = "skill",
			text_id = "menu_inspire_beta",
			icon_data = {
				source = "skill",
				skill_id = "inspire",
				tree = 1
			},
			display_format = ""
		},
		inspire_aced_cooldown = {
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_inspire_beta",
			icon_data = {
				source = "skill",
				skill_id = "inspire",
				tree = 1
			},
			display_format = "" --value is 1, which is evidently meaningless, so don't bother showing it
		},
		forced_friendship = { --forced friendship (nearby civs give damage absorption)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_triathlete_beta",
			icon_data = {
				source = "skill",
				skill_id = "triathlete",
				tree = 1
			},
			display_format = "%0.2f"
		},
		partners_in_crime = { --partners in crime (extra max health while you have a convert)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_control_freak_beta",
			icon_data = {
				source = "skill",
				skill_id = "control_freak",
				tree = 1
			},
			display_format = "+%0.2f%%"
		},
		stockholm_syndrome = { --stockholm syndrome (hostages autotrade for your return)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_stockholm_syndrome_beta",
			icon_data = {
				source = "skill",
				skill_id = "stockholm_syndrome",
				tree = 1
			},
			display_format = ""
		},
		stable_shot = { --stable shot (bonus accuracy while standing still)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_stable_shot_beta",
			icon_data = {
				source = "skill",
				skill_id = "stable_shot",
				tree = 1
			},
			display_format = "%0.2f%%"
		},
		rifleman = { --rifleman (bonus accuracy while moving)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_rifleman_beta",
			icon_data = {
				source = "skill",
				skill_id = "rifleman",
				tree = 1
			},
			display_format = "%0.2f%%"
		},
		ammo_efficiency = { --ammo efficiency (consecutive headshots refund ammo); show stacks
			disabled = true, --not implemented; requires "guessing" or coroutine override
			source = "skill",
			text_id = "menu_single_shot_ammo_return_beta",
			icon_data = {
				source = "skill",
				skill_id = "spotter_teamwork",
				tree = 1
			},
			display_format = "x%0.2f"
		},
		aggressive_reload = { --aggressive reload aced (killing headshot reduces reload speed)
			disabled = false,
			source = "skill",
			text_id = "menu_speedy_reload_beta",
			show_timer = true,
			icon_data = {
				source = "skill",
				skill_id = "speedy_reload",
				tree = 1
			},
			display_format = "%0.2fx"
		},
		
--enforcer
		underdog_basic = { --underdog (basic: damage bonus when targeted by enemies; aced: damage resist when targeted by enemies)
			disabled = false,
			source = "skill",
			text_id = "menu_underdog_beta",
			icon_data = {
				source = "skill",
				skill_id = "underdog",
				tree = 2
			},
			display_format = "%0.2f%%"
		},
		underdog_aced = { --underdog (basic: damage bonus when targeted by enemies; aced: damage resist when targeted by enemies)
			disabled = false,
			source = "skill",
			text_id = "menu_underdog_beta",
			icon_data = {
				source = "skill",
				skill_id = "underdog",
				tree = 2
			},
			display_format = "%0.2f%%"
		},
		far_away = { --far away basic (accuracy bonus while ads with shotguns)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_far_away_beta",
			icon_data = {
				source = "skill",
				skill_id = "far_away",
				tree = 2
			},
			display_format = "%0.2f%%"
		},
		close_by = { --close by (rof increase while hipfire with shotguns)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_close_by_beta",
			icon_data = {
				source = "skill",
				skill_id = "close_by",
				tree = 2
			},
			display_format = "%0.2f%%"
		},
		overkill = { --overkill (basic: damage bonus for saw/shotgun on kill with saw/shotgun; aced: damage bonus for all ranged weapons on kill with saw/shotgun)
			disabled = false, 
			show_timer = true,
			source = "skill",
			text_id = "menu_overkill_beta",
			icon_data = {
				source = "skill",
				skill_id = "overkill",
				tree = 2
			},
			display_format = "%0.2f%%"
		},
		die_hard = { --die hard basic (damage resist while interacting)
			disabled = true, --not implemented; requires manual checking via upd_func
			source = "skill",
			text_id = "menu_show_of_force_beta",
			icon_data = {
				source = "skill",
				skill_id = "show_of_force",
				tree = 2
			},
			display_format = "%0.2f%%"
		},
		bullseye = { --bullseye (armorgate) cooldown
			disabled = true, --not implemented; requires hooking to playermanager to get var ._on_headshot_dealt_t
			show_timer = true,
			source = "skill",
			text_id = "menu_prison_wife_beta",
			icon_data = {
				source = "skill",
				skill_id = "prison_wife",
				tree = 2
			},
			display_format = ""
		},
		scavenger = { --scavenger aced: extra ammo box every 6 kills
			disabled = true, --not implemented; requires hooking to playermanager to get var ._num_kills % ._target_kills
			source = "skill",
			text_id = "menu_scavenging_beta",
			icon_data = {
				source = "skill",
				skill_id = "scavenging",
				tree = 2
			},
			display_format = ""
		},
		bullet_storm = { --bulletstorm (temp don't consume ammo after using your ammo bags)
			disabled = true,
			source = "skill",
			text_id = "menu_ammo_reservoir_beta",
			icon_data = {
				source = "skill",
				skill_id = "ammo_reservoir",
				tree = 2
			},
			display_format = ""
		},
		fully_loaded = { --fully loaded aced (escalating throwable restore chance from ammo boxes)
			disabled = true, --not implemented; requires guessing FullyLoaded coroutine
			source = "skill",
			text_id = "menu_bandoliers_beta",
			icon_data = {
				source = "skill",
				skill_id = "bandoliers",
				tree = 2
			},
			display_format = "%0.2f%%"
		},

--technician
		hardware_expert = { --hardware expert (drill upgrades)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_hardware_expert_beta",
			icon_data = {
				source = "skill",
				skill_id = "hardware_expert",
				tree = 3
			},
			display_format = ""
		},
		drill_sawgeant = { --drill sawgeant (drill upgrades)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_drill_expert_beta",
			icon_data = {
				source = "skill",
				skill_id = "drill_expert",
				tree = 3
			},
			display_format = ""
		},
		kick_starter = { --kickstarter (drill upgrades); also show when a drill has attempted kickstarter
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_kick_starter_beta",
			icon_data = {
				source = "skill",
				skill_id = "kick_starter",
				tree = 3
			},
			display_format = ""
		},
		fire_control = { --fire control (basic: accuracy while hipfiring; aced: accuracy penalty reduction when moving)
			disabled = true, --not implemented
			source = "skill",
			text_id = "menu_fire_control_beta",
			icon_data = {
				source = "skill",
				skill_id = "fire_control",
				tree = 3
			},
			display_format = "%0.2fx"
		},
		lock_n_load = { --lock n' load aced (reload time reduction after autofire kills with lmg/ar/smg/specials )
			disabled = true,
			source = "skill",
			text_id = "menu_shock_and_awe_beta",
			icon_data = {
				source = "skill",
				skill_id = "shock_and_awe",
				tree = 3
			},
			display_format = "%0.2fx x%%i"
		},
		
	--ghost
		chameleon = { --sixth sense basic (mark nearby enemies)
			disabled = true, --not implemented; requires hooking to playerstandard:_update_omniscience()
			show_timer = true,
			source = "skill",
			text_id = "menu_chameleon_beta",
			icon_data = {
				source = "skill",
				skill_id = "chameleon",
				tree = 4
			},
			display_format = "%0.2f" --show number of nearby enemies?
		},
		second_chances = { --nimble basic (camera loop)
			disabled = true, --not implemented
			show_timer = true,
			source = "skill",
			text_id = "menu_second_chances_beta",
			icon_data = {
				source = "skill",
				skill_id = "second_chances",
				tree = 4
			},
			display_format = ""
		},
		dire_chance = { --dire need (stagger chance when armor is broken)
			disabled = true,
			show_timer = true,
			source = "skill",
			text_id = "menu_dire_need_beta",
			icon_data = {
				source = "skill",
				skill_id = "dire_need",
				tree = 4
			},
			display_format = "%0.2f"
		},
		second_wind = { --second wind (speed bonus on armor break)
			disabled = true,
			show_timer = true,
			source = "skill",
			text_id = "menu_scavenger_beta",
			icon_data = {
				source = "skill",
				skill_id = "scavenger",
				tree = 4
			},
			display_format = "%0.2fx"
		},
--needs a cooldown timer/timer til proc, and effect timer
		unseen_strike = { --unseen strike (crit chance when not taking damage)
			disabled = true,
			show_timer = true,
			source = "skill",
			text_id = "menu_unseen_strike_beta",
			icon_data = {
				source = "skill",
				skill_id = "unseen_strike",
				tree = 4
			},
			display_format = "%0.2f%%"
		},
	
	--fugitive
		desperado = { --desperado (stacking accuracy bonus per hit for pistols)
			disabled = true,
			show_timer = true,
			source = "skill",
			text_id = "menu_expert_handling",
			icon_data = {
				source = "skill",
				skill_id = "expert_handling",
				tree = 5
			},
			display_format = "%0.2fx"
		},
		trigger_happy = { --trigger happy (stacking damage bonus per hit for pistols)
			disabled = true,
			show_timer = true,
			source = "skill",
			text_id = "menu_trigger_happy_beta",
			icon_data = {
				source = "skill",
				skill_id = "trigger_happy",
				tree = 5
			},
			display_format = "%0.2fx"
		},
		running_from_death_basic_reload_speed = { --running_from_death (basic: reload/swap speed bonus after being revived; aced: move speed bonus after being revived)
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_running_from_death_beta",
			icon_data = {
				source = "skill",
				skill_id = "running_from_death",
				tree = 5
			},
			display_format = "%0.2fx"
		},
		running_from_death_basic_swap_speed = {
			disabled = true, --redundant; disabled
			show_timer = true,
			source = "skill",
			text_id = "menu_running_from_death_beta",
			icon_data = {
				source = "skill",
				skill_id = "running_from_death",
				tree = 5
			},
			display_format = "%0.2fx"
		},
		running_from_death_aced = {
			disabled = true, --redundant; disabled
			show_timer = true,
			source = "skill",
			text_id = "menu_running_from_death_beta",
			icon_data = {
				source = "skill",
				skill_id = "running_from_death",
				tree = 5
			},
			display_format = "%0.2fx"
		},
		up_you_go = { --up you go basic: damage resistance after being revived
			disabled = true,
			show_timer = true,
			source = "skill",
			text_id = "menu_up_you_go_beta",
			icon_data = {
				source = "skill",
				skill_id = "up_you_go",
				tree = 5
			},
			display_format = ""
		},
		swan_song = { --swan song: temporarily continue fighting after reaching 0 health
			disabled = true,
			source = "skill",
			text_id = "menu_perseverance_beta",
			icon_data = {
				source = "skill",
				skill_id = "perseverance",
				tree = 5
			},
			display_format = ""
		},
		messiah = { --messiah: kill an enemy to self-revive
			disabled = true,
			source = "skill",
			text_id = "menu_pistol_beta_messiah",
			icon_data = {
				source = "skill",
				skill_id = "messiah",
				tree = 5
			},
			display_format = ""
		},
		bloodthirst = { --bloodthirst (basic: stacking melee damage bonus per kill; aced: reload speed bonus on melee kill)
			disabled = true,
			source = "skill",
			text_id = "menu_bloodthirst",
			icon_data = {
				source = "skill",
				skill_id = "bloodthirst",
				tree = 5
			},
			display_format = ""
		},
		counterstrike = { --counterstrike (counter melee/cloaker kick)
			disabled = true,
			source = "skill",
			text_id = "menu_drop_soap_beta",
			icon_data = {
				source = "skill",
				skill_id = "drop_soap",
				tree = 5
			},
			display_format = ""
		},
		berserker = { --berserker (damage bonus inverse to health ratio)
			disabled = true,
			source = "skill",
			text_id = "menu_wolverine_beta",
			icon_data = {
				source = "skill",
				skill_id = "wolverine",
				tree = 5
			},
			display_format = ""
		},
--perkdecks

	--crewchief
		marathon_man = { --marathon man (damage reduction in medium range of enemies)
			disabled = true,
			source = "skill",
			text_id = "menu_deck1_1",
			icon_data = {
				source = "perk",
				tree = 1,
				card = 1
			},
			display_format = ""
		},
		hostage_situation = { --hostage situation (damage resistance per hostage)
			disabled = true,
			source = "skill",
			text_id = "menu_deck1_5",
			icon_data = {
				source = "perk",
				tree = 1,
				card = 5
			},
			display_format = ""
		},
	--muscle
		meat_shield = { --meat shield (increased threat when close to allies)
			disabled = true,
			source = "perk",
			text_id = "menu_deck2_3",
			icon_data = {
				source = "perk",
				tree = 2,
				card = 3
			},
			display_format = ""
		},
	--armorer
		reinforced_armor = { --reinforced armor (temporary invuln on armor break) + cooldown
			disabled = true,
			source = "perk",
			text_id = "menu_deck3_7",
			icon_data = {
				source = "perk",
				tree = 3,
				card = 7
			},
			display_format = ""
		},
	--rogue
		elusive = { --elusive (decreased threat when close to allies)
			disabled = true,
			source = "perk",
			text_id = "menu_deck4_3",
			icon_data = {
				source = "perk",
				tree = 4,
				card = 3
			},
			display_format = ""
		},
	--hitman
		tooth_and_claw = { --tooth and claw (guaranteed armor regen timer after break)
			disabled = true,
			source = "perk",
			text_id = "menu_deck5_9",
			icon_data = {
				source = "perk",
				tree = 5,
				card = 9
			},
			display_format = ""
		},
	--burglar
		bag_of_tricks = { --bag of tricks/luck of the irish/dutch courage (reduced target chance from crouching still)
			disabled = true,
			source = "perk",
			text_id = "menu_deck7_3",
			icon_data = {
				source = "perk",
				tree = 7,
				card = 3
			},
			display_format = ""
		},
		breath_of_fresh_air = { --breath of fresh air (increased armor recovery rate when standing still)
			disabled = true,
			source = "perk",
			text_id = "menu_deck7_9",
			icon_data = {
				source = "perk",
				tree = 7,
				card = 9
			},
			display_format = ""
		},
	--infiltrator
		overdog = { --overdog (damage resist when surrounded, stacking melee hit damage) (shared with sociopath)
			disabled = true,
			source = "perk",
			text_id = "menu_deck8_1",
			icon_data = {
				source = "perk",
				tree = 8,
				card = 1
			},
			display_format = ""
		},
		basic_close_combat = { --basic close combat
			disabled = true,
			source = "perk",
			text_id = "menu_deck8_3",
			icon_data = {
				source = "perk",
				tree = 8,
				card = 3
			},
			display_format = ""
		},
		life_leech = { --life leech (melee hit restores health)
			disabled = true,
			source = "perk",
			text_id = "menu_deck8_9",
			icon_data = {
				source = "perk",
				tree = 8,
				card = 9
			},
			display_format = ""
		},
	--sociopath
		tension = { --tension (armor gate on kill)
			disabled = true,
			source = "perk",
			text_id = "menu_deck9_3",
			icon_data = {
				source = "perk",
				tree = 9,
				card = 3
				
			},
			display_format = ""
		},
		clean_hit = { --clean hit (health on melee kill)
			disabled = true,
			source = "perk",
			text_id = "menu_deck9_5",
			icon_data = {
				source = "perk",
				tree = 9,
				card = 5
			},
			display_format = ""
		},
		overdose = { --overdose (armor gate on medium range kill)
			disabled = true,
			source = "perk",
			text_id = "menu_deck9_7",
			icon_data = {
				source = "perk",
				tree = 9,
				card = 7
			},
			display_format = ""
		},
	--gambler
		ammo_box_pickup_health = { --medical supplies (health on ammo box pickup)
			disabled = true,
			show_timer = true,
			source = "perk",
			text_id = "menu_deck10_1",
			icon_data = {
				source = "perk",
				tree = 10,
				card = 1
			},
			display_format = ""
		},
		ammo_box_pickup_share = { --ammo give out (ammo box team share)
			disabled = true,
			show_timer = true,
			source = "perk",
			text_id = "menu_deck10_3",
			icon_data = {
				source = "perk",
				tree = 10,
				card = 3
			},
			display_format = ""
		},
	--grinder
		histamine = { --histamine (health on damage)
			disabled = true,
			source = "perk",
			text_id = "menu_deck11_1",
			icon_data = {
				source = "perk",
				tree = 11,
				card = 1
			},
			display_format = ""
		},
	--yakuza
		koi_irezumi = { --koi irezumi (armor recovery rate inverse to health)
			disabled = true,
			source = "perk",
			text_id = "menu_deck12_1",
			icon_data = {
				source = "perk",
				tree = 12,
				card = 1
			},
			display_format = ""
		},
		hebi_irezumi = { --hebi irezumi (move speed inverse to health)
			disabled = true,
			source = "perk",
			text_id = "menu_deck12_3",
			icon_data = {
				source = "perk",
				tree = 12,
				card = 3
			},
			display_format = ""
		},
	--ex-president
		point_break = { --point break (stored health per kill)
			disabled = true,
			source = "perk",
			text_id = "menu_deck13_1",
			icon_data = {
				source = "perk",
				tree = 13,
				card = 1
			},
			display_format = ""
		},
	--maniac
		excitement = { --excitement (hysteria stacks)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 14,
				card = 1
			},
			display_format = ""
		},
	--anarchist
		blitzkrieg_bop = { --blitzkrieg bop (armor regen timer)
			disabled = true,
			source = "perk",
			text_id = "menu_deck15_1",
			icon_data = {
				source = "perk",
				tree = 15,
				card = 1
			},
			display_format = ""
		},
		lust_for_life = { --lust for life (armor on damage)
			disabled = true,
			source = "perk",
			text_id = "menu_deck15_7",
			icon_data = {
				source = "perk",
				tree = 15,
				card = 7
			},
			display_format = ""
		},
	--biker
		prospect = { --prospect (health/armor on any crew kill)
			disabled = true,
			source = "perk",
			text_id = "menu_deck16_1",
			icon_data = {
				source = "perk",
				tree = 16,
				card = 1
			},
			display_format = ""
		},
	--kingpin
		kingpin_injector = { --injector throwable
			disabled = true,
			source = "perk",
			text_id = "menu_deck17_1",
			icon_data = {
				source = "perk",
				tree = 17,
				card = 1
			},
			display_format = ""
		},
	--sicario
		sicario_smoke_bomb = { --smoke bomb (cooldown, in-screen effect)
			disabled = true,
			source = "perk",
			text_id = "menu_deck18_1",
			icon_data = {
				source = "perk",
				tree = 18,
				card = 1
			},
			display_format = ""
		},
		twitch = { --twitch (shot dodge cooldown)
			disabled = true,
			source = "perk",
			text_id = "menu_deck18_3",
			icon_data = {
				source = "perk",
				tree = 18,
				card = 3
			},
			display_format = ""
		},
	--stoic
		virtue = { --virtue (hip flask; general delayed damage) + cooldown
			disabled = true,
			source = "perk",
			text_id = "menu_deck19_1",
			icon_data = {
				source = "perk",
				tree = 19,
				card = 1
			},
			display_format = ""
		},
		calm = { --calm (4s free delayed damage negation)
			disabled = true,
			source = "perk",
			text_id = "menu_deck19_5",
			icon_data = {
				source = "perk",
				tree = 19,
				card = 5
			},
			display_format = ""
		},
	--tag team
		gas_dispenser = { --gas dispenser tagged
			disabled = true,
			source = "perk",
			text_id = "menu_deck20_1",
			icon_data = {
				source = "perk",
				tree = 20,
				card = 1
			},
			display_format = ""
		},
	--hacker
		pocket_ecm = { --pocket ecm throwable
			disabled = true,
			source = "perk",
			text_id = "menu_deck21_1",
			icon_data = {
				source = "perk",
				tree = 21,
				card = 1
			},
			display_format = ""
		},
		kluge = { --kluge (dodge on kill while feedback active)
			disabled = true,
			source = "perk",
			text_id = "menu_deck21_7",
			icon_data = {
				source = "perk",
				tree = 21,
				card = 7
			},
			display_format = ""
		},
	--leech 
		leech = { --leech throwable, temp invuln on healthgate
			disabled = true,
			source = "perk",
			text_id = "menu_deck22_1",
			icon_data = {
				source = "perk",
				tree = 22,
				card = 1
			},
			display_format = ""
		}
	}
	
	--todo overhaul-specific tweakdata
	if mode == "crackdown" then 
	elseif mode == "resmod" then
	end
	
	Hooks:Call("KineticTrackers_OnBuffDataLoaded",self.tweak_data)
end

function KineticTrackerCore:AddBuff(...)
	if self._holder then 
		self._holder:AddBuff(...)
	end
end

function KineticTrackerCore:RemoveBuff(...)
	if self._holder then 
		self._holder:RemoveBuff(...)
	end
end



--************************************************--
		--hud animate functions
--************************************************--

	-- hud animation manager --
	
function KineticTrackerCore:animate(object,func,done_cb,...)
	return self._animator:animate(object,func,done_cb,...)
end

function KineticTrackerCore:animate_stop(object,do_cb,...)
	return self._animator:animate_stop(object,do_cb,...)
end

function KineticTrackerCore:is_animating(object,...)
	return self._animator:is_animating(object,...)
end
