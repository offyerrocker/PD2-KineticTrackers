KineticTrackerItem = KineticTrackerItem or class()


function KineticTrackerItem:init(params)
	local id = params.id
	local icon_data = params.icon_data
	local margin = 4
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
		name = id
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
	
	local text_1,text_2
	if mode == "compact" then
		
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
		local icon_text = panel:text({
			name = "icon_text",
			text = params.secondary_label,
			font = font_2,
			font_size = font_size_2,
			align = "center",
			vertical = "top",
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
			align = "left",
			vertical = "top",
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
	self._text_bg_rect = text_bg_rect
		
	local bottom_text_params = params.bottom_text_params
	self._bottom_text = bottom_text
end

function KineticTrackerItem:SetPrimaryText(text)
	self._primary_text:set_text(text)
	
	local _x,_y,_w,_h = self._primary_text:text_rect()
	self._text_bg_rect:set_position(_x - margin,_y - margin)
	self._text_bg_rect:set_size(_w + margin + margin,_h + margin + margin)
end

function KineticTrackerItem:SetSecondaryText(text)
	self._secondary_text:set_text(text)
end

function KineticTrackerItem:Remove()
	self._panel:parent():remove(self._panel)
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







