local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("BrainrotCourtroom"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local rng = Random.new()

local RoleService = {
	assignments = {},
}

local function shuffled(players)
	local result = table.clone(players)
	for index = #result, 2, -1 do
		local swapIndex = rng:NextInteger(1, index)
		result[index], result[swapIndex] = result[swapIndex], result[index]
	end
	return result
end

function RoleService:Assign(players)
	self.assignments = {}

	local pool = shuffled(players)
	if #pool == 0 then
		return self.assignments
	end

	local function assign(player, role)
		self.assignments[player.UserId] = role
	end

	assign(table.remove(pool, 1), Config.Roles.Saboteur)

	if #players >= 4 and #pool > 0 then
		assign(table.remove(pool, 1), Config.Roles.Witness)
	end

	if #players >= 6 and #pool > 0 then
		assign(table.remove(pool, 1), Config.Roles.Forger)
	end

	for _, player in ipairs(pool) do
		assign(player, Config.Roles.Civilian)
	end

	return self.assignments
end

function RoleService:GetRole(player)
	return self.assignments[player.UserId]
end

function RoleService:GetAlignment(player)
	local role = self:GetRole(player)
	return role and role.alignment or Config.Alignment.Civilian
end

function RoleService:GetPlayersByAlignment(players, alignment)
	local matching = {}
	for _, player in ipairs(players) do
		if self:GetAlignment(player) == alignment then
			table.insert(matching, player)
		end
	end
	return matching
end

function RoleService:GetRoleReveal(players)
	local reveal = {}
	for _, player in ipairs(players) do
		local role = self:GetRole(player)
		table.insert(reveal, {
			userId = player.UserId,
			displayName = player.DisplayName,
			role = role and role.name or "Unknown",
			alignment = role and role.alignment or "Unknown",
		})
	end
	return reveal
end

return RoleService
