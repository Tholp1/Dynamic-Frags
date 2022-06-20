# Dynamic Frags
A SourceMod plugin that dynamically adds and removes from mp_fraglimit based on player count with many customizations.

## CVARS:  
Cvar (possible states) [default state] description

* sm_dynamicfrags_basefrags (int >= 0) [0]  
How high the frag limit is before any players join.  
Negative numbers will subtract from limit.

* sm_dynamicfrags_enabled (0/1) [1]  
Enables the plugin.

* sm_dynamicfrags_multiplier (int > 0) [3]  
How much frags are we adding after player joins the game.

* sm_dynamicfrags_messages (0/1) [1]  
Enable the chat messages from this plugin.

* sm_dynamicfrags_playercap (int > 0) [8]  
Frags are added to frag limit until players reach player cap.

* sm_dynamicfrags_timecutoff (int > 1) [500]  
Frags aren't added to frag limit if the time of current gameplay passes 500 (default value) seconds.
