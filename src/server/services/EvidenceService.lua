local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("BrainrotCourtroom"):WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Content = require(Shared:WaitForChild("Content"))

local rng = Random.new()

local EvidenceService = {
	records = {},
	discoveredByUser = {},
	roundId = nil,
	incident = nil,
}

local function getStationName(stationId)
	for _, station in ipairs(Content.ClueStations) do
		if station.id == stationId then
			return station.name
		end
	end
	return "Prototype Map"
end

local function pickPlayer(players)
	if #players == 0 then
		return nil
	end
	return players[rng:NextInteger(1, #players)]
end

local function getName(player)
	return player and player.DisplayName or "someone"
end

local function buildText(template, incident, relatedPlayer, forged)
	if template.id == "camera_snapshot" then
		return `Camera caught {getName(relatedPlayer)} near incident route before "{incident.title}".`
	elseif template.id == "item_trace" then
		return `Odd residue matches prop handled by {getName(relatedPlayer)}.`
	elseif template.id == "access_log" then
		return `Door log shows {getName(relatedPlayer)} entered suspicious room near disaster time.`
	elseif template.id == "witness_mumble" then
		return `Witness heard a voice "kind of like" {getName(relatedPlayer)}, but panic was loud.`
	elseif template.id == "audio_fragment" then
		return `Audio clip has footsteps and one half-word that may point at {getName(relatedPlayer)}.`
	elseif forged then
		return `Printed report loudly accuses {getName(relatedPlayer)}, with suspicious formatting.`
	end

	return `Clue mentions {getName(relatedPlayer)}, but context is incomplete.`
end

function EvidenceService:Generate(roundId, incident, players, roleService)
	self.records = {}
	self.discoveredByUser = {}
	self.roundId = roundId
	self.incident = incident

	local saboteurs = roleService:GetPlayersByAlignment(players, Config.Alignment.Saboteur)
	local civilians = roleService:GetPlayersByAlignment(players, Config.Alignment.Civilian)
	local saboteur = pickPlayer(saboteurs) or pickPlayer(players)

	for index, template in ipairs(Content.EvidenceTemplates) do
		local forged = template.canForge == true
		local relatedPlayer = saboteur

		if template.reliabilityClass == "Ambiguous" then
			relatedPlayer = pickPlayer(players)
		elseif forged then
			relatedPlayer = pickPlayer(civilians) or pickPlayer(players)
		end

		table.insert(self.records, {
			evidenceId = `{roundId}:{template.id}:{index}`,
			type = template.type,
			reliabilityClass = template.reliabilityClass,
			sourceLocation = template.stationId,
			stationName = getStationName(template.stationId),
			stationId = template.stationId,
			relatedPlayerId = relatedPlayer and relatedPlayer.UserId or nil,
			relatedPlayerName = relatedPlayer and relatedPlayer.DisplayName or nil,
			forged = forged,
			visibilityRules = "Discoverable by any active player",
			text = buildText(template, incident, relatedPlayer, forged),
		})
	end

	return self.records
end

function EvidenceService:InspectNext(player, stationId)
	local seen = self.discoveredByUser[player.UserId]
	if not seen then
		seen = {}
		self.discoveredByUser[player.UserId] = seen
	end

	for _, record in ipairs(self.records) do
		local stationMatches = stationId == nil or record.stationId == stationId
		if stationMatches and not seen[record.evidenceId] then
			seen[record.evidenceId] = true
			return record
		end
	end

	return {
		type = "No New Evidence",
		reliabilityClass = "None",
		sourceLocation = stationId or "Prototype Map",
		stationName = getStationName(stationId),
		text = "No new clues found. Use what you have in court.",
	}
end

function EvidenceService:ForgeEvidence(player, activePlayers, incident)
	local target = pickPlayer(activePlayers)
	if target == player and #activePlayers > 1 then
		for _, candidate in ipairs(activePlayers) do
			if candidate ~= player then
				target = candidate
				break
			end
		end
	end

	local record = {
		evidenceId = `{self.roundId or "round"}:forged:{player.UserId}:{os.clock()}`,
		type = "Fake Document",
		reliabilityClass = "Forgable",
		sourceLocation = "evidence_printer",
		stationName = getStationName("evidence_printer"),
		stationId = "evidence_printer",
		relatedPlayerId = target and target.UserId or nil,
		relatedPlayerName = target and target.DisplayName or nil,
		forged = true,
		forgedByUserId = player.UserId,
		visibilityRules = "Discoverable by any active player",
		text = `Fresh fake report accuses {getName(target)} of causing "{incident.title}". Ink still wet.`,
	}

	table.insert(self.records, 1, record)
	return record
end

return EvidenceService
