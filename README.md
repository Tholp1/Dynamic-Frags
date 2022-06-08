# Dynamic-Frags
A sourcemod plugin that dynamically adds and removes from mp_fraglimit based on player count with many customizations 

CVARS:
Cvar (possible states) [default state] description

*sm_dynamicfrags_enabled (0/1) [1] enables the plugin

*sm_dynamicfrags_multiplyer (>0) [3] how much to add to the frag limit per player

*sm_dynamicfrags_messages (0/1) [1] enables the messages in chat from this plugin

*sm_dynamicfrags_playercap (>0) [8] any players that join after this ammount already have wont affect the frag limit

*sm_dynamicfrags_timecutoff (>1) [500] stops adding or removing to the limit after this amount of time in seconds has passed, set this to 0 to have it change regardless.
