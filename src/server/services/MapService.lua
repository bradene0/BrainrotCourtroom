local Workspace = game:GetService("Workspace")

local MapService = {
	root = nil,
	spawns = {
		Lobby = {},
		Map = {},
		Court = {},
	},
	onCluePrompt = nil,
	onSabotagePrompt = nil,
	onForgePrompt = nil,
}

local function createPart(parent, name, size, cframe, color, transparency)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.Transparency = transparency or 0
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addLabel(parent, text)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(180, 42)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBlack
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0.4
	label.TextScaled = true
	label.Text = text
	label.Parent = gui
end

local function addPrompt(parent, actionText, objectText, callback)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = actionText
	prompt.ObjectText = objectText
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 12
	prompt.RequiresLineOfSight = false
	prompt.Parent = parent

	prompt.Triggered:Connect(callback)
	return prompt
end

function MapService:Init(callbacks)
	callbacks = callbacks or {}
	self.onCluePrompt = callbacks.OnCluePrompt
	self.onSabotagePrompt = callbacks.OnSabotagePrompt
	self.onForgePrompt = callbacks.OnForgePrompt

	self:Build()
end

function MapService:Build()
	local existing = Workspace:FindFirstChild("BrainrotCourtroomMap")
	if existing then
		existing:Destroy()
	end

	local root = Instance.new("Folder")
	root.Name = "BrainrotCourtroomMap"
	root.Parent = Workspace
	self.root = root
	self.spawns = {
		Lobby = {},
		Map = {},
		Court = {},
	}

	createPart(
		root,
		"BaseFloor",
		Vector3.new(190, 1, 130),
		CFrame.new(0, -0.55, 0),
		Color3.fromRGB(68, 72, 78)
	)
	self:BuildLobby(root)
	self:BuildInvestigation(root)
	self:BuildCourt(root)
end

function MapService:AddSpawn(groupName, cframe)
	table.insert(self.spawns[groupName], cframe)
end

function MapService:BuildLobby(root)
	createPart(
		root,
		"LobbyPad",
		Vector3.new(34, 1, 28),
		CFrame.new(-68, 0.02, 0),
		Color3.fromRGB(54, 118, 184)
	)
	local sign = createPart(
		root,
		"LobbySign",
		Vector3.new(18, 8, 1),
		CFrame.new(-68, 4, -15),
		Color3.fromRGB(30, 34, 42)
	)
	addLabel(sign, "LOBBY")

	for index = 1, 8 do
		local row = math.floor((index - 1) / 4)
		local column = (index - 1) % 4
		self:AddSpawn("Lobby", CFrame.new(-76 + column * 5, 3, -4 + row * 8))
	end
end

function MapService:BuildInvestigation(root)
	local rooms = {
		{
			name = "SecurityCloset",
			label = "SECURITY",
			position = Vector3.new(-28, 0, -32),
			color = Color3.fromRGB(44, 88, 120),
		},
		{
			name = "EvidenceLab",
			label = "EVIDENCE LAB",
			position = Vector3.new(10, 0, -32),
			color = Color3.fromRGB(88, 72, 126),
		},
		{
			name = "RecordsOffice",
			label = "RECORDS",
			position = Vector3.new(48, 0, -32),
			color = Color3.fromRGB(98, 92, 58),
		},
		{
			name = "WitnessCorner",
			label = "WITNESS",
			position = Vector3.new(-28, 0, 28),
			color = Color3.fromRGB(88, 120, 84),
		},
		{
			name = "SoundBooth",
			label = "AUDIO",
			position = Vector3.new(10, 0, 28),
			color = Color3.fromRGB(112, 76, 64),
		},
		{
			name = "SuspiciousRoom",
			label = "SUS ROOM",
			position = Vector3.new(48, 0, 28),
			color = Color3.fromRGB(128, 54, 54),
		},
	}

	for _, room in ipairs(rooms) do
		local floor = createPart(
			root,
			`${room.name}Floor`,
			Vector3.new(28, 1, 24),
			CFrame.new(room.position + Vector3.new(0, 0.04, 0)),
			room.color
		)
		addLabel(floor, room.label)
	end

	createPart(
		root,
		"MainHall",
		Vector3.new(106, 1, 16),
		CFrame.new(10, 0.08, 0),
		Color3.fromRGB(95, 95, 95)
	)
	createPart(
		root,
		"NorthSouthHall",
		Vector3.new(18, 1, 76),
		CFrame.new(10, 0.09, 0),
		Color3.fromRGB(82, 82, 82)
	)

	for index = 1, 14 do
		local row = math.floor((index - 1) / 7)
		local column = (index - 1) % 7
		self:AddSpawn("Map", CFrame.new(-38 + column * 8, 3, -5 + row * 10))
	end

	self:BuildClueStation(
		root,
		"camera_terminal",
		"Camera Terminal",
		CFrame.new(-34, 2, -32),
		Color3.fromRGB(82, 180, 255)
	)
	self:BuildClueStation(
		root,
		"trace_locker",
		"Trace Locker",
		CFrame.new(3, 2, -32),
		Color3.fromRGB(180, 142, 255)
	)
	self:BuildClueStation(
		root,
		"evidence_printer",
		"Evidence Printer",
		CFrame.new(17, 2, -32),
		Color3.fromRGB(255, 214, 84)
	)
	self:BuildClueStation(
		root,
		"access_panel",
		"Access Panel",
		CFrame.new(48, 2, -32),
		Color3.fromRGB(255, 244, 132)
	)
	self:BuildClueStation(
		root,
		"witness_marker",
		"Witness Marker",
		CFrame.new(-28, 2, 28),
		Color3.fromRGB(120, 255, 156)
	)
	self:BuildClueStation(
		root,
		"audio_console",
		"Audio Console",
		CFrame.new(10, 2, 28),
		Color3.fromRGB(255, 144, 112)
	)

	self:BuildActionStation(
		root,
		"Sabotage Console",
		CFrame.new(48, 2, 20),
		Color3.fromRGB(255, 68, 68),
		function(player)
			if self.onSabotagePrompt then
				self.onSabotagePrompt(player)
			end
		end,
		"Trigger Sabotage"
	)

	self:BuildActionStation(
		root,
		"Forgery Printer",
		CFrame.new(18, 2, -40),
		Color3.fromRGB(255, 116, 224),
		function(player)
			if self.onForgePrompt then
				self.onForgePrompt(player)
			end
		end,
		"Plant Fake"
	)
end

function MapService:BuildClueStation(root, stationId, labelText, cframe, color)
	local station = createPart(root, stationId, Vector3.new(5, 4, 4), cframe, color)
	addLabel(station, labelText)
	addPrompt(station, "Inspect", labelText, function(player)
		if self.onCluePrompt then
			self.onCluePrompt(player, stationId)
		end
	end)
end

function MapService:BuildActionStation(root, name, cframe, color, callback, actionText)
	local station = createPart(root, name, Vector3.new(5, 4, 4), cframe, color)
	addLabel(station, name)
	addPrompt(station, actionText, name, callback)
end

function MapService:BuildCourt(root)
	createPart(
		root,
		"CourtFloor",
		Vector3.new(54, 1, 44),
		CFrame.new(70, 0.05, 0),
		Color3.fromRGB(98, 62, 50)
	)
	local bench = createPart(
		root,
		"JudgeBench",
		Vector3.new(28, 5, 5),
		CFrame.new(70, 2.2, -18),
		Color3.fromRGB(92, 54, 42)
	)
	addLabel(bench, "COURTROOM")

	createPart(
		root,
		"AccusedPodium",
		Vector3.new(8, 3, 6),
		CFrame.new(58, 1.4, 4),
		Color3.fromRGB(52, 44, 44)
	)
	createPart(
		root,
		"DefensePodium",
		Vector3.new(8, 3, 6),
		CFrame.new(82, 1.4, 4),
		Color3.fromRGB(52, 44, 44)
	)

	for index = 1, 14 do
		local row = math.floor((index - 1) / 7)
		local column = (index - 1) % 7
		local x = 49 + column * 7
		local z = 12 + row * 8
		createPart(
			root,
			`CourtSpot{index}`,
			Vector3.new(4, 0.4, 4),
			CFrame.new(x, 0.25, z),
			Color3.fromRGB(255, 204, 64)
		)
		self:AddSpawn("Court", CFrame.new(x, 3, z))
	end
end

function MapService:TeleportPlayers(players, groupName)
	local spawns = self.spawns[groupName]
	if not spawns or #spawns == 0 then
		return
	end

	for index, player in ipairs(players) do
		self:TeleportPlayer(player, groupName, index)
	end
end

function MapService:TeleportPlayer(player, groupName, index)
	local spawns = self.spawns[groupName]
	if not spawns or #spawns == 0 then
		return
	end

	local character = player.Character
	if not character then
		return
	end

	local spawnCFrame = spawns[((index or 1) - 1) % #spawns + 1]
	character:PivotTo(spawnCFrame)
end

return MapService
