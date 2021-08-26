#include <sourcemod>
#include <sdktools>
#include <morecolors>
//#pragma semicolon 1

public Plugin myinfo =
{
    name = "Dynamic frag limit",
    author = "barcode scanner#6775",
    description = "Changes frag limit based on player count and set settings. Check this plugins convars",
    version = "1.5.1",
    url = "none" // 
};
static int playersActual = 0;
int playersB = 0;
//int playerBuffer = 0; // for future feature (maybe, i forgot what i was going to need it for tbh)
ConVar maxfrags = null;
ConVar PluginEnabled = null;
ConVar Fragmultiplyer = null;
//ConVar tv_on = null; //removed but left in incase i fuck shit up and need it back
ConVar PlayerCap = null;
ConVar OldFrags;
ConVar SecondstoDisable = null;
int tick = 0;
int second = 0;
ConVar DFmessages;
int spectators = 0;
char playername[64];
char playername2[64];
int spectatorsold = 0;

public void OnPluginStart()
{
 	OldFrags = FindConVar("mp_fraglimit");
 	maxfrags = FindConVar("mp_fraglimit");
 	PluginEnabled = CreateConVar("sm_dynamicfrags_enabled", "1", "(0/1) Turns dynamic frag limit on or off");
 	Fragmultiplyer = CreateConVar("sm_dynamicfrags_multiplyer", "3", "( >= 1) How much to add to the frag limit per player (players * this value)");
 	//tv_on = CreateConVar("sm_dynamicfrags_tv_on", "0", "(0/1) only exists because i couldnt get it to work of reading tv_enabled. turn on if you are using Sourcetv");
 	PlayerCap = CreateConVar("sm_dynamicfrags_playercap","8","( >= 1, 0 to disable this feature) Stop adding frags when more tham the set ammount of players join");
 	DFmessages = CreateConVar("sm_dynamicfrags_messages", "1","(0/1) Toggles messages in chat from this plugin");
 	SecondstoDisable = CreateConVar("sm_dynamicfrags_timecutoff", "500", "( >= 1, set to 0 to disable) Stop adding to frag limit after this ammount of time in seconds, Doesnt account for the Wainting for players time");
	//HookEvent("player_team", Event_TeamChange)
}

public void OnClientAuthorized(int client)
{
    playersActual++;
    if (PluginEnabled.IntValue == 1)
    {
           
      if (second <= SecondstoDisable.IntValue)
      {
      	playersB = playersActual;
      	if (DFmessages.IntValue == 1)
      	{
      		if (playersB <= PlayerCap.IntValue)
      		{
      			GetClientName(client, playername, sizeof(playername));
      			CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Joined. {green}Added %i {olive}to frags needed to win", playername, Fragmultiplyer.IntValue);
      		}
      		else if(PlayerCap.IntValue == 0)
      		{
      			GetClientName(client, playername, sizeof(playername));
      			CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Joined. {green}Added %i {olive}to frags needed to win", playername, Fragmultiplyer.IntValue); 
      		}
    	 }
      else if(SecondstoDisable.IntValue == 0)
      {
      	playersB = playersActual;
      	if (DFmessages.IntValue == 1)
      	{
      		if (playersB <= PlayerCap.IntValue)
      		{
      			GetClientName(client, playername, sizeof(playername));
      			CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Joined. {green}Added %i {olive}to frags needed to win", playername, Fragmultiplyer.IntValue);
      		}
      		else if(PlayerCap.IntValue == 0)
      		{
      			GetClientName(client, playername, sizeof(playername))
      			CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Joined. {green}Added %i {olive}to frags needed to win", playername, Fragmultiplyer.IntValue);
      		}
      	}
       }
    }

 }
}
public void OnClientDisconnect(int client)
	{
	   playersActual--;
	   if (PluginEnabled.IntValue == 1)
    	{
			
 			if (second <= SecondstoDisable.IntValue)
 			{
 				playersB = playersActual;
 				if (DFmessages.IntValue == 1)
 				{
 					if (playersB < PlayerCap.IntValue)
 					{
 						GetClientName(client, playername, sizeof(playername));
 						CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Left. {red}Removed  %i {olive}from frags needed to win", playername, Fragmultiplyer.IntValue);
 					}
 					else if (PlayerCap.IntValue == 0)
 					{
 						GetClientName(client, playername, sizeof(playername));
 						CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Left. {red}Removed  %i {olive}from frags needed to win", playername, Fragmultiplyer.IntValue);					
 					}
 				}
 			}
 			else if(SecondstoDisable.IntValue == 0)
 			{
 				playersB = playersActual; 
 				if (DFmessages.IntValue == 1)
 				{
 					if (playersB < PlayerCap.IntValue)
 					{
 						GetClientName(client, playername, sizeof(playername));
 						CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Left. {red}Removed  %i {olive}from frags needed to win", playername, Fragmultiplyer.IntValue);
 					}
 					else if(PlayerCap.IntValue == 0)
 					{ 
 						GetClientName(client, playername, sizeof(playername));
 						CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Left. {red}Removed  %i {olive}from frags needed to win", playername, Fragmultiplyer.IntValue);					
 					}
 				}
 			}
  
    }
}// find player count and send indicative messages if enabled

public void OnGameFrame()
{
	++tick;
	if (tick >= 67)
	{
		tick = 0;
		second++;
	}
	
	
		
	if (PluginEnabled.IntValue > 1)
	{
		PluginEnabled.IntValue = 1;
	}
	if (PluginEnabled.IntValue < 0)
	{
		PluginEnabled.IntValue = 0;
	} // sets the enabled convar to a 'valid' value
	

	if (PluginEnabled.IntValue == 1)
		{
			int newfraglimit = maxfrags.IntValue;
			if (playersB <= PlayerCap.IntValue)
			{
				newfraglimit = playersB * Fragmultiplyer.IntValue;
				/*if (tv_on.IntValue >= 1)
				{
					newfraglimit = newfraglimit - Fragmultiplyer.IntValue;
				};  */// unneeded with spectator removal, left in incase i mess shit up
				if (second <= SecondstoDisable.IntValue)
				{
					spectators = GetTeamClientCount(1);
				}
				else if (SecondstoDisable.IntValue == 0)
				{
					spectators = GetTeamClientCount(1);
				}
				if (DFmessages.IntValue == 1)
				{
					spectatorCompareMessage(spectators, spectatorsold)
				}
				spectatorsold = spectators
				newfraglimit = newfraglimit - (Fragmultiplyer.IntValue * spectators);
			}
			if (playersB > PlayerCap.IntValue)
			{
				newfraglimit = OldFrags.IntValue;
			}

			maxfrags.IntValue = newfraglimit;
		}
}

public void OnMapStart()
{
	tick = 0;
	second = 0;
}
public void OnMapEnd()
{
	tick = 0;
	second = 0;
} //reset time keeping

//catch whos chaging to spectator
//Action Event_TeamChange(Event event, int client, int newteamid, int oldteamid)

//events are the bane of my existance, removing this part. feel free to fix it and send it back
/*
Action Event_TeamChange(Event event, const char[] name, bool dontBroadcast)
{
	int userid = event.GetInt("userid")
	int newteamid = event.GetInt("team")
	int oldteamid = event.GetInt("oldteam")
	

	
	if (DFmessages.IntValue == 1)
	{
		if (second <= SecondstoDisable.IntValue)
		{
			spectatormessage(userid, newteamid, oldteamid);
			return Plugin_Handled;		
		}
		
		if (SecondstoDisable.IntValue == 0)
		{
			spectatormessage(userid, newteamid, oldteamid);
			return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}
	// the reason i handle it like this and not like i do player counting
	//is because i already handle counting spectators per game frame and its already able to be dynamicly stopped



void spectatormessage(int userid2, int nteamid, int oteamid)
{
	GetClientName(userid2, playername2, sizeof(playername2));
	if (nteamid == 1)
	{
		CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} s Became a spectator. {red}Removed  %i {olive}from frags needed to win", playername2, Fragmultiplyer.IntValue);
		
	}
		
	if (oteamid == 1)
	{	
		CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} s is no longer a spectator. {green}Added %i {olive}to frags needed to win", playername2, Fragmultiplyer.IntValue);
		
	}
	
}
*/ 
void spectatorCompareMessage(int spec, int specold)
{
	
	if (spec > specold)
	{
		CPrintToChatAll("{gold}[SM Dynamic Frags] {olive}A player became a spectator. {red}Removed  %i {olive}from frags needed to win", Fragmultiplyer.IntValue);
		
	}
		
	if (spec < specold)
	{	
		CPrintToChatAll("{gold}[SM Dynamic Frags] {olive}A player is no longer a spectator. {green}Added %i {olive}to frags needed to win", Fragmultiplyer.IntValue);
		
	}
	
}