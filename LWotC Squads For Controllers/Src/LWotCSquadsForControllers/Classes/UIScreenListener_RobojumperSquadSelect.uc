class UIScreenListener_RobojumperSquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local bool InSquadManagement;
	local UISquadMenu_ListItem CurrentSquadIcon;
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	InSquadManagement = HQPres.ScreenStack.IsInStack(class'UIPersonnel_SquadBarracks_ForControllers');

	// KDM : If we are in the squad management screen we want to disable the squad menu.
	// This is analogous to what is done in UIScreenListener_SquadSelect_LW.OnInit in regards to SquadContainer,
	// the UIPanel we are trying to replicate.
	if (InSquadManagement) return;

	HQPres.ScreenStack.SubscribeToOnInputForScreen(Screen, OnRobojumperSquadSelectClick);

	// KDM : A UI element which shows the current squad, on the squad select screen.
	CurrentSquadIcon = Screen.Spawn(class'UISquadMenu_ListItem', Screen);
	CurrentSquadIcon.MCName = 'CurrentSquadIconForController';
	CurrentSquadIcon.SquadRef = `LWSQUADMGR.LaunchingMissionSquad;
	CurrentSquadIcon.bAnimateOnInit = false;
	CurrentSquadIcon.bIsNavigable = false;
	// FROM LW2 : Create on a timer to avoid creation issues that arise when no pawn loading has occurred.
	CurrentSquadIcon.DelayedInit(0.75f);
}

simulated function bool OnRobojumperSquadSelectClick(UIScreen Screen, int cmd, int arg)
{
	if (!Screen.CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	// KDM : Left stick click brings up the squad menu.
	if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_L3)
	{
		OpenSquadMenu(Screen);
		return true;
	}

	return false;
}

simulated function OpenSquadMenu(UIScreen Screen)
{
	local robojumper_UISquadSelect SquadSelectScreen;
	local UISquadMenu SquadMenu;
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;
	SquadSelectScreen = robojumper_UISquadSelect(Screen);

	if (SquadSelectScreen == none)
	{
		`log("*** There is a big problem with UIScreenListener_RobojumperSquadSelect : SquadSelectScreen == none ***");
		return;
	}

	SquadMenu = HQPres.Spawn(class'UISquadMenu', HQPres);

	// KDM : If Robojumper's Squad Select has the option "Skip Intro" turned on, bInstantLineupUI = true.
	if (!SquadSelectScreen.bInstantLineupUI)
	{
		// KDM : Since we are bringing up a squad related menu, simply finish the intro cinematic if it is in progress.
		// This actually creates a nice, zooming in effect.
		SquadSelectScreen.FinishIntroCinematic();
	}

	HQPres.ScreenStack.Push(SquadMenu);

	if (!SquadSelectScreen.bInstantLineupUI)
	{
		// KDM : Very strange problem that exists even with Robojumper's Squad Select and a normal game.
		// robojumper_UISquadSelect.OnLoseFocus() sets bDirty to true; however, UISquadSelect.Cinematic_PawnsIdling.BeginState
		// only calls SnapCamera() if bDirty is false. Without this call to SnapCamera(), the camera suddenly zooms into the
		// squad's waist upon entering the idle state. Since I am only bringing up a menu, and the menu buttons update data 
		// whenever they need to, setting bDirty to false seems fairly safe.
		SquadSelectScreen.bDirty = false;
	}
}

event OnRemoved(UIScreen Screen)
{
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	HQPres.ScreenStack.UnsubscribeFromOnInputForScreen(Screen, OnRobojumperSquadSelectClick);
}

defaultproperties
{
	ScreenClass = class'robojumper_UISquadSelect';
}