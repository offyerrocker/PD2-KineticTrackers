KineticTrackerItem = KineticTrackerItem or class()

--given a guiobject's nonzero dimensions w1/h1, and maximum constrained nonzero dimensions w2/h2,
--calculates the largest possible dimensions within w2/h2 that maintain the aspect ratio of w1/h1
--optionally, allow growing up to w2/h2 if both dimensions are smaller(incomplete)
function KineticTrackerItem.ConstrainedScaleDown(w1,h1,w2,h2,can_grow)
	if w1 <= w2 and h1 <= h2 then 
--		if can_grow then 
			
--			return KineticTrackerItem.ConstrainedScaleDown(w2,h2,w1,h1,false)
--		else
			return w1,h1
--		end
	else
		if w1 > h1 then 
			return w2,h2 * w1/h1
		else --h1 >= w1
			return w2 * h1/w1,h2
		end
	end
end


KineticTrackerItem._TEXT_BG_MARGIN = 4


function KineticTrackerItem:init(params)
	local id = params.id
	local icon_data = params.icon_data
	local margin = KineticTrackerItem._TEXT_BG_MARGIN
	local mode = "normal"
	
	local primary_color,secondary_color
	if true then 
		primary_color = params.color
		secondary_color = Color.white
	else
		primary_color = Color.white
		secondary_color = params.color
	end
	
	local font_1 = tweak_data.hud.medium_font --"fonts/font_medium_mf"
	local font_size_1 = 16
	local font_2 = tweak_data.hud.medium_font_noshadow --"fonts/font_medium_shadow_mf"
	local font_size_2 = 16
	
	local texture,texture_rect
	if icon_data.source == "skill" then 
		texture = "guis/textures/pd2/skilltree_2/icons_atlas_2"
		local skill_icon_size = 80
		local x,y = unpack(tweak_data.skilltree.skills[icon_data.skill_id].icon_xy)
		texture_rect = {x * skill_icon_size,y * skill_icon_size,skill_icon_size,skill_icon_size}
	elseif icon_data.source == "perk" then
		texture,texture_rect = KineticTrackerCore.get_specialization_icon_data_by_tier(icon_data.tree,icon_data.card,false)
	elseif icon_data.source == "hud_icon" then 
		texture,texture_rect = tweak_data.hud_icons:get_icon_data(icon_data.skill_id)
	elseif icon_data.texture then 
		texture,texture_rect = icon_data.texture,icon_data.texture_rect
	end
	
	
	local parent_panel = params.parent_panel
	local panel = parent_panel:panel({
		name = id,
		w = 256,
		h = 32
	})
	local debug_rect = panel:rect({
		name = "debug",
		layer = -100,
		alpha = 0.2,
		color = Color(math.random(),math.random(),1)
	})
	
	self._panel = panel
	local icon = panel:bitmap({
		name = "icon",
		x = 0,
		y = 0,
		w = nil,
		h = nil,
		texture = texture,
		texture_rect = texture_rect,
		color = primary_color,
		blend_mode = "normal",
		alpha = 1,
		visible = true,
		layer = 1
	})
	
	local max_w,max_h = 24,24
	local icon_w,icon_h = icon:size()
	icon:set_size(KineticTrackerItem.ConstrainedScaleDown(icon_w,icon_h,max_w,max_h,false))
	icon:set_y((panel:h() - icon:h()) / 2)
	local text_1,text_2,buff_name
	local buff_label = params.buff_label

	if mode == "compact" then
		local buff_name_text = panel:text({
			name = "buff_name_text",
			text = buff_label,
			font = font_1,
			font_size = font_size_1,
			align = "left",
			vertical = "top",
			color = secondary_color,
			blend_mode = "normal",
			alpha = 1,	
			visible = true,
			layer = 2
		})
		buff_name = buff_name_text
		
		local top_text = panel:text({
			name = "top_text",
			text = params.primary_label,
			font = font_1,
			font_size = font_size_1,
			align = "center",
			vertical = "top",
			color = secondary_color,
			blend_mode = "normal",
			alpha = 1,
			visible = true,
			layer = 2
		})
		text_1 = top_text
		
		local _x,_y,_w,_h = top_text:text_rect()
		
		local bg = panel:rect({
			name = "bg",
			x = _x - margin,
			y = _y - margin,
			w = _w + margin + margin,
			h = _h + margin + margin,
			color = Color.black,
			blend_mode = "normal",
			alpha = 0.75,
			visible = true,
			layer = 1
		})
		text_bg_rect = bg
		
		local bottom_text = panel:text({
			name = "bottom_text",
			text = params.secondary_label,
			font = font_2,
			font_size = font_size_2,
			align = "center",
			vertical = "bottom",
			color = secondary_color,
			blend_mode = "normal",
			alpha = 1,
			visible = true,
			layer = 2
		})
		text_2 = bottom_text
	else
	--destiny style
		local buff_name_text = panel:text({
			name = "buff_name_text",
			text = buff_label,
			font = font_1,
			font_size = font_size_1,
			x = icon:right() + 2,
			align = "left",
			vertical = "center",
			color = secondary_color,
			blend_mode = "normal",
			alpha = 1,
			visible = true,
			layer = 2
		})
		buff_name = buff_name_text
		
		local icon_text = panel:text({
			name = "icon_text",
			text = params.secondary_label,
			font = font_2,
			font_size = font_size_2,
			align = "center",
			vertical = "center",
			color = secondary_color,
			blend_mode = "normal",
			alpha = 1,
			visible = true,
			layer = 2
		})
		text_1 = icon_text
		
		local _x,_y,_w,_h = icon_text:text_rect()
		
		local bg = panel:rect({
			name = "bg",
			x = _x - margin,
			y = _y - margin,
			w = _w + margin + margin,
			h = _h + margin + margin,
			color = Color.black,
			blend_mode = "normal",
			alpha = 0.75,
			visible = true,
			layer = 1
		})
		text_bg_rect = bg
		
		local main_text = panel:text({
			name = "main_text",
			text = params.primary_label,
			font = font_1,
			font_size = font_size_1,
			align = "right",
			vertical = "center",
			color = secondary_color,
			blend_mode = "normal",
			alpha = 1,
			visible = true,
			layer = 2
		})
		text_2 = main_text
	end
	self._primary_text = text_1
	self._secondary_text = text_2
	self._name_text = buff_name
	
	self._text_bg_rect = text_bg_rect
		
	local bottom_text_params = params.bottom_text_params
	self._bottom_text = bottom_text
end

function KineticTrackerItem:SetPrimaryText(text)
	self._primary_text:set_text(text)
	local margin = self._TEXT_BG_MARGIN
	local _x,_y,_w,_h = self._primary_text:text_rect()
	self._text_bg_rect:set_size(_w + margin + margin,_h + margin + margin)
	self._text_bg_rect:set_world_position(_x - margin,_y - margin)
end

function KineticTrackerItem:SetSecondaryText(text)
	self._secondary_text:set_text(text)
end

function KineticTrackerItem:Remove()
	self._panel:parent():remove(self._panel)
end

function KineticTrackerItem:SetVisible(state)
	self._panel:set_visible(state)
end

do return end


KineticTrackerDisplay = KineticTrackerDisplay or class()

function KineticTrackerDisplay:init(params)
	self._ws = self._ws or managers.gui_data:create_fullscreen_workspace()
	self._panel = self._ws:panel():panel({
		name = "tracker_display_panel"
	})
end

function KineticTrackerDisplay:AddBuff(params,priority)
	local item = KineticTrackerItem:new(params)
end







