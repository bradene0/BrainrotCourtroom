local Services = script.Parent:WaitForChild("services")

local RemoteService = require(Services:WaitForChild("RemoteService"))
local RoleService = require(Services:WaitForChild("RoleService"))
local IncidentService = require(Services:WaitForChild("IncidentService"))
local EvidenceService = require(Services:WaitForChild("EvidenceService"))
local VoteService = require(Services:WaitForChild("VoteService"))
local RewardService = require(Services:WaitForChild("RewardService"))
local MapService = require(Services:WaitForChild("MapService"))
local MatchService = require(Services:WaitForChild("MatchService"))

local profileModule = Services:FindFirstChild("ProfileService")
local ProfileService = profileModule and require(profileModule) or nil

RemoteService:Init()
MapService:Build()

if ProfileService then
	local ok, err = pcall(function()
		ProfileService:Init()
	end)

	if not ok then
		warn(`[BrainrotCourtroom] ProfileService disabled: {err}`)
		ProfileService = nil
	end
end

RewardService:Init(ProfileService)

MatchService:Init({
	RemoteService = RemoteService,
	RoleService = RoleService,
	IncidentService = IncidentService,
	EvidenceService = EvidenceService,
	VoteService = VoteService,
	RewardService = RewardService,
	ProfileService = ProfileService,
	MapService = MapService,
})

MatchService:Start()
