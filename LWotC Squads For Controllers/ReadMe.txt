#3 - I THINK THIS NEEDS TO BE AN || INSIDE BRACKETS - CHECK - 2 INSTANCES
#5 - SHOULD BE || - DOUBLE CHECK ACTUALLY
#9 - SHOULD BE || - DOUBLE CHECK ACTUALLY
#10 - THINK ABOUT && VS || - ACTUALLY I THINK IT'S GOOD HERE'
#11 - CHECK IT BUT LOOKS GOOD

****** I THINK WHEN DEALING WITH "NOT BEING ON STACK" NEED - && - 
WHEN DEALING WITH BEING ON STACK NEED ||

// ===================================================
// =================== STEP 1 ========================
// ===================================================
For proper integration with LWotC, I need to look for any situation in which 'UIPersonnel_SquadBarracks' is dealt with.
In particular, I need to be concerned with screen stack checks for 'UIPersonnel_SquadBarracks'.
 
// ======================= 1 =========================
FILE : UIPersonnel_SquadBarracks
FUNCTION : OnSquadIconClicked()
DESCRIPTION : BelowScreen is set to a screen of type 'UIPersonnel_SquadBarracks'.
SOLUTION : My custom class, 'UIPersonnel_SquadBarracks_ForControllers' sets BelowScreen to itself, within EditSquadIcon().
STATUS : SOLVED

// ======================= 2 =========================
FILE : UIScreenListener_LivingQuarters
SOLUTION : This class is deprecated and no longer used.
STATUS : SOLVED

// ======================= 3 =========================
FILE : UIScreenListener_LWOfficerPack
FUNCTION : CheckOfficerMissionStatus()
DESCRIPTION : The event OverrideGetPersonnelStatusSeparate calls CheckOfficerMissionStatus() which returns ELR_NoInterrupt if :
	1.] You are not in the Squad Select screen 2.] 'UIPersonnel_SquadBarracks' is not on the screen stack.
SOLUTION : I now also make sure :
	1.] 'UIPersonnel_SquadBarracks_ForControllers' is not on the screen stack, if a controller is active.
NOTE : Although I solved this problem, this particular event is never actually triggered.
STATUS : SOLVED

// ======================= 4 =========================
FILE : UIScreenListener_SquadSelect_LW
FUNCTION : OnInit()
DESCRIPTION : Sets bInSquadEdit to true if 'UIPersonnel_SquadBarracks' is on the screen stack, and false otherwise.
SOLUTION: Also sets bInSquadEdit to true if a controller is active, and 'UIPersonnel_SquadBarracks_ForControllers' is on the screen stack.
STATUS : SOLVED

// ======================= 5 =========================
FILE : UIScreenListener_SquadSelect_LW
FUNCTION : OnSquadManagerClicked()
DESCRIPTION : Spawns a 'UIPersonnel_SquadBarracks' screen if 'UIPersonnel_SquadBarracks' is not on the screen stack.
SOLUTION : Spawning a 'UIPersonnel_SquadBarracks' also requires 'UIPersonnel_SquadBarracks_ForControllers' not be on the screen stack.
NOTE : This function is never called.
STATUS : SOLVED

// ======================= 6 =========================
FILE : UIScreenListener_SquadSelect_LW
FUNCTION : OnSaveSquad()
SOLUTION : This functionality has been disabled, and the function is no longer called when a controller is active.
STATUS : SOLVED

// ======================= 7 =========================
FILE : UISquadContainer
FUNCTION : OnSquadManagerClicked()
SOLUTION : UISquadContainers are no longer spawned when a controller is active; therefore, this function will never be called.
STATUS : SOLVED

// ======================= 8 =========================
FILE : UISquadIconSelectionScreen
DESCRIPTION : BelowScreen is a screen of type 'UIPersonnel_SquadBarracks'.
SOLUTION : My custom class, 'UISquadIconSelectionScreen_ForControllers' solves this issue; BelowScreen is now a screen of type 'UIPersonnel_SquadBarracks_ForControllers'.
STATUS : SOLVED

// ======================= 9 =========================
FILE : X2EventListener_Soldiers
FUNCTION : OnOverridePersonnelStatus()
DESCRIPTION : Enters an else-if statement if 'UIPersonnel_SquadBarracks' is not on the screen stack.
SOLUTION : Entering the else-if statement also requires 'UIPersonnel_SquadBarracks_ForControllers' not be on the screen stack.
NOTE : The event, OverridePersonnelStatus, which calls OnOverridePersonnelStatus() is never triggered.
STATUS : SOLVED

// ======================= 10 =========================
FILE : XComGameState_LWSquadManager
FUNCTION : GoToSquadManagement()
DESCRIPTION : Spawns a 'UIPersonnel_SquadBarracks' screen if 'UIPersonnel_SquadBarracks' is not on the screen stack.
SOLUTION : Spawning a 'UIPersonnel_SquadBarracks' also requires 'UIPersonnel_SquadBarracks_ForControllers' not be on the screen stack.
NOTE : This is called when the Squad Management Avenger menu button is clicked.
STATUS : SOLVED

// ======================= 11 =========================
FILE : XComGameState_LWSquadManager
FUNCTION : SetDisabledSquadListItems()
DESCRIPTION : Sets bInSquadEdit to true if 'UIPersonnel_SquadBarracks' is on the screen stack, and false otherwise.
SOLUTION: Also sets bInSquadEdit to true if a controller is active, and 'UIPersonnel_SquadBarracks_ForControllers' is on the screen stack.
NOTE : The event OnSoldierListItemUpdateDisabled(), which is called in UIScreenListener_PersonnelSquadSelect.FireEvents(), calls SetDisabledSquadListItems(). 
STATUS : SOLVED

// ======================= 12 =========================
FILE : XComGameState_LWSquadManager
FUNCTION : ConfigureSquadOnEnterSquadSelect()
DESCRIPTION : Sets bInSquadEdit to true if 'UIPersonnel_SquadBarracks' is on the screen stack, and false otherwise.
SOLUTION: Also sets bInSquadEdit to true if a controller is active, and 'UIPersonnel_SquadBarracks_ForControllers' is on the screen stack.
NOTE : The event OnUpdateSquadSelectSoldiers calls ConfigureSquadOnEnterSquadSelect(); however, this event is never triggered.
STATUS : SOLVED



// ===================================================
// =================== STEP 2 ========================
// ===================================================
Go through the variables at the top of UIPersonnel_SquadBarracks and make sure they aren't referenced in other files. If they are, make sure everything syncs up.

VARIABLE : bHideSelect
DESCRIPTION : It is never set anywhere; therefore it is always false and can be ignored.
STATUS : SOLVED

VARIABLE : bSelectSquad
DESCRIPTION : I no longer make use of this variable; however, it is referenced elsewhere so I have left it in 'UIPersonnel_SquadBarracks_ForControllers'.
STATUS : SOLVED

VARIABLE : ExternalSelectedSquadRef
DESCRIPTION : It is never set anywhere; therefore it is always false and can be ignored.
STATUS : SOLVED

VARIABLE : CachedSquad
DESCRIPTION : It is dealt with in UIPersonnel_SquadBarracks : OnReceiveFocus(), and OnEditOrSelectClicked(). I now make use of it for my own purposes.
STATUS : SOLVED

VARIABLE : bRestoreCachedSquad
DESCRIPTION : It is dealt with in UIPersonnel_SquadBarracks : OnReceiveFocus(), and OnEditOrSelectClicked(). I now make use of my own variable, RestoreCachedSquad.
STATUS : SOLVED

VARIABLE : CurrentSquadSelection
DESCRIPTION : In addition to normal usage in 'UIPersonnel_SquadBarracks', it is dealt with in UIScreenListener_SquadSelect_LW.OnSaveSquad().
I now make use of my own variable, CurrentSquadIndex, within 'UIPersonnel_SquadBarracks_ForControllers'; furthermore, OnSaveSquad is never called when a controller is active.
STATUS : SOLVED















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
	



// TO DELETE BELOW

simulated function UpdateCachedNav()
{
	//local bool CanDeleteSquad;
	local bool ValidSquadWithSquadUIFocused, ValidSquadWithSoldierUIFocused;
	local XComGameState_LWPersistentSquad CurrentSquadState;
	local XComGameState_Unit DummySoldierState;

	CurrentSquadState = GetCurrentSquad();

	ValidSquadWithSquadUIFocused = (CurrentSquadIsValid() && (!SoldierUIFocused)) ? true : false;
	ValidSquadWithSoldierUIFocused = (CurrentSquadIsValid() && SoldierUIFocused) ? true : false;
	//CanDeleteSquad = (CurrentSquadIsValid() && 
	//	(!(CurrentSquadState.bOnMission || (CurrentSquadState.CurrentMission.ObjectID > 0)))) ? true : false;

	CachedNav[0] = true;															// KDM : Close screen with B button.
	CachedNav[1] = (!SoldierUIFocused) ? true : false;								// KDM : Create squad with Y button.
	CachedNav[2] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Scroll biography with right stick.
	CachedNav[3] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Edit squad icon with left stick click.
	CachedNav[4] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Edit squad biography with right trigger.
	CachedNav[5] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Rename squad with left trigger.
	CachedNav[6] = (SelectedSquadIsDeletable() && (!SoldierUIFocused)) ? true : false;			// KDM : Delete squad with X button.
	CachedNav[7] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Focus soldier UI with right stick click.
	CachedNav[8] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Previous squad with left bumper.
	CachedNav[9] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Next squad with right bumper.
	CachedNav[10] = (CanViewCurrentSquad() && (!SoldierUIFocused)) ? true : false;	// KDM : View squad with select button.

	CachedNav[11] = (ValidSquadWithSoldierUIFocused) ? true : false;				// KDM : Focus squad UI with right stick click.
	CachedNav[12] = (ValidSquadWithSoldierUIFocused && 
		DisplayingAvailableSoldiers) ? true : false;								// KDM : Show squad's soldiers.
	CachedNav[13] = (ValidSquadWithSoldierUIFocused && 
		(!DisplayingAvailableSoldiers)) ? true : false;								// KDM : Show available soldiers.
	
	CachedNav[14] = (ValidSquadWithSoldierUIFocused) ? true : false;				// KDM : Change columns with DPad
	CachedNav[15] = (ValidSquadWithSoldierUIFocused) ? true : false;				// KDM : Toggle sort with X button

	CachedNav[16] = (DetailsManagerExists() && ValidSquadWithSoldierUIFocused)
		? true : false;																// KDM : Toggle list details.
	
	CachedNav[17] = (ValidSquadWithSoldierUIFocused && 
		SelectedSoldierIsMoveable(m_kList, m_kList.selectedIndex, DummySoldierState) &&
		DisplayingAvailableSoldiers) ? true : false;								// KDM : Transfer soldier to squad.
	
	CachedNav[18] = (ValidSquadWithSoldierUIFocused && 
		SelectedSoldierIsMoveable(m_kList, m_kList.selectedIndex, DummySoldierState) &&
		(!DisplayingAvailableSoldiers)) ? true : false;								// KDM : Remove soldier from squad.
}

//CachedNav[0] = true;															// KDM : Close screen with B button.
//CachedNav[1] = (!SoldierUIFocused) ? true : false;								// KDM : Create squad with Y button.
//CachedNav[2] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Scroll biography with right stick.
//CachedNav[3] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Edit squad icon with left stick click.
//CachedNav[4] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Edit squad biography with right trigger.
//CachedNav[5] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Rename squad with left trigger.
//CachedNav[6] = (SelectedSquadIsDeletable() && (!SoldierUIFocused)) ? true : false;			// KDM : Delete squad with X button.
//CachedNav[7] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Focus soldier UI with right stick click.
//CachedNav[8] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Previous squad with left bumper.
//CachedNav[9] = (ValidSquadWithSquadUIFocused) ? true : false;					// KDM : Next squad with right bumper.
//CachedNav[10] = (CanViewCurrentSquad() && (!SoldierUIFocused)) ? true : false;	// KDM : View squad with select button.

//CachedNav[11] = (ValidSquadWithSoldierUIFocused) ? true : false;				// KDM : Focus squad UI with right stick click.
//CachedNav[12] = (ValidSquadWithSoldierUIFocused && 
//	DisplayingAvailableSoldiers) ? true : false;								// KDM : Show squad's soldiers.
//CachedNav[13] = (ValidSquadWithSoldierUIFocused && 
//	(!DisplayingAvailableSoldiers)) ? true : false;								// KDM : Show available soldiers.
	
//CachedNav[14] = (ValidSquadWithSoldierUIFocused) ? true : false;				// KDM : Change columns with DPad
//CachedNav[15] = (ValidSquadWithSoldierUIFocused) ? true : false;				// KDM : Toggle sort with X button

//CachedNav[16] = (DetailsManagerExists() && ValidSquadWithSoldierUIFocused)
//	? true : false;																// KDM : Toggle list details.
	
//CachedNav[17] = (ValidSquadWithSoldierUIFocused && 
//	SelectedSoldierIsMoveable(m_kList, m_kList.selectedIndex, DummySoldierState) &&
//	DisplayingAvailableSoldiers) ? true : false;								// KDM : Transfer soldier to squad.
	
//CachedNav[18] = (ValidSquadWithSoldierUIFocused && 
//	SelectedSoldierIsMoveable(m_kList, m_kList.selectedIndex, DummySoldierState) &&
//	(!DisplayingAvailableSoldiers)) ? true : false;								// KDM : Remove soldier from squad.
