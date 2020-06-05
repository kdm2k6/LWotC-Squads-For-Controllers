class UIScreenListener_RobojumperSquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	HQPres.ScreenStack.SubscribeToOnInputForScreen(Screen, OnRobojumperSquadSelectClick);
}

simulated function bool OnRobojumperSquadSelectClick(UIScreen Screen, int cmd, int arg)
{
	local bool InSquadManagement;
	local UISquadMenu SquadMenu;
	local XComHQPresentationLayer HQPres;

	if (!Screen.CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	HQPres = `HQPRES;
	
	// KDM : If we are in the squad management screen we want to disable the squad menu.
	// This is analogous to what is done in UIScreenListener_SquadSelect_LW.OnInit in regards to SquadContainer,
	// the UIPanel we are trying to replicate.
	InSquadManagement = HQPres.ScreenStack.IsInStack(class'UIPersonnel_SquadBarracks');

	// KDM : Left stick click brings up the squad menu
	if ((cmd == class'UIUtilities_Input'.const.FXS_BUTTON_L3) && (!InSquadManagement))
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