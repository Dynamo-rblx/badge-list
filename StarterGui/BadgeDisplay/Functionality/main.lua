-- @ScriptType: LocalScript
--// VARIABLES
local plr = game.Players.LocalPlayer
local UI = script.Parent.Parent
local Container = UI:WaitForChild("Container")
local toggle_btn = UI:WaitForChild("Toggle")
local Settings = UI:WaitForChild("Settings")
local config = Settings:WaitForChild("Colors")
local Colors = {
	["BadgeFound"] = config:GetAttribute("HasBadgeColor"),
	["BadgeMissing"] = config:GetAttribute("MissingBadgeColor")
}

local badges = require(Settings:WaitForChild("BadgeIDs"))
local badge_template = script:WaitForChild("template")
local badge_list = Container:WaitForChild("bg"):WaitForChild("badgeList")
local currentListed: {number} = {}
local downtime = Settings:WaitForChild("Downtime").Value
local tweentime = Settings:WaitForChild("Tweentime").Value
local basics = {
	["Size"] = Container.Size,
	["Position"] = Container.Position
}
local debounce = false

local visible = false
Container.Size = UDim2.fromScale(0,0); Container.Position = toggle_btn.Position

--// SERVICES
local BadgeService = game:GetService("BadgeService")

--// FUNCTIONS
local function UpdateList()
	for index, badgeID in pairs(badges) do
		local badge_data = BadgeService:GetBadgeInfoAsync(badgeID)

		if badge_data.IsEnabled and not(table.find(currentListed, badgeID)) then
			local new_item = badge_template:Clone()
			new_item.Name = badgeID
			new_item:WaitForChild("badgeImage").Image = "rbxassetid://"..badge_data.IconImageId
			new_item:WaitForChild("badgeTitle").Text = badge_data.Name
			new_item:WaitForChild("badgeDescription").Text = badge_data.Description
			new_item:WaitForChild("bg").Image = "rbxassetid://"..badge_data.IconImageId
			new_item.LayoutOrder = index
			new_item.Parent = badge_list
			new_item.Visible = true

			table.insert(currentListed, badgeID)

		elseif not(badge_data.IsEnabled) and table.find(currentListed, badgeID) then
			local item = badge_list:WaitForChild(badgeID)

			if badge_list:FindFirstChild(badgeID) then
				badge_list:FindFirstChild(badgeID):Destroy()
			end

			table.remove(currentListed, badgeID)
		end
	end
end

local UpdateBadgeBorders = coroutine.wrap(function()
	while task.wait() do
		for index, badgeID in pairs(currentListed) do
			if BadgeService:GetBadgeInfoAsync(badgeID).IsEnabled then
				local item = badge_list:WaitForChild(badgeID)

				if BadgeService:UserHasBadgeAsync(plr.UserId, badgeID) then
					item:WaitForChild("badgeImage"):WaitForChild("Border").Color = Colors.BadgeFound
					item:WaitForChild("badgeImage"):WaitForChild("checkmark").Visible = true
				else
					item:WaitForChild("badgeImage"):WaitForChild("Border").Color = Colors.BadgeMissing
					item:WaitForChild("badgeImage"):WaitForChild("checkmark").Visible = false
				end
			end
		end

		task.wait(10)
	end
end)

local function toggleApp()
	if not(debounce) then
		debounce = true
		toggle_btn:TweenSize(UDim2.fromScale(.075, 0.075), Enum.EasingDirection.Out, Enum.EasingStyle.Linear,0.03,false)
		toggle_btn:TweenSize(UDim2.fromScale(.08, 0.08), Enum.EasingDirection.Out, Enum.EasingStyle.Linear,0.03,false)
		toggle_btn:TweenSize(UDim2.fromScale(.075, 0.075), Enum.EasingDirection.Out, Enum.EasingStyle.Linear,0.03,false)

		if visible then
			visible = not(visible)
			Container:TweenSizeAndPosition(UDim2.fromScale(0,0), toggle_btn.Position, Enum.EasingDirection.In, Enum.EasingStyle.Back, tweentime, true)
			task.wait(tweentime)
			Container.Visible = false

		else
			visible = not(visible)
			Container.Visible = true
			Container:TweenSizeAndPosition(basics.Size, basics.Position, Enum.EasingDirection.Out, Enum.EasingStyle.Back, tweentime, true)
			task.wait(tweentime)
		end
		debounce = false
	end
end

--// RUNTIME
UpdateBadgeBorders()

toggle_btn.MouseButton1Click:Connect(toggleApp); toggle_btn.TouchTap:Connect(toggleApp)

toggle_btn.MouseEnter:Connect(function()
	toggle_btn:WaitForChild("Image").ImageColor3 = Color3.fromRGB(255, 177, 42)
	toggle_btn:WaitForChild("UIStroke").Color = Color3.fromRGB(255, 177, 42)
	toggle_btn:TweenSize(UDim2.fromScale(.08, 0.08), Enum.EasingDirection.In, Enum.EasingStyle.Back,0.1,false)
end)

toggle_btn.MouseLeave:Connect(function()
	toggle_btn:WaitForChild("Image").ImageColor3 = Color3.fromRGB(255,255, 255)
	toggle_btn:WaitForChild("UIStroke").Color = Color3.fromRGB(255, 255, 255)
	toggle_btn:TweenSize(UDim2.fromScale(.075, 0.075), Enum.EasingDirection.Out, Enum.EasingStyle.Back,0.1,false)
end)

while task.wait() do
	UpdateList()
	task.wait(downtime)
end