#include <sourcemod>
#include <sdktools>
#include <morecolors>

public Plugin myinfo =
{
    name = "Dynamic frag limit",
    author = "barcodescanner#6775",
    description = "Changes frag limit based on player count and set settings. Check this plugins convars",
    version = "1.3.2",
    url = "none" // 
}
static int players = 0;
ConVar maxfrags;
ConVar PluginEnabled = null;
ConVar Fragmultiplyer = null;
ConVar tv_on = null;
ConVar PlayerCap = null;
ConVar OldFrags;
ConVar SecondstoDisable =null;
int tick = 0
int second = 0
int SecondstoDisableB = 0;

public void OnPluginStart()
{
 	OldFrags = FindConVar("mp_fraglimit")
 	maxfrags = FindConVar("mp_fraglimit");
 	PluginEnabled = CreateConVar("sm_dynamicfrags_enabled", "1", "(0/1) turns dynamic frag limit on or off");
 	Fragmultiplyer = CreateConVar("sm_dynamicfrags_multiplyer", "3", "( >= 1) how much to add to the frag limit per player (players * this value)");
 	tv_on = CreateConVar("sm_dynamicfrags_tv_on", "0", "(0/1) only exists because i couldnt get it to work of reading tv_enabled. turn on if you are using Sourcetv")
 	PlayerCap = CreateConVar("sm_dynamicfrags_playercap","8","( >= 1) stop adding frags when more tham the set ammount of players join")
 	SecondstoDisable = CreateConVar("dm_dynamic_frags_timecutoff", "300", "( >= 1, 0 to disable)Stop adding to frag limit after this ammount of time in seconds")
}

public void OnClientConnected(int client)
{
    if (PluginEnabled.IntValue == 1)
    {
       if (second >= SecondstoDisableB)
       {
       	players++
       	CPrintToChatAll("{gold}[SM Dynamic Frags] {green}Added %i {olive}to frags needed to win", Fragmultiplyer.IntValue)
       }
    }
}
public void OnClientDisconnect(int client)
{
    players--
    if (PluginEnabled.IntValue == 1)
    {
    	 if (second >= SecondstoDisableB)
    	 {
    	 	players--
  	   	    CPrintToChatAll("{gold}[SM Dynamic Frags] {red}Removed  %i {olive}from frags needed to win", Fragmultiplyer.IntValue)
  	     }   
    }
}// find player count

public void OnGameFrame()
{
	++tick
	if (tick >= 67)
	{
		tick = 0
		second++
	}
	
	if (PluginEnabled.IntValue > 1)
	{
		PluginEnabled.IntValue = 1
	}
	if (PluginEnabled.IntValue < 0)
	{
		PluginEnabled.IntValue = 0
	} // sets the enabled convar to a 'valid' value
	
	if (SecondstoDisable.IntValue == 0)
	{
		SecondstoDisableB = 999999999999999999
	}
	else
	{
		SecondstoDisableB = SecondstoDisable.IntValue
	}
		if (PluginEnabled.IntValue == 1)
		{
			int newfraglimit = maxfrags.IntValue
			if (players <= PlayerCap.IntValue)
			{
				newfraglimit = players * Fragmultiplyer.IntValue
				if (tv_on.IntValue >= 1)
				{
					newfraglimit = newfraglimit - Fragmultiplyer.IntValue
				}
			}
			if (players > PlayerCap.IntValue)
			{
				newfraglimit = OldFrags.IntValue
			}

			maxfrags.IntValue = newfraglimit
		}
}