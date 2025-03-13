ScriptName LZP:System:HandHeldTerminalScript Extends ReferenceAlias

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Actor Property PlayerRef Auto Const mandatory
ObjectReference Property LP_TerminalDummyRef Auto Const mandatory
Weapon Property LP_TerminalControlWeapon Auto Const mandatory
Potion Property LP_Aid_ToggleLooting Auto Const mandatory
GlobalVariable Property LPSystemUtil_Debug Auto Const mandatory

;-- Functions ---------------------------------------

Function Log(String logMsg)
  If LPSystemUtil_Debug.GetValue() as Bool
    Debug.Trace(logMsg, 0)
  EndIf
EndFunction

Function ValidateProperties()
  If PlayerRef == None
    Log("Error: PlayerRef is None")
  EndIf
  If LP_TerminalDummyRef == None
    Log("Error: LP_TerminalDummyRef is None")
  EndIf
  If LP_TerminalControlWeapon == None
    Log("Error: LP_TerminalControlWeapon is None")
  EndIf
  If LP_Aid_ToggleLooting == None
    Log("Error: LP_Aid_ToggleLooting is None")
  EndIf
EndFunction

Event OnAliasInit()
  Log("OnAliasInit triggered")
  ValidateProperties()
  GiveItem()
EndEvent

Function GiveItem()
  Log("GiveItem called")
  If PlayerRef.GetItemCount(LP_Aid_ToggleLooting as Form) == 0
    Log("Adding Aid Toggle Looting to player")
    PlayerRef.AddItem(LP_Aid_ToggleLooting as Form, 1, False)
  Else
    Log("Player already has Aid Toggle Looting")
  EndIf
EndFunction

Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
  If (akBaseObject == LP_TerminalControlWeapon as Form) && (Game.IsMenuControlsEnabled() || Game.IsFavoritesControlsEnabled())
    Log("Terminal control weapon equipped; activating terminal dummy")
    LP_TerminalDummyRef.Activate(PlayerRef as ObjectReference, False)
    PlayerRef.UnequipItem(LP_TerminalControlWeapon as Form, False, True)
  EndIf
EndEvent
