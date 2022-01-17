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
		this allows "unchanged" values where a player can choose to have global settings (like ACH) which can be overrided on a per-buff basis
		
		
		
	
	add item style option (link Holder's update and Item:new() call to global style setting)
	add buff name popup per buff on first activation
	fix minor margin/2 offset display bug for primary_bg rect object
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
	straighten out buff-enabled setting vs buff data enabled value
	
	
	
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
		timer_precision = 2,
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
	
	
	
				MenuHelper:AddMultipleChoice({
					id = "ach_crosshairs_general_outofrange_mode",
					title = "menu_ach_crosshairs_general_outofrange_mode_title",
					desc = "menu_ach_crosshairs_general_outofrange_mode_desc",
					callback = "callback_ach_crosshairs_general_set_outofrange_mode",
					items = {
						"menu_ach_outofrange_disabled",
						"menu_ach_outofrange_size"
					},
					value = AdvancedCrosshair.settings.crosshair_outofrange_mode,
					menu_id = AdvancedCrosshair.crosshairs_menu_id,
					priority = 7
				})
				
				MenuHelper:AddButton({
					id = "id_ach_menu_crosshairs_categories_global_preview_bloom",
					title = "menu_ach_preview_bloom_title",
					desc = "menu_ach_preview_bloom_desc",
					callback = "callback_ach_crosshairs_categories_global_preview_bloom",
					menu_id = AdvancedCrosshair.crosshairs_categories_global_id,
					priority = 1
				})
				
				MenuHelper:AddSlider({
					id = "ach_hitsounds_set_hit_headshot_volume",
					title = "menu_ach_hitsounds_set_hit_headshot_volume_title",
					desc = "menu_ach_hitsounds_set_hit_headshot_volume_desc",
					callback = "callback_ach_hitsounds_set_hit_headshot_volume",
					value = AdvancedCrosshair.settings.hitsound_hit_headshot_volume,
					min = 0,
					max = 1,
					step = 0.1,
					show_value = true,
					menu_id = AdvancedCrosshair.hitsounds_menu_id,
					priority = 19
				})
					
				
				MenuHelper:AddDivider({
					id = "ach_crosshairs_general_divider_1",
					size = 16,
					menu_id = AdvancedCrosshair.crosshairs_menu_id,
					priority = 9
				})
				MenuHelper:AddToggle({
					id = "ach_crosshairs_general_master_enable",
					title = "menu_ach_crosshairs_general_master_enable_title",
					desc = "menu_ach_crosshairs_general_master_enable_desc",
					callback = "callback_ach_crosshairs_general_master_enable",
					value = AdvancedCrosshair.settings.crosshair_enabled,
					menu_id = AdvancedCrosshair.crosshairs_menu_id,
					priority = 8
				})
	
	
	
	
	
	
	
	buffs to be added:
		-todo (recursive; this todo is todo)
	
	
	
	
	
	
	
	
	
	
	
	
	separate entries for combat_medic property and timed buff to avoid possible conflicts (in practice it's fine but i'd prefer it to be more waterproof)
	
	separate equipment trackers? (ecm timers, sentry ammo counts, num tripmines out)
	
	
	
	
--]]

KineticTrackerCore = _G.KineticTrackerCore or {}


KineticTrackerCore._path = ModPath
KineticTrackerCore._options_path = ModPath .. "menu/options.json"
KineticTrackerCore._default_localization_path = ModPath .. "loc/english.json"
KineticTrackerCore._save_path = SavePath .. "KineticTrackers.json"

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
	toggle_setting = false,
	slider_setting = 0,
	palettes = table.deep_map_copy(KineticTrackerCore.default_palettes),
	multiplechoice_setting = 1,
	buffs = {
		TEMPLATE = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,--1 = minutes, 2 = seconds
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		absorption = {
			enabled = true,
			value_threshold = 2,
			color = "ffd700"
		},
		winters_present = {
			enabled = true,
			value_threshold = 2,
			color = "ffd700"
		},
		flashbang = {
			enabled = true,
			value_threshold = 2,
			color = "ffd700"
		},
		dodge_chance = {
			enabled = true,
			value_threshold = 0,
			color = "ffd700"
		},
		crit_chance = {
			enabled = true,
			value_threshold = 0,
			color = "ffd700"
		},
		damage_resistance = {
			enabled = true,
			value_threshold = 0,
			color = "ffd700"
		},
		fixed_health_regen = {
			enabled = true,
			value_threshold = 0,
			color = "ffd700"
		},
		health_regen = {
			enabled = true,
			value_threshold = 0,
			color = "ffd700"
		},
		weapon_reload_speed = {
			enabled = false,
			value_threshold = 0,
			color = "ffd700"
		},
		weapon_damage_bonus = {
			enabled = false,
			value_threshold = 0,
			color = "ffd700"
		},
		weapon_accuracy_bonus = {
			enabled = false,
			value_threshold = 0,
			color = "ffd700"
		},
		melee_damage_bonus = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		ecm_jammer = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		ecm_feedback = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		combat_medic = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		combat_medic_steelsight_mul = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		combat_medic_damage_mul = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		quick_fix = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		painkillers = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		inspire_basic = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		inspire_basic_cooldown = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		inspire_aced_cooldown = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		forced_friendship = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		partners_in_crime = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		stockholm_syndrome = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		stable_shot = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		rifleman = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		ammo_efficiency = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		aggressive_reload = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 1,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		underdog_basic = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		underdog_aced = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		far_away = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		close_by = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		overkill = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		die_hard = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		bullseye = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = false,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		scavenger = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		bullet_storm = {
			enabled = true,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		fully_loaded = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		hardware_expert = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		drill_sawgeant = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		kick_starter = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		fire_control = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		lock_n_load = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		chameleon = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		second_chances = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		dire_chance = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		second_wind = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		second_wind_aced = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		unseen_strike = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		desperado = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		trigger_happy = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		running_from_death_basic_reload_speed = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		running_from_death_basic_swap_speed = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		running_from_death_aced = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		up_you_go = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		swan_song = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		messiah = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		bloodthirst_basic = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		bloodthirst_aced = {
			enabled = false,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		counterstrike = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		berserker_basic = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		berserker_aced = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		marathon_man = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		hostage_situation = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		meat_shield = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		reinforced_armor = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		reinforced_armor_cooldown = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		elusive = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		tooth_and_claw = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		bag_of_tricks = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		breath_of_fresh_air = {
			enabled = false,
			value_threshold = 0,
			color = "ffffff"
		},
		overdog = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 1,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		basic_close_combat = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		life_leech = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		tension = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		clean_hit = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		overdose = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		ammo_box_pickup_health = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		ammo_box_pickup_share = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		histamine = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		koi_irezumi = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		hebi_irezumi = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		point_break = {
			enabled = true,
			value_threshold = 0,
			color = "ffffff"
		},
		excitement = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		blitzkrieg_bop = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		lust_for_life = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		prospect = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		kingpin_injector = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		sicario_smoke_bomb = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		twitch = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		virtue = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		delayed_damage = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		calm = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 2,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		gas_dispenser = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		pocket_ecm = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		kluge = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		},
		leech = {
			enabled = true,
			value_threshold = 0,
			timer_enabled = true,
			timer_minutes_display = 1,
			timer_precision = 2,
			timer_flashing_mode = 1,
			timer_flashing_threshold = 3,
			timer_flashing_speed = 1,
			color = "ffffff"
		}
	}
}
KineticTrackerCore.settings = table.deep_map_copy(KineticTrackerCore.default_settings)


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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
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
			focus_changed_callback = nil,
			menu_position = "perkdeck_hacker",
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
		"perkdeck_leech"
	},
	buffs_lookup = { --indexed by string buff_id; populated on MenuManagerSetupCustomMenus
	}
}

--[[
for i,v in ipairs(tweak_data.skilltree.specializations) do 
	if v.name_id then 
		Log(i .. " perk_" .. string.lower(managers.localization:text(v.name_id)))
	end
end
--]]




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

function KineticTrackerCore.get_temporary_property_time(self,prop,default)
	local time = Application:time()

	if self._properties[prop] and time <= self._properties[prop][2] then
		return self._properties[prop][2]
	elseif self._properties[prop] then
		self._properties[prop] = nil
	end

	return default
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
	return self.settings.buffs[id] or buff_options[id] or default
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

--aced/basic/cooldown text is applied later, on MenuManagerSetupCustomMenus
function KineticTrackerCore:InitBuffTweakData(mode)
	self.buff_id_lookups = {
		property = {
			revive_damage_reduction = "combat_medic", --while reviving other player
			shock_and_awe_reload_multiplier = "lock_n_load",
			trigger_happy = "trigger_happy",
			desperado = "desperado",
			copr_risen = "leech",
			copr_risen_cooldown_added = "leech_cooldown"
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
				team_damage_speed_multiplier_received = "second_wind_team", --second wind aced (from team)
				unseen_strike = "unseen_strike"
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
			text_id = "", --the localized name of this buff, as it appears in the menu and in the game
			icon_data = {
				source = "skill", --skill, perk, or hud_icon
				skill_id = "sadfasdf", --skill name, or hud_icon name
				tree = 1 --skilltree (to sort in menu options)
			},
			display_format = ""
		},
		example_perk = {
			disabled = false,
			text_id = "",
			icon_data = {
				source = "perk",
				tree = 1,
				card = 1
			},
			display_format = ""
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
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f"
		},
		winters_present = {
			disabled = false,
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
			display_format = "%i%%"
		},
		
		
		absorption = { --(general absorption)
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_damage_absorption_title",
			desc_id = "menu_kitr_buff_damage_absorption_desc",
			upd_func = function(t,dt,values,display_setting,buff_data)
				return managers.player:damage_absorption()
			end,
			modify_timer_func = nil,
			modify_value_func = function(n)
				return n * 10
			end,
			icon_data = {
				source = "perk",
				tree = 14,
				card = 1
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.1f"
		},
		dodge_chance = { --(general dodge chance)
			disabled = false,
			source = "general",
--			text_id = "menu_jail_diet_beta",
			text_id = "menu_kitr_buff_dodge_chance_title",
			desc_id = "menu_kitr_buff_dodge_chance_desc",
			upd_func = function(t,dt,values,display_setting,buff_data)
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
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%i%%"
		},
		crit_chance = { --(general crit chance)
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_crit_chance_title",
			desc_id = "menu_kitr_buff_crit_chance_desc",
			upd_func = function(t,dt,values,display_setting,buff_data)
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
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%i%%"
		},
		damage_resistance = { --general damage resist
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_damage_resistance_title",
			desc_id = "menu_kitr_buff_damage_resistance_desc",
			upd_func = function(t,dt,values,display_setting,buff_data)
				return (1 - managers.player:damage_reduction_skill_multiplier())
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "skill",
				skill_id = "juggernaut"
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%i%%"
		},
		fixed_health_regen = { --general health regen (heal +specific amount)
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_fixed_health_regen_title",
			desc_id = "menu_kitr_buff_fixed_health_regen_desc",
			show_timer = true,
			upd_func = function(t,dt,values,display_setting,buff_data)
				local pm = managers.player
				local player = pm:local_player()
				local dmg_ext = player:character_damage()
				return pm:fixed_health_regen()
			end,
			format_values_func = function(values,buff_display_setting)
				--
			end,
			modify_timer_func = function(timer)
				local pm = managers.player
				local player = pm:local_player()
				local dmg_ext = player:character_damage()
				return dmg_ext._health_regen_update_timer or 0 
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "csb_health" --temp
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "+%i%%"
		},
		health_regen = { --general fixed health regen (heal % of max health)
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_health_regen_title",
			desc_id = "menu_kitr_buff_health_regen_desc",
			show_timer = true,
			upd_func = function(t,dt,values,display_setting,buff_data)
				local pm = managers.player
				local player = pm:local_player()
				local dmg_ext = player:character_damage()
				local time_left = dmg_ext._health_regen_update_timer or 0
				values[1] = pm:health_regen()
			end,
			modify_timer_func = function()
				local pm = managers.player
				local player = pm:local_player()
				local dmg_ext = player:character_damage()
				return dmg_ext._health_regen_update_timer or 0 
			end,
			modify_value_func = function(n)
				return n * 10
			end,
			icon_data = {
				source = "perk",
				tree = 2,
				card = 9
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "+%0.2f"
		},
		
		--todo weapon buffs
		weapon_reload_speed = {
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_weapon_reload_speed_multiplier_title",
			desc_id = "menu_kitr_buff_weapon_reload_speed_multiplier_desc",
			show_timer = false,
			upd_func = function(t,dt,values,display_setting,buff_data)
				local player = managers.player:local_player()
				local inv_ext = player:inventory()
				local equipped_unit = inv_ext:equipped_unit()
				if alive(equipped_unit) then 
					local base = equipped_unit:base()
					values[1] = base and base:reload_speed_multiplier() or values[1]
				end
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "equipment_stapler"
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
		weapon_damage_bonus = {
			disabled = false,
			source = "general",
			text_id = "menu_kitr_buff_weapon_damage_multiplier_title",
			desc_id = "menu_kitr_buff_weapon_damage_multiplier_desc",
			show_timer = false,
			upd_func = function(t,dt,values,display_setting,buff_data)
				local player = managers.player:local_player()
				local inv_ext = player:inventory()
				local equipped_unit = inv_ext:equipped_unit()
				if alive(equipped_unit) then 
					local base = equipped_unit:base()
					values[1] = base and base:damage_multiplier() or values[1]
				end
			end,
			modify_value_func = function(n)
				return (n - 1) * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "equipment_stapler"
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "+%0.2f%%"
		},
		weapon_accuracy_bonus = {
			disabled = true,
			source = "general",
			text_id = "menu_kitr_buff_weapon_accuracy_multiplier_title",
			desc_id = "menu_kitr_buff_weapon_accuracy_multiplier_desc",
			show_timer = false,
			upd_func = function(t,dt,values,display_setting,buff_data)
				values[1] = managers.player:get_accuracy_multiplier()
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "equipment_stapler"
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
		melee_damage_bonus = { --this basically just checks the bloodthirst melee damage bonus
			disabled = true,
			source = "general",
			text_id = "menu_kitr_buff_melee_damage_multiplier_title",
			desc_id = "menu_kitr_buff_melee_damage_multiplier_desc",
			show_timer = false,
			upd_func = function(t,dt,values,display_setting,buff_data)
				values[1] = managers.player:get_melee_dmg_multiplier()
			end,
			modify_value_func = function(n)
				return n * 100
			end,
			icon_data = {
				source = "hud_icon",
				skill_id = "equipment_stapler"
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
		
		
		ecm_jammer = { --(ecm jammer timer)
			disabled = true,
			source = "general",
			text_id = "menu_ecm_2x_beta",
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
			icon_data = {
				source = "skill",
				skill_id = "ecm_2x",
				tree = 4
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
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
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
	
	
	
		combat_medic = { --combat medic (damage reduction during/after res)
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_combat_medic_beta",
--			desc_id = "menu_kitr_buff_combat_medic_desc",
			icon_data = {
				source = "skill",
				skill_id = "combat_medic",
				tree = 1
			},
			modify_value_func = function(n)
				return (1 - n) * 100
			end,
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
			display_format = "%i%%"
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
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
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
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
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
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			modify_value_func = function(n)
				return (1 - n) * 100
			end,
			display_format = "%0.2f%%"
		},
		painkillers = { --painkillers (damage reduction for teammates you revive)
			disabled = false, --needs testing
			show_timer = true,
			source = "skill",
			text_id = "menu_fast_learner_beta",
			icon_data = {
				source = "skill",
				skill_id = "fast_learner",
				tree = 1
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
		inspire_basic = { --inspire basic (move speed + reload speed bonus for teammates you shout at);
			disabled = false, --not implemented; requires hooking to player movement ext
			show_timer = true,
			source = "skill",
			text_id = "menu_inspire_beta",
			icon_data = {
				source = "skill",
				skill_id = "inspire",
				tree = 1
			},
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
			display_format = "%0.2f"
		},
		inspire_basic_cooldown = {
			disabled = false, --not implemented; requires checking var :rally_skill_data().morale_boost_delay_t in player movement ext
			show_timer = true,
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
			display_format = ""
		},
		inspire_aced_cooldown = {
			disabled = false,
			show_timer = true,
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
			display_format = "" --value is 1, which is evidently meaningless, so don't bother showing it
		},
		forced_friendship = { --forced friendship (nearby civs give damage absorption)
			disabled = false, --not implemented
			source = "skill",
			text_id = "menu_triathlete_beta",
			icon_data = {
				source = "skill",
				skill_id = "triathlete",
				tree = 1
			},
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
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
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = "+%0.2f%%"
		},
		stockholm_syndrome = { --stockholm syndrome aced (hostages autotrade for your return)
			disabled = false, --not implemented
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
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
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
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
		ammo_efficiency = { --ammo efficiency (consecutive headshots refund ammo); show stacks
			disabled = false, --not implemented; requires "guessing" or coroutine override
			source = "skill",
			text_id = "menu_single_shot_ammo_return_beta",
			icon_data = {
				source = "skill",
				skill_id = "spotter_teamwork",
				tree = 1
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
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
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
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
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
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
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
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
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
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
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
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
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
		die_hard = { --die hard basic (damage resist while interacting)
			disabled = false, --not implemented; requires manual checking via upd_func
			source = "skill",
			text_id = "menu_show_of_force_beta",
			icon_data = {
				source = "skill",
				skill_id = "show_of_force",
				tree = 2
			},
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
		bullseye = { --bullseye (armorgate) cooldown
			disabled = false, --not implemented; requires hooking to playermanager to get var ._on_headshot_dealt_t
			show_timer = true,
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
			display_format = ""
		},
		scavenger = { --scavenger aced: extra ammo box every 6 kills
			disabled = false, --not implemented; requires hooking to playermanager to get var ._num_kills % ._target_kills
			source = "skill",
			text_id = "menu_scavenging_beta",
			icon_data = {
				source = "skill",
				skill_id = "scavenging",
				tree = 2
			},
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
		bullet_storm = { --bulletstorm (temp don't consume ammo after using your ammo bags)
			disabled = false,
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
			display_format = ""
		},
		fully_loaded = { --fully loaded aced (escalating throwable restore chance from ammo boxes)
			disabled = false, --not implemented; requires guessing FullyLoaded coroutine
			source = "skill",
			text_id = "menu_bandoliers_beta",
			icon_data = {
				source = "skill",
				skill_id = "bandoliers",
				tree = 2
			},
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},

--technician
		hardware_expert = { --hardware expert (drill upgrades)
			disabled = false, --not implemented
			source = "skill",
			text_id = "menu_hardware_expert_beta",
			icon_data = {
				source = "skill",
				skill_id = "hardware_expert",
				tree = 3
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
		drill_sawgeant = { --drill sawgeant (drill upgrades)
			disabled = false, --not implemented
			source = "skill",
			text_id = "menu_drill_expert_beta",
			icon_data = {
				source = "skill",
				skill_id = "drill_expert",
				tree = 3
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
		kick_starter = { --kickstarter (drill upgrades); also show when a drill has attempted kickstarter
			disabled = false, --not implemented
			source = "skill",
			text_id = "menu_kick_starter_beta",
			icon_data = {
				source = "skill",
				skill_id = "kick_starter",
				tree = 3
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
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
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2fx"
		},
		lock_n_load = { --lock n' load aced (reload time reduction after autofire kills with lmg/ar/smg/specials )
			disabled = false,
			source = "skill",
			text_id = "menu_shock_and_awe_beta",
			icon_data = {
				source = "skill",
				skill_id = "shock_and_awe",
				tree = 3
			},
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2fx"
		},
		
	--ghost
		chameleon = { --sixth sense basic (mark nearby enemies)
			disabled = false, --not implemented; requires hooking to playerstandard:_update_omniscience()
			show_timer = true,
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
			display_format = "%0.2f" --show number of nearby enemies?
		},
		second_chances = { --nimble basic (camera loop)
			disabled = false, --not implemented
			show_timer = true,
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
			display_format = ""
		},
		dire_chance = { --dire need (stagger chance when armor is broken)
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_dire_need_beta",
			icon_data = {
				source = "skill",
				skill_id = "dire_need",
				tree = 4
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f"
		},
		second_wind = { --second wind (speed bonus on armor break)
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_scavenger_beta",
			icon_data = {
				source = "skill",
				skill_id = "scavenger",
				tree = 4
			},
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
			display_format = "%0.2fx"
		},
		second_wind_aced = {
			disabled = false,
			show_timer = false,
			source = "skill",
			text_id = "menu_scavenger_beta",
			icon_data = {
				source = "skill",
				skill_id = "scavenger",
				tree = 4
			},
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2fx"
		},
--needs a proc countdown timer, and effect timer
		unseen_strike = { --unseen strike (crit chance when not taking damage)
			disabled = false, --not implemented (requires guessing coroutine UnseenStrike)
			show_timer = true,
			source = "skill",
			text_id = "menu_unseen_strike_beta",
			icon_data = {
				source = "skill",
				skill_id = "unseen_strike",
				tree = 4
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
	
	--fugitive
		desperado = { --desperado (stacking accuracy bonus per hit for pistols)
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_expert_handling",
			icon_data = {
				source = "skill",
				skill_id = "expert_handling",
				tree = 5
			},
			modify_value_func = function(n)
				return (1 - n) * 100
			end,
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
			display_format = "%0.2f%%"
		},
		trigger_happy = { --trigger happy (stacking damage bonus per hit for pistols)
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_trigger_happy_beta",
			icon_data = {
				source = "skill",
				skill_id = "trigger_happy",
				tree = 5
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			modify_value_func = function(n)
				return n * 100
			end,
			display_format = "%0.2f%%"
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
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
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
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
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
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = "%0.2fx"
		},
		up_you_go = { --up you go basic: damage resistance after being revived
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_up_you_go_beta",
			icon_data = {
				source = "skill",
				skill_id = "up_you_go",
				tree = 5
			},
			modify_value_func = function(n)
				return (1 - n) * 100
			end,
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
			display_format = "%i%%"
		},
		swan_song = { --swan song: temporarily continue fighting after reaching 0 health
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_perseverance_beta",
			icon_data = {
				source = "skill",
				skill_id = "perseverance",
				tree = 5
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = "" --the value given is 1, as a damage multiplier, so don't bother showing it
		},
		messiah = { --messiah: kill an enemy to self-revive
			disabled = false, --not implemented; requires hooking to playermanager to get var ._messiah_charges
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
			display_format = ""
		},
		bloodthirst_basic = { --bloodthirst basic: stacking melee damage bonus per kill
			disabled = false, --not implemented; requires guessing coroutine playerbloodthirstbase
			show_timer = true,
			source = "skill",
			text_id = "menu_bloodthirst",
			icon_data = {
				source = "skill",
				skill_id = "bloodthirst",
				tree = 5
			},
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
			display_format = ""
		},
		bloodthirst_aced = { --bloodthirst aced: reload speed bonus on melee kill
			disabled = false,
			show_timer = true,
			source = "skill",
			text_id = "menu_bloodthirst",
			icon_data = {
				source = "skill",
				skill_id = "bloodthirst",
				tree = 5
			},
			modify_value_func = function(n)
				return n * 100
			end,
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = "%i%%"
		},
		counterstrike = { --counterstrike (counter melee/cloaker kick)
			disabled = false, --not implemented; requires upd_func to check playerstandard meleeing state
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
			display_format = ""
		},
		berserker_basic = { --berserker (melee damage bonus inverse to health ratio)
			disabled = false, --not implemented; requires upd_func
			source = "skill",
			text_id = "menu_wolverine_beta",
			icon_data = {
				source = "skill",
				skill_id = "wolverine",
				tree = 5
			},
			is_aced = false,
			is_basic = true,
			is_cooldown = false,
			display_format = ""
		},
		berserker_aced = { --berserker (ranged damage bonus inverse to health ratio)
			disabled = false, --not implemented; requires upd_func
			source = "skill",
			text_id = "menu_wolverine_beta",
			icon_data = {
				source = "skill",
				skill_id = "wolverine",
				tree = 5
			},
			is_aced = true,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
--perkdecks

	--crew chief
		marathon_man = { --marathon man (damage reduction in medium range of enemies)
			disabled = false, --not implemented
			source = "perk",
			text_id = "menu_deck1_1",
			icon_data = {
				source = "perk",
				tree = 1,
				card = 1
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
		hostage_situation = { --hostage situation (damage resistance per hostage)
			disabled = false, --not implemented
			source = "perk",
			text_id = "menu_deck1_5",
			icon_data = {
				source = "perk",
				tree = 1,
				card = 5
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
	--muscle
		meat_shield = { --meat shield (increased threat when close to allies)
			disabled = false, --not implemented
			source = "perk",
			text_id = "menu_deck2_3",
			icon_data = {
				source = "perk",
				tree = 2,
				card = 3
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
	--armorer
		reinforced_armor = { --reinforced armor (temporary invuln on armor break)
			disabled = false, --not implemented
			source = "perk",
			text_id = "menu_deck3_7",
			icon_data = {
				source = "perk",
				tree = 3,
				card = 7
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
		reinforced_armor_cooldown = { --(temp invuln cooldown)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--rogue
		elusive = { --elusive (decreased threat when close to allies)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--hitman
		tooth_and_claw = { --tooth and claw (guaranteed armor regen timer after break)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--burglar
		bag_of_tricks = { --bag of tricks/luck of the irish/dutch courage (reduced target chance from crouching still)
			disabled = false, --not implemented
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
			display_format = ""
		},
		breath_of_fresh_air = { --breath of fresh air (increased armor recovery rate when standing still)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--infiltrator
		overdog = { --overdog (damage resist when surrounded, stacking melee hit damage) (shared with sociopath)
			disabled = false, --not implemented
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
			display_format = ""
		},
		basic_close_combat = { --basic close combat
			disabled = false, --not implemented
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
			display_format = ""
		},
		life_leech = { --life leech (melee hit restores health cooldown)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--sociopath
		tension = { --tension (armor gate on kill cooldown)
			disabled = false, --not implemented
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
			display_format = ""
		},
		clean_hit = { --clean hit (health on melee kill cooldown)
			disabled = false, --not implemented
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
			display_format = ""
		},
		overdose = { --overdose (armor gate on medium range kill cooldown)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--gambler
		ammo_box_pickup_health = { --medical supplies (health on ammo box pickup)
			disabled = false,
			show_timer = true,
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
			display_format = ""
		},
		ammo_box_pickup_share = { --ammo give out (ammo box team share)
			disabled = false,
			show_timer = true,
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
			display_format = ""
		},
	--grinder
		histamine = { --histamine (health on damage stacks)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--yakuza
		koi_irezumi = { --koi irezumi (armor recovery rate inverse to health)
			disabled = false, --not implemented
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
			display_format = ""
		},
		hebi_irezumi = { --hebi irezumi (move speed inverse to health)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--ex-president
		point_break = { --point break (stored health per kill)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--maniac
		excitement = { --excitement (hysteria stacks)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--anarchist
		blitzkrieg_bop = { --blitzkrieg bop (armor regen timer)
			disabled = false, --not implemented
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
			display_format = ""
		},
		lust_for_life = { --lust for life (armor on damage cooldown)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--biker
		prospect = { --prospect (health/armor on any crew kill)
			disabled = false, --not implemented
			source = "perk",
			text_id = "menu_deck16_1",
			upd_func = function(t,dt,values,display_setting,buff_data)
				
			end,
			format_values_func = function(values,display_setting)
				return string.format("x%i",#values)
			end,
			icon_data = {
				source = "perk",
				tree = 16,
				card = 1
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
	--kingpin
		kingpin_injector = { --injector throwable duration/cooldown?
			disabled = false, --not implemented
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
			display_format = ""
		},
	--sicario
		sicario_smoke_bomb = { --smoke bomb (cooldown, in-screen effect)
			disabled = false, --not implemented
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
			display_format = ""
		},
		twitch = { --twitch (shot dodge cooldown)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--stoic
		virtue = { --virtue (hip flask) + cooldown
			disabled = false, --not implemented
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
			display_format = ""
		},
		delayed_damage = { --general delayed damage
			disabled = false, --not implemented
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
			display_format = ""
		},
		calm = { --calm (4s countdown free delayed damage negation)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--tag team
		gas_dispenser = { --gas dispenser tagged
			disabled = false, --not implemented
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
			display_format = ""
		},
	--hacker
		pocket_ecm = { --pocket ecm throwable
			disabled = false, --not implemented; requires tagteam playeraction
			source = "perk",
			text_id = "menu_deck21_1",
			icon_data = {
				source = "perk",
				tree = 21,
				card = 1
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = false,
			display_format = ""
		},
		kluge = { --kluge (dodge on kill while feedback active)
			disabled = false, --not implemented
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
			display_format = ""
		},
	--leech 
		leech = { --leech throwable, temp invuln on healthgate
			disabled = true, --not implemented
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
			display_format = ""
		},
		leech_cooldown = { --leech throwable, temp invuln on healthgate
			disabled = true, --not implemented
			source = "perk",
			text_id = "menu_deck22_1",
			icon_data = {
				source = "perk",
				tree = 22,
				card = 1
			},
			is_aced = false,
			is_basic = false,
			is_cooldown = true,
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

--*************************************************--
		--colorpicker/menu preview callbacks
--************************************************--

function KineticTrackerCore:GetColorPickerPalettes()
	return self.settings.palettes
end
function KineticTrackerCore:GetColorPickerDefaultPalettes()
	return self.default_palettes
end

function KineticTrackerCore:InitColorPicker()
	if _G.ColorPicker then 
		if not self._colorpicker then 
			local palettes
			local params = {
				palettes = self:GetColorPickerPalettes(),
				done_callback = callback(self,self,"callback_on_colorpicker_confirmed"),
				changed_callback = callback(self,self,"callback_on_colorpicker_selected")
			}
			ColorPicker:new("kinetictracker",params,callback(self,self,"callback_on_colorpicker_created"))
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


function KineticTrackerCore:CreateBuffPreview(buff_id)
	self:_CreateBuffPreview(self.tweak_data[buff_id])
end

function KineticTrackerCore:_CreateBuffPreview(buff_data)
	--todo
end

function KineticTrackerCore:RemoveAllBuffPreviews()
	--todo
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




KineticTrackerCore:InitBuffTweakData()