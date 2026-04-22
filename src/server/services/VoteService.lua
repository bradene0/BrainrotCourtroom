local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("BrainrotCourtroom"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local VoteService = {
	votes = {},
	eligible = {},
}

function VoteService:Begin(players)
	self.votes = {}
	self.eligible = {}

	for _, player in ipairs(players) do
		self.eligible[player.UserId] = true
	end
end

function VoteService:Submit(player, targetUserId, players)
	if not self.eligible[player.UserId] then
		return false, "Not eligible to vote."
	end

	if self.votes[player.UserId] then
		return false, "Vote already submitted."
	end

	local numericTarget = tonumber(targetUserId)
	local targetExists = false
	for _, candidate in ipairs(players) do
		if candidate.UserId == numericTarget then
			targetExists = true
			break
		end
	end

	if not targetExists then
		return false, "Invalid suspect."
	end

	self.votes[player.UserId] = numericTarget
	return true, "Vote locked."
end

function VoteService:GetCounts()
	local counts = {}
	for _, targetUserId in pairs(self.votes) do
		counts[targetUserId] = (counts[targetUserId] or 0) + 1
	end
	return counts
end

function VoteService:Resolve(roleService, players)
	local counts = self:GetCounts()
	local topTarget = nil
	local topCount = 0
	local tied = false

	for _, player in ipairs(players) do
		local count = counts[player.UserId] or 0
		if count > topCount then
			topTarget = player
			topCount = count
			tied = false
		elseif count == topCount and count > 0 then
			tied = true
		end
	end

	if not topTarget or tied then
		return {
			convictedUserId = nil,
			convictedName = "No one",
			winningSide = Config.Alignment.Saboteur,
			reason = "Tie or no majority. Saboteur side escapes.",
			counts = counts,
		}
	end

	local convictedAlignment = roleService:GetAlignment(topTarget)
	local civilianWin = convictedAlignment == Config.Alignment.Saboteur

	return {
		convictedUserId = topTarget.UserId,
		convictedName = topTarget.DisplayName,
		winningSide = civilianWin and Config.Alignment.Civilian or Config.Alignment.Saboteur,
		reason = civilianWin and "Correct conviction." or "Wrong conviction.",
		counts = counts,
	}
end

return VoteService
