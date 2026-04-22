local ReplicatedStorage = game:GetService("ReplicatedStorage")

local UIController = require(script.Parent:WaitForChild("UIController"))

local RoundController = {}

function RoundController:Init()
	local root = ReplicatedStorage:WaitForChild("BrainrotCourtroom")
	local remotes = root:WaitForChild("Remotes")

	UIController:Init()

	UIController.OnScan = function()
		local ok, result = pcall(function()
			return remotes:WaitForChild("RequestClue"):InvokeServer()
		end)

		if ok then
			UIController:AddEvidence(result)
		else
			UIController:AddEvidence({
				type = "Scan Failed",
				reliabilityClass = "Error",
				text = "Could not request clue.",
			})
		end
	end

	UIController.OnVote = function(targetUserId)
		remotes:WaitForChild("SubmitVote"):FireServer(targetUserId)
	end

	remotes:WaitForChild("RoundSnapshot").OnClientEvent:Connect(function(snapshot)
		UIController:RenderSnapshot(snapshot)
	end)

	remotes:WaitForChild("RoleAssigned").OnClientEvent:Connect(function(payload)
		UIController:SetRole(payload.role)
	end)

	remotes:WaitForChild("ClueFound").OnClientEvent:Connect(function(record)
		UIController:AddEvidence(record)
	end)

	remotes:WaitForChild("ActionReceipt").OnClientEvent:Connect(function(payload)
		UIController:ShowToast(payload.message)
	end)

	remotes:WaitForChild("VoteReceipt").OnClientEvent:Connect(function(payload)
		UIController:ShowToast(payload.message)
	end)
end

return RoundController
