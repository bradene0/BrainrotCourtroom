# BrainrotCourtroom

Roblox social deception prototype based on `Brainrot_Courtroom_SRS.txt`.

## Current Slice

- Rojo project scaffold
- Generated graybox map with lobby, investigation rooms, suspicious room, and courtroom
- Server-authoritative round phases
- Hidden role assignment
- Random incident selection
- Six prototype evidence templates tied to physical clue stations
- Saboteur console and forger printer role actions
- Courtroom teleport for debate, vote, and reveal
- Deterministic vote resolution
- Placeholder round rewards through leaderstats
- Client HUD for role, phase, evidence scan, voting, and reveal
- Studio dev commands for faster round testing

## Run

1. Install/launch Rojo.
2. Run `rojo serve default.project.json`.
3. Open Roblox Studio and connect Rojo plugin.
4. Press Play.

Studio uses one-player minimum for quick local testing. Live config target remains four-player minimum.

## Test Notes

- During `Investigation`, walk to colored stations and press `E` to inspect clues.
- `Sabotage Console` works only for saboteur during incident/investigation.
- `Forgery Printer` works only for forger during investigation.
- Players teleport to courtroom when debate starts.
- Studio chat commands:
  - `/bc fast` uses short phase timers.
  - `/bc normal` restores default timers.
  - `/bc next` jumps current phase.
