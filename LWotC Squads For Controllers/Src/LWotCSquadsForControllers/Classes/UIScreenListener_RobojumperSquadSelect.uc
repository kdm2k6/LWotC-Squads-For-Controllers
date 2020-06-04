class UIScreenListener_RobojumperSquadSelect extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;

	HQPres.ScreenStack.SubscribeToOnInputForScreen(Screen, OnRobojumperSquadSelectClick);

}

simulated function bool OnRobojumperSquadSelectClick(UIScreen Screen, int cmd, int arg)
{
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