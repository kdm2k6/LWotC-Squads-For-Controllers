class UIPersonnel_SquadBarracks_ForControllers extends UIPersonnel config(SquadSettings);

// KDM NOTES :
// Turn off autofill squads for RJ squad select or else empty LW squads will be filled out with individuals.

// KDM TO DO :
// 1. IF NO SQUAD'S EXIST - NEED to do testing for various things since I haven't checked it out at all.
// 2. Update LWotc regarding detailed soldier list - getting rid of nav help button if controller is active while
// UIPersonnel_SquadBarracks_ForControllers is on stack, I think - think about it
// 3. Only thing I haven't really tested is View Squad - probably actually test, but then jsut make it a config variable
// set to false by default - since save functionality doesn't even work.
// 4. If squad on a mission what can and can't happen ?
// 5. Make sure I don't look for A button or B button - do special function call stuff
// 6. Look for KDM REMOVE comments - these are likely no longer needed.
// 7. Place little headers at top like LW does

// KDM : I don't use bSelectSquad; however, it is referenced in LW2 files, so just leave it here and ignore it.
var bool bSelectSquad;

var StateObjectReference CachedSquad;
var bool RestoreCachedSquad;

// KDM : This is needed for the squad icon selector.
var config array<string> SquadImagePaths;

var localized string TitleStr, NoSquadsStr, DashesStr, StatusStr, MissionsStr, BiographyStr, SquadSoldiersStr, AvailableSoldiersStr;
var localized string FocusUISquadStr, FocusUISoldiersStr, CreateSquadStr, DeleteSquadStr, PrevSquadStr, NextSquadStr, ChangeSquadIconStr,
	RenameSquadStr, EditSquadBioStr, ScrollSquadBioStr, ViewSquadStr, ViewSquadSoldiersStr, ViewAvailableSoldierStr, TransferToSquadStr,
	RemoveFromSquadStr;

// KDM : Determines whether the squad UI, located at the top, or the soldier UI, located at the bottom, is focused.
var bool SoldierUIFocused;

// KDM : Determines whether the list is displaying available soldiers, or a squad's soldiers.
var bool DisplayingAvailableSoldiers;

var int CurrentSquadIndex;

var int PanelW, PanelH;

var int BorderPadding; 
var int SquadIconBorderSize, SquadIconSize;

var UIPanel MainPanel;
var UIBGBox SquadBG;
var UIX2PanelHeader SquadHeader;
var UIPanel DividerLine;
var UIPanel SquadIconBG1, SquadIconBG2;
var UIImage CurrentSquadIcon;
var UIScrollingText CurrentSquadStatus, CurrentSquadMissions;
var UITextContainer CurrentSquadBio;
var UIList SoldierIconList;
var UIButton SquadSoldiersTab, AvailableSoldiersTab;

simulated function OnInit()
{
	super.OnInit();

	// KDM : Hide pre-built UI elements we won't be using via Flash; the alternative is to : 
	// 1.] Spawn them 2.] Init them with the appropriate MC name 3.] Hide them.
	MC.ChildFunctionVoid("SoldierListBG", "Hide");
	MC.ChildFunctionVoid("deceasedSort", "Hide");
	MC.ChildFunctionVoid("personnelSort", "Hide");
}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local int AvailableW, XLoc, YLoc, HeightVal, WidthVal;

	super(UIScreen).InitScreen(InitController, InitMovie, InitName);

	// KDM : Fill in the sort type array since its original setup function, UIPersonnel.SwitchTab, is no longer called.
	m_aSortTypeOrder.AddItem(ePersonnelSoldierSortType_Rank);
	m_aSortTypeOrder.AddItem(ePersonnelSoldierSortType_Name);
	m_aSortTypeOrder.AddItem(ePersonnelSoldierSortType_Class);
	m_aSortTypeOrder.AddItem(ePersonnelSoldierSortType_Status);

	// KDM : Container which will hold our UI components : it's invisible.
	MainPanel = Spawn(class'UIPanel', self);
	MainPanel.bIsNavigable = false;
	MainPanel.InitPanel();
	MainPanel.SetPosition((Movie.UI_RES_X / 2) - (PanelW / 2), (Movie.UI_RES_Y / 2) - (PanelH / 2));

	// KDM : Background rectangle.
	SquadBG = Spawn(class'UIBGBox', MainPanel);
	SquadBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	SquadBG.InitBG(, 0, 0, PanelW, PanelH);

	// KDM : Header which displays the current squad's name.
	XLoc = BorderPadding;
	YLoc = BorderPadding;
	WidthVal = PanelW - (BorderPadding * 2);
	SquadHeader = Spawn(class'UIX2PanelHeader', MainPanel);
	SquadHeader.bIsNavigable = false;
	SquadHeader.InitPanelHeader(, "Current Squad Name");
	SquadHeader.SetPosition(XLoc, YLoc);
	SquadHeader.SetHeaderWidth(WidthVal);
	
	// KDM : Thin dividing line.
	XLoc = BorderPadding;
	YLoc = SquadHeader.Y + 45;
	WidthVal = PanelW - (BorderPadding * 2);
	DividerLine = Spawn(class'UIPanel', MainPanel);
	DividerLine.bIsNavigable = false;
	DividerLine.LibID = class'UIUtilities_Controls'.const.MC_GenericPixel;
	DividerLine.InitPanel();
	DividerLine.SetPosition(XLoc, YLoc);
	DividerLine.SetWidth(WidthVal);
	DividerLine.SetAlpha(30);
	
	// KDM : Current squad icon's background 1; this is located behind background 2.
	XLoc = BorderPadding;
	YLoc = DividerLine.Y + 10;
	WidthVal = SquadIconBorderSize + SquadIconSize + SquadIconBorderSize;
	HeightVal = SquadIconBorderSize + SquadIconSize + SquadIconBorderSize;
	SquadIconBG1 = Spawn(class'UIPanel', MainPanel);
	SquadIconBG1.bIsNavigable = false;
	SquadIconBG1.LibID = class'UIUtilities_Controls'.const.MC_GenericPixel;
	SquadIconBG1.InitPanel();
	SquadIconBG1.SetPosition(XLoc, YLoc);
	SquadIconBG1.SetSize(WidthVal, HeightVal);
	SquadIconBG1.SetColor("0x333333");
	SquadIconBG1.SetAlpha(80);

	// KDM : Current squad icon's background 2.
	XLoc = SquadIconBG1.X + SquadIconBorderSize;
	YLoc = SquadIconBG1.Y + SquadIconBorderSize;
	WidthVal = SquadIconSize;
	HeightVal = SquadIconSize;
	SquadIconBG2 = Spawn(class'UIPanel', MainPanel);
	SquadIconBG2.bIsNavigable = false;
	SquadIconBG2.LibID = class'UIUtilities_Controls'.const.MC_GenericPixel;
	SquadIconBG2.InitPanel();
	SquadIconBG2.SetPosition(XLoc, YLoc);
	SquadIconBG2.SetSize(WidthVal, HeightVal);
	SquadIconBG2.SetColor("0x000000");
	SquadIconBG2.SetAlpha(100);

	// KDM : Current squad's icon.
	XLoc = SquadIconBG2.X;
	YLoc = SquadIconBG2.Y;
	CurrentSquadIcon = Spawn(class'UIImage', MainPanel);
	CurrentSquadIcon.InitImage();
	CurrentSquadIcon.SetPosition(XLoc, YLoc);
	CurrentSquadIcon.SetSize(SquadIconSize, SquadIconSize);
	
	// KDM : Current squad's status.
	XLoc = SquadIconBG1.X + SquadIconBG1.Width + BorderPadding;
	YLoc = DividerLine.Y + 10;
	WidthVal = PanelW - SquadIconSize - (BorderPadding * 3);
	CurrentSquadStatus = Spawn(class'UIScrollingText', MainPanel);
	CurrentSquadStatus.InitScrollingText(, "Current Squad Status", WidthVal, XLoc, YLoc);

	// KDM : Current squad's mission count.
	XLoc = CurrentSquadStatus.X;
	YLoc = CurrentSquadStatus.Y;
	WidthVal = CurrentSquadStatus.Width;
	CurrentSquadMissions = Spawn(class'UIScrollingText', MainPanel);
	CurrentSquadMissions.InitScrollingText(, "Current Squad Missions", WidthVal, XLoc, YLoc);

	// KDM : List of icons representing soldiers in the squad.
	XLoc = CurrentSquadStatus.X;
	YLoc = CurrentSquadStatus.Y + 30;
	WidthVal = PanelW - SquadIconSize - (BorderPadding * 3);
	HeightVal = 24;
	SoldierIconList = Spawn(class'UIList', MainPanel);
	SoldierIconList.InitList(, XLoc, YLoc, WidthVal, HeightVal, true);

	// KDM : Current squad's biography.
	XLoc = CurrentSquadStatus.X;
	YLoc = SoldierIconList.Y + SoldierIconList.Height + 10;
	WidthVal = PanelW - SquadIconSize - (BorderPadding * 3);
	HeightVal = 100;
	CurrentSquadBio = Spawn(class'UITextContainer', MainPanel);
	CurrentSquadBio.InitTextContainer(, "", XLoc, YLoc, WidthVal, HeightVal, false, , false);
	CurrentSquadBio.SetText("Current Squad Bio");
	
	AvailableW = PanelW - (BorderPadding * 3);

	// KDM : Squad soldiers tab.
	XLoc = BorderPadding;
	YLoc = SquadIconBG1.Y + SquadIconBG1.Height + 10;
	WidthVal = int(float(AvailableW) * 0.5);
	SquadSoldiersTab = Spawn(class'UIButton', MainPanel);
	SquadSoldiersTab.ResizeToText = false;
	SquadSoldiersTab.InitButton(, SquadSoldiersStr, , eUIButtonStyle_NONE);
	SquadSoldiersTab.SetWarning(true);
	SquadSoldiersTab.SetPosition(XLoc, YLoc);
	SquadSoldiersTab.SetWidth(WidthVal);
	
	// KDM : Available soldiers tab.
	XLoc = SquadSoldiersTab.X + SquadSoldiersTab.Width + BorderPadding;
	YLoc = SquadSoldiersTab.Y;
	WidthVal = int(float(AvailableW) * 0.5);
	AvailableSoldiersTab = Spawn(class'UIButton', MainPanel);
	AvailableSoldiersTab.ResizeToText = false;
	AvailableSoldiersTab.InitButton(, AvailableSoldiersStr, , eUIButtonStyle_NONE);
	AvailableSoldiersTab.SetWarning(true);
	AvailableSoldiersTab.SetPosition(XLoc, YLoc);
	AvailableSoldiersTab.SetWidth(WidthVal);
	
	CreateSortableHeader();

	// KDM : Soldier list.
	XLoc = MainPanel.X + SquadSoldiersTab.X;
	YLoc = MainPanel.Y + SquadSoldiersTab.Y + 75;
	m_kList = Spawn(class'UIList', self);
	m_kList.bStickyHighlight = false;
	m_kList.InitList('listAnchor', XLoc, YLoc, m_iMaskWidth - 20, m_iMaskHeight);
	m_kList.MoveToHighestDepth();

	SetInitialCurrentSquadIndex();

	SetUIFocus(false, true);
	UpdateAll(true);

	UpdateNavHelp();
}

simulated function SetInitialCurrentSquadIndex()
{
	local UISquadMenu SquadMenu;

	SquadMenu = class'Utilities'.static.GetUISquadMenuFromStack();

	// KDM : We are entering the SquadBarracks through : Squad Select --> Squad Menu.
	// In this case, select the squad which was last highlighted in the Squad Menu.	
	if (SquadMenu != none)
	{
		CurrentSquadIndex = (SquadsExist()) ? SquadMenu.List.SelectedIndex : -1;
	}
	// KDM : We are entering the SquadBarracks through the 'Squad Management' Avenger tab.
	// In this case, select the 1st squad.
	else
	{
		CurrentSquadIndex = (SquadsExist()) ? 0 : -1;
	}
}

simulated function CreateSortableHeader()
{
	local int XLoc, YLoc;

	// KDM : Create the header container.
	XLoc = MainPanel.X + SquadSoldiersTab.X;
	YLoc = MainPanel.Y + SquadSoldiersTab.Y + 35;
	m_kSoldierSortHeader = Spawn(class'UIPanel', self);
	m_kSoldierSortHeader.bIsNavigable = false;
	m_kSoldierSortHeader.InitPanel('soldierSort', 'SoldierSortHeader');
	m_kSoldierSortheader.SetPosition(XLoc, YLoc);
	m_kSoldierSortHeader.MoveToHighestDepth();
	
	// KDM : Fill the header container with header buttons.
	Spawn(class'UIFlipSortButton', m_kSoldierSortHeader).InitFlipSortButton("rankButton", ePersonnelSoldierSortType_Rank, m_strButtonLabels[ePersonnelSoldierSortType_Rank]);
	Spawn(class'UIFlipSortButton', m_kSoldierSortHeader).InitFlipSortButton("nameButton", ePersonnelSoldierSortType_Name, m_strButtonLabels[ePersonnelSoldierSortType_Name]);
	Spawn(class'UIFlipSortButton', m_kSoldierSortHeader).InitFlipSortButton("classButton", ePersonnelSoldierSortType_Class, m_strButtonLabels[ePersonnelSoldierSortType_Class]);
	Spawn(class'UIFlipSortButton', m_kSoldierSortHeader).InitFlipSortButton("statusButton", ePersonnelSoldierSortType_Status, m_strButtonLabels[ePersonnelSoldierSortType_Status], m_strButtonValues[ePersonnelSoldierSortType_Status]);
}

simulated function UpdateAll(optional bool _ResetTabFocus = false, optional bool _ResetSortType = true)
{
	UpdateSquadUI();
	UpdateListUI(_ResetTabFocus, _ResetSortType);
}

simulated function UpdateSquadUI()
{
	local int TextState;
	local string SquadTitle, SquadStatus, SquadMissions, SquadBio;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	local XGParamTag ParamTag;
	
	CurrentSquadState = GetCurrentSquad();

	// KDM : If no squads exist, empty the UI then exit.
	if (!SquadsExist())
	{
		SquadHeader.SetText(NoSquadsStr);
		SquadHeader.MC.FunctionVoid("realize");
		CurrentSquadIcon.Hide();
		CurrentSquadStatus.SetHTMLText("");
		CurrentSquadMissions.SetHTMLText("");
		SoldierIconList.Hide();
		CurrentSquadBio.SetText("");
		return;
	}

	// KDM : Squads exist, yet no squad is selected; this shouldn't happen, so just exit.
	if (CurrentSquadState == none)
	{
		`log("*** KDM ERROR : UIPersonnel_SquadBarracks_ForControllers.UpdateSquadUI : Squads exist, yet there is no selection. ***");
		return;
	}

	// KDM : Set the squad title, which is of the form 'SQUAD [1/4] : NAME_OF_SQUAD'.
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = CurrentSquadIndex + 1;
	ParamTag.IntValue1 = GetTotalSquads();
	ParamTag.StrValue0 = CurrentSquadState.sSquadName;
	SquadTitle = `XEXPAND.ExpandString(TitleStr);
	
	SquadHeader.SetText(SquadTitle);
	// KDM : There is an ActionScript bug in UIX2PanelHeader which causes it to update its text only after realize() is called.
	// Unfortunately, SetText() doesn't call realize(), so we have to do it ourself.
	SquadHeader.MC.FunctionVoid("realize");

	// KDM : Set the squad icon; it also needs to be shown since, if no squads exist, it is hidden.
	CurrentSquadIcon.LoadImage(CurrentSquadState.GetSquadImagePath());
	CurrentSquadIcon.Show();
	
	// KDM : Set the squad status; it will be either 'ON MISSION' or 'AVAILABLE'.
	SquadStatus = (CurrentSquadState.IsDeployedOnMission()) ? class'UISquadListItem'.default.sSquadOnMission : class'UISquadListItem'.default.sSquadAvailable;
	TextState = (CurrentSquadState.IsDeployedOnMission()) ? eUIState_Warning : eUIState_Good;
	SquadStatus = class'UIUtilities_Text'.static.GetColoredText(SquadStatus, TextState); 
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = SquadStatus;
	SquadStatus = `XEXPAND.ExpandString(StatusStr);
	SquadStatus = class'UIUtilities_Text'.static.GetSizedText(SquadStatus, 24);
	CurrentSquadStatus.SetHTMLText(SquadStatus);
	
	// KDM : Set the squad's mission count; it will be of the form 'Missions : 1'.
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = CurrentSquadState.iNumMissions;
	SquadMissions = `XEXPAND.ExpandString(MissionsStr);
	SquadMissions = class'UIUtilities_Text'.static.GetColoredText(SquadMissions, eUIState_Normal, 24, "RIGHT"); 
	CurrentSquadMissions.SetHTMLText(SquadMissions);
	
	// KDM : Update the soldier icon list; it also needs to be shown since, if no squads exist, it is hidden.
	UpdateSoldierClassIcons(CurrentSquadState);
	SoldierIconList.Show();

	// KDM : Set the squad's biography.
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = CurrentSquadState.sSquadBiography;
	SquadBio = `XEXPAND.ExpandString(BiographyStr);
	CurrentSquadBio.SetText(SquadBio);
}

simulated function UpdateListUI(optional bool _ResetTabFocus = false, optional bool _ResetSortType = true)
{
	if (_ResetTabFocus) ResetTabFocus();
	if (_ResetSortType) ResetSortType();

	UpdateListData();
	SortListData();
	UpdateList();

	UpdateListSelection();
}

simulated function ResetTabFocus()
{
	// KDM : By default, the squad's soldiers tab has focus.
	SetTabFocus(false, true);
}

simulated function ResetSortType()
{
	// KDM : By default, sort the list in rank-descending order.
	m_iSortTypeOrderIndex = 0;
	m_eSortType = ePersonnelSoldierSortType_Rank;
	m_bFlipSort = false;
}

simulated function UpdateListData()
{
	local XComGameState_LWSquadManager SquadManager;

	SquadManager = `LWSQUADMGR;
	m_arrSoldiers.Length = 0;

	if (!CurrentSquadIsValid()) return;

	m_arrSoldiers = (DisplayingAvailableSoldiers) ? SquadManager.GetUnassignedSoldiers() : SquadManager.GetSquad(CurrentSquadIndex).GetSoldierRefs(true);
}

// KDM : This function is here as a simple 'name wrapper'.
simulated function SortListData()
{
	SortData();
}

simulated function UpdateList()
{
	local int i;
	local UIPersonnel_ListItem SoldierListItem;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	
	super.UpdateList();

	CurrentSquadState = GetCurrentSquad();

	// LW : Determine whether each soldier can be transferred or not.
	for (i = 0; i < m_kList.itemCount; i++)
	{
		SoldierListItem = UIPersonnel_ListItem(m_kList.GetItem(i));

		// LW : If we are viewing a squad on a mission, mark units not on the mission with a lower alpha value.
		if ((CurrentSquadState != none) && CurrentSquadState.IsDeployedOnMission() && (!CurrentSquadState.IsSoldierOnMission(SoldierListItem.UnitRef)))
		{
			SoldierListItem.SetAlpha(30);
		}

		if (!CanTransferSoldier(SoldierListItem.UnitRef))
		{
			SoldierListItem.SetDisabled(true);
		}
	}
}

simulated function UpdateListSelection()
{
	// KDM : If the soldier UI has focus, select the 1st soldier in the soldier list.
	if (SoldierUIFocused)
	{
		if (m_kList.ItemCount > 0) 
		{
			m_kList.SetSelectedIndex(0, true);
		}
	}
	// KDM : If the squad UI has focus, remove all focus from the soldier list.
	else
	{
		m_kList.ClearSelection();
	}
}

// KDM : LW function.
simulated function int GetClassIconAlphaStatus(XComGameState_Unit SoldierState, XComGameState_LWPersistentSquad CurrentSquadState)
{
	local bool IsSquadDeployedOnMission, IsSoldierOnMission;
	
	IsSquadDeployedOnMission = CurrentSquadState.IsDeployedOnMission();
	IsSoldierOnMission = CurrentSquadState.IsSoldierOnMission(SoldierState.GetReference());

	// LW : If the squad is on a mission, but this squad's soldier isn't, dim the icon regardless of their actual status.
	if (IsSquadDeployedOnMission && (!IsSoldierOnMission)) return 30;
	
	switch (SoldierState.GetStatus())
	{
		case eStatus_Active:
			return (CurrentSquadState.bOnMission && CurrentSquadState.IsSoldierTemporary(SoldierState.GetReference())) ? 50 : 100;

		case eStatus_OnMission:
			return (`LWOUTPOSTMGR.IsUnitAHavenLiaison(SoldierState.GetReference())) ? 50 : 100;
		
		case eStatus_PsiTraining:
		case eStatus_PsiTesting:
		case eStatus_Training:
		case eStatus_Healing:
		case eStatus_Dead:
		default:
			return 50;
	}
}

// KDM : LW function.
simulated function UpdateSoldierClassIcons(XComGameState_LWPersistentSquad CurrentSquadState)
{
	local int i, StartIndex;
	local array<XComGameState_Unit> SoldierStates;
	local UISquadClassItem SoldierClassIcon;
	local XComGameState_Unit SoldierState;
	
	SoldierStates = CurrentSquadState.GetSoldiers();
	
	// LWS : Add permanent soldier icons.
	for (i = 0; i < SoldierStates.Length; i++)
	{
		SoldierState = SoldierStates[i];
		SoldierClassIcon = UISquadClassItem(SoldierIconList.GetItem(i));
		
		if (SoldierClassIcon == none)
		{
			SoldierClassIcon = UISquadClassItem(SoldierIconList.CreateItem(class'UISquadClassItem'));
			// KDM : The size is automatically set to 38 x 38.
			SoldierClassIcon.InitSquadClassItem();
		}

		SoldierClassIcon.LoadClassImage(SoldierState.GetSoldierClassTemplate().IconImage);
		// LWS : Dim unavailable soldiers.
		SoldierClassIcon.SetAlpha(GetClassIconAlphaStatus(SoldierState, CurrentSquadState));
		SoldierClassIcon.ShowTempIcon(false);
		SoldierClassIcon.Show();
	}
	
	StartIndex = i;
	SoldierStates = CurrentSquadState.GetTempSoldiers();
	
	// LWS : Add temporary soldier icons.
	for (i = StartIndex; i < StartIndex + SoldierStates.Length; i++)
	{
		SoldierState = SoldierStates[i - StartIndex];
		SoldierClassIcon = UISquadClassItem(SoldierIconList.GetItem(i));
		
		if (SoldierClassIcon == none)
		{
			SoldierClassIcon = UISquadClassItem(SoldierIconList.CreateItem(class'UISquadClassItem'));
			// KDM : The size is automatically set to 38 x 38.
			SoldierClassIcon.InitSquadClassItem();
		}

		SoldierClassIcon.LoadClassImage(SoldierState.GetSoldierClassTemplate().IconImage);
		// LWS : Dim unavailable soldiers
		SoldierClassIcon.SetAlpha(GetClassIconAlphaStatus(SoldierState, CurrentSquadState));
		SoldierClassIcon.ShowTempIcon(true);
		SoldierClassIcon.Show();
	}

	StartIndex = i;

	// LWS : Hide additional icons.
	if (SoldierIconList.GetItemCount() > StartIndex)								
	{
		for (i = StartIndex; i < SoldierIconList.GetItemCount(); i++)
		{
			SoldierClassIcon = UISquadClassItem(SoldierIconList.GetItem(i));
			SoldierClassIcon.Hide();
		}
	}
}

simulated function XComGameState_LWPersistentSquad GetCurrentSquad()
{
	local StateObjectReference CurrentSquadRef;
	
	if (CurrentSquadIndex < 0) return none;
	
	CurrentSquadRef = `LWSQUADMGR.Squads[CurrentSquadIndex];
	return XComGameState_LWPersistentSquad(`XCOMHISTORY.GetGameStateForObjectID(CurrentSquadRef.ObjectID));
}

simulated function bool SquadsExist()
{
	return (GetTotalSquads() == 0) ? false : true;
}

simulated function bool CurrentSquadIsValid()
{
	return (SquadsExist() && (CurrentSquadIndex >= 0) && (CurrentSquadIndex < GetTotalSquads()));
}

simulated function int GetTotalSquads()
{
	return `LWSQUADMGR.Squads.Length;
}

simulated function NextSquad()
{
	if (!CurrentSquadIsValid()) return;

	CurrentSquadIndex = ((CurrentSquadIndex + 1) >=  GetTotalSquads()) ? 0 : CurrentSquadIndex + 1;
	UpdateAll(true);
}

simulated function PrevSquad()
{
	if (!CurrentSquadIsValid()) return;

	CurrentSquadIndex = ((CurrentSquadIndex - 1) < 0) ? (GetTotalSquads() - 1) : CurrentSquadIndex - 1;
	UpdateAll(true);
}

simulated function CreateSquad()
{
	local int TotalSquads;
	
	TotalSquads = GetTotalSquads();
	
	// KDM : Don't store `LWSQUADMGR in a variable and access it after calling CreateEmptySquad(); the reference has become stale !
	`LWSQUADMGR.CreateEmptySquad();

	CurrentSquadIndex = TotalSquads;
	UpdateAll(true);

	// KDM : A squad has been added so LW's underlying squad data is messed up and needs to be refreshed.
	SetLWSelectedSquadRef();
}

simulated function SetLWSelectedSquadRef(optional StateObjectReference SquadRef)
{
	// KDM : We have been given a valid squad reference, so select that squad.
	if (SquadRef.ObjectID > 0)
	{
		class'Utilities'.static.SetSquad(SquadRef);
	}
	// KDM : We were not given a valid squad reference, however, squads exist, so select the 1st squad.
	else if (`LWSQUADMGR.Squads.Length > 0)
	{
		class'Utilities'.static.SetSquad(`LWSQUADMGR.GetSquad(0).GetReference());
	}
}

simulated function DeleteSelectedSquad()
{
	local TDialogueBoxData DialogData;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	
	if (!CurrentSquadIsValid()) return;

	CurrentSquadState = GetCurrentSquad();

	// LW : Don't delete a squad if it is on a mission.
	if (!(CurrentSquadState.bOnMission || (CurrentSquadState.CurrentMission.ObjectID > 0)))
	{
		DialogData.eType = eDialog_Normal;
		DialogData.strTitle = class'UIPersonnel_SquadBarracks'.default.strDeleteSquadConfirm;
		DialogData.strText = class'UIPersonnel_SquadBarracks'.default.strDeleteSquadConfirmDesc;
		DialogData.fnCallback = OnDeleteSelectedSquadCallback;
		DialogData.strAccept = class'UIDialogueBox'.default.m_strDefaultAcceptLabel;
		DialogData.strCancel = class'UIDialogueBox'.default.m_strDefaultCancelLabel;
		Movie.Pres.UIRaiseDialog(DialogData);
	}
}

simulated function OnDeleteSelectedSquadCallback(Name eAction)
{
	local int TotalSquads;
	local StateObjectReference CurrentSquadRef;

	if (eAction == 'eUIAction_Accept')
	{
		CurrentSquadRef = `LWSQUADMGR.Squads[CurrentSquadIndex];

		// KDM : Don't store `LWSQUADMGR in a variable and access it after calling RemoveSquadByRef(); the reference has become stale !
		`LWSQUADMGR.RemoveSquadByRef(CurrentSquadRef);
		
		TotalSquads = GetTotalSquads();
		
		// KDM : We have 3 possible conditions here :
		// 1.] If there are no longer any squads, set CurrentSquadIndex to -1.
		// 2.] If CurrentSquadIndex is equal to the number of squads, we must have deleted the last squad; therefore, select the 'new' last squad.
		// 3.] Neither condition 1 nor 2 are true; therefore, we can select the squad next to the deleted squad by leaving CurrentSquadIndex unchanged.
		if (TotalSquads == 0)
		{
			CurrentSquadIndex = -1;
		}
		else if (CurrentSquadIndex >= TotalSquads)
		{
			CurrentSquadIndex = TotalSquads - 1;
		}
		
		UpdateAll(true);

		// KDM : A squad has been deleted so LW's underlying squad data is messed up and needs to be refreshed.
		SetLWSelectedSquadRef();
	}
}

simulated function RenameSquad()
{
	local TInputDialogData DialogData;

	if (!CurrentSquadIsValid()) return;

	DialogData.strTitle = class'UIPersonnel_SquadBarracks'.default.strRenameSquad;
	DialogData.iMaxChars = 50;
	DialogData.strInputBoxText = GetCurrentSquad().sSquadName;
	DialogData.fnCallback = OnRenameInputBoxClosed;

	`HQPRES.UIInputDialog(DialogData);
}

function OnRenameInputBoxClosed(string NewSquadName)
{
	local XComGameState NewGameState;
	local XComGameState_LWPersistentSquad CurrentSquadState;

	if (NewSquadName != "")
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Renaming Squad");
		CurrentSquadState = GetCurrentSquad();
		CurrentSquadState = XComGameState_LWPersistentSquad(NewGameState.CreateStateObject(class'XComGameState_LWPersistentSquad', CurrentSquadState.ObjectID));
		CurrentSquadState.sSquadName = NewSquadName;
		CurrentSquadState.bTemporary = false;
		NewGameState.AddStateObject(CurrentSquadState);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		UpdateSquadUI();
	}
}

function EditSquadBiography()
{
	local TInputDialogData DialogData;

	if (!CurrentSquadIsValid()) return;

	DialogData.strTitle = class'UIPersonnel_SquadBarracks'.default.strEditBiography;
	DialogData.iMaxChars = 500;
	DialogData.strInputBoxText = GetCurrentSquad().sSquadBiography;
	DialogData.fnCallback = OnEditBiographyInputBoxClosed;
	DialogData.DialogType = eDialogType_MultiLine;

	Movie.Pres.UIInputDialog(DialogData);
}

function OnEditBiographyInputBoxClosed(string NewSquadBio)
{
	local XComGameState NewGameState;
	local XComGameState_LWPersistentSquad CurrentSquadState;

	if (NewSquadBio != "")
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Edit Squad Biography");
		CurrentSquadState = GetCurrentSquad();
		CurrentSquadState = XComGameState_LWPersistentSquad(NewGameState.CreateStateObject(class'XComGameState_LWPersistentSquad', CurrentSquadState.ObjectID));
		CurrentSquadState.sSquadBiography = NewSquadBio;
		NewGameState.AddStateObject(CurrentSquadState);
		`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

		UpdateSquadUI();
	}
}

// LWotC: Integrated from Robojumper's Better Squad Icon Selector.
function EditSquadIcon()
{
	local UISquadIconSelectionScreen_ForControllers IconSelectionScreen;
	local XComPresentationLayerBase HQPres;
	
	if (!CurrentSquadIsValid()) return;
	if (CurrentSquadIcon == none) return;

	HQPres = `HQPRES;

	if (HQPres != none && HQPres.ScreenStack.IsNotInStack(class'UISquadIconSelectionScreen_ForControllers'))
	{
		IconSelectionScreen = HQPres.Spawn(class'UISquadIconSelectionScreen_ForControllers', HQPres);
		IconSelectionScreen.BelowScreen = self;
		IconSelectionScreen.BelowScreen.bHideOnLoseFocus = false;
		HQPres.ScreenStack.Push(IconSelectionScreen, HQPres.Get2DMovie());
	}
}

simulated function ToggleUIFocus()
{
	SetUIFocus(!SoldierUIFocused);
}

simulated function SetUIFocus(bool NewUIFocus, optional bool Forced = false)
{
	if (Forced || (SoldierUIFocused != NewUIFocus))
	{
		SoldierUIFocused = NewUIFocus;
		UpdateUIForFocus();
	}
}

simulated function ResetUIFocus()
{
	// KDM : By default, the squad UI has focus.
	SetUIFocus(false, true);
}

simulated function UpdateUIForFocus()
{
	local int FocusAlpha, UnfocusAlpha, TopUIAlpha, BottomUIAlpha;

	FocusAlpha = 100;
	UnfocusAlpha = 75;

	TopUIAlpha = (!SoldierUIFocused) ? FocusAlpha : UnfocusAlpha;
	BottomUIAlpha = (SoldierUIFocused) ? FocusAlpha : UnfocusAlpha;
	
	SquadHeader.SetAlpha(TopUIAlpha);
	CurrentSquadIcon.SetAlpha(TopUIAlpha);
	CurrentSquadStatus.SetAlpha(TopUIAlpha);
	CurrentSquadMissions.SetAlpha(TopUIAlpha);
	SoldierIconList.SetAlpha(TopUIAlpha);
	CurrentSquadBio.SetAlpha(TopUIAlpha);

	SquadSoldiersTab.SetAlpha(BottomUIAlpha);
	AvailableSoldiersTab.SetAlpha(BottomUIAlpha);
	m_kSoldierSortHeader.SetAlpha(BottomUIAlpha);
	m_kList.SetAlpha(BottomUIAlpha);
}

simulated function ToggleTabFocus()
{
	SetTabFocus(!DisplayingAvailableSoldiers);
}

simulated function SetTabFocus(bool NewTabFocus, optional bool Forced = false)
{
	if (Forced || (DisplayingAvailableSoldiers != NewTabFocus))
	{
		DisplayingAvailableSoldiers = NewTabFocus;
		UpdateTabsForFocus();
	}
}

simulated function UpdateTabsForFocus()
{
	if (DisplayingAvailableSoldiers)
	{
		SquadSoldiersTab.SetSelected(false);
		AvailableSoldiersTab.SetSelected(true);
	}
	else
	{
		SquadSoldiersTab.SetSelected(true);
		AvailableSoldiersTab.SetSelected(false);
	}
}

simulated function bool CanViewCurrentSquad()
{
	local robojumper_UISquadSelect SquadSelectScreen;

	SquadSelectScreen = class'Utilities'.static.GetRobojumpersSquadSelectFromStack();
	
	if (!CurrentSquadIsValid()) return false;
	// KDM : Don't allow squad viewing when coming through : Squad Select --> Squad Menu.
	if (SquadSelectScreen != none) return false;
	// KDM : LW logic doesn't allow squad viewing if the squad is on a mission; this is a good idea, as I don't want to
	// make an on-mission squad temporarily active. 
	if (GetCurrentSquad().bOnMission) return false;

	return true;
}

simulated function ViewCurrentSquad()
{
	// KDM REMOVE
	//local XComGameState NewGameState;
	//local XComGameState_LWSquadManager SquadManager, UpdatedSquadManager;
	
	if (!CanViewCurrentSquad()) return;

	// KDM : Store the current mission squad.
	CachedSquad = `LWSQUADMGR.LaunchingMissionSquad;
	RestoreCachedSquad = true;

	// KDM : Set the selected squad as the mission squad, so we can temporarily view it.
	class'Utilities'.static.SetSquad(GetCurrentSquad().GetReference());
	
	`HQPRES.UISquadSelect();


	// KDM : In LW2, these conditions disabled the button whose click called this function. Since I create no such button,
	// just return if these conditions are met.
	/*if (bSelectSquad && CurrentSquadState.bOnMission) return;

	if (bSelectSquad)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Assign persistent squad as current mission squad");
		SquadManager = `LWSQUADMGR;
		UpdatedSquadManager = XComGameState_LWSquadManager(NewGameState.CreateStateObject(SquadManager.Class, SquadManager.ObjectID));
		NewGameState.AddStateObject(UpdatedSquadManager);
		UpdatedSquadManager.LaunchingMissionSquad = CurrentSquadState.GetReference();
	
		CurrentSquadState.SetSquadCrew(NewGameState, false, false);

		`GAMERULES.SubmitGameState(NewGameState);

		CloseScreen();
	}
	else
	{
		CurrentSquadState.SetSquadCrew(, CurrentSquadState.bTemporary, true);

		CachedSquad = `XCOMHQ.Squad;
		bRestoreCachedSquad = true;

		`HQPRES.UISquadSelect();
	}*/
}

simulated function OnReceiveFocus()
{
	// KDM REMOVE
	//local XComGameState_HeadquartersXCom XComHQ;
	//local XComGameState NewGameState;

	// KDM : We are coming back from viewing a squad.
	if (RestoreCachedSquad)
	{
		RestoreCachedSquad = false;

		class'Utilities'.static.SetSquad(CachedSquad);
	}

	// LWS : If you were in 'view mode', restore the previously selected squad.
	/*if (bRestoreCachedSquad)
	{
		NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Restore previous soldiers to XComHQ Squad");
		XComHQ = XComGameState_HeadquartersXCom(NewGameState.CreateStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
		XComHQ.Squad = CachedSquad;
		NewGameState.AddStateObject(XComHQ);
		`GAMERULES.SubmitGameState(NewGameState);

		bRestoreCachedSquad = false;
		CachedSquad.Length = 0;

		// KDM : IS THE CURRENT INDEX AND UI STILL OK? NEED TO TEST.
		// CurrentSquadIndex = ((CurrentSquadIndex - 1) < 0) ? (GetTotalSquads() - 1) : CurrentSquadIndex - 1;
		// UpdateAll(true, true);
	}*/

	super(UIScreen).OnReceiveFocus();
	UpdateNavHelp();
}

simulated function OnLoseFocus()
{
	`HQPRES.m_kAvengerHUD.NavHelp.ClearButtonHelp();

	super.OnLoseFocus();
}

simulated function OnRemoved()
{
	local UISquadMenu SquadMenu;

	SquadMenu = class'Utilities'.static.GetUISquadMenuFromStack();
	
	// KDM : We are exiting the SquadBarracks and heading back to the Squad Menu.
	// Save the index of the squad we were looking at, so it can be selected when the Squad Menu receives focus.
	if (SquadMenu != none)
	{
		SquadMenu.CachedIndex = CurrentSquadIndex;
	}

	super.OnRemoved();
}

simulated function UpdateNavHelp()
{
	local string NavString;
	local UINavigationHelp NavHelp;

	NavHelp =`HQPRES.m_kAvengerHUD.NavHelp;
	
	NavHelp.ClearButtonHelp();
	NavHelp.bIsVerticalHelp = true;

	if (!CurrentSquadIsValid())
	{
		// KDM : If the squad is not valid, the soldier UI shouldn't be able to gain focus.
		if (!SoldierUIFocused)
		{
			NavHelp.AddBackButton();
			NavHelp.AddLeftHelp(CreateSquadStr, class'UIUtilities_Input'.const.ICON_Y_TRIANGLE);
		}
	}
	else
	{
		NavHelp.AddBackButton();

		// KDM : If the squad UI is focussed.
		if (!SoldierUIFocused)
		{
			NavHelp.AddLeftHelp(ScrollSquadBioStr, class'UIUtilities_Input'.const.ICON_RSTICK);
			NavHelp.AddLeftHelp(ChangeSquadIconStr, class'UIUtilities_Input'.const.ICON_LSCLICK_L3);
			NavHelp.AddLeftHelp(EditSquadBioStr, class'UIUtilities_Input'.const.ICON_RT_R2);
			NavHelp.AddLeftHelp(RenameSquadStr, class'UIUtilities_Input'.const.ICON_LT_L2);
			NavHelp.AddLeftHelp(DeleteSquadStr, class'UIUtilities_Input'.const.ICON_X_SQUARE);
			NavHelp.AddLeftHelp(CreateSquadStr, class'UIUtilities_Input'.const.ICON_Y_TRIANGLE);
			NavHelp.AddLeftHelp(FocusUISoldiersStr, class'UIUtilities_Input'.const.ICON_RSCLICK_R3);

			NavHelp.AddCenterHelp(PrevSquadStr, class'UIUtilities_Input'.const.ICON_LB_L1);
			NavHelp.AddCenterHelp(NextSquadStr, class'UIUtilities_Input'.const.ICON_RB_R1);

			if (CanViewCurrentSquad())
			{
				// KDM : For some reason, bIsVerticalHelp has to be false for the right container, else the help falls off the side of the screen.
				NavHelp.bIsVerticalHelp = false;
				NavHelp.AddRightHelp(ViewSquadStr, class'UIUtilities_Input'.const.ICON_BACK_SELECT);
			}
		}
		// KDM : If the soldier UI is focussed.
		else
		{
			NavString = (DisplayingAvailableSoldiers) ? TransferToSquadStr : RemoveFromSquadStr;
			NavHelp.AddLeftHelp(NavString, class'UIUtilities_Input'.const.ICON_A_X);
			NavHelp.AddLeftHelp(FocusUISquadStr, class'UIUtilities_Input'.const.ICON_RSCLICK_R3);
			
			NavHelp.AddCenterHelp(ViewSquadSoldiersStr, class'UIUtilities_Input'.const.ICON_LB_L1);
			NavHelp.AddCenterHelp(ViewAvailableSoldierStr, class'UIUtilities_Input'.const.ICON_RB_R1);
			NavHelp.AddCenterHelp(m_strToggleSort, class'UIUtilities_Input'.const.ICON_X_SQUARE);
			NavHelp.AddCenterHelp(m_strChangeColumn, class'UIUtilities_Input'.const.ICON_DPAD_HORIZONTAL);
			
			if (DetailsManagerExists())
			{
				NavHelp.bIsVerticalHelp = false;
				NavHelp.AddRightHelp(CAPS(class'MoreDetailsManager'.default.m_strToggleDetails), class'UIUtilities_Input'.const.ICON_RT_R2);
			}
		}
	}	

	NavHelp.Show();
}

simulated function bool DetailsManagerExists()
{
	return (GetDetailsManager() != none);
}

simulated function ToggleListDetails()
{
	local MoreDetailsManager DetailsManager;

	DetailsManager = GetDetailsManager();
	if (DetailsManager != none)
	{
		DetailsManager.OnToggleDetails();
	}
}

simulated function MoreDetailsManager GetDetailsManager()
{
	// KDM : The details manager is accessed through list items of type UIPersonnel_SoldierListItemDetailed; therefore, 
	// if no list items exist, we have to assume the details manager hasn't been set up.
	if (m_kList.ItemCount > 0)
	{
		return class'MoreDetailsManager'.static.GetParentDM(m_kList.GetItem(0));
	}

	return none;
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;
	
	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	//`log("KDM **** :" @ self.Movie.GetPathUnderMouse());
	//`log("KDM *** :" @ TempPanel.X @ TempPanel.Y @ TempPanel.Width @ TempPanel.Height);
	//`log("KDM *** :" @ MC.GetNum("SoldierListBG._x") @ MC.GetNum("SoldierListBG._y") @ MC.GetNum("SoldierListBG._width") @ MC.GetNum("SoldierListBG._height"));
	
	bHandled = true;

	// KDM : Right stick click toggles focus between the squad UI, on top, and the soldier UI, on the bottom.
	if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_R3)
	{
		if (CurrentSquadIsValid())
		{
			ToggleUIFocus();
			UpdateListUI(true);
			UpdateNavHelp();
		}
	}
	else if (cmd == class'UIUtilities_Input'.static.GetBackButtonInputCode())
	{
		CloseScreen();
	}
	else if (!SoldierUIFocused)
	{
		switch(cmd)
		{
			// KDM : Y button creates a squad.
			case class'UIUtilities_Input'.const.FXS_BUTTON_Y:
				CreateSquad();
				break;

			// KDM : X button deletes the selected squad.
			case class'UIUtilities_Input'.const.FXS_BUTTON_X:
				DeleteSelectedSquad();
				break;

			// KDM : Left bumper selects the previous squad.
			case class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER:
				PrevSquad();
				break;

			// KDM : Right bumper selects the next squad
			case class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER:
				NextSquad();
				break;

			// KDM : Left stick click changes squad icon.
			case class'UIUtilities_Input'.const.FXS_BUTTON_L3:
				EditSquadIcon();
				break;

			// KDM : Left trigger renames the squad.
			case class'UIUtilities_Input'.const.FXS_BUTTON_LTRIGGER:
				RenameSquad();
				break;
			
			// KDM : Right trigger edits the biography.
			case class'UIUtilities_Input'.const.FXS_BUTTON_RTRIGGER:
				EditSquadBiography();
				break;

			// KDM : Right stick up tells the squad biography to scroll up, if it is larger than its container size.
			case class'UIUtilities_Input'.const.FXS_VIRTUAL_RSTICK_UP:
				if (CurrentSquadIsValid())
				{
					CurrentSquadBio.OnChildMouseEvent(none, class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_DOWN);
				}
				break;

			// KDM : Right stick down tells the squad biography to scroll down, if it is larger than its container size.
			case class'UIUtilities_Input'.const.FXS_VIRTUAL_RSTICK_DOWN:
				if (CurrentSquadIsValid())
				{
					CurrentSquadBio.OnChildMouseEvent(none, class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_UP);
				}
				break;

			// KDM : Select button views the squad.
			case class'UIUtilities_Input'.const.FXS_BUTTON_SELECT:
				ViewCurrentSquad();
				break;

			default:
				bHandled = false;
				break;
		}
	}
	else if (SoldierUIFocused)
	{
		// KDM : Left bumper displays squad's soldiers while right bumper displays available soldiers.
		if (((cmd == class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER) && DisplayingAvailableSoldiers) ||
			((cmd == class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER) && (!DisplayingAvailableSoldiers)))
		{
			ToggleTabFocus();
			UpdateListUI(false);
			UpdateNavHelp();
		}
		// KDM : DPad left changes list column selection; this is UIPersonnel code.
		else if (cmd == class'UIUtilities_Input'.const.FXS_DPAD_LEFT)
		{
			m_bFlipSort = false;
			m_iSortTypeOrderIndex--;
			if (m_iSortTypeOrderIndex < 0)
			{
				m_iSortTypeOrderIndex = m_aSortTypeOrder.Length - 1;
			}
			SetSortType(m_aSortTypeOrder[m_iSortTypeOrderIndex]);
			UpdateSortHeaders();
			PlaySound(SoundCue'SoundUI.MenuScrollCue', true);
		}
		// KDM : DPad right changes list column selection; this is UIPersonnel code.
		else if (cmd == class'UIUtilities_Input'.const.FXS_DPAD_RIGHT)
		{
			m_bFlipSort = false;
			m_iSortTypeOrderIndex++;
			if (m_iSortTypeOrderIndex >= m_aSortTypeOrder.Length)
			{
				m_iSortTypeOrderIndex = 0;
			}
			SetSortType(m_aSortTypeOrder[m_iSortTypeOrderIndex]);
			UpdateSortHeaders();
			PlaySound(SoundCue'SoundUI.MenuScrollCue', true);
		}
		// KDM : X button changes list sorting.
		else if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_X)
		{
			m_bFlipSort = !m_bFlipSort;
			UpdateListUI(false, false);
		}
		// KDM : A button transfers a soldier to/from a squad, if possible.
		else if (cmd == class'UIUtilities_Input'.static.GetAdvanceButtonInputCode())
		{
			OnSoldierSelected(m_kList, m_kList.selectedIndex);
		}
		// KDM : Right trigger toggles the soldier list details.
		else if (cmd == class'UIUtilities_Input'.const.FXS_BUTTON_RTRIGGER)
		{
			ToggleListDetails();
		}
		else
		{
			bHandled = m_kList.OnUnrealCommand(cmd, arg);
		}
	}

	return bHandled; 
}

simulated function OnSoldierSelected(UIList SquadList, int SelectedIndex)
{
	local int SquadListSize;
	local UIPersonnel_ListItem SoldierListItem;
	local XComGameState NewGameState;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	local XComGameState_Unit CurrentSoldierState;

	if (!CurrentSquadIsValid()) return;
	if ((SelectedIndex < 0) || (SelectedIndex >= SquadList.ItemCount)) return;
	if (UIPersonnel_ListItem(SquadList.GetItem(SelectedIndex)).IsDisabled) return;

	CurrentSquadState = GetCurrentSquad();
	SoldierListItem = UIPersonnel_ListItem(SquadList.GetItem(SelectedIndex));
	CurrentSoldierState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(SoldierListItem.UnitRef.ObjectID));
	
	if (!CanTransferSoldier(CurrentSoldierState.GetReference(), CurrentSquadState)) return;

	NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Transferring Soldier");
	CurrentSquadState = XComGameState_LWPersistentSquad(NewGameState.CreateStateObject(class'XComGameState_LWPersistentSquad', CurrentSquadState.ObjectID));
	NewGameState.AddStateObject(CurrentSquadState);

	if(DisplayingAvailableSoldiers)
	{
		CurrentSquadState.AddSoldier(CurrentSoldierState.GetReference());
	}
	else
	{
		CurrentSquadState.RemoveSoldier(CurrentSoldierState.GetReference());
	}

	`XCOMGAME.GameRuleset.SubmitGameState(NewGameState);

	// KDM : Normally I would just update the list UI; howver, the squad's soldier icon list also needs to be updated.
	UpdateAll(false);
	
	// KDM : Attempt to keep the same item index selected for continuity.
	SquadListSize = SquadList.ItemCount;
	if ((SquadListSize > 0) && (SquadList.SelectedIndex != SelectedIndex))
	{
		if (SelectedIndex >= SquadListSize)
		{
			SelectedIndex = SquadListSize - 1;
		}
		SquadList.SetSelectedIndex(SelectedIndex);

		if (SquadList.Scrollbar != none)
		{
			SquadList.Scrollbar.SetThumbAtPercent(float(SelectedIndex) / float(SquadListSize - 1));
		}
	}
}

simulated function bool CanTransferSoldier(StateObjectReference SoldierRef, optional XComGameState_LWPersistentSquad CurrentSquadState)
{
	local int CurrentSquadSize, MaxSquadSize;
	local XComGameState_Unit CurrentSoldierState;
	
	CurrentSoldierState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(SoldierRef.ObjectID));

	// LW : You can't move soldiers on a mission; this does not include haven liaisons.
	if (class'LWDLCHelpers'.static.IsUnitOnMission(CurrentSoldierState) && (!`LWOUTPOSTMGR.IsUnitAHavenLiaison(CurrentSoldierState.GetReference())))
	{
		return false;
	}

	if (CurrentSquadState == none)
	{
		CurrentSquadState = GetCurrentSquad();
	}

	if (CurrentSquadState != none)
	{
		// LW : You can't add soldiers to squads that are on a mission.
		if(CurrentSquadState.bOnMission || CurrentSquadState.CurrentMission.ObjectID > 0)
		{
			if (DisplayingAvailableSoldiers)
			{
				return false;
			}
		}

		// LW : You can't add soldiers to a max size squad.
		CurrentSquadSize = CurrentSquadState.GetSoldiers().Length;
		MaxSquadSize = class'XComGameState_LWSquadManager'.default.MAX_SQUAD_SIZE;
		if (CurrentSquadSize >= MaxSquadSize)
		{
			if (DisplayingAvailableSoldiers)
			{
				return false;
			}
		}
	}

	return true;
}

defaultproperties
{
	PanelW = 985;
	PanelH = 985;

	BorderPadding = 10;
	
	SquadIconSize = 144;
	SquadIconBorderSize = 3;

	// KDM : Some of UIPersonnel's functions rely upon m_eListType and m_eCurrentTab being set; therefore, set them here.
	m_eListType = eUIPersonnel_Soldiers;
	m_eCurrentTab = eUIPersonnel_Soldiers;

	m_eSortType = ePersonnelSoldierSortType_Rank;
	
	m_iMaskWidth = 961;
	m_iMaskHeight = 670;

	CurrentSquadIndex = -1;

	SoldierUIFocused = false;
	DisplayingAvailableSoldiers = false;

	RestoreCachedSquad = false;
}
