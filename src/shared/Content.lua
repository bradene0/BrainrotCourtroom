local Content = {}

Content.Incidents = {
	{
		id = "screaming_head",
		title = "Giant Screaming Head",
		summary = "A giant screaming head fell through ceiling and blamed everyone.",
		objective = "Find who called it down.",
	},
	{
		id = "confetti_inferno",
		title = "Confetti Inferno",
		summary = "Lunch room exploded into confetti, sparks, and fake apology notes.",
		objective = "Trace who rigged lunch room.",
	},
	{
		id = "cursed_vault",
		title = "Cursed Vault Spill",
		summary = "Vault opened and cursed props rolled across map.",
		objective = "Identify who opened vault.",
	},
	{
		id = "evidence_printer",
		title = "Evidence Printer Meltdown",
		summary = "Printer spawned nonsense reports and one suspicious truth.",
		objective = "Separate useful clue from fake paperwork.",
	},
	{
		id = "lights_out",
		title = "Ten Second Darkness",
		summary = "Lights cut out. When they returned, disaster had already happened.",
		objective = "Use traces, logs, and witnesses to accuse.",
	},
}

Content.EvidenceTemplates = {
	{
		id = "camera_snapshot",
		type = "Camera Snapshot",
		reliabilityClass = "Reliable",
		canForge = false,
		stationId = "camera_terminal",
	},
	{
		id = "item_trace",
		type = "Item Trace",
		reliabilityClass = "Reliable",
		canForge = false,
		stationId = "trace_locker",
	},
	{
		id = "access_log",
		type = "Room Access Log",
		reliabilityClass = "Reliable",
		canForge = false,
		stationId = "access_panel",
	},
	{
		id = "witness_mumble",
		type = "Witness Statement",
		reliabilityClass = "Ambiguous",
		canForge = false,
		stationId = "witness_marker",
	},
	{
		id = "audio_fragment",
		type = "Audio Fragment",
		reliabilityClass = "Ambiguous",
		canForge = false,
		stationId = "audio_console",
	},
	{
		id = "fake_report",
		type = "Fake Document",
		reliabilityClass = "Forgable",
		canForge = true,
		stationId = "evidence_printer",
	},
}

Content.ClueStations = {
	{
		id = "camera_terminal",
		name = "Camera Terminal",
		room = "Security Closet",
	},
	{
		id = "trace_locker",
		name = "Trace Locker",
		room = "Evidence Lab",
	},
	{
		id = "access_panel",
		name = "Access Log Panel",
		room = "Records Office",
	},
	{
		id = "witness_marker",
		name = "Witness Marker",
		room = "Witness Corner",
	},
	{
		id = "audio_console",
		name = "Audio Console",
		room = "Sound Booth",
	},
	{
		id = "evidence_printer",
		name = "Evidence Printer",
		room = "Evidence Lab",
	},
}

Content.Cosmetics = {
	"Public Defender Wig",
	"Cardboard Gavel",
	"Objection Foam Finger",
	"Evidence Cone Hat",
	"Budget Bailiff Badge",
}

return Content
