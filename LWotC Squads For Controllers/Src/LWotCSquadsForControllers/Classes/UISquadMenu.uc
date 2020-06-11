class UISquadMenu extends UIScreen;

var localized string SquadManagementStr, TitleStr, OpenSquadMenuStr;

var int PanelH, PanelW;
var int BorderPadding;

var UIPanel MainPanel;
var UIBGBox ListBG;
var UIText ListTitle;
var UIX2PanelHeader LeftDiagonals, RightDiagonals;
var UIPanel DividerLine;
var UIList List;

var array<StateObjectReference> SquadRefs;

// KDM : If we are exiting the SquadBarracks and entering the Squad Menu, we want to maintain selection
// consistency; save the cached index within SquadBarrack's OnRemoved() and use it within Squad Menu's OnReceiveFocus().
var int CachedIndex;

simulated function OnInit()
{
	super.OnInit();

	MC.FunctionVoid("AnimateIn");
}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local int NextY;
	local string TitleHtmlStr;

	super.InitScreen(InitController, InitMovie, InitName);

	// KDM : Container which will hold our UI components : it's invisible.
	MainPanel = Spawn(class'UIPanel', self);
	MainPanel.bIsNavigable = false;
	MainPanel.InitPanel();
	MainPanel.SetPosition((Movie.UI_RES_X / 2) - (PanelW / 2), (Movie.UI_RES_Y / 2) - (PanelH / 2));

	// KDM : Background rectangle.
	ListBG = Spawn(class'UIBGBox', MainPanel);
	ListBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	ListBG.InitBG(, 0, 0, PanelW, PanelH);

	// KDM : Header text.
	ListTitle = Spawn(class'UIText', MainPanel);
	ListTitle.InitPanel();
	TitleHtmlStr = class'UIUtilities_Text'.static.GetColoredText(TitleStr, eUIState_Header, 32);
	ListTitle.SetHtmlText(TitleHtmlStr, TitleStrSizeRealized);
	ListTitle.SetPosition(BorderPadding, BorderPadding);
	
	// KDM : Diagonals to the left of the Header; makes use of a UIX2PanelHeader.
	LeftDiagonals = Spawn(class'UIX2PanelHeader', MainPanel);
	LeftDiagonals.bIsNavigable = false;
	LeftDiagonals.InitPanelHeader(, "Temporary Setup Text");
	LeftDiagonals.SetText("");
	
	// KDM : Diagonals to the right of the Header; makes use of a UIX2PanelHeader.
	RightDiagonals = Spawn(class'UIX2PanelHeader', MainPanel);
	RightDiagonals.bIsNavigable = false;
	RightDiagonals.InitPanelHeader(, "Temporary Setup Text");
	RightDiagonals.SetText("");

	NextY = ListTitle.Y + 45;

	// KDM : Thin dividing line.
	DividerLine = Spawn(class'UIPanel', MainPanel);
	DividerLine.bIsNavigable = false;
	DividerLine.LibID = class'UIUtilities_Controls'.const.MC_GenericPixel;
	DividerLine.InitPanel();
	DividerLine.SetPosition(BorderPadding, NextY);
	DividerLine.SetWidth(PanelW - (BorderPadding * 2));
	DividerLine.SetAlpha(30);

	NextY += 10;

	// KDM : List container which will hold rows of buttons.
	List = Spawn(class'UIList', MainPanel);
	List.bIsNavigable = true;
	List.bStickyHighlight = false;
	List.ItemPadding = 6;
	List.InitList(, BorderPadding, NextY, PanelW - (BorderPadding * 2) - 20, PanelH - NextY - BorderPadding);
	
	RefreshData();
	UpdateSelection(false);
	
	UpdateNavHelp();
}

simulated function RefreshData()
{
	UpdateData();
	UpdateList();
}

// KDM : UpdateData() fills in the SquadRefs array; most of this code is from UISquad_DropDown.UpdateData().
simulated function UpdateData()
{
	local int i;
	local XComGameState_LWPersistentSquad Squad;
	local XComGameState_LWSquadManager SquadManager;
	
	SquadManager = `LWSQUADMGR;

	SquadRefs.Length = 0;
		
	for (i = 0; i < SquadManager.Squads.Length; i++)
	{
		Squad = SquadManager.GetSquad(i);

		if ((!Squad.bOnMission) && (Squad.CurrentMission.ObjectID == 0))
		{
			SquadRefs.AddItem(Squad.GetReference());
		}
	}
}

simulated function UpdateList()
{
	//local int SelectedIndex;

	//SelectedIndex = List.SelectedIndex;

	List.ClearItems();

	PopulateList();

	/*
	if ((SelectedIndex < 0 || SelectedIndex >= List.ItemCount) && List.ItemCount > 0)
	{
		SelectedIndex = 0;
	}

	UpdateSelection();*/
}

simulated function UpdateSelection(optional bool UseCachedIndex = false)
{
	local int Index;

	Navigator.SetSelected(List);

	if (UseCachedIndex)
	{
		// KDM : Select the squad which was last looked at in the SquadBarracks, before it was closed.
		Index = CachedIndex;
	}
	else
	{
		// KDM : Select the squad that is currently being looked at in the Squad Select screen.
		Index = class'Utilities'.static.ListIndexWithSquadReference(List, `LWSQUADMGR.LaunchingMissionSquad);
	}
	
	class'Utilities'.static.SetSelectedIndexWithScroll(List, Index, true);
}

simulated function PopulateList()
{
	local int i;
	local UISquadMenu_ListItem ListItem;
	
	for (i = 0; i < SquadRefs.Length; i++)
	{
		ListItem = Spawn(class'UISquadMenu_ListItem',List.itemContainer);
		ListItem.InitListItem(SquadRefs[i], false, self);
		ListItem.Update();
	}
}

function TitleStrSizeRealized()
{
	local int DiagonalsWidth;

	// KDM : Border padding is placed between the title and diagonals, as well as between the diagonals and panel edges.
	DiagonalsWidth = (PanelW - (4 * BorderPadding) - ListTitle.Width) / 2;

	// KDM : Center the title.
	ListTitle.SetX((PanelW / 2) - (ListTitle.Width / 2));

	// KDM : Position the left & right diagonals and set their widths.
	// Unfortunately this requires a bit of hacking since the only way to get diagonals is to use empty UIX2PanelHeader's which
	// 1.] don't expect to be empty 2.] have ActionScript padding built into them 3.] seem to display differently depending upon
	// whether their 'supposed text' is to the left of the diagonals or right of the diagonals. Do the best we can, which is pretty good !
	LeftDiagonals.SetPosition(BorderPadding, BorderPadding);
	LeftDiagonals.SetHeaderWidth(DiagonalsWidth + 10, true);
	RightDiagonals.SetPosition(ListTitle.X + ListTitle.Width + BorderPadding, BorderPadding);
	RightDiagonals.SetHeaderWidth(DiagonalsWidth + 10, true);
}


simulated function OnSquadSelected(StateObjectReference SelectedSquadRef)
{
	local robojumper_UISquadSelect SquadSelectScreen;
	local UISquadMenu_ListItem CurrentSquadIcon;
	
	SquadSelectScreen = robojumper_UISquadSelect(`HQPRES.ScreenStack.GetScreen(class'robojumper_UISquadSelect'));

	class'Utilities'.static.SetSquad(SelectedSquadRef);

	CurrentSquadIcon = UISquadMenu_ListItem(SquadSelectScreen.GetChildByName('CurrentSquadIconForController', false));
	if (CurrentSquadIcon != none)
	{
		CurrentSquadIcon.SquadRef = SelectedSquadRef;
		CurrentSquadIcon.Update();
	}

	// KDM : Once a squad has been selected, just close the menu.
	CloseScreen();
}

simulated function OpenSquadManagement()
{
	local UIPersonnel_SquadBarracks_ForControllers SquadManagementScreen;
	
	// KDM : If we are viewing the squad through SquadBarracks, do not allow squad management to open.
	// This simulates what is done with UISquadContainer.
	if (`HQPRES.ScreenStack.IsInStack(class'UIPersonnel_SquadBarracks_ForControllers')) return;

	SquadManagementScreen = `HQPRES.Spawn(class'UIPersonnel_SquadBarracks_ForControllers', `HQPRES);
	SquadManagementScreen.bSelectSquad = true;
	`HQPRES.ScreenStack.Push(SquadManagementScreen);
}

simulated function UpdateNavHelp()
{
	local UINavigationHelp NavHelp;

	NavHelp =`HQPRES.m_kAvengerHUD.NavHelp;
	
	NavHelp.ClearButtonHelp();
	NavHelp.bIsVerticalHelp = true;
	NavHelp.AddBackButton();
	NavHelp.AddSelectNavHelp();
	NavHelp.AddLeftHelp(SquadManagementStr, class'UIUtilities_Input'.const.ICON_LSCLICK_L3);
	NavHelp.Show();
}

simulated function CloseScreen()
{
	local robojumper_UISquadSelect SquadSelectScreen;
	
	SquadSelectScreen = class'Utilities'.static.GetRobojumpersSquadSelectFromStack();
	// KDM TO REMOVE robojumper_UISquadSelect(`HQPRES.ScreenStack.GetScreen(class'robojumper_UISquadSelect'));

	if (SquadSelectScreen != none)
	{
		// KDM : We might have selected a new squad from the Squad Menu, or we might have made squad modifications via the 
		// Squad Management screen; therefore, make sure we update the data.
		SquadSelectScreen.UpdateData();
	}

	super.CloseScreen();
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();

	// KDM : We might have made squad modifications via the Squad Management screen; therefore, it's important we refresh the
	// squad data, and update the squad list.
	RefreshData();
	UpdateSelection(true);

	UpdateNavHelp();
}

simulated function OnLoseFocus()
{
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();

	super.OnLoseFocus();
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	bHandled = true;

	// KDM : Let the list handle the input first.
	if (List.OnUnrealCommand(cmd, arg))
	{
		return true;
	}

	switch (cmd)
	{
		// KDM : B button closes the screen.
		case class'UIUtilities_Input'.static.GetBackButtonInputCode() :
			// KDM : No squad was selected; however, the current squad could still have been modified via the Squad Management
			// screen; therefore, call OnSquadSelected() to guarantee an update.
			OnSquadSelected(`LWSQUADMGR.LaunchingMissionSquad);
			break;

		// KDM : Select button opens the squad management screen.
		case class'UIUtilities_Input'.const.FXS_BUTTON_L3:
			OpenSquadManagement();
			break;
		
		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

defaultproperties
{
	// KDM : Attach a black overlay, mouse guard, by setting bConsumeMouseEvents to true.
	bConsumeMouseEvents = true;
	InputState = eInputState_Consume;

	BorderPadding = 10;

	PanelW = 400;
	PanelH = 450;

	CachedIndex = -1;
}
