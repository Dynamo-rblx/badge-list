-- @ScriptType: Script
game.Players.PlayerAdded:Connect(function(plr)
	game:GetService("BadgeService"):AwardBadge(plr.UserId, 3123078660681386)
end)