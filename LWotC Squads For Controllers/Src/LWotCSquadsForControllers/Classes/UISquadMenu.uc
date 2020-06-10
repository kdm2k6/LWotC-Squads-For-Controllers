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

simulated function OnInit()
{
	super.OnInit();

	MC.FunctionVoid("AnimateIn");

	Navigator.SetSelected(List);
	List.SetSelectedIndex(0);
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
	
	UpdateNavHelp();
}

simulated function RefreshData()
{
	// KDM : UpdateData() fills in the SquadRefs array; most of this code is from UISquad_DropDown.UpdateData().
	UpdateData();
	UpdateList();
}

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

		if ((!Squad.bOnMission) && Squad.CurrentMission.ObjectID == 0)
		{
			SquadRefs.AddItem(Squad.GetReference());
		}
	}
}

simulated function UpdateList()
{
	local int SelectedIndex;

	SelectedIndex = List.SelectedIndex;

	List.ClearItems();

	PopulateList();

	if ((SelectedIndex < 0 || SelectedIndex >= List.ItemCount) && List.ItemCount > 0)
	{
		SelectedIndex = 0;
	}

	Navigator.SetSelected(List);
	List.SetSelectedIndex(SelectedIndex);
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

	SetSquad(SelectedSquadRef);

	CurrentSquadIcon = UISquadMenu_ListItem(SquadSelectScreen.GetChildByName('CurrentSquadIconForController', false));
	if (CurrentSquadIcon != none)
	{
		CurrentSquadIcon.SquadRef = SelectedSquadRef;
		CurrentSquadIcon.Update();
	}

	// KDM : Once a squad has been selected, just close the menu; I can't see any reason why someone would select several
	// squads within this menu screen.
	CloseScreen();
}

// KDM : This is LW2 code from UISquadContainer.
function SetSquad(optional StateObjectReference NewSquadRef)
{
	local StateObjectReference CurrentSquadRef;
	local XComGameState UpdateState;
	local XComGameState_HeadquartersXCom XComHQ;
	local XComGameState_LWPersistentSquad SquadState;
	local XComGameState_LWSquadManager SquadManager, UpdatedSquadManager;
	
	XComHQ = `XCOMHQ;
	SquadManager = `LWSQUADMGR;

	if (NewSquadRef.ObjectID > 0)
	{
		CurrentSquadRef = NewSquadRef;
	}
	else
	{
		CurrentSquadRef = SquadManager.LaunchingMissionSquad;
	}

	if (CurrentSquadRef.ObjectID > 0)
	{
		SquadState = XComGameState_LWPersistentSquad(`XCOMHISTORY.GetGameStateForObjectID(CurrentSquadRef.ObjectID));
	}
	else
	{
		SquadState = SquadManager.AddSquad(, XComHQ.MissionRef);
	}

	UpdateState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Update Launching Mission Squad");
	UpdatedSquadManager = XComGameState_LWSquadManager(UpdateState.CreateStateObject(SquadManager.Class, SquadManager.ObjectID));
	UpdateState.AddStateObject(UpdatedSquadManager);
	UpdatedSquadManager.LaunchingMissionSquad = SquadState.GetReference();
	UpdateState.AddStateObject(XComHQ);
	`GAMERULES.SubmitGameState(UpdateState);

	SquadState.SetSquadCrew(, false , false);
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
	
	SquadSelectScreen = robojumper_UISquadSelect(`HQPRES.ScreenStack.GetScreen(class'robojumper_UISquadSelect'));

	if (SquadSelectScreen != none)
	{
		// KDM : Update the squad select screen since we might have changed the selected squad or modified a squad
		// via the squad management menu.
		SquadSelectScreen.UpdateData();
	}

	super.CloseScreen();
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();

	// KDM : We could be, potentially, coming back from the squad management menu where squads could have been added/deleted/modified.
	// Therefore, it's important we update the data as well as the associated list via RefreshData().
	RefreshData();
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
			// KDM : OnSquadSelected guarantees the squad is updated upon closing the screen; this is important
			// because squads might have been modified via the squad management screen.
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
}




/*
simulated function SetNavHelpTimer()
{
	if (!IsTimerActive(nameof(UpdateNavHelp)))
	{
		// KDM : Hide the navigation help system so we don't get flicker; it will be shown again within UpdateNavHelp().
		`HQPRES.m_kAvengerHUD.NavHelp.Hide();

		// KDM : Robojumper's squad select uses a variety of timers; one seems to update the navigation system with its own 
		// information after a short period of time. Therefore, wait a little bit before resetting the navigation system.
		SetTimer(0.03f, false, nameof(UpdateNavHelp), self);
	}
}

simulated function RemoveNavHelpTimer()
{
	if (IsTimerActive(nameof(UpdateNavHelp)))
	{
		ClearTimer(nameof(UpdateNavHelp));
	}
}

simulated function OnLoseFocus()
{
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();

	RemoveNavHelpTimer();

	super.OnLoseFocus();
}

simulated function OnRemoved()
{
	RemoveNavHelpTimer();

	super.OnRemoved();
}
*/