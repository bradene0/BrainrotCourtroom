local Services = script.Parent:WaitForChild("services")

local RemoteService = require(Services:WaitForChild("RemoteService"))
local RoleService = require(Services:WaitForChild("RoleService"))
local IncidentService = require(Services:WaitForChild("IncidentService"))
local EvidenceService = require(Services:WaitForChild("EvidenceService"))
local VoteService = require(Services:WaitForChild("VoteService"))
local RewardService = require(Services:WaitForChild("RewardService"))
local MapService = require(Services:WaitForChild("MapService"))
local MatchService = require(Services:WaitForChild("MatchService"))

RemoteService:Init()
RewardService:Init()

MatchService:Init({
	RemoteService = RemoteService,
	RoleService = RoleService,
	IncidentService = IncidentService,
	EvidenceService = EvidenceService,
	VoteService = VoteService,
	RewardService = RewardService,
	MapService = MapService,
})

MatchService:Start()
