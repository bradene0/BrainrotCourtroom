local Players = game:GetService("Players")

local RewardService = {
	ProfileService = nil,
}

function RewardService:Init(profileService)
	self.ProfileService = profileService

	for _, player in ipairs(Players:GetPlayers()) do
		self:SetupPlayer(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:SetupPlayer(player)
	end)
end

function RewardService:SetupPlayer(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	local currency = leaderstats:FindFirstChild("BrainBucks")
	if not currency then
		currency = Instance.new("IntValue")
		currency.Name = "BrainBucks"
		currency.Value = 0
		currency.Parent = leaderstats
	end

	local wins = leaderstats:FindFirstChild("Wins")
	if not wins then
		wins = Instance.new("IntValue")
		wins.Name = "Wins"
		wins.Value = 0
		wins.Parent = leaderstats
	end

	local level = leaderstats:FindFirstChild("Level")
	if not level then
		level = Instance.new("IntValue")
		level.Name = "Level"
		level.Value = 1
		level.Parent = leaderstats
	end

	if self.ProfileService then
		self:ApplyProfileToLeaderstats(player)
	end
end

function RewardService:AwardRound(players, roleService, winningSide)
	for _, player in ipairs(players) do
		local role = roleService:GetRole(player)
		local didWin = role and role.alignment == winningSide
		local leaderstats = player:FindFirstChild("leaderstats")

		local currencyAward = didWin and 35 or 10

		if self.ProfileService then
			self.ProfileService:ApplyRoundReward(player, role, didWin, currencyAward)
		end

		if leaderstats then
			local currency = leaderstats:FindFirstChild("BrainBucks")
			local wins = leaderstats:FindFirstChild("Wins")
			local level = leaderstats:FindFirstChild("Level")
			local profile = self.ProfileService and self.ProfileService:Get(player) or nil

			if currency then
				currency.Value = profile and profile.currency or currency.Value + currencyAward
			end

			if wins and didWin then
				wins.Value = profile and profile.wins or wins.Value + 1
			end

			if level and profile then
				level.Value = profile.level
			end
		end
	end
end

function RewardService:ApplyProfileToLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	local profile = self.ProfileService:Get(player)
	if not leaderstats or not profile then
		return
	end

	local currency = leaderstats:FindFirstChild("BrainBucks")
	local wins = leaderstats:FindFirstChild("Wins")
	local level = leaderstats:FindFirstChild("Level")

	if currency then
		currency.Value = profile.currency
	end
	if wins then
		wins.Value = profile.wins
	end
	if level then
		level.Value = profile.level
	end
end

return RewardService
