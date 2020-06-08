// Based off Better Squad Icon Selector by Robojumper.

class UISquadIconSelectionScreen_ForControllers extends UIScreen config(SquadSettings);

// Screen reference needed for callbacks.
var UIPersonnel_SquadBarracks_ForControllers BelowScreen;

var config int ScreenW, ScreenH;

var UIPanel MainPanel;
var UIX2PanelHeader ScreenHeader;
var UIBGBox ScreenBG;

var UIImageSelector_LW ImageSelector;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local float XLoc, YLoc;
	local float WidthVal, HeightVal;

	super.InitScreen(InitController, InitMovie, InitName);

	XLoc = (1920 - ScreenW) / 2;
	YLoc = (1080 - ScreenH) / 2;
	WidthVal = ScreenW;
	HeightVal = ScreenH;

	MainPanel = Spawn(class'UIPanel', self);
	MainPanel.InitPanel('');
	MainPanel.SetPosition(XLoc, YLoc);
	MainPanel.SetSize(WidthVal, HeightVal);

	ScreenBG = Spawn(class'UIBGBox', MainPanel);
	ScreenBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	ScreenBG.InitBG('', 0, 0, MainPanel.Width, MainPanel.Height);
	
	ScreenHeader = Spawn(class'UIX2PanelHeader', MainPanel);
	ScreenHeader.bIsNavigable = false;
	ScreenHeader.InitPanelHeader('', "Select Squad Image", "");
	ScreenHeader.SetHeaderWidth(MainPanel.width - 20);
	ScreenHeader.SetPosition(10, 20);

	ImageSelector = Spawn(class'UIImageSelector_LW', MainPanel);
	ImageSelector.InitImageSelector(, 0, 70, MainPanel.Width - 10, MainPanel.height - 80, 
		BelowScreen.SquadImagePaths, , SetSquadImage, 
		BelowScreen.SquadImagePaths.Find(BelowScreen.GetCurrentSquad().SquadImagePath));
}

function SetSquadImage(int ImageIndex)
{
	local XComGameState NewGameState;
	local XComGameState_LWPersistentSquad CurrentSquadState;

	CurrentSquadState = BelowScreen.GetCurrentSquad();

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Change Squad ImagePath");
	CurrentSquadState = XComGameState_LWPersistentSquad(NewGameState.CreateStateObject(class'XComGameState_LWPersistentSquad', CurrentSquadState.ObjectID));
	CurrentSquadState.SquadImagePath = BelowScreen.SquadImagePaths[ImageIndex];
	NewGameState.AddStateObject(CurrentSquadState);
	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	BelowScreen.UpdateListUI(true);
	
	OnCancel();
}

/* LW2
simulated function OnReceiveFocus()
{
	//local Object ThisObj;
	local XComGameState UpdateState;
	local XComGameState_HeadquartersXCom XComHQ;

	//this is for handling receiving focus back from UISquadSelect
	//ThisObj = self;
	//`XEVENTMGR.UnRegisterFromEvent(ThisObj, 'PostSquadSelectInit');

	//restore previous squad to squad select, if there was one
	if(bRestoreCachedSquad)
	{
		UpdateState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Restore previous soldiers to XComHQ Squad");
		XComHQ = XComGameState_HeadquartersXCom(UpdateState.CreateStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
		XComHQ.Squad = CachedSquad;
		UpdateState.AddStateObject(XComHQ);
		`GAMERULES.SubmitGameState(UpdateState);

		bRestoreCachedSquad = false;
		CachedSquad.Length = 0;
	}
	`LWTRACE("OnReceiveFocus: CurrentSquadSelect=" $ CurrentSquadSelection);
	RefreshAllData();

	super(UIScreen).OnReceiveFocus();
}
*/

/* CONTROLLERIZED
simulated function OnReceiveFocus()
{
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState UpdateState;
	
	// LWS : Restore previous squad after viewing them
	if (bRestoreCachedSquad)
	{
		UpdateState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Restore previous soldiers to XComHQ Squad");
		XComHQ = XComGameState_HeadquartersXCom(UpdateState.CreateStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
		XComHQ.Squad = CachedSquad;
		UpdateState.AddStateObject(XComHQ);
		`GAMERULES.SubmitGameState(UpdateState);

		bRestoreCachedSquad = false;
		CachedSquad.Length = 0;

		ReloadCurrentSquad();		// KDM : Reload current squads info
	}
	
	// KDM : When we receive focus from :
	// 1] Squad deletion 2] Squad name change 3] Squad bio change 4] Squad icon change
	// ReloadCurrentSquad is called in the appropriate callback functions

	UpdateNavHelp();

	super(UIScreen).OnReceiveFocus();
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();
	
	// KDM : Within UIPersonnel, list selection is set in :
	// 1] RefreshData --> UpdateList if SelectedIndexOnFocusLost is -1
	// 2] OnReceieveFocus if SelectedIndexOnFocusLost is 0 or above
	// This list selection change starts up my cached loading of soldiers.
	// Within SquadBarracks I always reset everything when I receive focus and am not making
	// use of SelectedIndexOnFocusLost in OnReceiveFocus; therefore, just unset it here 
	// (after it is set in super)
	SelectedIndexOnFocusLost = -1;				
}
*/

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	bHandled = true;
	
	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			OnCancel();
			break;
		
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

simulated function OnCancel()
{
	BelowScreen.bHideOnLoseFocus = true;
	CloseScreen();
}

defaultproperties
{
	bConsumeMouseEvents = true
	InputState = eInputState_Consume;
}
