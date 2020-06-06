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

function DelayedInit(float Delay)
{
	SetTimer(Delay, false, nameof(StartDelayedInit));
}

function StartDelayedInit()
{
	InitListItem(, true);
	Update();
	SetPosition(1150, 50); // KDM : TEMP LOCATION UNTIL NORMAL ONE IS REMOVED
}

simulated function InitListItem(optional StateObjectReference _SquadRef, optional bool IgnoreSquadRef = false, optional UISquadMenu _OwningMenu)
{
	local int ImageSize, TextX, TextWidth;

	// KDM : When used as a separate UI element to show the current squad, we need to set the squad reference first before
	// calling InitListItem() on a delay. In that case, we don't want to overwrite the squad reference.
	if (!IgnoreSquadRef) 
	{
		SquadRef = _SquadRef;
	}
	OwningMenu = _OwningMenu;

	InitPanel(); 

	OwningList = UIList(GetParent(class'UIList'));

	// KDM : If this is a list item in a list, use the list's width; if it is being used as a separate UI element
	// to show the current squad, just set the width manually.
	if (OwningList != none)
	{
		SetWidth(OwningList.Width);
	}
	else
	{
		SetWidth(400);
	}

	ButtonBG = Spawn(class'UIButton', self);
	ButtonBG.bIsNavigable = false;
	ButtonBG.InitButton(, , , eUIButtonStyle_NONE);
	ButtonBG.SetSize(Width, Height);

	SquadImage = Spawn(class'UIImage', self);
	SquadImage.InitImage();
	ImageSize = Height - (BorderPadding * 2);
	SquadImage.SetSize(ImageSize, ImageSize);
	SquadImage.SetPosition(BorderPadding, BorderPadding);

	SquadNameText = Spawn(class'UIScrollingText', self);
	TextX = BorderPadding + ImageSize + BorderPadding;
	TextWidth = Width - (TextX + BorderPadding);
	SquadNameText.InitScrollingText(, "Setup Text", TextWidth, TextX, 2);
}

simulated function Update()
{
	local XComGameState_LWPersistentSquad SquadState;

	SquadState = XComGameState_LWPersistentSquad(`XCOMHISTORY.GetGameStateForObjectID(SquadRef.ObjectID));
	
	if (SquadState == none)
	{
		return;
	}

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
		// KDM : A button selects the squad.
		case class'UIUtilities_Input'.static.GetAdvanceButtonInputCode():
			if (OwningMenu != none) OwningMenu.OnSquadSelected(SquadRef);
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
