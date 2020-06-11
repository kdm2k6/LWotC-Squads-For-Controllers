class X2EventListener_UISquadSelect_NavHelpUpdate extends X2EventListener;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateListenerTemplate_UISquadSelect_NavHelpUpdate());
	
	return Templates;
}

static function CHEventListenerTemplate CreateListenerTemplate_UISquadSelect_NavHelpUpdate()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'UISquadSelect_NavHelpUpdate_ForController');

	Template.RegisterInTactical = false;
	Template.RegisterInStrategy = true;

	Template.AddCHEvent('UISquadSelect_NavHelpUpdate', OnUISquadSelect_NavHelpUpdate, ELD_Immediate);

	return Template;
}

static function EventListenerReturn OnUISquadSelect_NavHelpUpdate(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local UINavigationHelp NavHelp;
	
	NavHelp = UINavigationHelp(EventData);
	
	// KDM : We have reached the Squad Select screen through : SquadBarracks --> View Current Squad.
	// In this case, we only allow the user to select soldiers with the DPad and exit the screen with the B button.
	if (class'Utilities'.static.StackHasSquadBarracksForControllers())
	{
		NavHelp.ClearButtonHelp();
		NavHelp.AddBackButton();
		NavHelp.Show();
	}
	// KDM : We have reached the Squad Select screen normally.
	else
	{
		// KDM : Left stick click opens up the Squad Menu.
		NavHelp.AddRightHelp(class'UISquadMenu'.default.OpenSquadMenuStr, class'UIUtilities_Input'.const.ICON_LSCLICK_L3);
	}

	return ELR_NoInterrupt;
}