
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




-------------------------------------------------------------
--*********************    Core functionality    *********************--
-------------------------------------------------------------


function KineticTrackerCore:InitHolder()
	self:InitBuffTweakData()
	
	
	self._animator = QuickAnimate:new("kinetictracker_animator",{parent = KineticTrackerCore,updater_type = QuickAnimate.updater_types.HUDManager,paused = false})

	self._ws = self._ws or managers.gui_data:create_fullscreen_workspace()
	self._holder = KineticTrackerHolder:new(self)
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

function KineticTrackerCore:InitBuffTweakData(mode)
	self.buff_id_lookups = {
		property = {
			revive_damage_reduction = "combat_medic", --while reviving other player
			shock_and_awe = "lock_n_load" --reload mul
		},
		temporary_property = {
			revive_damage_reduction = "painkillers" --?
		},
		temporary_upgrade = {
			temporary = {
				revive_damage_reduction = "combat_medic", --on revive other player
				single_shot_fast_reload = "aggressive_reload"
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
			disabled = true,
			source = "general",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "skill",
				skill_id = "asgagadfgsdfgdf",
				tree = 1
			},
			display_format = ""
		},
		ecm_jammer = { --(ecm jammer timer)
			disabled = true,
			source = "skill",
			text_id = "menu_ecm_2x_beta",
			icon_data = {
				source = "skill",
				skill_id = "ecm_2x",
				tree = 4
			},
			display_format = ""
		},
		ecm_feedback = { --(ecm feedback timer) 
			disabled = true,
			source = "skill",
			text_id = "menu_ecm_booster_beta",
			icon_data = {
				source = "skill",
				skill_id = "ecm_booster",
				tree = 4
			},
			display_format = ""
		},
		dodge_chance = { --(general dodge chance)
			disabled = true,
			source = "skill",
			text_id = "menu_jail_diet_beta",
			icon_data = {
				source = "skill",
				skill_id = "jail_diet",
				tree = 4
			},
			display_format = ""
		},
		crit_chance = { --(general crit chance)
			disabled = true,
			source = "skill",
			text_id = "menu_backstab_beta",
			icon_data = {
				source = "skill",
				skill_id = "backstab",
				tree = 4
			},
			display_format = ""
		},
		damage_resistance = { --general damage resist
			disabled = true,
			source = "skill",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "skill",
				skill_id = "asgagadfgsdfgdf",
				tree = 1
			},
			display_format = ""
		},
		health_regeneration = { --general health regen
			disabled = true,
			source = "general",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "none",
				tree = 1,
				card = 1
			},
			display_format = ""
		},
	
	
	
		combat_medic = { --combat medic (damage reduction during/after res)
			disabled = false,
			source = "skill",
			text_id = "menu_combat_medic_beta",
			icon_data = {
				source = "skill",
				skill_id = "combat_medic",
				tree = 1
			},
			display_format = ""
		},
		quick_fix = { --quick fix (damage reduction after using health kit)
			disabled = true,
			source = "skill",
			text_id = "menu_tea_time_beta",
			icon_data = {
				source = "skill",
				skill_id = "tea_time",
				tree = 1
			},
			display_format = ""
		},
		painkillers = { --painkillers (damage reduction for teammates you revive)
			disabled = true,
			source = "skill",
			text_id = "menu_fast_learner_beta",
			icon_data = {
				source = "skill",
				skill_id = "fast_learner",
				tree = 1
			},
			display_format = ""
		},
		inspire = { --inspire basic (move speed + reload speed bonus for teammates you shout at)
			disabled = true,
			source = "skill",
			text_id = "menu_inspire_beta",
			icon_data = {
				source = "skill",
				skill_id = "inspire",
				tree = 1
			},
			display_format = ""
		},
		forced_friendship = { --forced friendship (nearby civs give damage absorption)
			disabled = true,
			source = "skill",
			text_id = "menu_triathlete_beta",
			icon_data = {
				source = "skill",
				skill_id = "triathlete",
				tree = 1
			},
			display_format = ""
		},
		partners_in_crime = { --partners in crime (extra max health while you have a convert)
			disabled = true,
			source = "skill",
			text_id = "menu_control_freak_beta",
			icon_data = {
				source = "skill",
				skill_id = "control_freak",
				tree = 1
			},
			display_format = ""
		},
		stockholm_syndrome = { --stockholm syndrome (hostages autotrade for your return)
			disabled = true,
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
			disabled = true,
			source = "skill",
			text_id = "menu_stable_shot_beta",
			icon_data = {
				source = "skill",
				skill_id = "stable_shot",
				tree = 1
			},
			display_format = ""
		},
		rifleman = { --rifleman (bonus accuracy while moving)
			disabled = true,
			source = "skill",
			text_id = "menu_rifleman_beta",
			icon_data = {
				source = "skill",
				skill_id = "rifleman",
				tree = 1
			},
			display_format = ""
		},
		ammo_efficiency = { --ammo efficiency (consecutive headshots refund ammo)
			disabled = true,
			source = "skill",
			text_id = "menu_single_shot_ammo_return_beta",
			icon_data = {
				source = "skill",
				skill_id = "spotter_teamwork",
				tree = 1
			},
			display_format = ""
		},
		aggressive_reload = { --aggressive reload aced (killing headshot reduces reload speed)
			disabled = true,
			source = "skill",
			text_id = "menu_speedy_reload_beta",
			icon_data = {
				source = "skill",
				skill_id = "speedy_reload",
				tree = 1
			},
			display_format = ""
		},
		
--enforcer
		underdog = { --underdog (basic: damage bonus when targeted by enemies; aced: damage resist when targeted by enemies)
			disabled = true,
			source = "skill",
			text_id = "menu_underdog_beta",
			icon_data = {
				source = "skill",
				skill_id = "underdog",
				tree = 2
			},
			display_format = ""
		},
		far_away = { --far away basic (accuracy bonus while ads with shotguns)
			disabled = true,
			source = "skill",
			text_id = "menu_far_away_beta",
			icon_data = {
				source = "skill",
				skill_id = "far_away",
				tree = 2
			},
			display_format = ""
		},
		close_by = { --close by (rof increase while hipfire with shotguns)
			disabled = true,
			source = "skill",
			text_id = "menu_close_by_beta",
			icon_data = {
				source = "skill",
				skill_id = "close_by",
				tree = 2
			},
			display_format = ""
		},
		overkill = { --overkill (basic: damage bonus for saw/shotgun on kill with saw/shotgun; aced: damage bonus for all ranged weapons on kill with saw/shotgun)
			disabled = true,
			source = "skill",
			text_id = "menu_overkill_beta",
			icon_data = {
				source = "skill",
				skill_id = "overkill",
				tree = 2
			},
			display_format = ""
		},
		die_hard = { --die hard basic (damage resist while interacting)
			disabled = true,
			source = "skill",
			text_id = "menu_show_of_force_beta",
			icon_data = {
				source = "skill",
				skill_id = "show_of_force",
				tree = 2
			},
			display_format = ""
		},
		bullseye = { --bullseye (armorgate) cooldown
			disabled = true,
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
			disabled = true,
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
			disabled = true,
			source = "skill",
			text_id = "menu_bandoliers_beta",
			icon_data = {
				source = "skill",
				skill_id = "bandoliers",
				tree = 2
			},
			display_format = ""
		},

--technician
		hardware_expert = { --hardware expert (drill upgrades)
			disabled = true,
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
			disabled = true,
			source = "skill",
			text_id = "menu_drill_expert_beta",
			icon_data = {
				source = "skill",
				skill_id = "drill_expert",
				tree = 3
			},
			display_format = ""
		},
		kick_starter = { --kickstarter (drill upgrades)
			disabled = true,
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
			disabled = true,
			source = "skill",
			text_id = "menu_fire_control_beta",
			icon_data = {
				source = "skill",
				skill_id = "fire_control",
				tree = 3
			},
			display_format = ""
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
			display_format = ""
		},
		
	--ghost
		chameleon = { --sixth sense basic (mark nearby enemies)
			disabled = true,
			source = "skill",
			text_id = "menu_chameleon_beta",
			icon_data = {
				source = "skill",
				skill_id = "chameleon",
				tree = 4
			},
			display_format = ""
		},
		second_chances = { --nimble basic (camera loop)
			disabled = true,
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
			source = "skill",
			text_id = "menu_dire_need_beta",
			icon_data = {
				source = "skill",
				skill_id = "dire_need",
				tree = 4
			},
			display_format = ""
		},
		second_wind = { --second wind (speed bonus on armor break)
			disabled = true,
			source = "skill",
			text_id = "menu_scavenger_beta",
			icon_data = {
				source = "skill",
				skill_id = "scavenger",
				tree = 4
			},
			display_format = ""
		},
		unseen_strike = { --unseen strike (crit chance when not taking damage)
			disabled = true,
			source = "skill",
			text_id = "menu_unseen_strike_beta",
			icon_data = {
				source = "skill",
				skill_id = "unseen_strike",
				tree = 4
			},
			display_format = ""
		},
	
	--fugitive
		desperado = { --desperado (stacking accuracy bonus per hit for pistols)
			disabled = true,
			source = "skill",
			text_id = "menu_expert_handling",
			icon_data = {
				source = "skill",
				skill_id = "expert_handling",
				tree = 5
			},
			display_format = ""
		},
		trigger_happy = { --trigger happy (stacking damage bonus per hit for pistols)
			disabled = true,
			source = "skill",
			text_id = "menu_trigger_happy_beta",
			icon_data = {
				source = "skill",
				skill_id = "trigger_happy",
				tree = 5
			},
			display_format = ""
		},
		running_from_death = { --running_from_death (basic: reload/swap speed bonus after being revived; aced: move speed bonus after being revived)
			disabled = true,
			source = "skill",
			text_id = "menu_running_from_death_beta",
			icon_data = {
				source = "skill",
				skill_id = "running_from_death",
				tree = 5
			},
			display_format = ""
		},
		up_you_go = { --up you go basic: damage resistance after being revived
			disabled = true,
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
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 1,
				card = 1
			},
			display_format = ""
		},
		hostage_situation = { --hostage situation (damage resistance per hostage)
			disabled = true,
			source = "skill",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 1,
				card = 5
			},
			display_format = ""
		},
	--muscle
		meat_shield = { --meat shield (increased threat when close to allies)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 2,
				card = 3
			},
			display_format = ""
		},
	--armorer
		reinforced_armor = { --reinforced armor (temporary invuln on armor break) + cooldown
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 3,
				card = 7
			},
			display_format = ""
		},
	--rogue
		elusive = { --elusive (decreased threat when close to allies)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 4,
				card = 3
			},
			display_format = ""
		},
	--hitman
		tooth_and_claw = { --tooth and claw (guaranteed armor regen timer after break)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 5,
				card = 9
			},
			display_format = ""
		},
	--burglar
		bag_of_tricks = { --bag of tricks/luck of the irish/dutch courage (reduced target chance from crouching still)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 7,
				card = 3
			},
			display_format = ""
		},
		breath_of_fresh_air = { --breath of fresh air (increased armor recovery rate when standing still)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 7,
				card = 9
			},
			display_format = ""
		},
	--infiltrator
		overdog = { --overdog (damage resist when surrounded, stacking melee hit damage) (shared with sociopath)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 8,
				card = 1
			},
			display_format = ""
		},
		basic_close_combat = { --basic close combat
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 8,
				card = 3
			},
			display_format = ""
		},
		life_leech = { --life leech (melee hit restores health)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 8,
				card = 9
			},
			display_format = ""
		},
	--sociopath
		tension = { --tension (armor gate on kill)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 9,
				card = 3,
				
			},
			display_format = ""
		},
		clean_hit = { --clean hit (health on melee kill)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 9,
				card = 5
			},
			display_format = ""
		},
		overdose = { --overdose (armor gate on medium range kill)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 9,
				card = 7,
			},
			display_format = ""
		},
	--gambler
		ammo_box_pickup_health = { --medical supplies (health on ammo box pickup)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 10,
				card = 7,
			},
			display_format = ""
		},
		ammo_box_pickup_share = { --ammo give out (ammo box team share)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 10,
				card = 7,
			},
			display_format = ""
		},
	--grinder
		histamine = { --histamine (health on damage)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 11,
				card = 1,
			},
			display_format = ""
		},
	--yakuza
		koi_irezumi = { --koi irezumi (armor recovery rate inverse to health)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 12,
				card = 1,
			},
			display_format = ""
		},
		hebi_irezumi = { --hebi irezumi (move speed inverse to health)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 12,
				card = 3,
			},
			display_format = ""
		},
	--ex-president
		point_break = { --point break (stored health per kill)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 13,
				card = 1,
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
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 15,
				card = 1,
			},
			display_format = ""
		},
		lust_for_life = { --lust for life (armor on damage)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 15,
				card = 7,
			},
			display_format = ""
		},
	--biker
		prospect = { --prospect (health/armor on any crew kill)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 16,
				card = 1,
			},
			display_format = ""
		},
	--kingpin
		kingpin_injector = { --injector throwable
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 17,
				card = 1,
			},
			display_format = ""
		},
	--sicario
		sicario_smoke_bomb = { --smoke bomb (cooldown, in-screen effect)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 18,
				card = 1,
			},
			display_format = ""
		},
		twitch = { --twitch (shot dodge cooldown)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 18,
				card = 3,
			},
			display_format = ""
		},
	--stoic
		virtue = { --virtue (hip flask; general delayed damage) + cooldown
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 19,
				card = 1,
			},
			display_format = ""
		},
		calm = { --calm (4s free delayed damage negation)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 19,
				card = 5,
			},
			display_format = ""
		},
	--tag team
		gas_dispenser = { --gas dispenser tagged
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 20,
				card = 1,
			},
			display_format = ""
		},
	--hacker
		pocket_ecm = { --pocket ecm throwable
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 21,
				card = 1,
			},
			display_format = ""
		},
		kluge = { --kluge (dodge on kill while feedback active)
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 21,
				card = 1,
			},
			display_format = ""
		},
	--leech 
		leech = { --leech throwable, temp invuln on healthgate
			disabled = true,
			source = "perk",
			text_id = "asgagadfgsdfgdf",
			icon_data = {
				source = "perk",
				skill_id = "asgagadfgsdfgdf",
				tree = 22,
				card = 1,
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
