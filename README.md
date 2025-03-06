# Lazy Panda-Starfield
Lazy Panda - A Scav’s Auto Loot for Starfield: Loot everything, manage nothing—explore without limits!

✅ Auto Loot Everything – Automatically picks up:
    Weapons & Ammo
    Corpses, containers, boxes, trunks, warehouses
    Spacesuits, Helmets & Backpacks
    Chems & Medical Supplies
    Books & Dataslates
    Junk Items
    Clothing & Apparel
    Food & Drinks
    All Resources: manufactured, asteroids, ore, gas geyser and nonlethal harvest.
    
✅ Fully Customizable Loot Settings – Choose what gets auto looted via the Lazy Panda - Loot Terminal, automatically added to your inventory.

✅ Light Master - Mean you can install more than 4000 of them. They don't take up the space of a .esm Full Master Mod.

✅ Multiple Loot Destinations - Send loot directly to the player, Lodge Safe or Lazy Panda Inventary.

✅ Hotkey Support² - Quickly toggle looting on and off, open Lazy Panda's Inventory, Lodge Safe, and Ship Cargo Hold with the console commands. (at the bottom of the page)

Install the mod with MO2 or Vortex.

Manually: Place your language folder into your My Games\Starfield\Data folder.
For example: Copy the folder "Lazy Panda - EN" to My Games\Starfield\Data, after that activate the mod on the Creations menu and close the game.If you have the Shattered Space DLC, you have also copy the LazyPanda_DLC.esm from DLC FOLDER to your newly created folderFor example: Copy the file "LazyPanda_DLC.esm" to My Games\Starfield\Data\Lazy Panda - EN\Data\LazyPanda_DLC.esm

﻿You should have the "StarfieldCustom.ini" text file in "My Games\Starfield" with the lines below. If you don't have it yet, create one:

﻿﻿[Archive]
﻿bInvalidateOlderFiles=1
﻿sResourceDataDirsFinal=

Access the Looting Menu – Open your inventory, navigate to the Weapons section, and launch the Lazy Panda - Loot Terminal.

Customize Your Loot Settings – Toggle individual item categories to control what is automatically looted.

Set Radius - Radius will effect performance. The larger the search radius the more of a performance impact.

Manage Loot Destination – By default, all items go directly to the player’s inventory

Enable Auto Looting – Under the Utilities Menu, select Enable Looting to activate the system or use the Hotkey.²

1) How to Properly Report a bug for Lazy Panda if you want to help me help you:

First of all, make sure you've endorsed the project. It's the minimum requirement I ask as recognition for my work.

When reporting a bug, providing the right details ensures that issues can be identified and fixed quickly. Before submitting a full complete bug report, follow these steps to help streamline the process.

I. Verify the Issue: Before reporting, make sure the issue is caused by Autoloot and not another mod or game setting. Try these steps:
Restart the game and check if the issue persists.
Ensure Lazy Panda is correctly installed and up to date.

II. Gather Essential Information: To make debugging easier, collect the following details:
A clear description of the issue (e.g., "Certain items are not being looted," or "Quest items are being taken incorrectly.")
When the issue occurs (specific quest, area, or interaction).
Game version and mod version being used.

III. Create a new save with normal settings toggled, turn off the game.

Edit your StarfieldCustom.ini adding these lines:
[Papyrus]
bEnableLogging=1
bEnableTrace=1
bLoadDebugInformation=1

IV. Launch Game and Load your save
Open Lazy Panda’s Terminal menu and toggle the items you want.
Enable Looting.
Wait a few minutes there will be no notification. 3 or 4 minutes is good.
Quit Game
Go to My Documents\My Games\Starfield\Logs\Script\
Zip those files
Attach the zip file to the post.
V. Turn off Papyrus Logging.
Providing this information ensures the issue is addressed as quickly as possible. Thanks for helping improve the mod! 

2) Setting your Hotkeys and usable commands: An easy way to set up your game to use hotkeys is through the Starfield Hotkeys mod. Below are the applicable commands. Do not copy the descriptive texts inside parentheses ( ).

cgf "LZP:SystemScript.OpenTerminal" (Opens the Termianl Via Hotkey)
cgf "LZP:SystemScript.ToggleLooting" (Toggles looting via Hotkey)
cgf "LZP:SystemScript.OpenHoldingInventory" (Opens Lazy Panda's Inventory)
cgf "LZP:SystemScript.OpenLodgeSafe" (Opens Lodge Safe)
cgf "LZP:SystemScript.OpenShipCargo" (Opens Ship Cargo Hold)
cgf "LZP:SystemScript.MoveAllToShip" (Ignores Lodge Safe, moves items from Lazy Panda's Inventory.)
cgf "LZP:SystemScript.MoveResourcesToShip" (Ignores Lodge Safe, moves resources from Lazy Panda's Inventory.)
cgf "LZP:SystemScript.MoveInventoryToLodgeSafe" (Moves Lazy Panda's Inventory to Lodge Safe.)
cgf "LZP:SystemScript.MoveValuablesToPlayer" (Moves all Valuables from ship and Lazy Panda to Player.)

All Mod Rewards go to "Make A Wish Foundation" please Endorse

Special Credits and Thanks:

A huge thank you goes to Aurelianis for granting me permission to alter and reuse her original script from Lazy Scav - An Autoloot for
Starfield. Without her permission it would have taken me significantly longer to put this together. She gets full credit for original script.
