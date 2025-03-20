Scriptname LZP:System:DeathMonitorQuestScript extends Quest

Event OnInit()
    LZP:SystemScript.Log("[Lazy Panda] DeathMonitorQuestScript initialized", 3)
EndEvent
LZP:Looting:CorpseProcessorScript Property CorpseProcessor Auto