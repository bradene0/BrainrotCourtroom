local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local STORE_NAME = "BrainrotCourtroomProfiles_v1"

local DEFAULT_PROFILE = {
	currency = 0,
	wins = 0,
	level = 1,
	gamesPlayed = 0,
	ownedCosmetics = {},
	selectedCosmetics = {
		title = "Public Nuisance",
		podium = "Default Podium",
		trail = "None",
	},
	stats = {
		civilianWins = 0,
		saboteurWins = 0,
		forgerWins = 0,
		witnessWins = 0,
	},
	tutorialCompleted = false,
}

local ProfileService = {
	profiles = {},
	store = nil,
	dataStoreAvailable = true,
}

local function deepCopy(value)
	if type(value) ~= "table" then
		return value
	end

	local copy = {}
	for key, child in pairs(value) do
		copy[key] = deepCopy(child)
	end
	return copy
end

local function mergeDefaults(profile, defaults)
	for key, defaultValue in pairs(defaults) do
		if profile[key] == nil then
			profile[key] = deepCopy(defaultValue)
		elseif type(profile[key]) == "table" and type(defaultValue) == "table" then
			mergeDefaults(profile[key], defaultValue)
		end
	end
end

function ProfileService:Init()
	self.store = DataStoreService:GetDataStore(STORE_NAME)

	for _, player in ipairs(Players:GetPlayers()) do
		self:Load(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:Load(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:Save(player)
		self.profiles[player.UserId] = nil
	end)
end

function ProfileService:GetKey(player)
	return `profile:{player.UserId}`
end

function ProfileService:Load(player)
	local profile = deepCopy(DEFAULT_PROFILE)

	if not RunService:IsStudio() or self.dataStoreAvailable then
		local ok, stored = pcall(function()
			return self.store:GetAsync(self:GetKey(player))
		end)

		if ok and type(stored) == "table" then
			mergeDefaults(stored, DEFAULT_PROFILE)
			profile = stored
		elseif not ok then
			self.dataStoreAvailable = false
			warn(
				`[BrainrotCourtroom] Profile load failed for {player.UserId}. Using session profile.`
			)
		end
	end

	self.profiles[player.UserId] = profile
	return profile
end

function ProfileService:Get(player)
	local profile = self.profiles[player.UserId]
	if not profile then
		profile = self:Load(player)
	end
	return profile
end

function ProfileService:ApplyRoundReward(player, role, didWin, currencyAward)
	local profile = self:Get(player)
	profile.currency += currencyAward
	profile.gamesPlayed += 1

	if didWin then
		profile.wins += 1

		if role and role.id == "saboteur" then
			profile.stats.saboteurWins += 1
		elseif role and role.id == "forger" then
			profile.stats.forgerWins += 1
		elseif role and role.id == "witness" then
			profile.stats.witnessWins += 1
		else
			profile.stats.civilianWins += 1
		end
	end

	profile.level = math.max(1, math.floor(profile.currency / 250) + 1)
end

function ProfileService:Save(player)
	local profile = self.profiles[player.UserId]
	if not profile or not self.dataStoreAvailable then
		return
	end

	local ok = pcall(function()
		self.store:SetAsync(self:GetKey(player), profile)
	end)

	if not ok then
		warn(`[BrainrotCourtroom] Profile save failed for {player.UserId}.`)
	end
end

return ProfileService
