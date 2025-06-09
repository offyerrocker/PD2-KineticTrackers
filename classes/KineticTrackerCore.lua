--[[
	todo: 
	
	#1 priority
		straighten out data schema for displayed buff values
		
		buffs can have:
		any number of values? (case-specific)
			1 value: display value (format with display_format)
			2 dissimilar values: display values 
		zero or more timers
			0: don't display or save a timer
			1: save a timer value 
			2+: multi-timer visual only bar
	
		
		any values related to the buff item display should be stored in the buff_data
		this will allow the items to be recreated midgame
		
		
		per-buff display settings are saved to settings
		buff_display_setting is an extraneous table generated from per-buff display settings overlaid onto settings
		this allows "unchanged" values where a player can choose to have global settings (like ACH) which can be overridden on a per-buff basis
		
	keybind to enter edit mode, a la hunterpie
		* click+drag/resize buffs window 
		
	
	add item style option (link Holder's update and Item:new() call to global style setting)
	add buff name popup per buff on first activation
		use the rotation trick to bypass clipping?
	add multi-value display (mainly for biker/grinder)
	add optional border around buffs:
		* circle
		* square
		* triangle (EXTREMELY SPICY)
		* custom?
	show stacks option vs show value option	
	fix trigger happy/desperado proc (procs on any hit)
	fix for cases where buff properties are "added" although they are not active and do not have a valid buff display
		fix bloodthirst proc ("blank" buff always added)
	sort menu items by tree/alphabetical?
	
	
	custom buff icon sets?
		
		
		
	thinking about making options per-	specifically now.
	
	
	
	different display modes for buffs overall:
		orientation
			halign
				* left
				* center
				* right
			
			halign order:
				left to right
				right to left
			
			valign 
				* top
				* center
				* bottom
			
			valign order:
				top to bottom
				bottom to top
			
		style:
			warframe (icons)
			destiny (list)
		transform:
			size (scale mul)
			position
	
	buff_setting = {
		enabled = true,
		value_threshold = 2,
		timer_enabled = true,
		timer_minutes_display = 1,--1 = minutes, 2 = seconds
		timer_precision_places = 2,
		timer_flashing_mode = 1,
		timer_flashing_threshold = 3,
		timer_flashing_speed = 1,
		color = "ffd700"
	}
	
	for updating values:
		upd_func
	for changing values or timers in cases where the add/proc hook matches the schema but value does not (eg. mul is a reciprocal, timer is a direct duration value, value is 1-n instead)
		modify_value_func 
		modify_timer_func 
	for getting the display string from one or more buff values:
		format_values_func
	
	
	
	buff customization menus:
		global:
			time format:
				display :
					A) minutes:seconds (1:30)
					B) seconds (90)
				float precision (xx.yy or just xx)
				append seconds "s"
			value format?
				stack style:
					A) Burdened by Riches x2
				mul style:
					A) Berserker x0.15
					B) Berserker x1.15
					C) Berserker +0.15
					D) Berserker +15%
					E) Berserker 15%
			flashing:
				enabled on/off
				use threshold on/off
				threshold (time left) 
				color 
			-master alpha?
				
		per buff:
			-enabled
			-timer enabled
			-threshold enabled
			-min threshold (hide if not greater than this value)
			
			-text color (both)
			-icon color
			-bg color
			-bg alpha
	
	options:
		- per-buff enable/disable
		- color coding for:
			- normal
			- Max stacks/value
			- cooldown
	
	
	buffs to be added:
		flashbang (timer)
		winters (multiplier)
		inspire basic cooldown (timer)
		inspire basic (timer)
		forced friendship (damage absorption from civs) (absorption amount)
		partners in crime (hp bonus/status)
		die hard (interaction dmg resist; should be aggregated)
		bullseye cooldown (timer)
		fully loaded (stacking chance)
		chameleon (omniscience)
		unseen_strike (activation timer, duration timer)
		swan song (timer)
		messiah ready/messiah charges (status/stack)
		bloodthirst basic (melee damage increase)
		bloodthirst aced (timer/50% faster reload speed)
		berserker basic/aced (ratio or melee/ranged bonus)
		
		marathon man (damage reduction in medium range of enemies)
		hostage situation (damage resistance per hostage)
		meat shield (increased threat when close to allies)
		reinforced armor (temporary invuln on armor break + cooldown)
		elusive (decreased threat when close to allies)
		tooth and claw (guaranteed armor regen timer after break)
		bag of tricks/luck of the irish/dutch courage (reduced target chance from crouching still)
		breath of fresh air (increased armor recovery rate when standing still
		overdog (damage resist when surrounded, stacking melee hit damage) (shared with sociopath)
		basic close combat
		life leech (melee hit restores health cooldown)
		tension (armor gate on kill cooldown)
		clean hit (health on melee kill cooldown)
		overdose (armor gate on medium range kill cooldown)
		medical supplies (health on ammo box pickup)
		ammo give out (ammo box team share)
		histamine (health on damage stacks)
		koi irezumi (armor recovery rate inverse to health)
		hebi irezumi (move speed inverse to health)
		point break (stored health per kill)
		excitement (hysteria stacks)
		blitzkrieg bop (armor regen timer)
		lust for life (armor on damage cooldown)
		prospect (health/armor on any crew kill)
		injector throwable duration/cooldown?
		smoke bomb (cooldown, in-screen effect)
		twitch (shot dodge cooldown)
		virtue (hip flask) + cooldown
		general delayed damage
		calm (4s countdown free delayed damage negation)
		gas dispenser tagged
		pocket ecm throwable
		kluge (dodge on kill while feedback active)
		leech throwable, temp invuln on healthgate
		leech throwable, temp invuln on healthgate
		
		copycat things?
		
		
	i probably don't want to implement:
		ammo efficiency (headshot counter)
			* not very necessary
		scavenger (kill counter)
			* not very necessary
		stockholm syndrome aced- hostage autotrade ready
			* only relevant when the player is dead; mod is designed to work when you are not dead
		stable shot
			* obvious proc conditions; minor impact to gameplay
		rifleman
			* obvious proc conditions; minor impact to gameplay
		far away
			* obvious proc conditions; minor impact to gameplay
		fire control
			* obvious proc conditions; minor impact to gameplay
		counterstrike
			* obvious proc conditions
	misc tracker features:
		drill timers
		camera loop timer (second chances)
		equipment timers (ecms)
		sentry trackers
	
	
	
	
	
	
	
	
	
	separate entries for combat_medic property and timed buff to avoid possible conflicts (in practice it's fine but i'd prefer it to be more waterproof)
	
	separate equipment trackers? (ecm timers, sentry ammo counts, num tripmines out)
	
	
	
	
--]]

-- static class

KineticTrackerCore = _G.KineticTrackerCore or {}


KineticTrackerCore._path = ModPath
KineticTrackerCore._options_path = ModPath .. "menu/menu_main.json"
KineticTrackerCore._default_localization_path = ModPath .. "loc/english.json"
KineticTrackerCore._save_path_base = SavePath
KineticTrackerCore._save_path_general = KineticTrackerCore._save_path_base .. "KineticTrackers_general.json"
KineticTrackerCore._save_path_buff_template = "KineticTrackers_buffs_$mode.json"
KineticTrackerCore.tweak_data = {
	buff_id_lookups = {},
	buffs = {}
}
KineticTrackerCore._require_libs = {} -- cached lua chunks from this mod's implementation of require via loadfile, keyed by path

KineticTrackerCore.TIMER_SETTING_PRECISION_PLACES_LOOKUP = { 0,1,2 }
KineticTrackerCore.TIMER_SETTING_PRECISION_THRESHOLD_LOOKUP = { 0,3,5,10,math.huge }

KineticTrackerCore.default_palettes = {
	"e32727",
	"e38527",
	"e3e327",
	"e32785",
	"e327e3",
	
	"d4e327",
	"76e327",
	"27e336",
	"e39427",
	"e33627",
	
	"30e327",
	"27e37c",
	"27e3da",
	"8ee327",
	"e3da27",
	
	"27b6e3",
	"2758e3",
	"5427e3",
	"27e3b2",
	"27e354",
	
	"8927e3",
	"e327df",
	"e32781",
	"2b27e3",
	"2781e3"
}
KineticTrackerCore.default_settings = {
	logs_enabled = true,
	x = 0, -- buff panel x
	y = 0, -- buff panel y
	w = 1280, -- buff panel w
	h = 720, -- buff panel h
	orientation = 1, -- int [1-12]; see KineticTrackerHolder for more info
	
	buff_style = 1, -- 1: destiny 2 style; 2: warframe style
	
	buff_color_value_normal = "ffffff", -- value label color default
	buff_color_value_full = "ffd700", -- value label color when the value has reached its max
	buff_color_timer_normal = "ffffff", -- timer label color default
	buff_color_timer_cooldown = "ff5050", -- timer label color when the buff is a cooldown (or is a negative trait such as winters/flashbang)
	
	value_threshold = 0,
	
	timer_enabled = true,
	timer_minutes_display = 1,
	timer_precision_places = 2,
	timer_precision_threshold = 3, -- (lookup index) under this threshold, the timer will start showing decimal precision (if timer_precision_places is enabled). 1: never, 2: 3s, 3: 5s, 4: 10s, 5: always
	timer_flashing_mode = 1, -- flash when: 1: under threshold. 2: always. 3: never.
	timer_flashing_threshold = 3, -- if timer is under this amount and flashing mode is 1, do flash
	
	timer_flashing_speed = 1, -- global setting only, no individual setting
	
	sort_by_priority = false,
	
	palettes = table.deep_map_copy(KineticTrackerCore.default_palettes),
	buffs = {
		TEMPLATE = {
			enabled = true,
			value_inherit_global = false, -- if false, use global settings instead
			value_threshold = 0,
			
			timer_enabled = true,
			timer_inherit_global = false, -- if true, disregard the buff-specific settings and use the global setting
			timer_precision_places = 2,
			timer_precision_threshold = 5,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1
		}
	}
}

-- all/global settings
KineticTrackerCore.settings = table.deep_map_copy(KineticTrackerCore.default_settings)

-- buff-specific settings (may vary by overhaul)
KineticTrackerCore.default_buff_settings = {}
KineticTrackerCore.buff_settings = {}

-- since buff behavior can theoretically be entirely different between overhauls
-- (particularly buffs with the same name but different effects)
-- this can cause crashing or other unexpected behavior;
-- therefore, settings (and in turn, settings) should be overhaul/balance specific

function KineticTrackerCore:GenerateBuffSettings(buff_tweakdata)
	local buff_settings = {}
	for buff_id,buff_data in pairs(buff_tweakdata.buffs) do 
		if not buff_data.disabled then
			local setting = {}
			buff_settings[buff_id] = setting
			
			local menu_defaults = buff_data.menu_options
			if menu_defaults then
			
				setting.enabled = menu_defaults.enabled
				
				if buff_data.show_value then 
					setting.value_threshold = menu_defaults.value_threshold or self.default_settings.value_threshold
					setting.value_inherit_global = menu_defaults.value_inherit_global
					setting.buff_color_value_normal = menu_defaults.buff_color_value_normal or self.default_settings.buff_color_value_normal
					setting.buff_color_value_full = menu_defaults.buff_color_value_full or self.default_settings.buff_color_value_full
				end
				
				if buff_data.show_timer then
					setting.timer_enabled = menu_defaults.timer_enabled or self.default_settings.timer_enabled
					setting.timer_inherit_global = (menu_defaults.timer_inherit_global == nil and true) or menu_defaults.timer_inherit_global
					setting.timer_minutes_display = menu_defaults.timer_minutes_display or self.default_settings.timer_minutes_display
					setting.timer_precision_places = menu_defaults.timer_precision_places or self.default_settings.timer_precision_places
					setting.timer_precision_threshold = menu_defaults.timer_precision_threshold or self.default_settings.timer_precision_threshold
					setting.timer_flashing_mode = menu_defaults.timer_flashing_mode or self.default_settings.timer_flashing_mode
					setting.timer_flashing_threshold = menu_defaults.timer_flashing_threshold or self.default_settings.timer_flashing_threshold
					setting.timer_flashing_speed = menu_defaults.timer_flashing_speed or self.default_settings.timer_flashing_speed
					setting.buff_color_timer_normal = menu_defaults.buff_color_timer_normal or self.default_settings.buff_color_timer_normal
					setting.buff_color_timer_cooldown = menu_defaults.buff_color_timer_cooldown or self.default_settings.buff_color_timer_cooldown
				end
			else
				setting.enabled = true
				
				if buff_data.show_value then 
					setting.value_threshold = self.default_settings.value_threshold
					setting.value_inherit_global = true
					setting.buff_color_value_normal = self.default_settings.buff_color_value_normal
					setting.buff_color_value_full = self.default_settings.buff_color_value_full
				end
				
				if buff_data.show_timer then
					setting.timer_enabled = self.default_settings.timer_enabled or false
					setting.timer_inherit_global = self.default_settings.timer_inherit_global or false
					setting.timer_minutes_display = self.default_settings.timer_minutes_display
					setting.timer_precision_places = self.default_settings.timer_precision_places
					setting.timer_precision_threshold = self.default_settings.timer_precision_threshold
					setting.timer_flashing_mode = self.default_settings.timer_flashing_mode
					setting.timer_flashing_threshold = self.default_settings.timer_flashing_threshold
					setting.timer_flashing_speed = self.default_settings.timer_flashing_speed
					setting.buff_color_timer_normal = self.default_settings.buff_color_timer_normal
					setting.buff_color_timer_cooldown = self.default_settings.buff_color_timer_cooldown
				end
			end
			
		end
	end
	return buff_settings
end



-------------------------------------------------------------
--********************* Menu Data *********************--
-------------------------------------------------------------

KineticTrackerCore.menu_data = {
	menus = {
		main = {
			skip_add_menu_item = true,
			id = "menu_kitr_main",
			title = "menu_kitr_main_menu_title",
			desc = "menu_kitr_main_menu_desc",
			parent = "blt_options",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = nil,
			subposition = nil
		},
		appearance = {
			skip_add_menu_item = false,
			id = "menu_kitr_appearance",
			title = "menu_kitr_appearance_menu_title",
			desc = "menu_kitr_appearance_menu_desc",
			parent = "menu_kitr_main",
			area_bg = "none",
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = nil,
			subposition = nil
		},
		buffs = {
			id = "menu_kitr_buffs",
			title = "menu_kitr_buffs_title",
			desc = "menu_kitr_buffs_desc",
			parent = "menu_kitr_main",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = nil,
			subposition = nil
		},
		general = {
			id = "menu_kitr_buff_category_general",
			title = "menu_kitr_buff_category_general_title",
			desc = "menu_kitr_buff_category_general_desc",
			parent = "menu_kitr_buffs",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = nil,
			subposition = nil
		},
		skill = {
			id = "menu_kitr_buff_category_skill",
			title = "menu_kitr_buff_category_skill_title",
			desc = "menu_kitr_buff_category_skill_desc",
			parent = "menu_kitr_buffs",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "menu_kitr_buff_category_general",
			subposition = "after"
		},
	--skilltree menus
		skilltree_mastermind = {
			id = "menu_kitr_buff_category_skilltree_mastermind",
			title = "st_menu_mastermind",
			desc = "menu_kitr_buff_category_skilltree_mastermind_desc",
			parent = "menu_kitr_buff_category_skill",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = nil,
			subposition = nil
		},
		skilltree_enforcer = {
			id = "menu_kitr_buff_category_skilltree_enforcer",
			title = "st_menu_enforcer",
			desc = "menu_kitr_buff_category_skilltree_enforcer_desc",
			parent = "menu_kitr_buff_category_skill",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "skilltree_mastermind",
			subposition = "after"
		},
		skilltree_technician = {
			id = "menu_kitr_buff_category_skilltree_technician",
			title = "st_menu_technician",
			desc = "menu_kitr_buff_category_skilltree_technician_desc",
			parent = "menu_kitr_buff_category_skill",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "skilltree_enforcer",
			subposition = "after"
		},
		skilltree_ghost = {
			id = "menu_kitr_buff_category_skilltree_ghost",
			title = "st_menu_ghost",
			desc = "menu_kitr_buff_category_skilltree_ghost_desc",
			parent = "menu_kitr_buff_category_skill",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "skilltree_technician",
			subposition = "after"
		},
		skilltree_fugitive = {
			id = "menu_kitr_buff_category_skilltree_fugitive",
			title = "st_menu_hoxton_pack",
			desc = "menu_kitr_buff_category_skilltree_fugitive_desc",
			parent = "menu_kitr_buff_category_skill",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "skilltree_ghost",
			subposition = "after"
		},
		perk = {
			id = "menu_kitr_buff_category_perk",
			title = "menu_kitr_buff_category_perk_title",
			desc = "menu_kitr_buff_category_perk_desc",
			parent = "menu_kitr_buffs",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "menu_kitr_buff_category_skill",
			subposition = "after"
		},
		--consolidate all these into the perks menu
		perkdeck_crew_chief = {
			id = "menu_kitr_buff_category_perkdeck_crew_chief",
			title = "menu_st_spec_1",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = nil,
			subposition = nil
		},
		perkdeck_muscle = {
			id = "menu_kitr_buff_category_perkdeck_muscle",
			title = "menu_st_spec_2",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_crew_chief",
			subposition = "after"
		},
		perkdeck_armorer = {
			id = "menu_kitr_buff_category_perkdeck_armorer",
			title = "menu_st_spec_3",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_muscle",
			subposition = "after"
		},
		perkdeck_rogue = {
			id = "menu_kitr_buff_category_perkdeck_rogue",
			title = "menu_st_spec_4",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_armorer",
			subposition = "after"
		},
		perkdeck_hitman = {
			id = "menu_kitr_buff_category_perkdeck_hitman",
			title = "menu_st_spec_5",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_rogue",
			subposition = "after"
		}, 
		perkdeck_crook = { --doesn't have any perks to change
			disabled = true,
			id = "menu_kitr_buff_category_perkdeck_crook",
			title = "menu_st_spec_6",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_crook",
			subposition = "after"
		},
		perkdeck_burglar = {
			id = "menu_kitr_buff_category_perkdeck_burglar",
			title = "menu_st_spec_7",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_hitman",
			subposition = "after"
		},
		perkdeck_infiltrator = {
			id = "menu_kitr_buff_category_perkdeck_infiltrator",
			title = "menu_st_spec_8",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_burglar",
			subposition = "after"
		},
		perkdeck_sociopath = {
			id = "menu_kitr_buff_category_perkdeck_sociopath",
			title = "menu_st_spec_9",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_infiltrator",
			subposition = "after"
		},
		perkdeck_gambler = {
			id = "menu_kitr_buff_category_perkdeck_gambler",
			title = "menu_st_spec_10",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_sociopath",
			subposition = "after"
		},
		perkdeck_grinder = {
			id = "menu_kitr_buff_category_perkdeck_grinder",
			title = "menu_st_spec_11",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_gambler",
			subposition = "after"
		},
		perkdeck_yakuza = {
			id = "menu_kitr_buff_category_perkdeck_yakuza",
			title = "menu_st_spec_12",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_grinder",
			subposition = "after"
		},
		perkdeck_ex_president = {
			id = "menu_kitr_buff_category_perkdeck_ex_president",
			title = "menu_st_spec_13",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_yakuza",
			subposition = "after"
		},
		perkdeck_maniac = {
			id = "menu_kitr_buff_category_perkdeck_maniac",
			title = "menu_st_spec_14",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_ex_president",
			subposition = "after"
		},
		perkdeck_anarchist = {
			id = "menu_kitr_buff_category_perkdeck_anarchist",
			title = "menu_st_spec_15",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_maniac",
			subposition = "after"
		},
		perkdeck_biker = {
			id = "menu_kitr_buff_category_perkdeck_biker",
			title = "menu_st_spec_16",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_anarchist",
			subposition = "after"
		},
		perkdeck_kingpin = {
			id = "menu_kitr_buff_category_perkdeck_kingpin",
			title = "menu_st_spec_17",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_biker",
			subposition = "after"
		},
		perkdeck_sicario = {
			id = "menu_kitr_buff_category_perkdeck_sicario",
			title = "menu_st_spec_18",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_kingpin",
			subposition = "after"
		},
		perkdeck_stoic = {
			id = "menu_kitr_buff_category_perkdeck_stoic",
			title = "menu_st_spec_19",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_sicario",
			subposition = "after"
		},
		perkdeck_tag_team = {
			id = "menu_kitr_buff_category_perkdeck_tag_team",
			title = "menu_st_spec_20",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_stoic",
			subposition = "after"
		},
		perkdeck_hacker = {
			id = "menu_kitr_buff_category_perkdeck_hacker",
			title = "menu_st_spec_21",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_tag_team",
			subposition = "after"
		},
		perkdeck_leech = {
			id = "menu_kitr_buff_category_perkdeck_leech",
			title = "menu_st_spec_22",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_hacker",
			subposition = "after"
		},
		perkdeck_copycat = {
			id = "menu_kitr_buff_category_perkdeck_copycat",
			title = "menu_st_spec_23",
			desc = "menu_kitr_buff_category_perkdeck_generic_desc",
			parent = "menu_kitr_buff_category_perk",
			area_bg = nil,
			back_callback_name = nil,
			focus_changed_callback_name = nil,
			menu_position = "perkdeck_leech",
			subposition = "after"
		}
	},
	skilltree_lookup = { --ordered
		"skilltree_mastermind",
		"skilltree_enforcer",
		"skilltree_technician",
		"skilltree_ghost",
		"skilltree_fugitive"
	},
	perkdeck_lookup = { --ordered
		"perkdeck_crew_chief",
		"perkdeck_muscle",
		"perkdeck_armorer",
		"perkdeck_rogue",
		"perkdeck_hitman",
		"perkdeck_crook",
		"perkdeck_burglar",
		"perkdeck_infiltrator",
		"perkdeck_sociopath",
		"perkdeck_gambler",
		"perkdeck_grinder",
		"perkdeck_yakuza",
		"perkdeck_ex_president",
		"perkdeck_maniac",
		"perkdeck_anarchist",
		"perkdeck_biker",
		"perkdeck_kingpin",
		"perkdeck_sicario",
		"perkdeck_stoic",
		"perkdeck_tag_team",
		"perkdeck_hacker",
		"perkdeck_leech",
		"perkdeck_copycat"
	},
	buffs_lookup = { --indexed by string buff_id; populated on MenuManagerSetupCustomMenus
	}
}

KineticTrackerCore._preview_buffs = {}
KineticTrackerCore.buff_preview_data = {
	generic = {
		value = 3,
		end_t = 10
	},
	flashbang = {
		value = true,
		end_t = 5
	}
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

function KineticTrackerCore:require(path)
	local _path = self._path .. path .. ".lua"
	if self._require_libs[path] then
		return self._require_libs[path]
	elseif io.file_is_readable(_path) then
		local result = blt.vm.dofile(_path)
		self._require_libs[path] = result
		return result
	else
		error("KineticTrackerCore:require() File could not be read: " .. tostring(_path))
	end
end

function KineticTrackerCore.table_traverse(tbl,cb,record,current_depth,max_depth)
	current_depth = (current_depth and current_depth + 1) or 0
	max_depth = max_depth or 3
	if not record[tbl] then
		record[tbl] = true
		
		for k,v in pairs(tbl) do 
			if type(v) == "table" then
				if current_depth <= max_depth then
					traverse(v,cb,record,current_depth,max_depth)
				end
			else
				cb(k,v)
			end
		end
	end
end

function KineticTrackerCore.format_time(seconds,precision,show_minutes)

--	local style_index = 1
--	local item_styles = {
--		KineticTrackerItemDestiny,
--		KineticTrackerItemWarframe
--	}
--	self._item_style = item_styles[style_index]
--	self._item_style = self.STYLES[style_index]

	local str = ""
	local SECONDS_ABBREV_STR = "s"
	local seconds_format = "%02d"
	local minutes_format = "%02i"
	
	local precision_threshold = 5
	if precision >= 1 and seconds < precision_threshold then 
--		seconds_format = "%02." .. string.format("%i",precision) .. "f"
		seconds_format = seconds_format .. string.format(".%02i",(seconds - math.floor(seconds)) * math.pow(10,precision))
	end
	
	if show_minutes then 
		local _minutes = math.min(seconds / 60,99)
		local _seconds = seconds % 60
		str = string.format(minutes_format .. ":" .. seconds_format,_minutes,_seconds)
	else
		str = string.format(seconds_format,seconds) .. SECONDS_ABBREV_STR
	end
	
	return str
end

-------------------------------------------------------------
--*********************    I/O    *********************--
-------------------------------------------------------------

function KineticTrackerCore:SaveSettings()
	local file = io.open(self._save_path_general,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function KineticTrackerCore:LoadSettings()
	local file = io.open(self._save_path_general, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:SaveSettings()
	end
end

function KineticTrackerCore:SaveBuffSettings(mode)
	local save_path = self._save_path_base .. string.gsub(KineticTrackerCore._save_path_buff_template,"$mode",mode)
	local file = io.open(save_path,"w+")
	if file then
		file:write(json.encode(self.buff_settings))
		file:close()
	end
end

function KineticTrackerCore:LoadBuffSettings(mode)
	local save_path = self._save_path_base .. string.gsub(KineticTrackerCore._save_path_buff_template,"$mode",mode)
	local file = io.open(save_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.buff_settings[k] = v
		end
	else
		self:SaveBuffSettings(mode)
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

-------------------------------------------------------------
--*********************    Core functionality    *********************--
-------------------------------------------------------------

function KineticTrackerCore:Setup(_managers)
	_managers = _managers or _G.managers
	
	local KineticTrackerHolder = self:require("classes/KineticTrackerHolder")
	local holder = KineticTrackerHolder:new(self.settings,self.buff_settings,self.tweak_data)
	self._holder = holder
	
	local KineticTrackerHandler = self:require("classes/KineticTrackerHandler")
	_managers.kinetictrackers = KineticTrackerHandler:new(self.settings,self.tweak_data,holder)
	
	local QuickAnimate = self:require("classes/QuickAnimate")
	self._animator = QuickAnimate:new("kinetictracker_animator",{parent = self,updater_type = QuickAnimate.updater_types.none,paused = false})
end

function KineticTrackerCore:OnAddUpdaters()
	if self._animator then
		self:AddUpdater("kinetictracker_update_animate",callback(self._animator,self._animator,"UpdateAnimate"),true,false,false)
	end
	if self._holder then
		self:AddUpdater("kinetictracker_update_holder",callback(self._holder,self._holder,"Update"),true,false,false)
	end
end

--aced/basic/cooldown text is applied later, on MenuManagerSetupCustomMenus
function KineticTrackerCore:LoadBuffData(mode)
	local td
	if mode == "crackdown" then 
		td = {}
	elseif mode == "resmod" then
		td = {}
	else
		td = {
			buff_id_lookups = {
				property = {
					revive_damage_reduction = "combat_medic", --while reviving other player
					shock_and_awe_reload_multiplier = "lock_n_load",
					trigger_happy = "trigger_happy",
					desperado = "desperado",
					copr_risen = "leech",
					copr_risen_cooldown_added = "leech_cooldown",
					primary_reload_secondary_kills = "copycat_primarykills", -- stack counter
					secondary_reload_primary_kills = "copycat_secondarykills" -- stack counter
				},
				temporary_property = {
					revive_damage_reduction = "painkillers", --needs testing
					bloodthirst_reload_speed = "bloodthirst_aced"
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
						reload_weapon_faster = "running_from_death_basic_reload_speed",
						berserker_damage_multiplier = "swan_song",
						team_damage_speed_multiplier_received = "second_wind_aced", --second wind aced (from team)
						unseen_strike = "unseen_strike"
					}
				},
				cooldown_upgrade = {
					cooldown = {
						long_dis_revive = "inspire_aced_cooldown"
					}
				},
				assault = { -- not used
					vip = "winters_resistance"
				}
			},
			buffs = {
		--[[
				example_skill = {
					disabled = false, -- if true, this buff will not be displayed; useful for properties that I want to acknowledge (not log) but not display (eg if they're trivial or irrelevant)
					text_id = "", --the localization id for this buff; this will be used to generate the label for in-game, and the menu if not otherwise specified
					name_id = "", -- if specified, this overrides the text_id
					icon_data = {
						source = "skill", --skill, perk, or hud_icon
						skill_id = "sadfasdf", --skill name, or hud_icon name
						tree = 1 --skilltree (to sort in menu options)
					},
					
					get_display_string = function(buff,value) -- buff_value is this table (whose key is "example_skill"); value may be any type, timer may be float or nil (depending on what's passed to the buff)
						return tostring(value)
					end,
					
					default_settings = { -- this is only used for setting generation
					-- this section is only used if show_timer is true
						enabled = true,
						value_threshold = 0,
						buff_color_value_normal = "ffffff", -- default value color
						buff_color_value_full = "ffd700", -- value color if value is above "max" threshold
						buff_color_timer_normal = "ffffff", -- default timer color
						buff_color_timer_cooldown = "ff4040", -- timer color if buff is a "cooldown" type
						timer_enabled = true, -- bool
						timer_minutes_display = 1, -- 1: minutes, 2: seconds
						timer_precision_places = 1, -- 1: integer. 2: 1 decimal place. 3: 2 decimal places
						timer_flashing_mode = 1, -- flash when: 1: under threshold. 2: always. 3: never.
						timer_flashing_threshold = 5 -- if timer is under this amount and flashing mode is 1, do flash
					}
					-- 
				},
				example_perk = {
					disabled = false,
					text_id = "",
					source = "perk",
					icon_data = {
						source = "perk",
						tree = 1,
						card = 1
					}
				},
				
				
				
				
					menu_options = {
						min_value = 0, --used for sliders
						max_value = 10, --used for sliders
						step = 1, --used for sliders
						default_value = 1, --used for all menu option types
					},
		--]]
				--misc "fake" statuses
				flashbang = {
					disabled = false,
					show_timer = true,
					show_value = false,
					source = "general",
					text_id = "menu_kitr_buff_flashbanged_title",
					name_id = nil, --overrides generated name_id
					desc_id = "menu_kitr_buff_flashbanged_desc",
					icon_data = {
						source = "perk",
						tree = 1,
						card = 1
					},
					is_aced = false,
					is_cooldown = false,
					menu_options = {
						enabled = true,
						timer_inherit_global = false,
						timer_precision_places = 2,
						timer_flashing_mode = 2
					},
					preview = {
						value = 1, -- placeholder
						timer = 5
					}
				},
				winters_resistance = {
					disabled = false,
					show_timer = false,
					show_value = true,
					source = "general",
					text_id = "menu_kitr_buff_winters_present_title",
					desc_id = "menu_kitr_buff_winters_present_desc",
					icon_data = {
						source = "perk",
						tree = 1,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					get_display_string = function(buff,value)
						return string.format("%i%%",value) --> eg 1%
					end,
					menu_options = {
						enabled = true,
						value_inherit_global = true,
						buff_color_value_normal = "ff7777",
						buff_color_value_full = "ff5050"
					},
					preview = {
						value = 1
					}
				},
				absorption = { --(general absorption)
					disabled = false,
					show_timer = false,
					show_value = true,
					source = "general",
					text_id = "menu_kitr_buff_damage_absorption_title",
					desc_id = "menu_kitr_buff_damage_absorption_desc",
					show_timer = false,
					show_value = true,
					upd_func = function(buff,t,dt)
						return managers.player:damage_absorption()
					end,
					get_display_string = function(buff,value)
						return string.format("%i",value*10)
					end,
					icon_data = {
						source = "perk",
						tree = 14,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true,
						value_inherit_global = false,
						buff_color_value_normal = "76d2e2",
						buff_color_value_full = "3cd2ed"
					},
					preview = {
						value = 100
					}
				},
				dodge_chance = { --(general dodge chance)
					disabled = false,
					source = "general",
					text_id = "menu_kitr_buff_dodge_chance_title",
					desc_id = "menu_kitr_buff_dodge_chance_desc",
					show_timer = false,
					show_value = true,
					upd_func = function(buff_data,t,dt)
						local pm = managers.player
						local player = pm:local_player()
						if player then
							local movement_ext = player:movement()
							return pm:skill_dodge_chance(movement_ext:running(), movement_ext:crouching(), movement_ext:zipline_unit())
						end
					end,
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value*100)
					end,
					icon_data = {
						source = "skill",
						skill_id = "jail_diet",
						tree = 4
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true,
						value_inherit_global = false,
						buff_color_value_normal = "76d2e2",
						buff_color_value_full = "3cd2ed"
					},
					preview = {
						value = 0.4
					}
				},
				crit_chance = { --(general crit chance)
					disabled = false,
					source = "general",
					text_id = "menu_kitr_buff_crit_chance_title",
					desc_id = "menu_kitr_buff_crit_chance_desc",
					show_timer = false,
					show_value = true,
					upd_func = function(t,dt,values,display_setting,buff_data)
						local detection_risk = math.round(managers.blackmarket:get_suspicion_offset_from_custom_data({
							armors = managers.blackmarket:equipped_armor(true,true)
						}, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75) * 100)
						return managers.player:critical_hit_chance(detection_risk)
					end,
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value*100)
					end,
					icon_data = {
						source = "skill",
						skill_id = "backstab",
						tree = 4
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					},
					preview = {
						value = 0.4
					}
				},
				damage_resistance = { --general damage resist
					disabled = false,
					source = "general",
					text_id = "menu_kitr_buff_damage_resistance_title",
					desc_id = "menu_kitr_buff_damage_resistance_desc",
					show_timer = false,
					show_value = true,
					upd_func = function(t,dt,values,display_setting,buff_data)
						return (1 - managers.player:damage_reduction_skill_multiplier())
					end,
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					icon_data = {
						source = "skill",
						skill_id = "juggernaut"
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					},
					preview = {
						value = 0.5
					}
				},
				fixed_health_regen = { --general health regen (heal +specific amount)
					disabled = false,
					source = "general",
					text_id = "menu_kitr_buff_fixed_health_regen_title",
					desc_id = "menu_kitr_buff_fixed_health_regen_desc",
					show_timer = false,
					show_value = true,
					--[[
					upd_func = function(t,dt,values,display_setting,buff_data)
						local pm = managers.player
						local player = pm:local_player()
						if player then
							local dmg_ext = player:character_damage()
							return pm:fixed_health_regen()
						end
					end,
					get_display_string = function(buff,value)
						return string.format("+%i%%",value*100)
					end,
					modify_timer_func = function(timer)
						local pm = managers.player
						local player = pm:local_player()
						local dmg_ext = player:character_damage()
						return dmg_ext._health_regen_update_timer or 0 
					end,
					--]]
					icon_data = {
						source = "hud_icon",
						skill_id = "csb_health" --temp
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					},
					preview = {
						value = 0.4
					}
				},
				health_regen = { --general fixed health regen (heal % of max health)
					disabled = false,
					source = "general",
					text_id = "menu_kitr_buff_health_regen_title",
					desc_id = "menu_kitr_buff_health_regen_desc",
					show_timer = false,
					show_value = true,
					--[[
					upd_func = function(t,dt,values,display_setting,buff_data)
						local pm = managers.player
						local player = pm:local_player()
						local dmg_ext = player:character_damage()
						local time_left = dmg_ext._health_regen_update_timer or 0
						values[1] = pm:health_regen()
					end,
					get_display_string = function(buff,value)
						return string.format("+%0.2f",value*100)
					end,
					modify_timer_func = function()
						local pm = managers.player
						local player = pm:local_player()
						local dmg_ext = player:character_damage()
						return dmg_ext._health_regen_update_timer or 0 
					end,
					--]]
					icon_data = {
						source = "perk",
						tree = 2,
						card = 9
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				
				--todo weapon buffs
				weapon_reload_speed = {
					disabled = false,
					source = "general",
					text_id = "menu_kitr_buff_weapon_reload_speed_multiplier_title",
					desc_id = "menu_kitr_buff_weapon_reload_speed_multiplier_desc",
					show_timer = false,
					show_value = true,
					--[[
					upd_func = function(t,dt,values,display_setting,buff_data)
						local player = managers.player:local_player()
						local inv_ext = player:inventory()
						local equipped_unit = inv_ext:equipped_unit()
						if alive(equipped_unit) then 
							local base = equipped_unit:base()
							values[1] = base and base:reload_speed_multiplier() or values[1]
						end
					end,
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value*100)
					end,
					--]]
					icon_data = {
						source = "hud_icon",
						skill_id = "equipment_stapler"
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				weapon_damage_bonus = {
					disabled = false,
					source = "general",
					text_id = "menu_kitr_buff_weapon_damage_multiplier_title",
					desc_id = "menu_kitr_buff_weapon_damage_multiplier_desc",
					show_timer = false,
					show_value = true,
					--[[
					upd_func = function(t,dt,values,display_setting,buff_data)
						local player = managers.player:local_player()
						local inv_ext = player:inventory()
						local equipped_unit = inv_ext:equipped_unit()
						if alive(equipped_unit) then 
							local base = equipped_unit:base()
							values[1] = base and base:damage_multiplier() or values[1]
						end
					end,
					--]]
					get_display_string = function(buff,value)
						return string.format("+%0.2f%%",value*100)
					end,
					icon_data = {
						source = "hud_icon",
						skill_id = "equipment_stapler"
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				weapon_accuracy_bonus = {
					disabled = true,
					source = "general",
					text_id = "menu_kitr_buff_weapon_accuracy_multiplier_title",
					desc_id = "menu_kitr_buff_weapon_accuracy_multiplier_desc",
					show_timer = false,
					show_value = true,
					--[[
					upd_func = function(t,dt,values,display_setting,buff_data)
						values[1] = managers.player:get_accuracy_multiplier()
					end,
					--]]
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value*100)
					end,
					icon_data = {
						source = "hud_icon",
						skill_id = "equipment_stapler"
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				melee_damage_bonus = { --this basically just checks the bloodthirst melee damage bonus
					disabled = true,
					source = "general",
					text_id = "menu_kitr_buff_melee_damage_multiplier_title",
					desc_id = "menu_kitr_buff_melee_damage_multiplier_desc",
					show_timer = false,
					show_value = true,
					--[[
					upd_func = function(t,dt,values,display_setting,buff_data)
						values[1] = managers.player:get_melee_dmg_multiplier()
					end,
					--]]
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value*100)
					end,
					icon_data = {
						source = "hud_icon",
						skill_id = "equipment_stapler"
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				
				
				ecm_jammer = { --(ecm jammer timer)
					disabled = false,
					source = "general",
					name_id = "kitr_buff_ecm_jammer_title",
					show_timer = false,
					show_value = true,
					--[[
					upd_func = function(t,dt,values,display_setting,buff_data)
						local threshold = display_setting.value_threshold
						local groupaistate = managers.groupai:state()
						local ecm_jammers = groupaistate._ecm_jammers
						for u_key,ecm_data in pairs(ecm_jammers) do
							local unit = ecm_data.unit
							local jam_settings = ecm_data.settings
		--					if jam_settings.camera then 
							
		--					end
						end
		--				values[1] = "example"
					end,
					--]]
					icon_data = {
						source = "skill",
						skill_id = "ecm_2x",
						tree = 4
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				ecm_feedback = { --(ecm feedback timer) 
					disabled = false,
					source = "general",
					text_id = "kitr_buff_ecm_feedback_title",
					show_timer = true,
					show_value = false,
					icon_data = {
						source = "skill",
						skill_id = "ecm_booster",
						tree = 4
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			
			
		--mastermind
				combat_medic = { --combat medic (damage reduction during/after res)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_combat_medic_beta",
					desc_id = "menu_kitr_buff_combat_medic_desc",
					icon_data = {
						source = "skill",
						skill_id = "combat_medic",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",(1-value)*100)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				combat_medic_damage_mul = {
					disabled = true, --actually disabled
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_combat_medic_beta",
					icon_data = {
						source = "skill",
						skill_id = "combat_medic",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				combat_medic_steelsight_mul = {
					disabled = true, --actually disabled
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_combat_medic_beta",
					icon_data = {
						source = "skill",
						skill_id = "combat_medic",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				quick_fix = { --quick fix (damage reduction after using health kit)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_tea_time_beta",
					icon_data = {
						source = "skill",
						skill_id = "tea_time",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",(1-value)*100)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				painkillers = { --painkillers (damage reduction for teammates you revive)
					disabled = false, --needs testing
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_fast_learner_beta",
					icon_data = {
						source = "skill",
						skill_id = "fast_learner",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				inspire_basic = { --inspire basic (move speed + reload speed bonus for teammates you shout at);
					disabled = false, --not implemented; requires hooking to player movement ext
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_inspire_beta",
					icon_data = {
						source = "skill",
						skill_id = "inspire",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				inspire_basic_cooldown = {
					disabled = false, --not implemented; requires checking var :rally_skill_data().morale_boost_delay_t in player movement ext
					show_timer = true,
					show_value = false,
					source = "skill",
					text_id = "menu_inspire_beta",
					icon_data = {
						source = "skill",
						skill_id = "inspire",
						tree = 1
					},
					is_aced = false,
					is_basic = true,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
				inspire_aced_cooldown = { --value is 1, which is evidently meaningless, so don't bother showing it, just the timer
					disabled = false,
					show_timer = true,
					show_value = false,
					source = "skill",
					text_id = "menu_inspire_beta",
					desc_id = "menu_kitr_buff_inspire_aced_cooldown_desc",
					icon_data = {
						source = "skill",
						skill_id = "inspire",
						tree = 1
					},
					is_aced = true,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
				forced_friendship = { --forced friendship (nearby civs give damage absorption)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_triathlete_beta",
					icon_data = {
						source = "skill",
						skill_id = "triathlete",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				partners_in_crime = { --partners in crime (extra max health while you have a convert)
					disabled = true, --not implemented
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_control_freak_beta",
					icon_data = {
						source = "skill",
						skill_id = "control_freak",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("+%0.2f%%",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false
				},
				stockholm_syndrome = { --stockholm syndrome aced (hostages autotrade for your return)
					disabled = true, --not implemented
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_stockholm_syndrome_beta",
					icon_data = {
						source = "skill",
						skill_id = "stockholm_syndrome",
						tree = 1
					},
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				stable_shot = { --stable shot (bonus accuracy while standing still)
					disabled = true, --not implemented
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_stable_shot_beta",
					icon_data = {
						source = "skill",
						skill_id = "stable_shot",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				rifleman = { --rifleman (bonus accuracy while moving)
					disabled = true, --not implemented
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_rifleman_beta",
					icon_data = {
						source = "skill",
						skill_id = "rifleman",
						tree = 1
					},
					is_aced = true,
					is_basic = false,
					is_cooldown = false
				},
				ammo_efficiency = { --ammo efficiency (consecutive headshots refund ammo); show stacks
					disabled = false, --not implemented; requires "guessing" or coroutine override
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_single_shot_ammo_return_beta",
					icon_data = {
						source = "skill",
						skill_id = "spotter_teamwork",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("x%0.2f",value)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				aggressive_reload = { --aggressive reload aced (killing headshot reduces reload speed)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_speedy_reload_beta",
					show_timer = true,
					icon_data = {
						source = "skill",
						skill_id = "speedy_reload",
						tree = 1
					},
					get_display_string = function(buff,value)
						return string.format("%0.2fx",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				
		--enforcer
				underdog_basic = { --underdog (basic: damage bonus when targeted by enemies; aced: damage resist when targeted by enemies)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_underdog_beta",
					icon_data = {
						source = "skill",
						skill_id = "underdog",
						tree = 2
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				underdog_aced = { --underdog (basic: damage bonus when targeted by enemies; aced: damage resist when targeted by enemies)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_underdog_beta",
					icon_data = {
						source = "skill",
						skill_id = "underdog",
						tree = 2
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				far_away = { --far away basic (accuracy bonus while ads with shotguns)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_far_away_beta",
					icon_data = {
						source = "skill",
						skill_id = "far_away",
						tree = 2
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				close_by = { --close by (rof increase while hipfire with shotguns)
					disabled = true, --not implemented
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_close_by_beta",
					icon_data = {
						source = "skill",
						skill_id = "close_by",
						tree = 2
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false
				},
				overkill = { --overkill (basic: damage bonus for saw/shotgun on kill with saw/shotgun; aced: damage bonus for all ranged weapons on kill with saw/shotgun)
					disabled = false, 
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_overkill_beta",
					icon_data = {
						source = "skill",
						skill_id = "overkill",
						tree = 2
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				die_hard = { --die hard basic (damage resist while interacting)
					disabled = false, --not implemented; requires manual checking via upd_func
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_show_of_force_beta",
					icon_data = {
						source = "skill",
						skill_id = "show_of_force",
						tree = 2
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				bullseye = { --bullseye (armorgate) cooldown
					disabled = false,
					show_timer = true,
					show_value = false,
					source = "skill",
					text_id = "menu_prison_wife_beta",
					icon_data = {
						source = "skill",
						skill_id = "prison_wife",
						tree = 2
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
				scavenger = { --scavenger aced: extra ammo box every 6 kills
					disabled = false, --not implemented; requires hooking to playermanager to get var ._num_kills % ._target_kills
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_scavenging_beta",
					icon_data = {
						source = "skill",
						skill_id = "scavenging",
						tree = 2
					},
					get_display_string = function(buff,value)
						return string.format("%i",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				bullet_storm = { --bulletstorm (temp don't consume ammo after using your ammo bags)
					disabled = false,
					show_timer = true,
					show_value = false,
					source = "skill",
					text_id = "menu_ammo_reservoir_beta",
					icon_data = {
						source = "skill",
						skill_id = "ammo_reservoir",
						tree = 2
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				fully_loaded = { --fully loaded aced (escalating throwable restore chance from ammo boxes)
					disabled = false, --not implemented; requires guessing FullyLoaded coroutine
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_bandoliers_beta",
					icon_data = {
						source = "skill",
						skill_id = "bandoliers",
						tree = 2
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},

		--technician
				hardware_expert = { --hardware expert (drill upgrades)
					disabled = true, --not implemented
					show_timer = false,
					show_value = false,
					source = "skill",
					text_id = "menu_hardware_expert_beta",
					icon_data = {
						source = "skill",
						skill_id = "hardware_expert",
						tree = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false
				},
				drill_sawgeant = { --drill sawgeant (drill upgrades)
					disabled = true, --not implemented
					show_timer = false,
					show_value = false,
					source = "skill",
					text_id = "menu_drill_expert_beta",
					icon_data = {
						source = "skill",
						skill_id = "drill_expert",
						tree = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false
				},
				kick_starter = { --kickstarter (drill upgrades); also show when a drill has attempted kickstarter
					disabled = true, --not implemented
					show_timer = false,
					show_value = false,
					source = "skill",
					text_id = "menu_kick_starter_beta",
					icon_data = {
						source = "skill",
						skill_id = "kick_starter",
						tree = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false
				},
				fire_control = { --fire control (basic: accuracy while hipfiring; aced: accuracy penalty reduction when moving)
					disabled = true, --not implemented
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_fire_control_beta",
					icon_data = {
						source = "skill",
						skill_id = "fire_control",
						tree = 3
					},
					get_display_string = function(buff,value)
						return string.format("%0.2fx",value)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false
				},
				lock_n_load = { --lock n' load aced (reload time reduction after autofire kills with lmg/ar/smg/specials )
					disabled = false,
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_shock_and_awe_beta",
					icon_data = {
						source = "skill",
						skill_id = "shock_and_awe",
						tree = 3
					},
					get_display_string = function(buff,value)
						return string.format("%0.2fx",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				
			--ghost
				chameleon = { --sixth sense basic (mark nearby enemies)
					disabled = false, --not implemented; requires hooking to playerstandard:_update_omniscience()
					show_timer = true,
					show_value = false,
					source = "skill",
					text_id = "menu_chameleon_beta",
					icon_data = {
						source = "skill",
						skill_id = "chameleon",
						tree = 4
					},
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				second_chances = { --nimble basic (camera loop)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "skill",
					text_id = "menu_second_chances_beta",
					icon_data = {
						source = "skill",
						skill_id = "second_chances",
						tree = 4
					},
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				dire_chance = { --dire need (stagger chance when armor is broken)
					disabled = false,
					show_timer = true,
					show_value = false,
					source = "skill",
					text_id = "menu_dire_need_beta",
					icon_data = {
						source = "skill",
						skill_id = "dire_need",
						tree = 4
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f",value)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				second_wind = { --second wind (speed bonus on armor break)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_scavenger_beta",
					icon_data = {
						source = "skill",
						skill_id = "scavenger",
						tree = 4
					},
					get_display_string = function(buff,value)
						return string.format("%0.2fx",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				second_wind_aced = {
					disabled = false,
					show_timer = false,
					show_value = false,
					source = "skill",
					text_id = "menu_scavenger_beta",
					icon_data = {
						source = "skill",
						skill_id = "scavenger",
						tree = 4
					},
					get_display_string = function(buff,value)
						return string.format("%0.2fx",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
		--needs a proc countdown timer, and effect timer
				unseen_strike = { --unseen strike (crit chance when not taking damage)
					disabled = false, --not implemented (requires guessing coroutine UnseenStrike)
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_unseen_strike_beta",
					icon_data = {
						source = "skill",
						skill_id = "unseen_strike",
						tree = 4
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			
			--fugitive
				desperado = { --desperado (stacking accuracy bonus per hit for pistols)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_expert_handling",
					icon_data = {
						source = "skill",
						skill_id = "expert_handling",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",(1-value) * 100)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				trigger_happy = { --trigger happy (stacking damage bonus per hit for pistols)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_trigger_happy_beta",
					icon_data = {
						source = "skill",
						skill_id = "trigger_happy",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",n * 100)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				running_from_death_basic_reload_speed = { --running_from_death (basic: reload/swap speed bonus after being revived; aced: move speed bonus after being revived)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_running_from_death_beta",
					icon_data = {
						source = "skill",
						skill_id = "running_from_death",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%0.2fx",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				running_from_death_basic_swap_speed = {
					disabled = false, --redundant; disabled
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_running_from_death_beta",
					icon_data = {
						source = "skill",
						skill_id = "running_from_death",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%0.2fx",value)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				running_from_death_aced = {
					disabled = true, --redundant; disabled
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_running_from_death_beta",
					icon_data = {
						source = "skill",
						skill_id = "running_from_death",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%0.2fx",value)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				up_you_go = { --up you go basic: damage resistance after being revived
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_up_you_go_beta",
					icon_data = {
						source = "skill",
						skill_id = "up_you_go",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",(1-value) * 100)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				swan_song = { --swan song: temporarily continue fighting after reaching 0 health
					disabled = false,
					show_timer = true,
					show_value = false, --the value given is 1, as a damage multiplier, so don't bother showing it
					source = "skill",
					text_id = "menu_perseverance_beta",
					icon_data = {
						source = "skill",
						skill_id = "perseverance",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value*100)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				messiah = { --messiah: kill an enemy to self-revive
					disabled = false, --not implemented; requires hooking to playermanager to get var ._messiah_charges
					show_timer = false,
					show_value = false,
					source = "skill",
					text_id = "menu_pistol_beta_messiah",
					icon_data = {
						source = "skill",
						skill_id = "messiah",
						tree = 5
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				bloodthirst_basic = { --bloodthirst basic: stacking melee damage bonus per kill
					disabled = false, --not implemented; requires guessing coroutine playerbloodthirstbase
					show_timer = true,
					show_value = false,
					source = "skill",
					text_id = "menu_bloodthirst",
					icon_data = {
						source = "skill",
						skill_id = "bloodthirst",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%0.2f%%",value*100)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				bloodthirst_aced = { --bloodthirst aced: reload speed bonus on melee kill
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "skill",
					text_id = "menu_bloodthirst",
					icon_data = {
						source = "skill",
						skill_id = "bloodthirst",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				counterstrike = { --counterstrike (counter melee/cloaker kick)
					disabled = false, --not implemented; requires upd_func to check playerstandard meleeing state
					show_timer = false,
					show_value = false,
					source = "skill",
					text_id = "menu_drop_soap_beta",
					icon_data = {
						source = "skill",
						skill_id = "drop_soap",
						tree = 5
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
				berserker_basic = { --berserker (melee damage bonus inverse to health ratio)
					disabled = false, --not implemented; requires upd_func
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_wolverine_beta",
					icon_data = {
						source = "skill",
						skill_id = "wolverine",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					is_aced = false,
					is_basic = true,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				berserker_aced = { --berserker (ranged damage bonus inverse to health ratio)
					disabled = false, --not implemented; requires upd_func
					show_timer = false,
					show_value = true,
					source = "skill",
					text_id = "menu_wolverine_beta",
					icon_data = {
						source = "skill",
						skill_id = "wolverine",
						tree = 5
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					is_aced = true,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
		--perkdecks

			--crew chief
				marathon_man = { --marathon man (damage reduction in medium range of enemies)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck1_1",
					icon_data = {
						source = "perk",
						tree = 1,
						card = 1
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				hostage_situation = { --hostage situation (damage resistance per hostage)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck1_5",
					icon_data = {
						source = "perk",
						tree = 1,
						card = 5
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--muscle
				meat_shield = { --meat shield (increased threat when close to allies)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck2_3",
					icon_data = {
						source = "perk",
						tree = 2,
						card = 3
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--armorer
				reinforced_armor = { --reinforced armor (temporary invuln on armor break)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck3_7",
					icon_data = {
						source = "perk",
						tree = 3,
						card = 7
					},
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				reinforced_armor_cooldown = { --(temp invuln cooldown)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck3_7",
					icon_data = {
						source = "perk",
						tree = 3,
						card = 7
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
			--rogue
				elusive = { --elusive (decreased threat when close to allies)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck4_3",
					icon_data = {
						source = "perk",
						tree = 4,
						card = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--hitman
				tooth_and_claw = { --tooth and claw (guaranteed armor regen timer after break)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck5_9",
					icon_data = {
						source = "perk",
						tree = 5,
						card = 9
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--burglar
				bag_of_tricks = { --bag of tricks/luck of the irish/dutch courage (reduced target chance from crouching still)
					disabled = true, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck7_3",
					icon_data = {
						source = "perk",
						tree = 7,
						card = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				breath_of_fresh_air = { --breath of fresh air (increased armor recovery rate when standing still)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck7_9",
					icon_data = {
						source = "perk",
						tree = 7,
						card = 9
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = false
					}
				},
			--infiltrator
				overdog = { --overdog (damage resist when surrounded, stacking melee hit damage) (shared with sociopath)
					disabled = false, --not implemented
					show_timer = true,
					show_value = true,
					source = "perk",
					text_id = "menu_deck8_1",
					icon_data = {
						source = "perk",
						tree = 8,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				basic_close_combat = { --basic close combat (damage resist when within medium range of enemy)
					disabled = false, --not implemented
					show_timer = true,
					show_value = true,
					source = "perk",
					text_id = "menu_deck8_3",
					icon_data = {
						source = "perk",
						tree = 8,
						card = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				life_leech = { --life drain (melee hit restores health cooldown)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck8_9",
					icon_data = {
						source = "perk",
						tree = 8,
						card = 9
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
			--sociopath
				tension = { --tension (armor gate on kill cooldown)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck9_3",
					icon_data = {
						source = "perk",
						tree = 9,
						card = 3
						
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
				clean_hit = { --clean hit (health on melee kill cooldown)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck9_5",
					icon_data = {
						source = "perk",
						tree = 9,
						card = 5
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
				overdose = { --overdose (armor gate on medium range kill cooldown)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck9_7",
					icon_data = {
						source = "perk",
						tree = 9,
						card = 7
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
			--gambler
				ammo_box_pickup_health = { --medical supplies (health on ammo box pickup cooldown)
					disabled = false,
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck10_1",
					icon_data = {
						source = "perk",
						tree = 10,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
				ammo_box_pickup_share = { --ammo give out (ammo box team share cooldown)
					disabled = false,
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck10_3",
					icon_data = {
						source = "perk",
						tree = 10,
						card = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
			--grinder
				histamine = { --histamine (current health on damage stacks/current duration)
					disabled = false, --not implemented
					show_timer = true,  
					show_value = false,
					source = "perk",
					text_id = "menu_deck11_1",
					icon_data = {
						source = "perk",
						tree = 11,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				histamine_cooldown = { --histamine (health on damage stacks cooldown)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck11_1",
					icon_data = {
						source = "perk",
						tree = 11,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
			--yakuza
				koi_irezumi = { --koi irezumi (armor recovery rate inverse to health)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck12_1",
					icon_data = {
						source = "perk",
						tree = 12,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				hebi_irezumi = { --hebi irezumi (move speed inverse to health)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck12_3",
					icon_data = {
						source = "perk",
						tree = 12,
						card = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--ex-president
				point_break = { --point break (stored health per kill)
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck13_1",
					icon_data = {
						source = "perk",
						tree = 13,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--maniac
				excitement = { --excitement (hysteria stacks + decay timer)
					disabled = false, --not implemented
					show_timer = true,
					show_value = true,
					source = "perk",
					text_id = "menu_deck14_1",
					icon_data = {
						source = "perk",
						tree = 14,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--anarchist
				blitzkrieg_bop = { --blitzkrieg bop (armor regen timer)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck15_1",
					icon_data = {
						source = "perk",
						tree = 15,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				lust_for_life = { --lust for life (armor on damage cooldown)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck15_7",
					icon_data = {
						source = "perk",
						tree = 15,
						card = 7
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
			--biker
				prospect = { --prospect (health/armor on any crew kill)
					disabled = false, --not implemented
					show_timer = true,
					show_value = true,
					source = "perk",
					text_id = "menu_deck16_1",
					upd_func = function(t,dt,values,display_setting,buff_data)
						
					end,
					--[[
					format_values_func = function(values,display_setting)
						return string.format("x%i",#values)
					end,
					get_display_string = function(buff,value)
						return string.format("%i%%",value*100)
					end,
					--]]
					icon_data = {
						source = "perk",
						tree = 16,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--kingpin
				kingpin_injector = { --injector throwable duration + damage resist
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck17_1",
					icon_data = {
						source = "perk",
						tree = 17,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
			--sicario
				sicario_smoke_bomb = { --smoke bomb (cooldown, in-screen effect)
					disabled = false, --not implemented
					show_timer = false,
					show_value = false,
					source = "perk",
					text_id = "menu_deck18_1",
					icon_data = {
						source = "perk",
						tree = 18,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				twitch = { --twitch shot dodge gain
					disabled = false, --not implemented
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "menu_deck18_3",
					icon_data = {
						source = "perk",
						tree = 18,
						card = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				twitch_cooldown = { --twitch (shot dodge cooldown)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck18_3",
					icon_data = {
						source = "perk",
						tree = 18,
						card = 3
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
			--stoic
				virtue = { --virtue (hip flask)
					disabled = true, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck19_1",
					icon_data = {
						source = "perk",
						tree = 19,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true,
					menu_options = {
						enabled = true
					}
				},
				delayed_damage = { --general delayed damage
					disabled = false, --not implemented
					show_timer = true,
					show_value = true,
					source = "perk",
					text_id = "menu_kitr_buff_delayed_damage_title",
					desc_id = "menu_kitr_buff_delayed_damage_desc",
					icon_data = {
						source = "perk",
						tree = 19,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				calm = { --calm (4s countdown free delayed damage negation)
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck19_5",
					icon_data = {
						source = "perk",
						tree = 19,
						card = 5
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--tag team
				gas_dispenser = { --gas dispenser tagged/tagging status/duration?
					disabled = false, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck20_1",
					icon_data = {
						source = "perk",
						tree = 20,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--hacker
				pocket_ecm_jammer = { --pocket ecm throwable (jammer mode)
					disabled = false,
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "kitr_buff_hacker_pecm_jammer_title",
					icon_data = {
						source = "perk",
						tree = 21,
						card = 1
					},
					get_display_string = nil,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				pocket_ecm_feedback = { --pocket ecm throwable (feedback mode)
					disabled = false,
					show_timer = true,
					show_value = true,
					source = "perk",
					text_id = "kitr_buff_hacker_pecm_feedback_title",
					icon_data = {
						source = "perk",
						tree = 21,
						card = 1
					},
					get_display_string = function(buff,value)
						return string.format("x%i",value) -- number of ticks remaining
					end,
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				kluge = { --kluge (dodge on kill while feedback active)
					disabled = false, --not implemented
					show_timer = true,
					show_value = true, -- dodge amount
					source = "perk",
					text_id = "menu_deck21_7",
					icon_data = {
						source = "perk",
						tree = 21,
						card = 7
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
			--leech 
				leech = { --leech throwable duration
					disabled = true, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck22_1",
					icon_data = {
						source = "perk",
						tree = 22,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false
				},
				leech_grace = { -- temp invuln on healthgate duration
					disabled = true, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck22_1",
					icon_data = {
						source = "perk",
						tree = 22,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = false,
					menu_options = {
						enabled = true
					}
				},
				leech_cooldown = {
					disabled = true, --not implemented
					show_timer = true,
					show_value = false,
					source = "perk",
					text_id = "menu_deck22_1",
					icon_data = {
						source = "perk",
						tree = 22,
						card = 1
					},
					is_aced = false,
					is_basic = false,
					is_cooldown = true
				},
				copycat_primarykills = { -- show only when primary is out
					disabled = false,
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "kitr_buff_copycat_primarykills_title",
					icon_data = {
						source = "perk",
						tree = 23,
						card = 1
					},
					menu_options = {
						enabled = true
					}
				},
				copycat_secondarykills = { -- show only when secondary is out
					disabled = false,
					show_timer = false,
					show_value = true,
					source = "perk",
					text_id = "kitr_buff_copycat_secondarykills_title",
					icon_data = {
						source = "perk",
						tree = 23,
						card = 1
					},
					menu_options = {
						enabled = true
					}
				}
			}
		}
		
	--todo overhaul-specific tweakdata
	end
	
	for k,v in pairs(td) do 
		self.tweak_data[k] = v
	end
	Hooks:Call("KineticTrackers_OnBuffDataLoaded",td)
	for k,v in pairs(self:GenerateBuffSettings(self.tweak_data)) do 
		self.buff_settings[k] = v
	end
end

--*************************************************--
		--colorpicker/menu preview callbacks
--************************************************--

function KineticTrackerCore:CreatePreviewPanel()
	if not (self._preview_panel and alive(self._preview_panel)) then
		local ws = managers.menu_component and managers.menu_component._fullscreen_ws
		if ws then
			self._preview_panel = ws:panel():panel({
				name = "preview_panel",
				layer = 1000
			})
			local preview_text = self._preview_panel:text({
				name = "preview_text",
				text = managers.localization:text("menu_kitr_preview_buff_title"),
				font = tweak_data.hud.medium_font,
				font_size = tweak_data.hud.medium_font,
				align = "left",
				vertical = "top",
				valign = "grow",
				halign = "grow",
				color = Color.white,
				blend_mode = "normal",
				x = 550,
				y = 24,
				alpha = 1,
				layer = 2
			})
			preview_text:animate(function(o)
				local t = 0
				while true do 
					t = t + coroutine.yield()
					o:set_alpha((3+math.cos(t * 180))/4)
				end
			end)
			local preview_bg = self._preview_panel:rect({
				name = "preview_bg",
				color = Color.black,
				alpha = 0.66,
				w = 0,
				h = 0
			})
			local x,y,w,h = preview_text:text_rect()
			local wmargin = 6
			local hmargin = 4
			preview_bg:set_size(w+wmargin+wmargin,h+hmargin+hmargin)
			preview_bg:set_position(x-wmargin,y-hmargin)
		end
	end
	return self._preview_panel
end

function KineticTrackerCore:RemovePreviewPanel()
	self:RemoveAllBuffPreviews()
	if self._preview_panel and alive(self._preview_panel) then
		self._preview_panel:parent():remove(self._preview_panel)
	end
	self._preview_panel = nil
end

function KineticTrackerCore:InitColorPicker()
	if _G.ColorPicker then 
		if not self._colorpicker then 
			local params = {
				palettes = self:GetColorPickerPalettes(),
				done_callback = callback(self,self,"callback_on_colorpicker_confirmed"),
				changed_callback = callback(self,self,"callback_on_colorpicker_selected")
			}
			self._colorpicker = ColorPicker:new("kinetictrackers",params,callback(self,self,"callback_on_colorpicker_created"))
		end
	end
end

function KineticTrackerCore:callback_on_colorpicker_created(colorpicker_menu)
	self._colorpicker = colorpicker_menu
end

function KineticTrackerCore:callback_on_colorpicker_selected(colorpicker_menu)
	--edit buff preview
end

function KineticTrackerCore:callback_on_colorpicker_confirmed(colorpicker_menu)
	--edit buff preview, save settings
end

function KineticTrackerCore:callback_on_colorpicker_save_palettes(palettes)
	for i,col_str in pairs(palettes) do 
		self.settings.palettes[i] = col_str
	end
	self:SaveSettings()
end

function KineticTrackerCore:callback_on_buffmenu_focus_changed(buff_id,this,focus)
	if focus then
		local buff_preview_panel = self:CreatePreviewPanel()
		if alive(buff_preview_panel) then
			self:CreateBuffPreview(buff_id,buff_preview_panel)
		end
	else
		self:RemoveBuffPreview(buff_id)
	end
end

function KineticTrackerCore:CreateBuffPreview(buff_id,buff_preview_panel)
	local settings = self.settings
	local buff_tweakdata = self.tweak_data.buffs[buff_id]
	local buff_display_setting = self.buff_settings[buff_id]
	local icon_data = buff_tweakdata.icon_data
	
	local preview_data = buff_tweakdata.preview
	local preview_value = preview_data and preview_data.value or 1
	local preview_timer = preview_data and preview_data.timer or 7
	
	local value_color
	if false then -- if value is full
		value_color = Color(buff_display_setting.buff_color_value_full)
	else
		value_color = Color(buff_display_setting.buff_color_value_normal)
	end
	
	local timer_color
	if buff_tweakdata.is_cooldown then
		timer_color = Color(buff_display_setting.buff_color_timer_cooldown)
	else	
		timer_color = Color(buff_display_setting.buff_color_timer_normal)
	end
	
	local texture_data = {}
	
	if icon_data.source == "skill" then 
		texture_data.texture = "guis/textures/pd2/skilltree_2/icons_atlas_2"
		local skill_icon_size = 80
		local x,y = unpack(tweak_data.skilltree.skills[icon_data.skill_id].icon_xy)
		texture_data.texture_rect = {x * skill_icon_size,y * skill_icon_size,skill_icon_size,skill_icon_size}
	elseif icon_data.source == "perk" then
		texture_data.texture,texture_data.texture_rect = self._holder.get_specialization_icon_data_by_tier(icon_data.tree,icon_data.card,false)
	elseif icon_data.source == "hud_icon" then 
		texture_data.texture,texture_data.texture_rect = tweak_data.hud_icons:get_icon_data(icon_data.skill_id)
	elseif icon_data.texture then 
		texture_data.texture,texture_data.texture_rect = icon_data.texture,icon_data.texture_rect
	end
	
	local value_str = ""
	if buff_tweakdata.show_value then
		if buff_tweakdata.get_display_string then
			value_str = buff_tweakdata.get_display_string(buff_tweakdata,preview_value)
		else
			value_str = tostring(preview_value)
		end
	end
	
	local gui_class = self:require("classes/KineticTrackerItemBase")
	local params = {
		name_text = buff_tweakdata.text_id and managers.localization:text(buff_tweakdata.text_id) or "ERROR",
		primary_text = value_str,
		secondary_text = "", -- timer text; set in update
		buff_data = buff_tweakdata,
		name_color = nil,
		primary_color = value_color,
		secondary_color = Color(buff_display_setting.buff_color_timer_normal),
		texture_data = texture_data
	}
	
	local item = gui_class:new(buff_id,params,buff_preview_panel)
	item._panel:set_position(500,360)
	
	--local format_time_func = self._holder.get_format_time_func(buff_display_setting,settings)
	if buff_tweakdata.show_timer then
		
		local duration = preview_timer
		if duration then
			item._updater_id = "kinetictracker_updater_buff_preview_" .. buff_id
			self:AddUpdater(updater_id,function(t,dt)
				if alive(item._panel) then
					duration = duration - dt
					if duration < 0 then
						duration = preview_timer
					end
					-- bad practice for perf optimization but easier for updating preview with settings
					
					local flash_mode = buff_display_setting.timer_flashing_mode
					local timer_flashing_threshold = buff_display_setting.timer_flashing_threshold or 0
					if flash_mode == 2 or flash_mode == 1 and timer_flashing_threshold > duration then
						item:set_secondary_text_flash(buff_display_setting.timer_flashing_speed * 90)
					end
					
					local format_time_func = self._holder.get_format_time_func(buff_display_setting,settings)
					item:set_secondary_text(format_time_func(duration))
				end
			end,true,true,true)
		end
	end
	
	self._preview_buffs[buff_id] = item
end

function KineticTrackerCore:RemoveBuffPreview(buff_id)
	local item = self._preview_buffs[buff_id]
	if item then
		self:RemoveUpdater(item._updater_id)
		item:destroy()
		self._preview_buffs[buff_id] = nil
	end
end

function KineticTrackerCore:RemoveAllBuffPreviews()
	for k,item in pairs(self._preview_buffs) do 
		item:destroy()
		self._preview_buffs[k] = nil
	end
end

function KineticTrackerCore:UpdBuffPreviewFlash(buff_id)
	local item = self._preview_buffs[buff_id]
	if item then
		item:stop_animate(item._primary_label,"primary_flash")
		item._primary_label:set_alpha(1)
		item:stop_animate(item._secondary_label,"secondary_flash")
		item._secondary_label:set_alpha(1)
	end
end

function KineticTrackerCore:callback_show_dialogue_missing_colorpicker()
--[[
		local function confirm_reset()
			for _,key in pairs(AdvancedCrosshair.setting_categories.palettes) do 
				AdvancedCrosshair.settings[key] = AdvancedCrosshair.default_settings[key]
			end
			QuickMenu:new(
				managers.localization:text("menu_ach_reset_palettes_prompt_success_title"),managers.localization:text("menu_ach_reset_palettes_prompt_success_desc"),{
					{
						text = managers.localization:text("menu_ach_prompt_ok"),
						is_cancel_button = true,
						is_focused_button = true
					}
				}
			,true)
		end
		AdvancedCrosshair:Save()
		QuickMenu:new(
			managers.localization:text("menu_ach_reset_palettes_prompt_confirm_title"),managers.localization:text("menu_ach_reset_palettes_prompt_confirm_desc"),{
				{
					text = managers.localization:text("menu_ach_prompt_confirm"),
					callback = confirm_reset
				},
				{
					text = managers.localization:text("menu_ach_prompt_cancel"),
					is_focused_button = true,
					is_cancel_button = true
				}
			}
		,true)
--]]
	local title = managers.localization:text("menu_kitr_missing_dependency_colorpicker_title")
	local desc = managers.localization:text("menu_kitr_missing_dependency_colorpicker_desc")
	QuickMenu:new(title,desc,
		{
			{
				text = managers.localization:text("menu_ok")
			}
		},
		true
	)
end

function KineticTrackerCore:AddUpdater(id,cb,unpaused,paused,menu)
	if unpaused then
		Hooks:Add("GameSetupUpdate",id,cb)
	end
	if paused then
		Hooks:Add("GameSetupPausedUpdate",id,cb)
	end
	if menu then
		Hooks:Add("MenuUpdate",id,cb)
	end
end

function KineticTrackerCore:RemoveUpdater(id,unpaused,paused,menu)
	if unpaused then
		Hooks:Remove("GameSetupUpdate",id)
	end
	if paused then
		Hooks:Remove("GameSetupPausedUpdate",id)
	end
	if menu then
		Hooks:Remove("MenuUpdate",id)
	end
end

function KineticTrackerCore:GetPaletteColors()
	local result = {}
	for i,hex in ipairs(self.settings.palettes) do 
		result[i] = Color(hex)
	end
	return result
end

function KineticTrackerCore:SetPaletteCodes(tbl)
	if type(tbl) == "table" then 
		for i,color in ipairs(tbl) do 
			self.settings.palettes[i] = ColorPicker.color_to_hex(color)
		end
	else
		self:log("Error: SetPaletteCodes(" .. tostring(tbl) .. ") Bad palettes table from ColorPicker callback")
	end
end

function KineticTrackerCore:GetColorPickerPalettes()
	return self.settings.palettes
end
function KineticTrackerCore:GetColorPickerDefaultPalettes()
	return self.default_palettes
end

function KineticTrackerCore:UpdBuffPreviewColor(color)
	for buff_id,item in pairs(self._preview_buffs) do
		item:set_primary_text_color(color)
		item:set_secondary_text_color(color)
	end
end

--[[
function KineticTrackerCore:AddGeneralBuffs()
	-- [ [
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
	-- ] ]
end
--]]
