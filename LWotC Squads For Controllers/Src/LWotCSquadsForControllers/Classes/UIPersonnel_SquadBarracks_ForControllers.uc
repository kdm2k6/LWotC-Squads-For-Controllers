// MC.ChildFunctionVoid("personnelSort", "MoveToHighestDepth");
// Default flash background is - X/Y/WIDTH/HEIGHT : 480.0000 90.0000 1000.0000 895.9500

class UIPersonnel_SquadBarracks_ForControllers extends UIPersonnel;

var localized string TitleStr, SubtitleStr, NoSquadsStr;

var int CurrentSquadIndex;

var bool bSelectSquad;
var int PanelW, PanelH;

var int BorderPadding, FontSize, SquadIconSize;

var UIPanel MainPanel;
var UIBGBox SquadBG;
var UIX2PanelHeader SquadHeader;
var UIPanel DividerLine;
var UIImage CurrentSquadIcon;
var UIScrollingText CurrentSquadStatus;
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
	// TopBG_H was 300
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
	
	// KDM : Current squad's icon.
	XLoc = BorderPadding;
	YLoc = DividerLine.Y + 10;
	CurrentSquadIcon = Spawn(class'UIImage', MainPanel);
	CurrentSquadIcon.InitImage();
	CurrentSquadIcon.SetPosition(XLoc, YLoc);
	CurrentSquadIcon.SetSize(SquadIconSize, SquadIconSize);
	
	// KDM : Current squad's status.
	XLoc = CurrentSquadIcon.X + CurrentSquadIcon.Width + BorderPadding;
	YLoc = DividerLine.Y + 30;
	WidthVal = PanelW - SquadIconSize - (BorderPadding * 3);
	CurrentSquadStatus = Spawn(class'UIScrollingText', MainPanel);
	CurrentSquadStatus.InitScrollingText(, "Current Squad Status", WidthVal, XLoc, YLoc);

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
	YLoc = CurrentSquadIcon.Y + CurrentSquadIcon.Height + BorderPadding;
	WidthVal = int(float(AvailableW) * 0.5);
	SquadSoldiersTab = Spawn(class'UIButton', MainPanel);
	SquadSoldiersTab.ResizeToText = false;
	SquadSoldiersTab.InitButton(, "Squad soldiers tab", , eUIButtonStyle_NONE);
	SquadSoldiersTab.SetPosition(XLoc, YLoc);
	SquadSoldiersTab.SetWidth(WidthVal);
	
	// KDM : Available soldiers tab.
	XLoc = SquadSoldiersTab.X + SquadSoldiersTab.Width + BorderPadding;
	YLoc = CurrentSquadIcon.Y + CurrentSquadIcon.Height + BorderPadding;
	WidthVal = int(float(AvailableW) * 0.5);
	AvailableSoldiersTab = Spawn(class'UIButton', MainPanel);
	AvailableSoldiersTab.ResizeToText = false;
	AvailableSoldiersTab.InitButton(, "Available soldiers tab", , eUIButtonStyle_NONE);
	AvailableSoldiersTab.SetPosition(XLoc, YLoc);
	AvailableSoldiersTab.SetWidth(WidthVal);
	
	// KDM : If at least 1 squad exists, select the 1st one by setting CurrentSquadIndex to 0.
	// If no squads exist, signify this by setting CurrentSquadIndex to -1.
	CurrentSquadIndex = (GetTotalSquads() == 0) ? -1 : 0;

	UpdateSquadUI();
	
}

simulated function UpdateSquadUI()
{
	local bool NoSquads, NoSquadSelected;
	local string SquadTitle, SquadSubtitle;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	local XGParamTag ParamTag;
	
	NoSquads = (GetTotalSquads() == 0) ? true : false;
	
	// KDM : Set the squad title and subtitle; title is of the form 'SQUAD : NAME_OF_SQUAD' while subtitle is of the form '[1/4]'.
	ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
	ParamTag.StrValue0 = (NoSquads) ? NoSquadsStr : CAPS(SquadState.sSquadName);
	SquadTitle = `XEXPAND.ExpandString(TitleStr);

	if (GetTotalSquads() == 0)
	{
		
		
		ParamTag = XGParamTag(`XEXPANDCONTEXT.FindTag("XGParam"));
		ParamTag.IntValue0 = 0;
		ParamTag.IntValue1 = 0;
		Subtitle = `XEXPAND.ExpandString(SubtitleStr);

		SquadHeader.SetText(Title, Subtitle);
	}
	//var localized string TitleStr, SubtitleStr, NoSquadsStr;
}

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

simulated function int GetTotalSquads()
{
	return `LWSQUADMGR.Squads.Length;
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

	switch(cmd)
	{
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


/* LW2 VERSION
simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	// Init UI
	super(UIScreen).InitScreen(InitController, InitMovie, InitName);

	//shift the whole screen over to make room for the squad list
	SetPosition(340, 0);

	SquadListBG = Spawn(class'UIBGBox', self);
	SquadListBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	SquadListBG.InitBG('ListBG', -241, 123, 702, 863);

	m_kSquadList = Spawn(class'UIList', self);
	m_kSquadList.bIsNavigable = false;
	m_kSquadList.ItemPadding = 3;
	m_kSquadList.InitList(, SquadListBG.X + 11, SquadListBG.Y + 11, SquadListBG.width-47, SquadListBG.height-22, false ); //, true , class'UIUtilities_Controls'.const.MC_X2Background);
	m_kSquadList.bStickyHighlight = false;
	m_kSquadList.SetSelectedIndex(0);
	m_kSquadList.OnItemClicked = SquadListButtonCallback;

    // Redirect all mouse events for the background to the list. Ensures all mouse
    // wheel events get processed by the list instead of consumed by the background
    // when the cursor falls "between" list items.
    SquadListBG.ProcessMouseEvents(m_kSquadList.OnChildMouseEvent);

	DeleteSquadBtn = Spawn(class'UIButton', self);
	DeleteSquadBtn.SetResizeToText(false);
	DeleteSquadBtn.InitButton(, strDeleteSquad, OnDeleteClicked).SetPosition(SquadListBG.X+5, SquadListBG.Y - 28).SetWidth(190);

	CreateSquadBtn = Spawn(class'UIButton', self);
	CreateSquadBtn.SetResizeToText(false);
	CreateSquadBtn.InitButton(, strAddSquad, OnCreateSquadClicked).SetPosition(SquadListBG.X + SquadListBG.Width - 194, SquadListBG.Y - 28).SetWidth(190);

	m_kList = Spawn(class'UIList', self);
	m_kList.bIsNavigable = true;
	m_kList.InitList('listAnchor', 487, 316, m_iMaskWidth, m_iMaskHeight);
	m_kList.bStickyHighlight = false;

	UpperContainer = Spawn(class'UIPanel', self).InitPanel().SetPosition(492, 145).SetSize(994, 132);

	SquadImage = UIImage(Spawn(class'UIImage', UpperContainer).InitImage().SetSize(100, 100).SetPosition(8, 2));
	SquadImage.bProcessesMouseEvents = true;
	SquadImage.MC.FunctionVoid("processMouseEvents");
	SquadImage.OnClickedDelegate = OnSquadIconClicked;

	SquadImageSelectLeftButton = Spawn(class'UIButton', UpperContainer);
	SquadImageSelectLeftButton.LibID = 'X2DrawerButton';
	SquadImageSelectLeftButton.bAnimateOnInit = false;
	SquadImageSelectLeftButton.InitButton(,,OnImageScrollButtonClicked); 

	SquadImageSelectRightButton = Spawn(class'UIButton', UpperContainer);
	SquadImageSelectRightButton.LibID = 'X2DrawerButton';
	SquadImageSelectRightButton.bAnimateOnInit = false;
	SquadImageSelectRightButton.InitButton(,,OnImageScrollButtonClicked); 
	UpdateLeftRightButtonPositions();

	SquadMissionsText = Spawn(class'UIScrollingText', UpperContainer).InitScrollingText(, "Squad Name", 600,,,true);
	SquadMissionsText.SetPosition(11, 97);

	SquadBiography = Spawn(class'UITextContainer', UpperContainer);	
	SquadBiography.InitTextContainer( , "", 131, 5, 430, 121);
	SquadBiography.SetHTMLText(class'UIUtilities_Text'.static.GetColoredText("Bravely bold Sir Robin rode forth from Camelot\nHe was not afraid to die, O brave Sir Robin\nHe was not at all afraid to be killed in nasty ways\nBrave, brave, brave, brave Sir Robin\nHe was not in the least bit scared to be mashed into a pulp\nOr to have his eyes gouged out and his elbows broken\nTo have his kneecaps split and his body burned away\nAnd his limbs all hacked and mangled, brave Sir Robin", eUIState_Normal));
	//SquadBiography.SetHeight(121);

	SelectOrViewBtn = Spawn(class'UILargeButton', UpperContainer);
	if(bSelectSquad)
		SelectOrViewBtn.InitLargeButton(, strSelect, strSquad, OnEditOrSelectClicked).SetPosition(566, 14);
	else
		SelectOrViewBtn.InitLargeButton(, strEdit, strSquad, OnEditOrSelectClicked).SetPosition(566, 14);

	RenameSquadBtn = Spawn(class'UIButton', UpperContainer);
	RenameSquadBtn.SetResizeToText(false);
	RenameSquadBtn.InitButton(, strRenameSquad, OnRenameClicked).SetPosition(772, 14).SetWidth(190);

	EditBiographyButton = Spawn(class'UIButton', UpperContainer);
	EditBiographyButton.SetResizeToText(false);
	EditBiographyButton.InitButton(, strEditBiography, OnEditBiographyClicked).SetPosition(772, 54).SetWidth(190);

	ViewUnassignedBtn = Spawn(class'UIButton', UpperContainer);
	ViewUnassignedBtn.SetResizeToText(false);
	ViewUnassignedBtn.InitButton(, strViewUnassigned, OnViewUnassignedClicked).SetPosition(772, 94).SetWidth(190);

	m_arrNeededTabs.AddItem(m_eListType);
	m_arrTabButtons[eUIPersonnel_Soldiers] = CreateTabButton('SoldierTab', m_strSoldierTab, SoldiersTab);
	m_arrTabButtons[eUIPersonnel_Soldiers].bIsNavigable = false;

	if(ExternalSelectedSquadRef.ObjectID < 0)
		CurrentSquadSelection = -1;
	else
		CurrentSquadSelection = SelectInitialSquad(ExternalSelectedSquadRef);

	CreateSortHeaders();
	
	RefreshAllData();

	EnableNavigation();
	Navigator.LoopSelection = true;
	Navigator.SelectedIndex = 0;
	Navigator.OnSelectedIndexChanged = SelectedHeaderChanged;
}
*/

defaultproperties
{
	PanelW = 961;
	PanelH = 900;

	BorderPadding = 10;
	FontSize = 24;
	SquadIconSize = 150;

	m_eListType = eUIPersonnel_Soldiers;
	
	m_iMaskWidth = 961;
	m_iMaskHeight = 658;

	CurrentSquadIndex = -1;
}

// Looks like UIPersonnel size is
// m_iMaskWidth = 961;
// m_iMaskHeight = 780;