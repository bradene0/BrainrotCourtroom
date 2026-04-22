local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("BrainrotCourtroom"):WaitForChild("Shared")
local RemoteNames = require(Shared:WaitForChild("RemoteNames"))

local RemoteService = {
	Remotes = {},
}

function RemoteService:Init()
	local root = ReplicatedStorage:FindFirstChild("BrainrotCourtroom")
	if not root then
		root = Instance.new("Folder")
		root.Name = "BrainrotCourtroom"
		root.Parent = ReplicatedStorage
	end

	local remotesFolder = root:FindFirstChild("Remotes")
	if not remotesFolder then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "Remotes"
		remotesFolder.Parent = root
	end

	for _, spec in ipairs(RemoteNames) do
		local remote = remotesFolder:FindFirstChild(spec.name)
		if not remote then
			remote = Instance.new(spec.className)
			remote.Name = spec.name
			remote.Parent = remotesFolder
		end

		self.Remotes[spec.name] = remote
	end
end

function RemoteService:Get(name)
	return self.Remotes[name]
end

function RemoteService:FireClient(player, name, payload)
	local remote = self:Get(name)
	if remote then
		remote:FireClient(player, payload)
	end
end

function RemoteService:FireAllClients(name, payload)
	local remote = self:Get(name)
	if remote then
		remote:FireAllClients(payload)
	end
end

return RemoteService
