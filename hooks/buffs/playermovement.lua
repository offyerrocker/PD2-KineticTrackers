Hooks:PostHook(PlayerMovement,"on_morale_boost","noblehud_buff_morale_boost",function(self,benefactor_unit) --inspire basic buff (receive)
	NobleHUD:AddBuff("morale_boost",{end_t = Application:time() + tweak_data.upgrades.morale_boost_time})
--this gives move speed AND reload speed apparently so i'm just gonna show that you have the inspire bonus rather than clutter the HUD
end)