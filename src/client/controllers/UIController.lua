local Players = game:GetService("Players")

local LOCAL_PLAYER = Players.LocalPlayer

local UIController = {
	OnScan = nil,
	OnVote = nil,
	OnDebateAction = nil,
	evidenceRecords = {},
	evidenceRows = {},
	voteButtons = {},
	debateButtons = {},
	debateActionButtons = {},
	selectedDebateTarget = nil,
	latestEvidenceSummary = nil,
}

local TOP_SAFE_Y = 88
local SIDE_MARGIN = 20

local function makeText(parent, name, size, position, textSize)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = size
	label.Position = position
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(245, 245, 245)
	label.TextSize = textSize
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextWrapped = true
	label.Text = ""
	label.Parent = parent
	return label
end

local function stylePanel(frame, color)
	frame.BackgroundColor3 = color
	frame.BackgroundTransparency = 0.08
	frame.BorderSizePixel = 0

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame
end

local function makeButton(parent, name, text, size, position)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = size
	button.Position = position
	button.BackgroundColor3 = Color3.fromRGB(255, 204, 64)
	button.BorderSizePixel = 0
	button.Font = Enum.Font.GothamBlack
	button.TextColor3 = Color3.fromRGB(24, 24, 24)
	button.TextSize = 14
	button.TextWrapped = true
	button.Text = text
	button.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = button

	return button
end

local function clearList(list)
	for _, item in ipairs(list) do
		item:Destroy()
	end
	table.clear(list)
end

function UIController:Init()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BrainrotCourtroomHud"
	gui.ResetOnSpawn = false
	gui.Parent = LOCAL_PLAYER:WaitForChild("PlayerGui")
	self.Gui = gui

	local hud = Instance.new("Frame")
	hud.Name = "Hud"
	hud.AnchorPoint = Vector2.new(1, 0)
	hud.Size = UDim2.new(0, 420, 0, 240)
	hud.Position = UDim2.new(1, -SIDE_MARGIN, 0, TOP_SAFE_Y)
	stylePanel(hud, Color3.fromRGB(30, 34, 42))
	hud.Parent = gui
	self.Hud = hud

	self.PhaseLabel = makeText(hud, "Phase", UDim2.new(1, -24, 0, 28), UDim2.new(0, 12, 0, 10), 20)
	self.TimerLabel = makeText(hud, "Timer", UDim2.new(1, -24, 0, 22), UDim2.new(0, 12, 0, 40), 16)
	self.RoleLabel = makeText(hud, "Role", UDim2.new(1, -24, 0, 48), UDim2.new(0, 12, 0, 66), 15)
	self.ObjectiveLabel =
		makeText(hud, "Objective", UDim2.new(1, -24, 0, 72), UDim2.new(0, 12, 0, 112), 14)

	local actionBar = Instance.new("Frame")
	actionBar.Name = "ActionBar"
	actionBar.AnchorPoint = Vector2.new(0.5, 1)
	actionBar.Size = UDim2.new(0, 180, 0, 52)
	actionBar.Position = UDim2.new(0.5, 0, 1, -28)
	actionBar.BackgroundTransparency = 1
	actionBar.Parent = gui
	self.ActionBar = actionBar

	self.ScanButton = makeButton(
		actionBar,
		"ScanButton",
		"Scan Clue",
		UDim2.new(1, 0, 1, 0),
		UDim2.new(0, 0, 0, 0)
	)
	self.ScanButton.Activated:Connect(function()
		if self.OnScan then
			self.OnScan()
		end
	end)
	self.ScanButton.Visible = false

	self.ToastLabel =
		makeText(hud, "Toast", UDim2.new(1, -160, 0, 34), UDim2.new(0, 150, 1, -46), 14)

	local evidence = Instance.new("Frame")
	evidence.Name = "Evidence"
	evidence.AnchorPoint = Vector2.new(1, 0)
	evidence.Size = UDim2.new(0, 420, 0, 340)
	evidence.Position = UDim2.new(1, -SIDE_MARGIN, 0, TOP_SAFE_Y + 252)
	stylePanel(evidence, Color3.fromRGB(37, 32, 46))
	evidence.Parent = gui
	self.EvidencePanel = evidence

	makeText(evidence, "Title", UDim2.new(1, -24, 0, 24), UDim2.new(0, 12, 0, 10), 18).Text =
		"Evidence"

	local debate = Instance.new("Frame")
	debate.Name = "Debate"
	debate.AnchorPoint = Vector2.new(0, 0)
	debate.Size = UDim2.new(0, 330, 0, 390)
	debate.Position = UDim2.new(0, SIDE_MARGIN, 0, TOP_SAFE_Y)
	stylePanel(debate, Color3.fromRGB(34, 44, 50))
	debate.Parent = gui
	self.DebatePanel = debate
	debate.Visible = false

	makeText(debate, "DebateTitle", UDim2.new(1, -24, 0, 24), UDim2.new(0, 12, 0, 10), 18).Text =
		"Debate"

	local debateTargets = Instance.new("ScrollingFrame")
	debateTargets.Name = "DebateTargets"
	debateTargets.Size = UDim2.new(1, -24, 0, 132)
	debateTargets.Position = UDim2.new(0, 12, 0, 42)
	debateTargets.BackgroundTransparency = 1
	debateTargets.BorderSizePixel = 0
	debateTargets.ScrollBarThickness = 6
	debateTargets.CanvasSize = UDim2.new()
	debateTargets.Parent = debate
	self.DebateTargets = debateTargets

	self.DebateLog =
		makeText(debate, "DebateLog", UDim2.new(1, -24, 0, 82), UDim2.new(0, 12, 1, -94), 12)

	local vote = Instance.new("Frame")
	vote.Name = "Vote"
	vote.AnchorPoint = Vector2.new(0.5, 0)
	vote.Size = UDim2.new(0, 320, 0, 390)
	vote.Position = UDim2.new(0.5, 0, 0, TOP_SAFE_Y)
	stylePanel(vote, Color3.fromRGB(42, 30, 30))
	vote.Parent = gui
	self.VotePanel = vote
	vote.Visible = false

	makeText(vote, "VoteTitle", UDim2.new(1, -24, 0, 24), UDim2.new(0, 12, 0, 10), 18).Text = "Vote"

	local voteList = Instance.new("ScrollingFrame")
	voteList.Name = "VoteList"
	voteList.Size = UDim2.new(1, -24, 0, 225)
	voteList.Position = UDim2.new(0, 12, 0, 42)
	voteList.BackgroundTransparency = 1
	voteList.BorderSizePixel = 0
	voteList.ScrollBarThickness = 6
	voteList.CanvasSize = UDim2.new()
	voteList.Parent = vote
	self.VoteList = voteList

	self.RecapLabel =
		makeText(vote, "Recap", UDim2.new(1, -24, 0, 96), UDim2.new(0, 12, 1, -110), 14)
end

function UIController:SetRole(role)
	if not role then
		self.RoleLabel.Text = "Role: Waiting"
		return
	end

	self.RoleLabel.Text = `Role: {role.name} ({role.alignment})\n{role.objective}`
	self:ShowToast(`Secret role assigned: {role.name}`)
end

function UIController:RenderSnapshot(snapshot)
	self.LastSnapshot = snapshot
	self.PhaseLabel.Text = `Phase: {snapshot.phase or "Lobby"}`
	self.TimerLabel.Text =
		`Time: {snapshot.timeRemaining or 0}s | Players: {snapshot.playerCount}/{snapshot.requiredPlayers}`

	local objective = "Waiting for enough players."
	if snapshot.incident then
		objective = `{snapshot.incident.title}: {snapshot.incident.objective}`
	end
	self.ObjectiveLabel.Text = objective

	self.ScanButton.Visible = snapshot.phase == "Investigation" and snapshot.hudScanEnabled == true
	self:RenderDebate(snapshot)
	self:RenderVote(snapshot)
	self:RenderReveal(snapshot)
end

function UIController:AddEvidence(record)
	if not record then
		return
	end

	table.insert(self.evidenceRecords, record)
	record.discoveredAt = os.date("%H:%M:%S")
	self.latestEvidenceSummary = `{record.type}: {record.text}`
	while #self.evidenceRecords > 4 do
		table.remove(self.evidenceRecords, 1)
	end

	self:RenderEvidence()
end

function UIController:RenderEvidence()
	clearList(self.evidenceRows)

	for index, record in ipairs(self.evidenceRecords) do
		local card = Instance.new("Frame")
		card.Name = `EvidenceCard{index}`
		card.Size = UDim2.new(1, -24, 0, 68)
		card.Position = UDim2.new(0, 12, 0, 40 + (index - 1) * 72)
		stylePanel(card, Color3.fromRGB(48, 43, 58))
		card.Parent = self.EvidencePanel

		local title = makeText(card, "Title", UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 6), 13)
		title.Text = `{record.type} | {record.reliabilityClass}`

		local meta = makeText(card, "Meta", UDim2.new(1, -20, 0, 18), UDim2.new(0, 10, 0, 24), 11)
		meta.Font = Enum.Font.Gotham
		meta.TextColor3 = Color3.fromRGB(205, 214, 225)
		meta.Text =
			`{record.stationName or record.sourceLocation or "Station"} | Suspect: {record.relatedPlayerName or "unclear"} | {record.discoveredAt or "--:--"}`

		local body = makeText(card, "Body", UDim2.new(1, -20, 0, 22), UDim2.new(0, 10, 0, 42), 11)
		body.Font = Enum.Font.Gotham
		body.Text = record.text or ""

		table.insert(self.evidenceRows, card)
	end
end

function UIController:RenderDebate(snapshot)
	clearList(self.debateButtons)
	clearList(self.debateActionButtons)

	local canDebate = snapshot.phase == "Debate"
	self.DebatePanel.Visible = canDebate

	if not canDebate then
		return
	end

	local players = snapshot.players or {}
	if not self.selectedDebateTarget and #players > 0 then
		self.selectedDebateTarget = players[1].userId
	end

	for index, playerInfo in ipairs(players) do
		local selected = self.selectedDebateTarget == playerInfo.userId
		local button = makeButton(
			self.DebateTargets,
			`DebateTarget{playerInfo.userId}`,
			selected and `> {playerInfo.displayName}` or playerInfo.displayName,
			UDim2.new(1, -8, 0, 28),
			UDim2.new(0, 0, 0, (index - 1) * 32)
		)
		button.BackgroundColor3 = selected and Color3.fromRGB(120, 255, 156)
			or Color3.fromRGB(255, 204, 64)
		button.Activated:Connect(function()
			self.selectedDebateTarget = playerInfo.userId
			self:RenderDebate(snapshot)
		end)
		table.insert(self.debateButtons, button)
	end
	self.DebateTargets.CanvasSize = UDim2.new(0, 0, 0, #players * 32)

	local actionY = 190
	local actions = { "Accuse", "Present Evidence", "Interrupt" }
	for index, action in ipairs(actions) do
		local button = makeButton(
			self.DebatePanel,
			`DebateAction{index}`,
			action,
			UDim2.new(1, -24, 0, 30),
			UDim2.new(0, 12, 0, actionY + (index - 1) * 34)
		)
		button.Activated:Connect(function()
			if self.OnDebateAction then
				self.OnDebateAction({
					action = action,
					targetUserId = self.selectedDebateTarget,
					evidenceSummary = self.latestEvidenceSummary,
				})
			end
		end)
		table.insert(self.debateActionButtons, button)
	end

	local lines = {}
	for _, event in ipairs(snapshot.debateActions or {}) do
		table.insert(lines, event.text)
	end
	self.DebateLog.Text = table.concat(lines, "\n")
end

function UIController:RenderVote(snapshot)
	clearList(self.voteButtons)

	local canVote = snapshot.phase == "Vote"
	self.VotePanel.Visible = canVote or snapshot.phase == "Reveal"

	if not canVote then
		return
	end

	for index, playerInfo in ipairs(snapshot.players or {}) do
		local button = makeButton(
			self.VoteList,
			`Vote{playerInfo.userId}`,
			playerInfo.displayName,
			UDim2.new(1, -8, 0, 34),
			UDim2.new(0, 0, 0, (index - 1) * 40)
		)

		button.Activated:Connect(function()
			if self.OnVote then
				self.OnVote(playerInfo.userId)
			end
		end)

		table.insert(self.voteButtons, button)
	end

	self.VoteList.CanvasSize = UDim2.new(0, 0, 0, #(snapshot.players or {}) * 40)
end

function UIController:RenderReveal(snapshot)
	if snapshot.phase ~= "Reveal" or not snapshot.verdict then
		self.RecapLabel.Text = ""
		return
	end

	local lines = {
		`Convicted: {snapshot.verdict.convictedName}`,
		`Winner: {snapshot.verdict.winningSide}`,
		snapshot.verdict.reason,
	}

	for _, reveal in ipairs(snapshot.roleReveal or {}) do
		table.insert(lines, `{reveal.displayName}: {reveal.role}`)
	end

	self.RecapLabel.Text = table.concat(lines, "\n")
end

function UIController:ShowToast(message)
	self.ToastLabel.Text = message or ""
end

return UIController
