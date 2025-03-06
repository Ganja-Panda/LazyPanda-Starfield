ScriptName LZP:System:HandHeldTerminalScript Extends ReferenceAlias

;-- Variables ---------------------------------------

;-- Properties --------------------------------------
Actor Property PlayerRef Auto Const mandatory
ObjectReference Property LP_TerminalDummyRef Auto Const mandatory
Weapon Property LP_TerminalControlWeapon Auto Const mandatory
Potion Property LP_Aid_ToggleLooting Auto Const mandatory

;-- Functions ---------------------------------------

Event OnAliasInit()
  Debug.Notification("OnAliasInit triggered") ; #DEBUG_LINE_NO:9
  Self.GiveItem() ; #DEBUG_LINE_NO:10
EndEvent

Function GiveItem()
  Debug.Notification("GiveItem called") ; #DEBUG_LINE_NO:14
  If Self.PlayerRef.GetItemCount(Self.LP_Aid_ToggleLooting as Form) == 0 ; #DEBUG_LINE_NO:15
    Debug.Notification("Adding Aid Toggle Looting to player") ; #DEBUG_LINE_NO:16
    Self.PlayerRef.AddItem(Self.LP_Aid_ToggleLooting as Form, 1, False) ; #DEBUG_LINE_NO:17
  Else
    Debug.Notification("Player already has Aid Toggle Looting") ; #DEBUG_LINE_NO:19
  EndIf
EndFunction

Event OnItemEquipped(Form akBaseObject, ObjectReference akReference)
  If (akBaseObject == Self.LP_TerminalControlWeapon as Form) && (Game.IsMenuControlsEnabled() || Game.IsFavoritesControlsEnabled()) ; #DEBUG_LINE_NO:24
    Self.LP_TerminalDummyRef.Activate(Self.PlayerRef as ObjectReference, False) ; #DEBUG_LINE_NO:25
    Self.PlayerRef.UnequipItem(Self.LP_TerminalControlWeapon as Form, False, True) ; #DEBUG_LINE_NO:26
  EndIf
EndEvent
