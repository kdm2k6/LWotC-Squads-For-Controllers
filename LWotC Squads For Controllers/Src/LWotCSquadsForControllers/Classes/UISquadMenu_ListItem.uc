class UISquadMenu_ListItem extends UIPanel;

// KDM : Reference to a XComGameState_LWPersistentSquad.
var StateObjectReference SquadRef; 

var UIList OwningList;
var UISquadMenu OwningMenu;

var UIButton ButtonBG;
var UIImage SquadImage;
var UIScrollingText SquadNameText;

var int BorderPadding, TextSize;
var string SquadName;

simulated function InitListItem(StateObjectReference _SquadRef, optional UISquadMenu _OwningMenu)
{
	local int ImageSize, TextX, TextWidth;

	SquadRef = _SquadRef;
	OwningMenu = _OwningMenu;

	InitPanel(); 

	OwningList = UIList(GetParent(class'UIList'));

	// KDM : Use the list's width as the list item's width.
	SetWidth(OwningList.Width);

	ButtonBG = Spawn(class'UIButton', self);
	ButtonBG.bIsNavigable = false;
	ButtonBG.InitButton();
	ButtonBG.SetSize(Width, Height);

	SquadImage = Spawn(class'UIImage', self);
	SquadImage.InitImage();
	ImageSize = Height - (BorderPadding * 2);
	SquadImage.SetSize(ImageSize, ImageSize);
	SquadImage.SetPosition(BorderPadding, BorderPadding);

	SquadNameText = Spawn(class'UIScrollingText', self);
	TextX = BorderPadding + ImageSize + BorderPadding;
	TextWidth = Width - (TextX + BorderPadding);
	SquadNameText.InitScrollingText(, "Setup Text", TextWidth, TextX, 6);

	Update(); 
}

simulated function Update()
{
	local XComGameState_LWPersistentSquad SquadState;

	SquadState = XComGameState_LWPersistentSquad(`XCOMHISTORY.GetGameStateForObjectID(SquadRef.ObjectID));
	
	if (SquadState == none) return;

	SquadImage.LoadImage(SquadState.GetSquadImagePath());

	SquadName = SquadState.sSquadName;
	
	UpdateSquadNameText(true);
}

simulated function UpdateSquadNameText(optional bool ForceUpdate)
{
	local int ColourState;
	local string SquadNameHTML;

	ColourState = (bIsFocused) ? -1 : eUIState_Normal;
	SquadNameHTML = class'UIUtilities_Text'.static.GetColoredText(SquadName, ColourState, TextSize);

	SquadNameText.SetHTMLText(SquadNameHTML, ForceUpdate);
}

simulated function OnReceiveFocus()
{
	super.OnReceiveFocus();

	ButtonBG.MC.FunctionVoid("mouseIn");
	UpdateSquadNameText(true);
}

simulated function OnLoseFocus()
{
	super.OnLoseFocus();

	ButtonBG.MC.FunctionVoid("mouseOut");
	UpdateSquadNameText(true);
}

simulated function bool OnUnrealCommand(int cmd, int arg)
{
	local bool bHandled;

	if (!CheckInputIsReleaseOrDirectionRepeat(cmd, arg))
	{
		return false;
	}

	bHandled = true;

	switch (cmd)
	{
		case class'UIUtilities_Input'.const.FXS_BUTTON_B:
			//CloseScreen();
			break;

		default:
			bHandled = false;
			break;
	}

	return bHandled || super.OnUnrealCommand(cmd, arg);
}

	


defaultproperties
{
	BorderPadding = 4;
	TextSize = 32;

	Height = 44;
}