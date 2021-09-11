#include <sourcemod>
#include <sdktools>
#include <morecolors>
//#pragma semicolon 1

public Plugin myinfo =
{
    name = "Dynamic frag limit",
    author = "barcode scanner#6775",
    description = "Changes frag limit based on player count and set settings. Check this plugins convars",
    version = "1.6.5",
    url = "none" // 
};
static int playersActual = 0;
int playersB = 0;
//int playerBuffer = 0; // for future feature (maybe, i forgot what i was going to need it for tbh)
ConVar maxfrags = null;
ConVar PluginEnabled = null;
ConVar Fragmultiplyer = null;
ConVar PlayerCap = null;
ConVar SecondstoDisable = null;
int tick = 0;
int second = 0;
ConVar DFmessages;
int spectators = 0;
char playername[64];
//char playername2[64];
int spectatorsold = 0;

public void OnPluginStart()
{	
 	maxfrags = FindConVar("mp_fraglimit");
 	PluginEnabled = CreateConVar("sm_dynamicfrags_enabled", "1", "(0/1) Turns dynamic frag limit on or off", FCVAR_NOTIFY);
 	Fragmultiplyer = CreateConVar("sm_dynamicfrags_multiplyer", "3", "( >= 1) How much to add to the frag limit per player (players * this value)", FCVAR_NOTIFY);
 	PlayerCap = CreateConVar("sm_dynamicfrags_playercap","8","( >= 1, 0 to disable this feature) Stop adding frags when more tham the set ammount of players join", FCVAR_NOTIFY);
 	DFmessages = CreateConVar("sm_dynamicfrags_messages", "1","(0/1) Toggles messages in chat from this plugin", FCVAR_NOTIFY);
 	SecondstoDisable = CreateConVar("sm_dynamicfrags_timecutoff", "500", "( >= 1, set to 0 to disable) Stop adding to frag limit after this ammount of time in seconds, Doesnt account for the Wainting for players time", FCVAR_NOTIFY);
	//HookEvent("player_team", Event_TeamChange)
	HookEvent("round_start",Event_RoundStart,EventHookMode_PostNoCopy)
}

public void OnClientAuthorized(int client)
{
    playersActual++;
    if (PluginEnabled.IntValue == 1)
    {
           
      if (second <= SecondstoDisable.IntValue || SecondstoDisable.IntValue == 0)
      {
      	playersB = playersActual;
      	if (DFmessages.IntValue == 1)
      	{
      		if (playersB <= PlayerCap.IntValue || PlayerCap.IntValue == 0)
      		{
      			GetClientName(client, playername, sizeof(playername));
      			CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Joined. {green}Added %i {olive}to frags needed to win", playername, Fragmultiplyer.IntValue);
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
			if (second >= 15)
			{
				

 				if (second <= SecondstoDisable.IntValue)
 				{
 					playersB = playersActual;
 					if (DFmessages.IntValue == 1 || SecondstoDisable.IntValue == 0)
 					{
 						if (playersB < PlayerCap.IntValue || PlayerCap.IntValue == 0)
 						{
 							GetClientName(client, playername, sizeof(playername));
 							CPrintToChatAll("{gold}[SM Dynamic Frags] {olive} %s Left. {red}Removed  %i {olive}from frags needed to win", playername, Fragmultiplyer.IntValue);
 						}
 					}
 				}
 			}
  
    }
}// find player count and send indicative messages if enabled

public void OnGameFrame()
{
	tick++;
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
				if (second <= SecondstoDisable.IntValue || SecondstoDisable.IntValue == 0)
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
				newfraglimit = PlayerCap.IntValue * Fragmultiplyer.IntValue;
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
}//reset time keeping on map change 

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
 	tick = 0
 	second = 0
} // reset time on round start





//catch WHO is chaging to spectator
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
