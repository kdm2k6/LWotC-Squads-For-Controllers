class Utilities extends object;

static function bool StackHasRobojumpersSquadSelect()
{
	return (`HQPRES.ScreenStack.GetFirstInstanceOf(class'robojumper_UISquadSelect') == none) ? false : true;
}

static function robojumper_UISquadSelect GetRobojumpersSquadSelectFromStack()
{
	return robojumper_UISquadSelect(`HQPRES.ScreenStack.GetFirstInstanceOf(class'robojumper_UISquadSelect'));
}

static function bool StackHasSquadBarracksForControllers()
{
	return (`HQPRES.ScreenStack.GetFirstInstanceOf(class'UIPersonnel_SquadBarracks_ForControllers') == none) ? false : true;
}

static function UIPersonnel_SquadBarracks_ForControllers GetSquadBarracksForControllersFromStack()
{
	return UIPersonnel_SquadBarracks_ForControllers(`HQPRES.ScreenStack.GetFirstInstanceOf(class'UIPersonnel_SquadBarracks_ForControllers'));
}

static function bool StackHasUISquadMenu()
{
	return (`HQPRES.ScreenStack.GetFirstInstanceOf(class'UISquadMenu') == none) ? false : true;
}

static function UISquadMenu GetUISquadMenuFromStack()
{
	return UISquadMenu(`HQPRES.ScreenStack.GetFirstInstanceOf(class'UISquadMenu'));
}

// KDM : Iterates through a list containing UISquadMenu_ListItem's
static function int ListIndexWithSquadReference(UIList TheList, StateObjectReference SquadRef)
{
	local int i, ListSize;
	local UISquadMenu_ListItem ListItem;

	ListSize = TheList.ItemCount;

	for (i = 0; i < ListSize ; i++)
	{
		ListItem = UISquadMenu_ListItem(TheList.GetItem(i));
		if ((ListItem != none) && (ListItem.SquadRef == SquadRef))
		{
			return i;
		}
	}

	return -1;
}

// KDM : Iterates through XComGameState_LWSquadManager.Squads
static function int SquadsIndexWithSquadReference(StateObjectReference SquadRef)
{
	local int i;
	local XComGameState_LWSquadManager SquadManager;

	SquadManager = class'XComGameState_LWSquadManager'.static.GetSquadManager(true);
	if (SquadManager == none) return -1;

	for (i = 0; i < SquadManager.Squads.Length; i++)
	{
		if (SquadManager.Squads[i] == SquadRef)
		{
			return i;
		}
	}
	
	return -1;
}

static function SetSelectedIndexWithScroll(UIList TheList, int Index, optional bool Force)
{
	TheList.SetSelectedIndex(Index, Force);

	if (TheList.Scrollbar != none)
	{
		TheList.Scrollbar.SetThumbAtPercent(float(Index) / float(TheList.ItemCount - 1));
	}
}