-- ui element for each item
local KineticTrackerItemBase = blt_class()

KineticTrackerItemBase.STYLE = {
	panel_width = 256,
	panel_height = 32,
	icon_max_width = 24,
	icon_max_height = 24,
	icon_halign = "left",
	icon_valign = "center",
	icon_blend_mode = "normal",
	name_label_halign = "left",
	name_label_valign = "center",
	name_label_font = tweak_data.hud.medium_font,
	name_label_font_size = 16,
	name_label_blend_mode = "normal",
	name_label_alpha = 1,
	name_label_visible = true,
	name_label_align_to_icon = true,
	primary_label_halign = "left",
	primary_label_valign = "center",
	primary_label_font = tweak_data.hud.medium_font,
	primary_label_font_size = 16,
	primary_label_align_to_name = true,
	primary_label_blend_mode = "normal",
	primary_label_alpha = 1,
	secondary_label_halign = "left",
	secondary_label_valign = "center",
	secondary_label_font = tweak_data.hud.medium_font_noshadow,
	secondary_label_font_size = 16,
	secondary_label_blend_mode = "normal",
	secondary_label_align_to_primary = true,
	secondary_label_alpha = 1,
	reversed_color_scheme = false,
	primary_bg_blend_mode = "normal",
	primary_bg_alpha = 0.66,
	primary_bg_visible = false,
	
	margin_small = 2,
	margin_medium = 4
}

KineticTrackerItemBase.COLOR_PAYDAY_BLUE = Color(63/255,162/255,248/255)

function KineticTrackerItemBase:init(id,params,parent_panel)
	self._animthread_fade = nil
	self._animthread_sort = nil
	
	self:recreate_panel(id,params,parent_panel)
end

-- todo delete prev panel; nts id should be concatenation of id and secondary identifier (peer_id) if any
function KineticTrackerItemBase:recreate_panel(id,params,parent_panel)
	local texture_data = params.texture_data
	local style = self.STYLE
	local icon_color = params.icon_color or Color.white
	local name_color = params.name_color or Color.white
	local primary_color = params.primary_color or self.COLOR_PAYDAY_BLUE
	local secondary_color = params.secondary_color or self.COLOR_PAYDAY_BLUE
	local texture,texture_rect
	
	local name_text = params.name_text
	local primary_text = params.primary_text
	local secondary_text = params.secondary_text
	
	local panel = parent_panel:panel({
		name = id,
		w = style.panel_width,
		h = style.panel_height,
		visible = true
	})
	self._panel = panel
	local debug_rect = panel:rect({
		name = "debug",
		layer = -100,
		alpha = 0.2,
		color = Color(math.random(),math.random(),1)
	})
	local icon_frame = panel:panel({
		name = "icon_frame",
		w = style.icon_max_width,
		h = style.icon_max_height,
		layer = nil
	})
	icon_frame:set_center_y(panel:h()/2)
	self._icon_frame = icon_frame
	local icon = icon_frame:bitmap({
		name = "icon",
		x = 0,
		y = 0,
		w = style.icon_max_width,
		h = style.icon_max_height,
		valign = "grow",
		halign = "grow",
		texture = texture_data.texture,
		texture_rect = texture_data.texture_rect,
		color = icon_color,
		blend_mode = style.icon_blend_mode,
		alpha = 1,
		visible = true,
		layer = 1
	})
	self._icon = icon
	
	-- should be used for buff name
	local name_label = panel:text({
		name = "name_label",
		text = name_text,
		font = style.name_label_font,
		font_size = style.name_label_font_size,
		x = icon_frame:right() + style.margin_small,
		align = style.name_label_halign,
		vertical = style.name_label_valign,
		valign = "grow",
		halign = "grow",
		color = name_color,
		blend_mode = style.name_label_blend_mode,
		alpha = style.name_label_alpha,
		layer = 2
	})
	self._name_label = name_label
	
	-- should be used for buff stacks/value (if any)
	local primary_label = panel:text({
		name = "primary_label",
		text = primary_text,
		font = style.primary_label_font,
		font_size = style.primary_label_font_size,
		x = 0,
		align = style.primary_label_halign,
		vertical = style.primary_label_valign,
		valign = "grow",
		halign = "grow",
		color = primary_color,
		blend_mode = style.primary_label_blend_mode,
		alpha = style.primary_label_alpha,
		layer = 2
	})
	self._primary_label = primary_label
	
	-- should be used for buff timer (if any)
	local secondary_label = panel:text({
		name = "secondary_label",
		text = secondary_text,
		font = style.secondary_label_font,
		font_size = style.secondary_label_font_size,
		x = icon_frame:right() + style.margin_small,
		align = style.secondary_label_halign,
		vertical = style.secondary_label_valign,
		valign = "grow",
		halign = "grow",
		color = secondary_color,
		blend_mode = style.secondary_label_blend_mode,
		alpha = style.secondary_label_alpha,
		layer = 2
	})
	self._secondary_label = secondary_label
	
	--local _x,_y,_w,_h = text_1:text_rect()
	
	--[[
	local text_bg_rect = panel:rect({
		name = "text_bg_rect",
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
	--]]
	
	self:align_labels()
	
end



function KineticTrackerItemBase:set_icon_color(color)
	self._icon:set_color(color)
end
function KineticTrackerItemBase:set_name_text(s,skip_align)
	self._name_label:set_text(s)
	if not skip_align then
		self:align_labels()
	end
end
function KineticTrackerItemBase:set_primary_text(s,skip_align)
	self._primary_label:set_text(s)
	if not skip_align then
		self:align_labels()
	end
end
function KineticTrackerItemBase:set_secondary_text(s,skip_align)
	self._secondary_label:set_text(s)
	if not skip_align then
		self:align_labels()
	end
end

function KineticTrackerItemBase:align_labels()
	local style = self.STYLE
	if style.primary_label_align_to_name then
		local x1,y1,w1,h1 = self._name_label:text_rect()
		self._primary_label:set_x(self._name_label:x() + w1 + style.margin_medium)
	end
	
	if style.secondary_label_align_to_primary then
		local x2,y2,w2,h2 = self._primary_label:text_rect()
		self._secondary_label:set_x(self._primary_label:x() + w2 + style.margin_medium)
	end
end

function KineticTrackerItemBase:set_primary_text_color(color)
	self._primary_label:set_color(color)
end
function KineticTrackerItemBase:set_secondary_text_color(color)
	self._secondary_label:set_color(color)
end

-- todo anim flash func

-- used for visual indication of timer progress
function KineticTrackerItemBase:set_progress(n) -- float [0-1] progress of timer, in total

end

function KineticTrackerItemBase:destroy()
	if alive(self._panel) then
		self._panel:parent():remove(self._panel)
	end
end


do return KineticTrackerItemBase end















--utils

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


KineticTrackerItem._TEXT_BG_MARGIN = 2

KineticTrackerItem.STYLES = {
	{
		panel_width = 256,
		panel_height = 32,
		icon_max_width = 24,
		icon_max_height = 24,
		icon_halign = "left",
		icon_valign = "center",
		icon_blend_mode = "normal",
		buff_label_halign = "left",
		buff_label_valign = "center",
		buff_label_font = tweak_data.hud.medium_font,
		buff_label_font_size = 16,
		buff_label_blend_mode = "normal",
		buff_label_alpha = 1,
		buff_label_visible = true,
		buff_label_align_to_icon = true,
		primary_label_halign = "left",
		primary_label_valign = "center",
		primary_label_font = tweak_data.hud.medium_font,
		primary_label_font_size = 16,
		primary_label_align_to_name = true,
		primary_label_blend_mode = "normal",
		primary_label_alpha = 1,
		secondary_label_halign = "left",
		secondary_label_valign = "center",
		secondary_label_font = tweak_data.hud.medium_font_noshadow,
		secondary_label_font_size = 16,
		secondary_label_blend_mode = "normal",
		secondary_label_align_to_primary = true,
		reversed_color_scheme = false,
		primary_bg_blend_mode = "normal",
		primary_bg_alpha = 0.66,
		primary_bg_visible = false
	},
	{
		panel_width = 48,
		panel_height = 64,
		icon_max_width = 32,
		icon_max_height = 32,
		icon_halign = "center",
		icon_valign = "center",
		icon_blend_mode = "normal",
		buff_label_halign = "left",
		buff_label_valign = "center",
		buff_label_font = tweak_data.hud.medium_font,
		buff_label_font_size = 16,
		buff_label_blend_mode = "normal",
		buff_label_visible = false,
		buff_label_align_to_icon = false,
		primary_label_halign = "right",
		primary_label_valign = "top",
		primary_label_font = tweak_data.hud.medium_font,
		primary_label_font_size = 16,
		primary_label_align_to_name = false,
		primary_label_blend_mode = "normal",
		primary_label_alpha = 1,
		secondary_label_halign = "center",
		secondary_label_valign = "bottom",
		secondary_label_font = tweak_data.hud.medium_font_noshadow,
		secondary_label_font_size = 16,
		secondary_label_blend_mode = "normal",
		secondary_label_alpha = 1,
		secondary_label_align_to_primary = false,
		reversed_color_scheme = false,
		primary_bg_blend_mode = "normal",
		primary_bg_alpha = 0.66,
		primary_bg_visible = true
	}
}

--base methods
function KineticTrackerItem:init(params)
	local id = params.id
	local icon_data = params.icon_data
	local buff_label_string = params.buff_label_string
	local primary_label_string = params.primary_label_string
	local secondary_label_string = params.secondary_label_string
	
	local style_index = params.style_index
	self._style = style_index
	local style_data = self.STYLES[style_index]
	
	
	local primary_color,secondary_color
	if style_data.reversed_color_scheme then 
		primary_color = params.color
		secondary_color = Color.white
	else
		primary_color = Color.white
		secondary_color = params.color
	end
	
	local panel_width = style_data.panel_width
	local panel_height = style_data.panel_height
	self._panel_width = panel_width
	self._panel_height = panel_height
	
	local buff_label_font = style_data.buff_label_font
	local buff_label_font_size = style_data.buff_label_font_size
	local buff_label_halign = style_data.buff_label_halign
	local buff_label_valign = style_data.buff_label_valign
	local buff_label_blend_mode = style_data.buff_label_blend_mode
	local buff_label_visible = style_data.buff_label_visible
	local buff_label_alpha = style_data.buff_label_alpha
	local buff_label_align_to_icon = style_data.buff_label_align_to_icon
	
	local primary_label_font = style_data.primary_label_font
	local primary_label_font_size = style_data.primary_label_font_size
	local primary_label_halign = style_data.primary_label_halign
	local primary_label_valign = style_data.primary_label_valign
	local primary_label_blend_mode = style_data.primary_label_blend_mode
	local primary_label_alpha = style_data.primary_label_alpha
	local primary_label_align_to_name = style_data.primary_label_align_to_name
	
	local secondary_label_halign = style_data.secondary_label_halign
	local secondary_label_valign = style_data.secondary_label_valign
	local secondary_label_font_size = style_data.secondary_label_font_size
	local secondary_label_font = style_data.secondary_label_font
	local secondary_label_blend_mode = style_data.secondary_label_blend_mode
	local secondary_label_alpha = style_data.secondary_label_alpha
	local secondary_label_align_to_primary = style_data.secondary_label_align_to_primary
	
	local icon_max_width = style_data.icon_max_width
	local icon_max_height = style_data.icon_max_height
	local icon_blend_mode = style_data.icon_blend_mode
	local icon_halign = style_data.icon_halign
	local icon_valign = style_data.icon_valign
	
	local primary_bg_alpha = style_data.primary_bg_alpha
	local primary_bg_visible = style_data.primary_bg_visible
	local primary_bg_blend_mode = style_data.primary_bg_blend_mode
	
	local margin = KineticTrackerItem._TEXT_BG_MARGIN
	
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
		w = panel_width,
		h = panel_height,
		visible = false
	})
	local debug_rect = panel:rect({
		name = "debug",
		layer = -100,
		alpha = 0.2,
		visible = true,
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
		blend_mode = icon_blend_mode,
		alpha = 1,
		visible = true,
		layer = 0
	})
	
	local icon_w,icon_h = icon:size()
	icon_w,icon_h = KineticTrackerItem.ConstrainedScaleDown(icon_w,icon_h,icon_max_width,icon_max_height,false)
	icon:set_size(icon_w,icon_h)
	
	if icon_valign == "center" then 
		icon:set_y((panel_height - icon_h) / 2)
	elseif icon_valign == "right" then 
		icon:set_right(panel:right())
	end
	if icon_halign == "center" then 
		icon:set_x((panel_width - icon_w) / 2)
	elseif icon_halign == "bottom" then 
		icon:set_bottom(panel:bottom())
	end

	local buff_label = panel:text({
		name = "buff_label",
		text = buff_label_string,
		font = buff_label_font,
		font_size = buff_label_font_size,
		align = buff_label_halign,
		vertical = buff_label_valign,
		color = secondary_color,
		blend_mode = buff_label_blend_mode,
		alpha = buff_label_alpha,
		visible = buff_label_visible,
		layer = 2
	})
	if buff_label_align_to_icon then 
		buff_label:set_x(icon:right() + margin)
	end
	
	
	local primary_label = panel:text({
		name = "primary_label",
		text = primary_label_string,
		font = primary_label_font,
		font_size = primary_label_font_size,
		align = primary_label_halign,
		vertical = primary_label_valign,
		color = secondary_color,
		blend_mode = primary_label_blend_mode,
		alpha = 1,
		visible = false,
		layer = 4
	})
	if primary_label_align_to_name then 
		local b_x,b_y,b_w,b_h = buff_label:text_rect()
		primary_label:set_world_x(b_x + b_w + margin)
	end
	primary_label:show()
	
	local _x,_y,_w,_h = primary_label:text_rect()
	
	local primary_bg = panel:rect({
		name = "primary_bg",
		x = _x - margin,
		y = _y - margin,
		w = _w + margin + margin,
		h = _h + margin + margin,
		color = Color.black,
		blend_mode = primary_bg_blend_mode,
		alpha = primary_bg_alpha,
		visible = primary_bg_visible,
		layer = 1
	})
	if _w > 0 then 
	else
		primary_bg:set_w(0)
	end
	
	
	local secondary_label = panel:text({
		name = "secondary_label",
		text = secondary_label_string,
		font = secondary_label_font,
		font_size = secondary_label_font_size,
		align = secondary_label_halign,
		vertical = secondary_label_valign,
		color = secondary_color,
		blend_mode = secondary_label_blend_mode,
		alpha = 1,
		visible = false,
		layer = 3
	})
	if secondary_label_align_to_primary then 
		secondary_label:set_world_x(_x + _w + margin)
	end
	secondary_label:show()
	
	self._primary_text = primary_label
	self._secondary_text = secondary_label
	self._name_text = buff_label
	
	self._text_bg_rect = primary_bg
end

function KineticTrackerItem:SetPrimaryText(text)
	if alive(self._primary_text) then 
		self._primary_text:set_text(text)
		
		if alive(self._text_bg_rect) then 
			local _x,_y,_w,_h = self._primary_text:text_rect()
			local margin = self._TEXT_BG_MARGIN
			if _w > 0 then 
				self._text_bg_rect:set_size(_w + margin + margin,_h + margin + margin)
				self._text_bg_rect:set_world_position(_x - margin,_y - margin)
			else
				self._text_bg_rect:set_w(0)
			end
		end
	end
end

function KineticTrackerItem:SetSecondaryText(text)
	if alive(self._secondary_text) then 
		self._secondary_text:set_text(text)
	end
end

function KineticTrackerItem:SetVisible(state)
	if alive(self._panel) then 
		self._panel:set_visible(state)
	end
end

function KineticTrackerItem:GetHeight()
	return self._panel_height
end

function KineticTrackerItem:GetWidth()
	return self._panel_width
end

function KineticTrackerItem:Remove()
	if alive(self._panel) then 
		self._panel:parent():remove(self._panel)
	end
end



do return end
--yeah so using these softlock on the loading screen, not sure if i made an infinite loop or what

--destiny style variant (icon, full buff name, buff value, buff timer)

KineticTrackerItemDestiny = KineticTrackerItemDestiny or class(KineticTrackerItem)

function KineticTrackerItemDestiny:init(params,...)
	local id = params.id
	local icon_data = params.icon_data
	local margin = KineticTrackerItem._TEXT_BG_MARGIN
	
	local primary_color,secondary_color
	if true then 
		primary_color = params.color
		secondary_color = Color.white
	else
		primary_color = Color.white
		secondary_color = params.color
	end
	local buff_label = params.buff_label
	
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
		h = 32,
		visible = false
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
	
	local text_1 = panel:text({
		name = "text_1",
		text = params.secondary_label_string,
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
	
	local text_2 = panel:text({
		name = "text_2",
		text = params.primary_label_string,
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
	
	local _x,_y,_w,_h = text_1:text_rect()
	
	local text_bg_rect = panel:rect({
		name = "text_bg_rect",
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
	
	self._primary_text = text_1
	self._secondary_text = text_2
	self._name_text = buff_name_text
	
	self._text_bg_rect = text_bg_rect
	
	return KineticTrackerItemDestiny.super.init(self,...)
end

function KineticTrackerItemDestiny:SetPrimaryText(text,...)
	if alive(self._primary_text) then 
		self._primary_text:set_text(text)
		local _x,_y,_w,_h = self._primary_text:text_rect()
		
		if alive(self._text_bg_rect) then 
			local margin = self._TEXT_BG_MARGIN
			self._text_bg_rect:set_size(_w + margin + margin,_h + margin + margin)
			self._text_bg_rect:set_world_position(_x - margin,_y - margin)
		end
	end
	
	return KineticTrackerItemDestiny.super.SetPrimaryText(self,text,...)
end

function KineticTrackerItemDestiny:SetSecondaryText(text,...)
	if alive(self._secondary_text) then 
		self._secondary_text:set_text(text)
	end
	
	return KineticTrackerItemDestiny.super.SetSecondaryText(self,text,...)
end

function KineticTrackerItem:SetVisible(state,...)
	if alive(self._panel) then 
		self._panel:set_visible(state)
	end
	return KineticTrackerItemDestiny.super.SetVisible(self,state,...)
end




KineticTrackerItemWarframe = KineticTrackerItemWarframe or class(KineticTrackerItem)

function KineticTrackerItemWarframe:init(params,...)
	local id = params.id
	local icon_data = params.icon_data
	local margin = KineticTrackerItem._TEXT_BG_MARGIN
	
	local primary_color,secondary_color
	if true then 
		primary_color = params.color
		secondary_color = Color.white
	else
		primary_color = Color.white
		secondary_color = params.color
	end
	local buff_label = params.buff_label
	
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
		h = 32,
		visible = false
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

	--destiny style

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
	
	local text_1 = panel:text({
		name = "text_1",
		text = params.primary_label_string,
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
	
	local _x,_y,_w,_h = text_1:text_rect()
	
	local text_bg_rect = panel:rect({
		name = "text_bg_rect",
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
	
	local text_2 = panel:text({
		name = "text_2",
		text = params.secondary_label_string,
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
	
	self._primary_text = text_1
	self._secondary_text = text_2
	self._name_text = buff_name_text
	
	self._text_bg_rect = text_bg_rect
	
	return KineticTrackerItemDestiny.super.init(self,...)
end


function KineticTrackerItemWarframe:SetPrimaryText(text)
	if alive(self._primary_text) then 
		self._primary_text:set_text(text)
	end
end

function KineticTrackerItemWarframe:SetSecondaryText(text,...)
	if alive(self._secondary_text) then 
		self._secondary_text:set_text(text)
	end
	
	return KineticTrackerItemWarframe.super.SetSecondaryText(self,text,...)
end

function KineticTrackerItemWarframe:SetVisible(state,...)
	if alive(self._panel) then 
		self._panel:set_visible(state)
	end
	return KineticTrackerItemWarframe.super.SetVisible(self,state,...)
end







do return end
--unused
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







