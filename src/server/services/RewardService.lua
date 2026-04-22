local Players = game:GetService("Players")

local RewardService = {}

function RewardService:Init()
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
end

function RewardService:AwardRound(players, roleService, winningSide)
	for _, player in ipairs(players) do
		local role = roleService:GetRole(player)
		local didWin = role and role.alignment == winningSide
		local leaderstats = player:FindFirstChild("leaderstats")

		if leaderstats then
			local currency = leaderstats:FindFirstChild("BrainBucks")
			local wins = leaderstats:FindFirstChild("Wins")

			if currency then
				currency.Value += didWin and 35 or 10
			end

			if wins and didWin then
				wins.Value += 1
			end
		end
	end
end

return RewardService
