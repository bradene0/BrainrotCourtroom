local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("BrainrotCourtroom"):WaitForChild("Shared")
local Content = require(Shared:WaitForChild("Content"))

local rng = Random.new()

local IncidentService = {}

function IncidentService:Pick()
	local incident = Content.Incidents[rng:NextInteger(1, #Content.Incidents)]
	return table.clone(incident)
end

return IncidentService
