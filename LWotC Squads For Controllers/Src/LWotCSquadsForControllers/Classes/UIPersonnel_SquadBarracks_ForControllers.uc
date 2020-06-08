// Default flash background is - X/Y/WIDTH/HEIGHT : 480.0000 90.0000 1000.0000 895.9500

class UIPersonnel_SquadBarracks_ForControllers extends UIPersonnel config(SquadSettings);

// KDM TO DO : IF NO SQUAD'S EXIST
// NAVIGATION
// FLIP SORT BUTTON WHEN CLICKED CALLS - RefreshData - might need to deal with that - actually probably just mouse stuff - controller dealt with in OnUnrealCommand

// KDM : This is needed for the squad icon selector.
var config array<string> SquadImagePaths;

var localized string TitleStr, NoSquadsStr, DashesStr, StatusStr, MissionsStr, BiographyStr, SquadSoldiersStr, AvailableSoldiersStr;

// KDM : Determines whether the squad UI, located at the top, or the soldier UI, located at the bottom, is focused.
var bool SoldierUIFocused;

// KDM : Determines whether the list is displaying available soldiers, or a squad's soldiers.
var bool DisplayingAvailableSoldiers;

var int CurrentSquadIndex;

var bool bSelectSquad; // KDM UNUSED RIGHT NOW
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

	// KDM : Hide pre-built UI elements we won't be using via Flash; the alternative is to spawn them, init them with the appropriate
	// MC name, then hide them.
	MC.ChildFunctionVoid("SoldierListBG", "Hide");
	MC.ChildFunctionVoid("deceasedSort", "Hide");
	MC.ChildFunctionVoid("personnelSort", "Hide");
}

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local int AvailableW, XLoc, YLoc, HeightVal, WidthVal;

	super(UIScreen).InitScreen(InitController, InitMovie, InitName);

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

	// KDM : Squad mission information & biography.
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
	
	CreateListHeader();

	// KDM : Soldier list.
	XLoc = MainPanel.X + SquadSoldiersTab.X;
	YLoc = MainPanel.Y + SquadSoldiersTab.Y + 75;
	m_kList = Spawn(class'UIList', self);
	m_kList.bStickyHighlight = false;
	m_kList.InitList('listAnchor', XLoc, YLoc, m_iMaskWidth, m_iMaskHeight);
	m_kList.MoveToHighestDepth();

	// KDM : If at least 1 squad exists, select the 1st one by setting CurrentSquadIndex to 0.
	// If no squads exist, signify this by setting CurrentSquadIndex to -1.
	CurrentSquadIndex = (SquadsExist()) ? 0 : -1;

	UpdateAll();
}

simulated function CreateListHeader()
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

simulated function UpdateAll()
{
	UpdateSquadUI();

	UpdateListData();
	SortListData();
	UpdateListUI();

	UpdateTabsForFocus();
	UpdateUIForFocus();
}

simulated function UpdateSquadUI()
{
	local bool NoSquads;
	local int TextState;
	local string SquadTitle, SquadStatus, SquadMissions, SquadBio;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	local XGParamTag ParamTag;
	
	NoSquads = !SquadsExist();
	CurrentSquadState = GetCurrentSquad();

	// KDM : If no squads exist set up the UI a little differently, then exit.
	if (NoSquads)
	{
		return;
	}

	// KDM : Somehow squads exist, yet no squad is selected; this shouldn't happen, so just exit.
	if (CurrentSquadState == none) return;

	// KDM : Set the squad title, which is of the form 'SQUAD [1/4] : NAME_OF_SQUAD'.
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.IntValue0 = CurrentSquadIndex + 1;
	ParamTag.IntValue1 = GetTotalSquads();
	ParamTag.StrValue0 = CurrentSquadState.sSquadName;
	SquadTitle = `XEXPAND.ExpandString(TitleStr);
	
	SquadHeader.SetText(SquadTitle);
	// KDM : There is flash bug in UIX2PanelHeader such that the text is only updated after realize() is called.
	// Unfortunately, SetText() doesn't call realize(), so we have to do it ourself.
	SquadHeader.MC.FunctionVoid("realize");

	// KDM : Set the squad icon.
	CurrentSquadIcon.LoadImage(CurrentSquadState.GetSquadImagePath());
	
	// KDM : Set the squad status; it will be wither 'ON MISSION' or 'AVAILABLE'.
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
	
	// KDM : Update the soldier icon list.
	UpdateSoldierClassIcons(CurrentSquadState);

	// KDM : Set the squad biography; this includes the number of missions on the 1st line.
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = CurrentSquadState.sSquadBiography;
	SquadBio = `XEXPAND.ExpandString(BiographyStr);
	CurrentSquadBio.SetText(SquadBio);
}

simulated function UpdateListData()
{
	local XComGameState_LWSquadManager SquadManager;

	SquadManager = `LWSQUADMGR;
	m_arrSoldiers.Length = 0;

	if (!CurrentSquadIsValid()) return;

	if (DisplayingAvailableSoldiers)
	{
		m_arrSoldiers = SquadManager.GetUnassignedSoldiers();
	}
	else
	{
		m_arrSoldiers = SquadManager.GetSquad(CurrentSquadIndex).GetSoldierRefs(true);
	}
}

simulated function SortListData()
{
	SortData();
}

simulated function UpdateListUI()
{
	local int i;
	local UIPersonnel_ListItem SoldierListItem;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	
	super.UpdateList();

	CurrentSquadState = GetCurrentSquad();

	// LW2 : Determine whether each soldier can be transferred or not.
	for (i = 0; i < m_kList.itemCount; i++)
	{
		SoldierListItem = UIPersonnel_ListItem(m_kList.GetItem(i));

		// LW2 : If we are viewing a squad on a mission, mark units not on the mission with a lower alpha value.
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

// KDM : LW2 function.
simulated function int GetClassIconAlphaStatus(XComGameState_Unit SoldierState, XComGameState_LWPersistentSquad CurrentSquadState)
{
	local bool IsSquadDeployedOnMission, IsSoldierOnMission;
	
	IsSquadDeployedOnMission = CurrentSquadState.IsDeployedOnMission();
	IsSoldierOnMission = CurrentSquadState.IsSoldierOnMission(SoldierState.GetReference());

	// LW2 : If the squad is on a mission, but this squad's soldier isn't, dim the icon regardless of their actual status.
	if (IsSquadDeployedOnMission && (!IsSoldierOnMission)) return 30;
	
	switch (SoldierState.GetStatus())
	{
		case eStatus_Active:
			if (CurrentSquadState.bOnMission && CurrentSquadState.IsSoldierTemporary(SoldierState.GetReference())) return 50;
			else return 100;

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

// KDM : LW2 function.
simulated function UpdateSoldierClassIcons(XComGameState_LWPersistentSquad CurrentSquadState)
{
	local int i, StartIndex;
	local array<XComGameState_Unit> SoldierStates;
	local UISquadClassItem SoldierClassIcon;
	local XComGameState_Unit SoldierState;
	
	SoldierStates = CurrentSquadState.GetSoldiers();
	
	// LWS : Add permanent soldiers icons
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
	
	// LWS : Add temporary soldiers icons
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

	// LWS : Hide additional icons
	if (SoldierIconList.GetItemCount() > StartIndex)								
	{
		for (i = StartIndex; i < SoldierIconList.GetItemCount(); i++)
		{
			SoldierClassIcon = UISquadClassItem(SoldierIconList.GetItem(i));
			SoldierClassIcon.Hide();
		}
	}
}

// KDM : LW2 function modified.
simulated function XComGameState_LWPersistentSquad GetCurrentSquad()
{
	local StateObjectReference CurrentSquadRef;
	
	if (CurrentSquadIndex < 0)
	{
		return none;
	}
	
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
	UpdateAll();
}

simulated function PrevSquad()
{
	if (!CurrentSquadIsValid()) return;

	CurrentSquadIndex = ((CurrentSquadIndex - 1) < 0) ? (GetTotalSquads() - 1) : CurrentSquadIndex - 1;
	UpdateAll();
}

simulated function CreateSquad()
{
	local int TotalSquads;

	TotalSquads = GetTotalSquads();
	
	// KDM : Don't store `LWSQUADMGR in a variable and access it after calling CreateEmptySquad(); the reference has become stale !
	`LWSQUADMGR.CreateEmptySquad();

	// KDM : Since we added 1 squad above, TotalSquads is now the 'index' of the last squad in the array; the squad we just added.
	CurrentSquadIndex = TotalSquads;
	UpdateAll();
}

simulated function DeleteSelectedSquad()
{
	local TDialogueBoxData DialogData;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	
	if (!CurrentSquadIsValid()) return;

	CurrentSquadState = GetCurrentSquad();

	// LW2 : Don't delete a squad if it is on a mission.
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
		
		UpdateAll();
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

		UpdateAll();
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

		UpdateAll();
	}
}

// LWOTC: Integrated from robojumper's Better Squad Icon Selector mod
function EditSquadIcon()
{
	local UISquadIconSelectionScreen_ForControllers IconSelectionScreen;
	local XComPresentationLayerBase HQPres;
	
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

simulated function SetUIFocus(bool NewUIFocus)
{
	SoldierUIFocused = NewUIFocus;
}

simulated function ResetUIFocus()
{
	// KDM : By default, the squad UI on top, has focus.
	SetUIFocus(false);
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

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	// KDM TEMP : KEYBOARD KEYS
	local bool bHandled;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	//`log("KDM **** :" @ self.Movie.GetPathUnderMouse());
	//`log("KDM *** :" @ TempPanel.X @ TempPanel.Y @ TempPanel.Width @ TempPanel.Height);
	//`log("KDM *** :" @ MC.GetNum("SoldierListBG._x") @ MC.GetNum("SoldierListBG._y") @ MC.GetNum("SoldierListBG._width") @ MC.GetNum("SoldierListBG._height"));
	

	bHandled = true;

	switch(cmd)
	{
		// KDM : Right stick click toggles focus between the squad UI, on top, and the soldier UI, on the bottom.
		case class'UIUtilities_Input'.const.FXS_BUTTON_R3:
			ToggleUIFocus();
			UpdateUIForFocus();
			break;








		case class'UIUtilities_Input'.const.FXS_VIRTUAL_RSTICK_UP:
			CurrentSquadBio.OnChildMouseEvent(none, class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_DOWN);
			break;

		case class'UIUtilities_Input'.const.FXS_VIRTUAL_RSTICK_DOWN:
			CurrentSquadBio.OnChildMouseEvent(none, class'UIUtilities_Input'.const.FXS_MOUSE_SCROLL_UP);
			break;

		// KDM : Left trigger changes squad icon.
		case class'UIUtilities_Input'.const.FXS_BUTTON_LTRIGGER:
		case class'UIUtilities_Input'.const.FXS_KEY_Z:
			EditSquadIcon();
			break;

		// KDM : Right stick click edit the biography.
		case class'UIUtilities_Input'.const.FXS_BUTTON_R3:
		case class'UIUtilities_Input'.const.FXS_KEY_Y:
			EditSquadBiography();
			break;

		// KDM : Left stick click renames the squad.
		case class'UIUtilities_Input'.const.FXS_BUTTON_L3:
		case class'UIUtilities_Input'.const.FXS_KEY_X:
			RenameSquad();
			break;

		// KDM : Y button creates a squad.
		case class'UIUtilities_Input'.const.FXS_BUTTON_Y:
		case class'UIUtilities_Input'.const.FXS_KEY_E:
			CreateSquad();
			break;

		// KDM : X button deletes the selected squad.
		case class'UIUtilities_Input'.const.FXS_BUTTON_X:
		case class'UIUtilities_Input'.const.FXS_KEY_Q:
			DeleteSelectedSquad();
			break;

		// KDM : Left bumper selects the previous squad.
		case class'UIUtilities_Input'.const.FXS_BUTTON_LBUMPER:
		case class'UIUtilities_Input'.const.FXS_ARROW_LEFT:
			PrevSquad();
			break;

		// KDM : Right bumper selects the next squad
		case class'UIUtilities_Input'.const.FXS_BUTTON_RBUMPER:
		case class'UIUtilities_Input'.const.FXS_ARROW_RIGHT:
			NextSquad();
			break;

		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
		case class'UIUtilities_Input'.const.FXS_KEY_ESCAPE:
		case class'UIUtilities_Input'.const.FXS_R_MOUSE_DOWN:
			CloseScreen();
			break;

		default:
			bHandled = false;
			break;
	}

	return bHandled || super(UIScreen).OnUnrealCommand(cmd, arg);
}

simulated function bool CanTransferSoldier(StateObjectReference SoldierRef, optional XComGameState_LWPersistentSquad CurrentSquadState)
{
	local int CurrentSquadSize, MaxSquadSize;
	local XComGameState_Unit CurrentSoldierState;
	
	CurrentSoldierState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(SoldierRef.ObjectID));

	// LW2 : You can't move soldiers on a mission; this does not include haven liaisons.
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
		// LW2 : You can't add soldiers to squads that are on a mission.
		if(CurrentSquadState.bOnMission || CurrentSquadState.CurrentMission.ObjectID > 0)
		{
			if (DisplayingAvailableSoldiers)
			{
				return false;
			}
		}

		// LW2 : You can't add soldiers to a max size squad.
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
	PanelH = 900;

	BorderPadding = 10;
	
	SquadIconSize = 144;
	SquadIconBorderSize = 3;

	// KDM : Some of UIPersonnel's functions rely upon m_eListType and m_eCurrentTab being set; therefore, set them here.
	m_eListType = eUIPersonnel_Soldiers;
	m_eCurrentTab = eUIPersonnel_Soldiers;
	
	m_iMaskWidth = 961;
	m_iMaskHeight = 658;

	CurrentSquadIndex = -1;

	SoldierUIFocused = false;
	DisplayingAvailableSoldiers = false;
}

// Looks like UIPersonnel size is
// m_iMaskWidth = 961;
// m_iMaskHeight = 780;