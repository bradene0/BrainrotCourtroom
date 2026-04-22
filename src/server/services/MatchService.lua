local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("BrainrotCourtroom"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))

local MatchService = {
	running = false,
	phase = Config.Phases.Lobby,
	roundId = nil,
	phaseEndsAt = 0,
	activePlayers = {},
	incident = nil,
	verdict = nil,
	paceMode = Config.Dev.defaultPace,
	skipPhase = false,
	sabotageUsed = false,
	forgeryUsedBy = {},
}

function MatchService:Init(services)
	self.RemoteService = services.RemoteService
	self.RoleService = services.RoleService
	self.IncidentService = services.IncidentService
	self.EvidenceService = services.EvidenceService
	self.VoteService = services.VoteService
	self.RewardService = services.RewardService
	self.MapService = services.MapService

	self.MapService:Init({
		OnCluePrompt = function(player, stationId)
			self:HandleCluePrompt(player, stationId)
		end,
		OnSabotagePrompt = function(player)
			self:HandleSabotagePrompt(player)
		end,
		OnForgePrompt = function(player)
			self:HandleForgePrompt(player)
		end,
	})

	self.RemoteService:Get("RequestClue").OnServerInvoke = function(player)
		if self.phase ~= Config.Phases.Investigation then
			return {
				type = "Court Locked",
				reliabilityClass = "None",
				sourceLocation = "Prototype Map",
				text = "Evidence can only be scanned during investigation.",
			}
		end

		return self.EvidenceService:InspectNext(player)
	end

	self.RemoteService:Get("SubmitVote").OnServerEvent:Connect(function(player, targetUserId)
		if self.phase ~= Config.Phases.Vote then
			self.RemoteService:FireClient(player, "VoteReceipt", {
				ok = false,
				message = "Court is not voting right now.",
			})
			return
		end

		local ok, message = self.VoteService:Submit(player, targetUserId, self.activePlayers)
		self.RemoteService:FireClient(player, "VoteReceipt", {
			ok = ok,
			message = message,
		})
		self:BroadcastSnapshot()
	end)

	Players.PlayerAdded:Connect(function()
		self:BroadcastSnapshot()
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:BindPlayer(player)
	end

	Players.PlayerAdded:Connect(function(player)
		self:BindPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function()
		task.defer(function()
			self:BroadcastSnapshot()
		end)
	end)
end

function MatchService:BindPlayer(player)
	player.Chatted:Connect(function(message)
		self:HandleDevCommand(player, message)
	end)

	player.CharacterAdded:Connect(function()
		task.defer(function()
			local groupName = self:GetSpawnGroupForPhase()
			local players = self:GetCurrentPlayers()
			local index = table.find(players, player) or 1
			self.MapService:TeleportPlayer(player, groupName, index)
		end)
	end)
end

function MatchService:Start()
	if self.running then
		return
	end

	self.running = true
	task.spawn(function()
		while self.running do
			self:WaitForPlayers()
			self:RunRound()
			task.wait(3)
		end
	end)
end

function MatchService:GetRequiredPlayers()
	if RunService:IsStudio() then
		return Config.STUDIO_MIN_PLAYERS
	end
	return Config.MIN_PLAYERS
end

function MatchService:GetCurrentPlayers()
	local players = Players:GetPlayers()
	table.sort(players, function(left, right)
		return left.UserId < right.UserId
	end)
	return players
end

function MatchService:WaitForPlayers()
	self.phase = Config.Phases.Lobby
	self.roundId = nil
	self.phaseEndsAt = 0
	self.incident = nil
	self.verdict = nil
	self.sabotageUsed = false
	self.forgeryUsedBy = {}
	self.MapService:TeleportPlayers(self:GetCurrentPlayers(), "Lobby")

	while #self:GetCurrentPlayers() < self:GetRequiredPlayers() do
		self.activePlayers = self:GetCurrentPlayers()
		self:BroadcastSnapshot()
		task.wait(2)
	end
end

function MatchService:RunRound()
	self.roundId = HttpService:GenerateGUID(false)
	self.activePlayers = self:GetCurrentPlayers()
	self.verdict = nil
	self.sabotageUsed = false
	self.forgeryUsedBy = {}

	self:SetPhase(Config.Phases.RoleAssignment)
	self.MapService:TeleportPlayers(self.activePlayers, "Lobby")
	self.RoleService:Assign(self.activePlayers)
	for _, player in ipairs(self.activePlayers) do
		local role = self.RoleService:GetRole(player)
		self.RemoteService:FireClient(player, "RoleAssigned", {
			role = role,
		})
	end
	self:RunPhaseTimer(Config.Phases.RoleAssignment)

	self.incident = self.IncidentService:Pick()
	self.EvidenceService:Generate(self.roundId, self.incident, self.activePlayers, self.RoleService)
	self.MapService:TeleportPlayers(self.activePlayers, "Map")
	self:RunPhaseTimer(Config.Phases.Incident)
	self:RunPhaseTimer(Config.Phases.Investigation)
	self.MapService:TeleportPlayers(self.activePlayers, "Court")
	self:RunPhaseTimer(Config.Phases.Debate)

	self.VoteService:Begin(self.activePlayers)
	self:RunPhaseTimer(Config.Phases.Vote)

	self.verdict = self.VoteService:Resolve(self.RoleService, self.activePlayers)
	self.RewardService:AwardRound(self.activePlayers, self.RoleService, self.verdict.winningSide)
	self:RunPhaseTimer(Config.Phases.Reveal)
end

function MatchService:SetPhase(phase)
	self.phase = phase
	self.skipPhase = false
	self.phaseEndsAt = os.clock() + self:GetPhaseDuration(phase)
	self:BroadcastSnapshot()
end

function MatchService:RunPhaseTimer(phase)
	self:SetPhase(phase)

	while os.clock() < self.phaseEndsAt do
		if self.skipPhase then
			self.skipPhase = false
			break
		end
		self:BroadcastSnapshot()
		task.wait(1)
	end
end

function MatchService:GetPhaseDuration(phase)
	local durations = self.paceMode == "fast" and Config.FastPhaseDurations or Config.PhaseDurations
	return durations[phase] or 0
end

function MatchService:GetSpawnGroupForPhase()
	if
		self.phase == Config.Phases.Debate
		or self.phase == Config.Phases.Vote
		or self.phase == Config.Phases.Reveal
	then
		return "Court"
	end

	if self.phase == Config.Phases.Incident or self.phase == Config.Phases.Investigation then
		return "Map"
	end

	return "Lobby"
end

function MatchService:IsActivePlayer(player)
	return table.find(self.activePlayers, player) ~= nil
end

function MatchService:SendAction(player, message)
	self.RemoteService:FireClient(player, "ActionReceipt", {
		message = message,
	})
end

function MatchService:HandleCluePrompt(player, stationId)
	if self.phase ~= Config.Phases.Investigation then
		self:SendAction(player, "Clues unlock during investigation.")
		return
	end

	if not self:IsActivePlayer(player) then
		self:SendAction(player, "Only active players can inspect clues.")
		return
	end

	local record = self.EvidenceService:InspectNext(player, stationId)
	self.RemoteService:FireClient(player, "ClueFound", record)
	self:SendAction(player, `Clue checked: {record.type}`)
end

function MatchService:HandleSabotagePrompt(player)
	if self.phase ~= Config.Phases.Incident and self.phase ~= Config.Phases.Investigation then
		self:SendAction(player, "Sabotage console is asleep.")
		return
	end

	local role = self.RoleService:GetRole(player)
	if not role or role.id ~= Config.Roles.Saboteur.id then
		self:SendAction(player, "Only saboteur can use this console.")
		return
	end

	if self.sabotageUsed then
		self:SendAction(player, "Sabotage already triggered this round.")
		return
	end

	self.sabotageUsed = true
	if self.incident then
		self.incident.summary = `{self.incident.summary} Sabotage console was manually spiked.`
		self.incident.objective = `{self.incident.objective} Watch who reached suspicious room.`
	end

	self:SendAction(player, "Sabotage triggered. Act innocent.")
	self:BroadcastSnapshot()
end

function MatchService:HandleForgePrompt(player)
	if self.phase ~= Config.Phases.Investigation then
		self:SendAction(player, "Forgery only works during investigation.")
		return
	end

	local role = self.RoleService:GetRole(player)
	if not role or role.id ~= Config.Roles.Forger.id then
		self:SendAction(player, "Only forger can plant fake report.")
		return
	end

	if self.forgeryUsedBy[player.UserId] then
		self:SendAction(player, "Fake report already planted.")
		return
	end

	self.forgeryUsedBy[player.UserId] = true
	local record = self.EvidenceService:ForgeEvidence(player, self.activePlayers, self.incident)
	self.RemoteService:FireClient(player, "ClueFound", record)
	self:SendAction(player, "Fake report planted in evidence printer.")
end

function MatchService:HandleDevCommand(player, message)
	if not RunService:IsStudio() then
		return
	end

	local prefix = Config.Dev.commandPrefix
	local lowered = string.lower(message)
	if string.sub(lowered, 1, #prefix) ~= prefix then
		return
	end

	if lowered == `{prefix} fast` then
		self.paceMode = "fast"
		self:SendAction(player, "Dev pace: fast.")
		self:BroadcastSnapshot()
	elseif lowered == `{prefix} normal` then
		self.paceMode = "normal"
		self:SendAction(player, "Dev pace: normal.")
		self:BroadcastSnapshot()
	elseif lowered == `{prefix} next` then
		self.skipPhase = true
		self.phaseEndsAt = os.clock()
		self:SendAction(player, "Dev jump: next phase.")
		self:BroadcastSnapshot()
	elseif lowered == `{prefix} help` then
		self:SendAction(player, "/bc fast, /bc normal, /bc next")
	end
end

function MatchService:GetPublicPlayers()
	local publicPlayers = {}
	for _, player in ipairs(self.activePlayers) do
		table.insert(publicPlayers, {
			userId = player.UserId,
			displayName = player.DisplayName,
			name = player.Name,
		})
	end
	return publicPlayers
end

function MatchService:BuildSnapshot()
	return {
		roundId = self.roundId,
		phase = self.phase,
		timeRemaining = math.max(0, math.ceil(self.phaseEndsAt - os.clock())),
		requiredPlayers = self:GetRequiredPlayers(),
		playerCount = #self:GetCurrentPlayers(),
		players = self:GetPublicPlayers(),
		incident = self.incident,
		devPace = self.paceMode,
		hudScanEnabled = Config.Dev.showHudScanFallback,
		sabotageUsed = self.sabotageUsed,
		voteCounts = self.VoteService:GetCounts(),
		verdict = self.verdict,
		roleReveal = self.verdict and self.RoleService:GetRoleReveal(self.activePlayers) or nil,
	}
end

function MatchService:BroadcastSnapshot()
	self.RemoteService:FireAllClients("RoundSnapshot", self:BuildSnapshot())
end

return MatchService
