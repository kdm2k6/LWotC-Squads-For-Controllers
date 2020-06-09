// ===================================================
I need to look for all cases where UIPersonnel_SquadBarracks is dealt with; specifically where the screen stack looks for an instance of it.

// ======================= 1 =========================
FILE : UIPersonnel_SquadBarracks
FUNCTION : OnSquadIconClicked()
DESCRIPTION : BelowScreen is set to a screen of type UIPersonnel_SquadBarracks.
SOLUTION : UIPersonnel_SquadBarracks_ForControllers.EditSquadIcon sets BelowScreen to itself.
STATUS : SOLVED IN NEW CLASS "UIPersonnel_SquadBarracks_ForControllers".

// ======================= 2 =========================
FILE : UIScreenListener_LivingQuarters
SOLUTION : It is deprecated and no longer used.
STATUS : SOLVED SINCE CLASS IS DEPRECATED.

// ======================= 3 =========================
FILE : UIScreenListener_LWOfficerPack
FUNCTION : CheckOfficerMissionStatus()
DESCRIPTION : The event OverrideGetPersonnelStatusSeparate calls CheckOfficerMissionStatus(); however, this particular
event is never triggered.
STATUS : EVENT IS NEVER TRIGGERED - MIGHT WANT TO UPDATE IT ANYWAYS.

// ======================= 4 =========================
FILE : UIScreenListener_SquadSelect_LW
FUNCTION : OnInit()
DESCRIPTION : When in a UISquadSelect screen, sets bInSquadEdit to the value of `SCREENSTACK.IsInStack(class'UIPersonnel_SquadBarracks').
This determines what type of information will and will not be displayed on the UISquadSelect screen.
SOLUTION :
- 1.] Create a new LWotC function, IsNamedClassInStack(name), making use of Object's "final function bool IsA(name ClassName)".
If the controller is not active, perform the normal code; if the controller is active, do a search using my new code.
I might be able to make use of X2EventListener_Soldiers.GetScreenOrChild(name ScreenType).
- 2.] Within LWotC code, return immediately if a controller is active. Then add a screen listener in this mod which does
basically the same thing.
STATUS : TO DO

// ======================= 5 =========================
FILE : UIScreenListener_SquadSelect_LW
FUNCTION : OnSquadManagerClicked()
STATUS : FUNCTION NEVER CALLED - MIGHT WANT TO UPDATE IT ANYWAYS

// ======================= 6 =========================
FILE : UIScreenListener_SquadSelect_LW
FUNCTION : OnSaveSquad()
DESCRIPTION : If bInSquadEdit is true, the launch button's click delegate calls OnSaveSquad(). When it is clicked, the screen
stack is popped until Barracks, which is a UIPersonnel_SquadBarracks.
SOLUTION : Depends on #4. Will definitely have to base it on OnUnrealCommand, instead of a button click though.
Could probably put some code in UIScreenListener_RobojumperSquadSelect.OnRobojumperSquadSelectClick(); need to think about it.
STATUS : TO DO

// ======================= 7 =========================
FILE : UISquadContainer
FUNCTION : OnSquadManagerClicked()
DESCRIPTION : When the squad container is clicked, a UIPersonnel_SquadBarracks is spawned with bSelectSquad set to true,
and then pushed onto the stack.
SOLUTION : When a controller is active make sure that UIScreenListener_SquadSelect_LW.OnInit() doesn't spawn a squad container.
I might also want to add a menu item to the squad menu which sends you to the squad management screen, simulating this button press.
STATUS : TO DO

// ======================= 8 =========================
FILE : UISquadIconSelectionScreen
DESCRIPTION : Makes use of BelowScreen, which is a screen of type UIPersonnel_SquadBarracks. Basically, same issue as #1.
STATUS : SOLVED IN NEW CLASS "UISquadIconSelectionScreen_ForControllers".

// ======================= 9 =========================
FILE : X2EventListener_Soldiers
FUNCTION : OnOverridePersonnelStatus()
DESCRIPTION : The event OverridePersonnelStatus calls OnOverridePersonnelStatus(); however, this particular
event is never triggered.
STATUS : EVENT IS NEVER TRIGGERED - MIGHT WANT TO UPDATE IT ANYWAYS.


// ======================= 10 =========================
FILE : XComGameState_LWSquadManager
FUNCTION : GoToSquadManagement()
DESCRIPTION : When the squad management avenger menu is clicked, if a UIPersonnel_SquadBarracks is not on the stack,
one is spawned and pushed.
STATUS : TO DO

// ======================= 11 =========================
FILE : XComGameState_LWSquadManager
FUNCTION : SetDisabledSquadListItems()
DESCRIPTION : The event OnSoldierListItemUpdateDisabled(), which is called in UIScreenListener_PersonnelSquadSelect.FireEvents(),
calls SetDisabledSquadListItems(). Within this function, bInSquadEdit is set according to whether or not a screen of type
UIPersonnel_SquadBarracks is on the stack. It looks like it disables list items when bInSquadEdit is true.
STATUS : TO DO

// ======================= 12 =========================
FILE : XComGameState_LWSquadManager
FUNCTION : ConfigureSquadOnEnterSquadSelect()
DESCRIPTION : The event OnUpdateSquadSelectSoldiers calls ConfigureSquadOnEnterSquadSelect(); however, this particular
event is never triggered.
STATUS : EVENT IS NEVER TRIGGERED - MIGHT WANT TO UPDATE IT ANYWAYS.





Go through the variables at the top of UIPersonnel_SquadBarracks and make sure they aren't referenced in other files; if they are, make sure the names sync up.
// -----------------------------------------------------

VARIABLE : bHideSelect
DESCRIPTION : It is never set anywhere; therefore it is always false and can be ignored.
STATUS : NO MODIFICATION NEEDED.

VARIABLE : bSelectSquad
DESCRIPTION : It is set to "true" in UISquadContainer.OnSquadManagerClicked() and UIScreenListener_SquadSelect_LW.OnSquadManagerClicked().
It is accessed 3 times within UIPersonnel_SquadBarracks : InitScreen(), UpdateSquadHeader(), and OnEditOrSelectClicked(). 
STATUS : LOOK INTO IT.

VARIABLE : ExternalSelectedSquadRef
DESCRIPTION : It is never set anywhere; therefore it is always false and can be ignored.
STATUS : NO MODIFICATION NEEDED.

VARIABLE : CachedSquad
DESCRIPTION : It is dealt with in UIPersonnel_SquadBarracks : OnReceiveFocus(), and OnEditOrSelectClicked().
STATUS : LOOK INTO IT.

VARIABLE : bRestoreCachedSquad
DESCRIPTION : It is dealt with in UIPersonnel_SquadBarracks : OnReceiveFocus(), and OnEditOrSelectClicked().
STATUS : LOOK INTO IT.

VARIABLE : CurrentSquadSelection
DESCRIPTION : In addition to normal usage, it is dealt with in UIScreenListener_SquadSelect_LW.OnSaveSquad().
STATUS : LOOK INTO IT.




// -----------------------------------------------------
WHAT HAS BEEN DONE

- Helper functions added to UIScreenListener_LWOfficerPack since GetScreenOrChild already existed there, and I needed it before LW_Overhaul since the OfficerPack package is compiled 1st, and you can't dependsOn future packages.

- #3 Done in LW code
- #4/5/6 Done in LW code
- #7 Done in LW code since a UIContainer is no longer created when the controller is active.
- #9 Done in LW code
- #10/11/12 Done in LW code

bSelectSquad : 
	- UISquadContainer not created anymore
	- Value is set in UIScreenListener_UIPersonnel_SquadBarracks before UIPersonnel_SquadBarracks is popped; this should deal with it in terms of UIScreenListener_SquadSelect_LW.OnSquadManagerClicked.
	- Checked in UIPersonnel_SquadBarracks
	- DONE
	
CachedSquad
	- Checked in UIPersonnel_SquadBarracks - DONE
	
bRestoreCachedSquad
	- Checked in UIPersonnel_SquadBarracks - DONE

CurrentSquadSelection
	- UIScreenListener_SquadSelect_LW.OnSaveSquad is no longer called, because the save button is no longer created when a controller is active. DONE.
	
	
ALSO TO DO : 
- Probably get rid of all navhelp and buttons (except for B - close screen) while viewing squad - nothing sticks anyways since you can't
save anything
- If from squadbarracks - probably select squad menu item which is active - same with squad management