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
  If LPSystemUtil_Debug.GetValue() as Bool ; #DEBUG_LINE_NO:30
    Debug.Trace(logMsg, 0) ; #DEBUG_LINE_NO:31
  EndIf
EndFunction

Function ValidateProperties()
  If PlayerRef == None ; #DEBUG_LINE_NO:38
    Self.Log("Error: PlayerRef is None") ; #DEBUG_LINE_NO:39
  EndIf
  If LP_TerminalDummyRef == None ; #DEBUG_LINE_NO:41
    Self.Log("Error: LP_TerminalDummyRef is None") ; #DEBUG_LINE_NO:42
  EndIf
  If LP_TerminalControlWeapon == None ; #DEBUG_LINE_NO:44
    Self.Log("Error: LP_TerminalControlWeapon is None") ; #DEBUG_LINE_NO:45
  EndIf
  If LP_Aid_ToggleLooting == None ; #DEBUG_LINE_NO:47
    Self.Log("Error: LP_Aid_ToggleLooting is None") ; #DEBUG_LINE_NO:48
  EndIf
EndFunction

Event OnAliasInit()
  Self.Log("OnAliasInit triggered") ; #DEBUG_LINE_NO:59
  Self.ValidateProperties() ; #DEBUG_LINE_NO:60
  Self.GiveItem() ; #DEBUG_LINE_NO:61
EndEvent

Function GiveItem()
  Self.Log("GiveItem called") ; #DEBUG_LINE_NO:67
  If PlayerRef.GetItemCount(LP_Aid_ToggleLooting as Form) == 0 ; #DEBUG_LINE_NO:68
    Self.Log("Adding Aid Toggle Looting to player") ; #DEBUG_LINE_NO:69
    PlayerRef.AddItem(LP_Aid_ToggleLooting as Form, 1, False) ; #DEBUG_LINE_NO:70
  Else
    Self.Log("Player already has Aid Toggle Looting") ; #DEBUG_LINE_NO:72
  EndIf
EndFunction

Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
  If (akBaseObject == LP_TerminalControlWeapon as Form) && (Game.IsMenuControlsEnabled() || Game.IsFavoritesControlsEnabled()) ; #DEBUG_LINE_NO:79
    Self.Log("Terminal control weapon equipped; activating terminal dummy") ; #DEBUG_LINE_NO:80
    LP_TerminalDummyRef.Activate(PlayerRef as ObjectReference, False) ; #DEBUG_LINE_NO:81
    PlayerRef.UnequipItem(LP_TerminalControlWeapon as Form, False, True) ; #DEBUG_LINE_NO:82
  EndIf
EndEvent
