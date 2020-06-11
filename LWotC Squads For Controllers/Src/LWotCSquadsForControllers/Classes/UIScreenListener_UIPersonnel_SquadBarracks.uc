class UIScreenListener_UIPersonnel_SquadBarracks extends UIScreenListener;

event OnInit(UIScreen Screen)
{
	local UIPersonnel_SquadBarracks SquadBarracks;
	local UIPersonnel_SquadBarracks_ForControllers SquadBarracksForControllers;
	local XComHQPresentationLayer HQPres;

	HQPres = `HQPRES;
	SquadBarracks = UIPersonnel_SquadBarracks(Screen);

	SquadBarracksForControllers = HQPres.Spawn(class'UIPersonnel_SquadBarracks_ForControllers', HQPres);
	// KDM : I need to update the new squad barracks screen with SquadBarracks's bSelectSquad value before it is popped.
	// KDM REMOVE SquadBarracksForControllers.bSelectSquad = SquadBarracks.bSelectSquad; 
	
	HQPres.ScreenStack.Pop(SquadBarracks);
	HQPres.ScreenStack.Push(SquadBarracksForControllers);
}

defaultproperties
{
	ScreenClass = class'UIPersonnel_SquadBarracks';
}
