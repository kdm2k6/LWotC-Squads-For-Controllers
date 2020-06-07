// MC.ChildFunctionVoid("personnelSort", "MoveToHighestDepth");
// Default flash background is - X/Y/WIDTH/HEIGHT : 480.0000 90.0000 1000.0000 895.9500

class UIPersonnel_SquadBarracks_ForControllers extends UIPersonnel;

// KDM TO DO : IF NO SQUAD'S EXIST
// Probably make a function like : IsCurrentSquadValid() - returns false if no squads or selected index is -1

var localized string TitleStr, NoSquadsStr, DashesStr, StatusStr, MissionsStr, BiographyStr;

var int CurrentSquadIndex;

var bool bSelectSquad;
var int PanelW, PanelH;

var int BorderPadding, FontSize; 
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

	// KDM : Hide the pre-built flash background panel; we use our own custom UI.
	MC.ChildFunctionVoid("SoldierListBG", "Hide");
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
	CurrentSquadBio.InitTextContainer(, , XLoc, YLoc, WidthVal, HeightVal, false, , true);
	CurrentSquadBio.SetText("Current Squad Bio");

	AvailableW = PanelW - (BorderPadding * 3);

	// KDM : Squad soldiers tab.
	XLoc = BorderPadding;
	YLoc = SquadIconBG1.Y + SquadIconBG1.Height + BorderPadding;
	WidthVal = int(float(AvailableW) * 0.5);
	SquadSoldiersTab = Spawn(class'UIButton', MainPanel);
	SquadSoldiersTab.ResizeToText = false;
	SquadSoldiersTab.InitButton(, "Squad soldiers tab", , eUIButtonStyle_NONE);
	SquadSoldiersTab.SetPosition(XLoc, YLoc);
	SquadSoldiersTab.SetWidth(WidthVal);
	
	// KDM : Available soldiers tab.
	XLoc = SquadSoldiersTab.X + SquadSoldiersTab.Width + BorderPadding;
	YLoc = SquadSoldiersTab.Y;
	WidthVal = int(float(AvailableW) * 0.5);
	AvailableSoldiersTab = Spawn(class'UIButton', MainPanel);
	AvailableSoldiersTab.ResizeToText = false;
	AvailableSoldiersTab.InitButton(, "Available soldiers tab", , eUIButtonStyle_NONE);
	AvailableSoldiersTab.SetPosition(XLoc, YLoc);
	AvailableSoldiersTab.SetWidth(WidthVal);
	
	// KDM : If at least 1 squad exists, select the 1st one by setting CurrentSquadIndex to 0.
	// If no squads exist, signify this by setting CurrentSquadIndex to -1.
	CurrentSquadIndex = (SquadsExist()) ? 0 : -1;

	UpdateSquadUI();
	
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
	ParamTag.StrValue0 = CAPS(CurrentSquadState.sSquadName);
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
	UpdateSquadUI();
}

simulated function PrevSquad()
{
	if (!CurrentSquadIsValid()) return;

	CurrentSquadIndex = ((CurrentSquadIndex - 1) < 0) ? (GetTotalSquads() - 1) : CurrentSquadIndex - 1;
	UpdateSquadUI();
}

simulated function CreateSquad()
{
	local int TotalSquads;

	TotalSquads = GetTotalSquads();
	
	// KDM : Don't store `LWSQUADMGR in a variable and access it after calling CreateEmptySquad(); the reference has become stale !
	`LWSQUADMGR.CreateEmptySquad();

	// KDM : Since we added 1 squad above, TotalSquads is now the 'index' of the last squad in the array; the squad we just added.
	CurrentSquadIndex = TotalSquads;
	UpdateSquadUI();
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
		
		UpdateSquadUI();
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

		// KDM : Left trigger selects the previous squad.
		case class'UIUtilities_Input'.const.FXS_BUTTON_LTRIGGER:
		case class'UIUtilities_Input'.const.FXS_ARROW_LEFT:
			PrevSquad();
			break;

		// KDM : Right trigger selects the next squad
		case class'UIUtilities_Input'.const.FXS_BUTTON_RTRIGGER:
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



defaultproperties
{
	PanelW = 961;
	PanelH = 900;

	BorderPadding = 10;
	FontSize = 24;

	SquadIconSize = 144;
	SquadIconBorderSize = 3;

	m_eListType = eUIPersonnel_Soldiers;
	
	m_iMaskWidth = 961;
	m_iMaskHeight = 658;

	CurrentSquadIndex = -1;
}

// Looks like UIPersonnel size is
// m_iMaskWidth = 961;
// m_iMaskHeight = 780;