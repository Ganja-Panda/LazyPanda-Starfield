;======================================================================
; Script Name   : LZP:Potion:AidLootToggleScript
; Author        : Ganja Panda
; Mod           : Lazy Panda - A Scav's Auto Loot for Starfield
; Purpose       : Toggles the core looting system on or off via consumable
; Description   : ActiveMagicEffect script that toggles the looting state
;                 through a global variable, shows player feedback messages,
;                 logs the event, and restores the aid item.
; Dependencies  : LazyPanda.esm, LoggerScript, ToggleLootingPotion, Messages
; Usage         : Attach this to an Aid item’s MagicEffect
;======================================================================

ScriptName LZP:Potion:AidLootToggleScript Extends ActiveMagicEffect Hidden

;======================================================================
; PROPERTIES
;======================================================================

;-- ToggleControl
; Controls global state of looting system (1 = ON, 0 = OFF)
Group ToggleControl
    GlobalVariable Property LZP_System_ToggleLooting Auto ; 1 = ON, 0 = OFF
EndGroup

;-- MessageFeedback
; UI messages shown to the player when looting is toggled
Group MessageFeedback
    Message Property LZP_MESG_Looting_Enabled Auto   ; Message shown when looting is enabled
    Message Property LZP_MESG_Looting_Disabled Auto  ; Message shown when looting is disabled
EndGroup

;-- PotionReference
; The toggle potion used by the player (added back after use)
Group PotionReference
    Potion Property LZP_Chem_LootToggle Auto   ; Reference to the toggle potion
EndGroup

;-- Logger
; Logging interface for debug messages
Group Logger
    LZP:Debug:LoggerScript Property Logger Auto Const   ; Logger script reference
EndGroup

;======================================================================
; EVENT: OnEffectStart
; Called when the player consumes the toggle potion
;
; @param akTarget     - Reference receiving the effect (should be the player)
; @param akCaster     - Actor who cast the effect
; @param akBaseEffect - Source magic effect
; @param afMagnitude  - Magnitude of effect
; @param afDuration   - Duration of effect
;======================================================================
Event OnEffectStart(ObjectReference akTarget, Actor akCaster, MagicEffect akBaseEffect, Float afMagnitude, Float afDuration)
    if akTarget != Game.GetPlayer()
        return
    endif

    if LZP_System_ToggleLooting == None
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("LPSystemUtil_ToggleLooting is not set.", 3, "AidLootToggleScript")
        endif
        return
    endif

    if LZP_MESG_Looting_Enabled == None || LZP_MESG_Looting_Disabled == None
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("Feedback messages not assigned.", 3, "AidLootToggleScript")
        endif
        return
    endif

    if LZP_Chem_LootToggle == None
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("LP_Aid_ToggleLooting property is not set.", 3, "AidLootToggleScript")
        endif
        return
    endif

    int toggleValue = LZP_System_ToggleLooting.GetValueInt()

    if toggleValue == 1
        LZP_System_ToggleLooting.SetValue(0.0)
        LZP_MESG_Looting_Disabled.Show()
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("Looting disabled by toggle item.", 1, "AidLootToggleScript")
        endif
    else
        LZP_System_ToggleLooting.SetValue(1.0)
        LZP_MESG_Looting_Enabled.Show()
        if Logger && Logger.IsEnabled()
            Logger.LogAdv("Looting enabled by toggle item.", 1, "AidLootToggleScript")
        endif
    endif

    akTarget.AddItem(LZP_Chem_LootToggle as Form, 1, true)
EndEvent
