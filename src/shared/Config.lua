local Config = {}

Config.MIN_PLAYERS = 4
Config.STUDIO_MIN_PLAYERS = 1
Config.MAX_PLAYERS = 14

Config.Phases = {
	Lobby = "Lobby",
	RoleAssignment = "RoleAssignment",
	Incident = "Incident",
	Investigation = "Investigation",
	Debate = "Debate",
	Vote = "Vote",
	Reveal = "Reveal",
}

Config.PhaseDurations = {
	[Config.Phases.RoleAssignment] = 6,
	[Config.Phases.Incident] = 8,
	[Config.Phases.Investigation] = 45,
	[Config.Phases.Debate] = 35,
	[Config.Phases.Vote] = 18,
	[Config.Phases.Reveal] = 10,
}

Config.FastPhaseDurations = {
	[Config.Phases.RoleAssignment] = 2,
	[Config.Phases.Incident] = 3,
	[Config.Phases.Investigation] = 8,
	[Config.Phases.Debate] = 6,
	[Config.Phases.Vote] = 6,
	[Config.Phases.Reveal] = 5,
}

Config.Dev = {
	commandPrefix = "/bc",
	defaultPace = "normal",
	showHudScanFallback = false,
}

Config.Roles = {
	Civilian = {
		id = "civilian",
		name = "Civilian",
		alignment = "Civilian",
		objective = "Find evidence, accuse saboteur, vote correctly.",
	},
	Saboteur = {
		id = "saboteur",
		name = "Saboteur",
		alignment = "Saboteur",
		objective = "Cause chaos, dodge blame, survive vote.",
	},
	Witness = {
		id = "witness",
		name = "Witness",
		alignment = "Civilian",
		objective = "Use partial clue wisely. It may not tell full story.",
	},
	Forger = {
		id = "forger",
		name = "Forger",
		alignment = "Saboteur",
		objective = "Plant doubt with one fake clue, protect saboteur side.",
	},
}

Config.Alignment = {
	Civilian = "Civilian",
	Saboteur = "Saboteur",
}

return Config
