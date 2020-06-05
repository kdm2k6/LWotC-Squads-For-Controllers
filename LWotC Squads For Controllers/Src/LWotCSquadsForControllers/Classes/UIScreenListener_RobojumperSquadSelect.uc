class UIScreenListener_RobojumperSquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local bool InSquadManagement;
	local UISquadMenu_ListItem CurrentSquadIcon;
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	InSquadManagement = HQPres.ScreenStack.IsInStack(class'UIPersonnel_SquadBarracks');

	// KDM : If we are in the squad management screen we want to disable the squad menu.
	// This is analogous to what is done in UIScreenListener_SquadSelect_LW.OnInit in regards to SquadContainer,
	// the UIPanel we are trying to replicate.
	if (InSquadManagement) return;

	HQPres.ScreenStack.SubscribeToOnInputForScreen(Screen, OnRobojumperSquadSelectClick);

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
	local UISquadMenu SquadMenu;
	local XComHQPresentationLayer HQPres;

	if (!Screen.CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	HQPres = `HQPRES;

	// KDM : Left stick click brings up the squad menu
	if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_L3)
	{
		SquadMenu = HQPres.Spawn(class'UISquadMenu', HQPres);
		HQPres.ScreenStack.Push(SquadMenu);
		return true;
	}

	return false;
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