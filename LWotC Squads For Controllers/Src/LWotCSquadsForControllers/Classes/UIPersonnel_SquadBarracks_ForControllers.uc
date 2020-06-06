class UIPersonnel_SquadBarracks_ForControllers extends UIPersonnel;

var bool bSelectSquad;
var int PanelW, PanelH, TopBG_H;

var int BorderPadding, FontSize;

var UIPanel MainPanel;
var UIBGBox TopBG, BottomBG;
var UIImage CurrentSquadIcon;
var UIScrollingText CurrentSquadName, CurrentSquadStatus, CurrentSquadBio;
var UIList SoldierIconList;
var UIButton SquadSoldiersTab, AvailableSoldiersTab;

simulated function InitScreen(XComPlayerController InitController, UIMovie InitMovie, optional name InitName)
{
	local int AvailableW, XLoc, YLoc, HeightVal, WidthVal;
	local int SquadIconSize;

	super(UIScreen).InitScreen(InitController, InitMovie, InitName); // KDM : CONTROLLERIZED JUST CALLS SUPER - WAS THIS A MISTAKE ?

	// KDM : Container which will hold our UI components : it's invisible.
	MainPanel = Spawn(class'UIPanel', self);
	MainPanel.bIsNavigable = false;
	MainPanel.InitPanel();
	MainPanel.SetPosition((Movie.UI_RES_X / 2) - (PanelW / 2), (Movie.UI_RES_Y / 2) - (PanelH / 2));

	// KDM : Background rectangle on top.
	TopBG = Spawn(class'UIBGBox', MainPanel);
	TopBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	TopBG.InitBG(, 0, 0, PanelW, TopBG_H);

	// KDM : Background rectangle on bottom.
	BottomBG = Spawn(class'UIBGBox', MainPanel);
	BottomBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	BottomBG.InitBG(, 0, TopBG_H, PanelW, PanelH - TopBG_H);

	// KDM : Current squad's icon.
	XLoc = BorderPadding;
	YLoc = BorderPadding;
	SquadIconSize = TopBG_H - (BorderPadding * 2);
	CurrentSquadIcon = Spawn(class'UIImage', MainPanel);
	CurrentSquadIcon.InitImage();
	CurrentSquadIcon.SetSize(SquadIconSize, SquadIconSize);
	CurrentSquadIcon.SetPosition(XLoc, YLoc);

	AvailableW = PanelW - SquadIconSize - (BorderPadding * 4);

	// KDM : Current squad's name.
	XLoc = CurrentSquadIcon.X + CurrentSquadIcon.Width + BorderPadding;
	YLoc = BorderPadding;
	WidthVal = int(float(AvailableW) * 0.5);
	CurrentSquadName = Spawn(class'UIScrollingText', MainPanel);
	CurrentSquadName.InitScrollingText(, "Setup Text", WidthVal, XLoc, YLoc);
	
	// KDM : Current squad's status.
	XLoc = CurrentSquadName.X + CurrentSquadName.Width + BorderPadding;
	YLoc = BorderPadding;
	WidthVal = int(float(AvailableW) * 0.5);
	CurrentSquadStatus = Spawn(class'UIScrollingText', MainPanel);
	CurrentSquadStatus.InitScrollingText(, "Setup Text", WidthVal, XLoc, YLoc);

	// KDM : List of icons representing soldiers in the squad.
	XLoc = BorderPadding;
	YLoc = CurrentSquadName.Y + FontSize + 10;
	WidthVal = PanelW - SquadIconSize - (BorderPadding * 3);
	HeightVal = 24;
	SoldierIconList = Spawn(class'UIList', MainPanel);
	SoldierIconList.InitList(,,,,, true);
	SoldierIconList.SetSize(WidthVal, HeightVal);
	SoldierIconList.SetPosition(XLoc, YLoc);

	// KDM : Squad mission information & biography.
	XLoc = BorderPadding;
	YLoc = SoldierIconList.Y + SoldierIconList.Height + 10;
	WidthVal = PanelW - SquadIconSize - (BorderPadding * 3);
	CurrentSquadBio = Spawn(class'UIScrollingText', MainPanel);
	CurrentSquadBio.InitScrollingText(, "Setup Text", WidthVal, XLoc, YLoc);

	AvailableW = PanelW - (BorderPadding * 3);

	// KDM : Squad soldiers tab.
	XLoc = BorderPadding;
	YLoc = BottomBG.Y + BorderPadding;
	WidthVal = int(float(AvailableW) * 0.5);
	SquadSoldiersTab = Spawn(class'UIButton', MainPanel);
	SquadSoldiersTab.ResizeToText = false;
	SquadSoldiersTab.InitButton(, "Setup Text", , eUIButtonStyle_NONE);
	SquadSoldiersTab.SetWidth(WidthVal);
	SquadSoldiersTab.SetPosition(XLoc, YLoc);
	
	// KDM : Available soldiers tab.
	XLoc = SquadSoldiersTab.X + SquadSoldiersTab.Width + BorderPadding;
	YLoc = BottomBG.Y + BorderPadding;
	WidthVal = int(float(AvailableW) * 0.5);
	AvailableSoldiersTab = Spawn(class'UIButton', MainPanel);
	AvailableSoldiersTab.ResizeToText = false;
	AvailableSoldiersTab.InitButton(, "Setup Text", , eUIButtonStyle_NONE);
	AvailableSoldiersTab.SetWidth(WidthVal);
	AvailableSoldiersTab.SetPosition(XLoc, YLoc);

	
	/*
	// KDM : Reposition column header container
	m_kSoldierSortHeader.SetPosition(SquadSoldiersBtn.X, SquadSoldiersBtn.Y + BottomPanelItemHeight + BottomPanelItemPaddingV);
	// KDM : Reposition main list
	m_kList.SetPosition(SquadSoldiersBtn.X, m_kSoldierSortHeader.Y + ColumnHeaderFontSize + 10 + BottomPanelItemPaddingV);
	m_kList.SetHeight(SquadBottomBG.Height - (m_kList.Y - SquadBottomBG.Y) - BottomPanelEdgePadding);

	ListTitle.Hide();			// KDM : This is created is UIPersonnel (super), but we don't want it here
	*/


	/*local int AvailableW;
	local int TopPanelItemHeight, TopPanelEdgePadding, TopPanelItemPaddingH, TopPanelItemPaddingV;
	local int BottomPanelItemHeight, BottomPanelEdgePadding, BottomPanelItemPaddingH, BottomPanelItemPaddingV;
	local float SquadNamePctW;
	local string TmpString;

	// KDM : Get font size
	SquadFontSize = class'UIUtilities_KDM'.const.DEFAULT_NORMAL_FONT_SIZE_KDM + 2;

	PanelW = 1800;									// KDM : Set width
	PanelH =  970;									// KDM : Set height
	
	TopPanelEdgePadding = 10;
	TopPanelItemPaddingH = 10;
	TopPanelItemPaddingV = 4;
	BottomPanelEdgePadding = 10;
	BottomPanelItemPaddingH = 10;
	BottomPanelItemPaddingV = 10;

	SquadNamePctW = 0.5;							// KDM : The squad name and squad status are on the same line.
													// This determines how wide the name text field is compared to the status text field.

	TopPanelItemHeight = SquadFontSize + 10;
	BottomPanelItemHeight = SquadFontSize + 10;

	super.InitScreen(InitController, InitMovie, InitName);

	NavInfoString = GetNavInfoString();				// KDM : Get navigation info string

	// KDM : Create main squad container panel (centered)
	SquadMainPanel = Spawn(class'UIPanel', self);
	SquadMainPanel.bAnimateOnInit = false;
    SquadMainPanel.InitPanel();
	SquadMainPanel.SetPosition((Movie.UI_RES_X / 2) - (PanelW / 2),  (Movie.UI_RES_Y / 2) - (PanelH / 2));
	SquadMainPanel.DisableNavigation();

	// KDM : Create top squad background panel
    SquadTopBG = Spawn(class'UIBGBox', SquadMainPanel);
	SquadTopBG.bAnimateOnInit = false;
	SquadTopBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	SquadTopBG.InitBG(, 0, 0, PanelW, 2 * TopPanelEdgePadding + 3 * TopPanelItemHeight + 2 * TopPanelItemPaddingV);

	// KDM : Create bottom squad background panel (unused)
    SquadBottomBG = Spawn(class'UIBGBox', SquadMainPanel);
	SquadBottomBG.bAnimateOnInit = false;
	SquadBottomBG.LibID = class'UIUtilities_Controls'.const.MC_X2Background;
	SquadBottomBG.InitBG(,0 ,SquadTopBG.Y + SquadTopBG.Height, PanelW, PanelH - SquadTopBG.Height);
	SquadBottomBG.Hide();

	// KDM : Create squad icon
	SquadIcon = Spawn(class'UIImage', SquadMainPanel);
	SquadIcon.bAnimateOnInit = false;
	SquadIcon.InitImage();
	SquadIcon.SetSize(SquadTopBG.Height - 2 * TopPanelEdgePadding, SquadTopBG.Height - 2 * TopPanelEdgePadding);
	SquadIcon.SetPosition(SquadTopBG.X + TopPanelEdgePadding, SquadTopBG.Y + TopPanelEdgePadding);

	AvailableW = SquadTopBG.Width - SquadIcon.Width - 2 * TopPanelEdgePadding - 2 * TopPanelItemPaddingH;
	
	// KDM : Create squad name label
	SquadNameLabel = Spawn(class'UIScrollingTextField', SquadMainPanel);
	SquadNameLabel.bAnimateOnInit = false;
	SquadNameLabel.InitScrollingText();
	SquadNameLabel.SetWidth(float(AvailableW) * SquadNamePctW);
	SquadNameLabel.SetPosition(SquadIcon.X + SquadIcon.Width + TopPanelItemPaddingH, SquadTopBG.Y + TopPanelEdgePadding);
	
	// KDM : Create squad status label
	SquadStatusLabel = Spawn(class'UIScrollingTextField', SquadMainPanel);
	SquadStatusLabel.bAnimateOnInit = false;
	SquadStatusLabel.InitScrollingText();
	SquadStatusLabel.SetWidth(float(AvailableW) * (1.0 - SquadNamePctW));
	SquadStatusLabel.SetPosition(SquadNameLabel.X + SquadNameLabel.Width + TopPanelItemPaddingH, SquadTopBG.Y + TopPanelEdgePadding);
	
	AvailableW = SquadTopBG.Width - SquadIcon.Width - 2 * TopPanelEdgePadding - TopPanelItemPaddingH;

	// KDM : Create squad class icon list
	ClassIconList = Spawn(class'UIList', SquadMainPanel);
	ClassIconList.bAnimateOnInit = false;
	ClassIconList.InitList(,,,,, true);			// KDM : Create a horizontal list
	ClassIconList.SetSize(AvailableW, TopPanelItemHeight);
	ClassIconList.SetPosition(SquadNameLabel.X, SquadNameLabel.Y + TopPanelItemHeight + TopPanelItemPaddingV);

	// KDM : Add squad mission info + biography
	SquadBioLabel = Spawn(class'UIScrollingTextField', SquadMainPanel);
	SquadBioLabel.bAnimateOnInit = false;
	SquadBioLabel.InitScrollingText();
	SquadBioLabel.SetWidth(AvailableW);
	SquadBioLabel.SetPosition(SquadNameLabel.X, ClassIconList.Y + TopPanelItemHeight + TopPanelItemPaddingV);
	
	AvailableW = SquadBottomBG.Width - 2 * BottomPanelEdgePadding - BottomPanelItemPaddingH;
	
	// KDM : Add squad soldiers button
	SquadSoldiersBtn = Spawn(class'UIButton', SquadMainPanel);
	SquadSoldiersBtn.SetResizeToText(false);
	SquadSoldiersBtn.bAnimateOnInit = false;
	SquadSoldiersBtn.InitButton();
	SquadSoldiersBtn.MC.SetNum("textHeightPadding", 20);
	SquadSoldiersBtn.SetSize(AvailableW / 2, BottomPanelItemHeight);
	SquadSoldiersBtn.SetPosition(SquadBottomBG.X + BottomPanelEdgePadding, SquadBottomBG.Y + BottomPanelEdgePadding);
	TmpString = class'UIUtilities_KDM'.static.Modify_Font("Squad Soldiers", SquadFontSize);
	SquadSoldiersBtn.SetText(TmpString);

	// KDM : Add available soldiers button
	AvailableSoldiersBtn = Spawn(class'UIButton', SquadMainPanel);
	AvailableSoldiersBtn.SetResizeToText(false);
	AvailableSoldiersBtn.bAnimateOnInit = false;
	AvailableSoldiersBtn.InitButton();
	AvailableSoldiersBtn.MC.SetNum("textHeightPadding", 20);
	AvailableSoldiersBtn.SetSize(AvailableW / 2, BottomPanelItemHeight);
	AvailableSoldiersBtn.SetPosition(SquadSoldiersBtn.X + SquadSoldiersBtn.Width + BottomPanelItemPaddingH, SquadSoldiersBtn.Y);
	TmpString = class'UIUtilities_KDM'.static.Modify_Font("Available Soldiers", SquadFontSize);
	AvailableSoldiersBtn.SetText(TmpString);

	// KDM : Reposition column header container
	m_kSoldierSortHeader.SetPosition(SquadSoldiersBtn.X, SquadSoldiersBtn.Y + BottomPanelItemHeight + BottomPanelItemPaddingV);
	// KDM : Reposition main list
	m_kList.SetPosition(SquadSoldiersBtn.X, m_kSoldierSortHeader.Y + ColumnHeaderFontSize + 10 + BottomPanelItemPaddingV);
	m_kList.SetHeight(SquadBottomBG.Height - (m_kList.Y - SquadBottomBG.Y) - BottomPanelEdgePadding);

	ListTitle.Hide();			// KDM : This is created is UIPersonnel (super), but we don't want it here
	
	// KDM : Create no squads exist label
	NoSquadsExistLabel = Spawn(class'UIText', SquadMainPanel);
	NoSquadsExistLabel.bAnimateOnInit = false;
	NoSquadsExistLabel.InitText();
	NoSquadsExistLabel.SetWidth(SquadTopBG.Width);
	NoSquadsExistLabel.SetPosition(SquadTopBG.X, SquadTopBG.Y + (SquadTopBG.Height / 2) - (SquadFontSize / 2));
	TmpString = class'UIUtilities_KDM'.static.Modify_Font("NO SQUADS EXIST", SquadFontSize);
	TmpString = "<p align='CENTER'>" $ TmpString $ "</p>";
	NoSquadsExistLabel.SetHtmlText(TmpString);
	NoSquadsExistLabel.Hide();

	if (ExternalSelectedSquadRef.ObjectID < 0)
	{
		CurrentSquadIndex = -1;
	}
	else
	{
		CurrentSquadIndex = SelectInitialSquad(ExternalSelectedSquadRef);
	}
	
	ReloadCurrentSquad();		// KDM : Load 1st squad
	
	UpdateNavHelp();
	UpdateUIBasedOnSquadNum();
	DisableNavigation();*/
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

	TopBG_H = 300;

	BorderPadding = 5;
	FontSize = 24;

	m_eListType = eUIPersonnel_Soldiers;
	
	m_iMaskWidth = 961;
	m_iMaskHeight = 658;
}

// Looks like UIPersonnel size is
// m_iMaskWidth = 961;
// m_iMaskHeight = 780;