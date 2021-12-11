# Dynamic-Frags
A sourcemod (https://github.com/Scags/Open-Fortress-Tools) plugin for Open Fortress that dynamically adds and removes from mp_fraglimit based on player count with many customizations 

License shit blah blah, just dont steal and claim as your own.

Plugin has an optional requirement for morecolors.inc which can be found here: https://forums.alliedmods.net/showthread.php?t=185016
only needed to show text in chat


CVARS:
Cvar (possible states) [default state] description

*sm_dynamicfrags_enabled (0/1) [1] enables the plugin

*sm_dynamicfrags_multiplyer (>0) [3] how much to add to the frag limit per player

*sm_dynamicfrags_messages (0/1) [1] enables the messages in chat from this plugin

*sm_dynamicfrags_playercap (>0) [8] any players that join after this ammount already have wont affect the frag limit

*sm_dynamicfrags_timecutoff (>1) [500] stops adding or removing to the limit after this amount of time in seconds has passed, set this to 0 to have it change regardless.
