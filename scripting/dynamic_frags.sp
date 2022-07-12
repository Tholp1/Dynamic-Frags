#include <morecolors>
#include <sdktools>
#include <sourcemod>
//#include <openfortress>
#pragma semicolon 1

public Plugin myinfo =
{
	name        = "Dynamic frag limit",
	author      = "Discord: tholp#6775",
	description = "Changes frag limit based on player count and set settings. Check this plugins convars",
	version     = "2.1.0",
	url         = "none"    //
};

static int playersActual = 0;
int        playersB      = 0;

ConVar MaxFrags         = null;
ConVar PluginEnabled    = null;
ConVar FragMultiplier   = null;
ConVar PlayerCap        = null;
ConVar SecondstoDisable = null;
ConVar BaseFrags        = null;
ConVar DFmessages;

int    spectators = 0;
char   playername[64];
int    spectatorsold   = 0;
bool   ModifyFragLimit = true;
Handle DisableTimer    = null;

public void OnPluginStart()
{
	LoadTranslations("dynamic_frags.phrases");

	MaxFrags         = FindConVar("mp_fraglimit");
	PluginEnabled    = CreateConVar("sm_dynamicfrags_enabled", "1", "(0/1) Turns dynamic frag limit on or off", FCVAR_NOTIFY);
	FragMultiplier   = CreateConVar("sm_dynamicfrags_multiplier", "3", "( >= 1) How much to add to the frag limit per player (players * this value)", FCVAR_NOTIFY);
	BaseFrags        = CreateConVar("sm_dynamicfrags_basefrags", "0", "(any int) How high the frag limit is before any players join. Negative numbers will subtract from limit", FCVAR_NOTIFY);
	PlayerCap        = CreateConVar("sm_dynamicfrags_playercap", "8", "( >= 1, 0 to disable this feature) Stop adding frags when more tham the set ammount of players join", FCVAR_NOTIFY);
	DFmessages       = CreateConVar("sm_dynamicfrags_messages", "1", "(0/1) Toggles messages in chat from this plugin", FCVAR_NOTIFY);
	SecondstoDisable = CreateConVar("sm_dynamicfrags_timecutoff", "180", "( any float >= 1, set to 0 to disable) Stop adding to frag limit after this ammount of time in seconds, Doesnt account for the Waiting for players time", FCVAR_NOTIFY);

	HookEvent("player_team", Event_TeamChange);
	HookEvent("teamplay_round_start", Event_RoundStart, EventHookMode_PostNoCopy);

	if (SecondstoDisable.FloatValue < 0)
	{
		SecondstoDisable.FloatValue = -SecondstoDisable.FloatValue;
	}
	if (SecondstoDisable.FloatValue > 0)
	{
		DisableTimer = CreateTimer(SecondstoDisable.FloatValue, DisableFraglimitModify, _);
	}

	AutoExecConfig(true, "dynamic_frags");
	MaxFrags.IntValue = BaseFrags.IntValue;
}

public Action DisableFraglimitModify(Handle timer)
{
	ModifyFragLimit = false;
	DisableTimer    = null;
	if (!DFmessages.BoolValue) { return; }

	int seconds = SecondstoDisable.IntValue % 60;
	int minutes = (SecondstoDisable.IntValue - seconds) / 60;

	CPrintToChatAll("%t", "DisableFraglimitModify", minutes, seconds);
}

public void Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
	ModifyFragLimit = true;
	if (DisableTimer != null)
	{
		KillTimer(DisableTimer);
		DisableTimer = null;
	}
	if (SecondstoDisable.FloatValue > 0)
	{
		DisableTimer = CreateTimer(SecondstoDisable.FloatValue, DisableFraglimitModify, _);
	}
	playersB = playersActual;    // make sure to update limit

}    // reset timer on round start
public void Event_TeamChange(Event event, const char[] name, bool dontBroadcast)
{
	if (playersActual - GetTeamClientCount(1) == 1)    // reset time if the player joining is joining when the server is empty
	{
		if (DisableTimer != null)
		{
			KillTimer(DisableTimer);
		}
		ModifyFragLimit = true;
		if (SecondstoDisable.FloatValue > 0)
		{
			DisableTimer = CreateTimer(SecondstoDisable.FloatValue, DisableFraglimitModify, _);
		}
	}
}

public void OnClientAuthorized(int client)
{
	playersActual++;
	if (!PluginEnabled.BoolValue)
	{
		return;
	}

	if (ModifyFragLimit)
	{
		playersB = playersActual;
		if (DFmessages.BoolValue)
		{
			if (playersB <= PlayerCap.IntValue || PlayerCap.IntValue == 0)
			{
				GetClientName(client, playername, sizeof(playername));
				CPrintToChatAll("%t", "ClientAuthorized", playername, FragMultiplier.IntValue);
			}
		}
	}

	if (playersActual - GetTeamClientCount(1) == 1)    // reset time if the player joining is joining when the server is empty
	{
		if (DisableTimer != null)
		{
			KillTimer(DisableTimer);
			ModifyFragLimit = true;
			DisableTimer    = CreateTimer(SecondstoDisable.FloatValue, DisableFraglimitModify, _);
		}
	}
}

public void OnClientDisconnect(int client)
{
	playersActual--;
	if (PluginEnabled.BoolValue)
	{
		if (ModifyFragLimit)
		{
			playersB = playersActual;
			if (DFmessages.BoolValue)
			{
				if (playersB < PlayerCap.IntValue || PlayerCap.IntValue == 0)
				{
					GetClientName(client, playername, sizeof(playername));
					CPrintToChatAll("%t", "ClientDisconnected", playername, FragMultiplier.IntValue);
				}
			}
		}
	}
}    // find player count and send indicative messages if enabled

void spectatorCompareMessage(int spec, int specold)
{
	if (spec > specold)
	{
		CPrintToChatAll("%t", "BecameSpectator", FragMultiplier.IntValue);
	}

	if (spec < specold)
	{
		CPrintToChatAll("%t", "BecamePlayer", FragMultiplier.IntValue);
	}
}

public void OnGameFrame()
{
	if (PluginEnabled.BoolValue && ModifyFragLimit)
	{
		int newfraglimit = MaxFrags.IntValue;
		if (playersB <= PlayerCap.IntValue)
		{
			newfraglimit = playersB * FragMultiplier.IntValue;
			spectators   = GetTeamClientCount(1);

			if (DFmessages.BoolValue)
			{
				spectatorCompareMessage(spectators, spectatorsold);
			}

			spectatorsold = spectators;
			newfraglimit  = newfraglimit - (FragMultiplier.IntValue * spectators);
		}

		if (playersB > PlayerCap.IntValue)
		{
			newfraglimit = PlayerCap.IntValue * FragMultiplier.IntValue;
		}

		MaxFrags.IntValue = newfraglimit + BaseFrags.IntValue;
	}
}
