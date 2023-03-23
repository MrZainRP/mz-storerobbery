## MZ-STOREROBBERY - a fork of the popular qb-storerobbery with or without mz-skills integration

PLEASE MAKE SURE YOU USE EITHER THE BASE CONFIG OR THE GABZ_CONFIG (NOT BOTH) - DELETE THE ONE YOU ARE NOT USING. 

PLEASE ALSO NOTE, NO SUPPORT IS OFFERED FOR THE GABZ_CONFIG AND IT WILL NOT BE UPDATED.

By Mr_Zain#4139

- Outward file name changed to mz-storerobbery to track developments on forkline - all credit to Kakarot and QB-Core - this is a qb-core base script and all internal functions retain qb-storerobbery designations.
- A varied take on qb-storerobberies with a focus on RP servers. Removed stickynote keypad function and replaced with mhacking in connection with mz-usbhacks (can be changed if you are not using mz-skills and particularly the "Hacking" skill).
- Hack is harder at lower XP levels and becomes easier as player gains XP in Hacking.
- Progressbars added to register, safe and alcohol safe components to slow player down giving time for police response and RP between police and criminals.
- Substitutes "dirtymoney" for "markedbills".
- Configured to function with standard qb-core notifications and oKoKNotify.
- Configured to function with mz-skills or independently. 

## DEPENDENCIES

NOTE: You should have each of the dependencies other than qb-lock and mz-skills as part of a conventional qb-core install.

**[mz-skills](https://github.com/MrZainRP/mz-skills)** - to track skill progress. All credit to Kings#4220 for the original qb-skillz now **[B1-skillz](https://github.com/Burn-One-Studios/B1-skillz)**

**[progressbar](https://github.com/qbcore-framework/progressbar)**

**[qb-target](https://github.com/qbcore-framework/qb-target)**

**[ps-ui](https://github.com/Project-Sloth/ps-ui)**

OPTIONAL: (Configured to work with okokNotify as well as base qb-core notifications).

## Installation Instruction

## A. MZ-SKILLS (NOT MANDATORY BUT RECOMMENDED)

1. Ensure that mz-skills forms part of your running scripts. If you have downloaded mz-skills before and are running it, please make sure you download the latest version of it. 

2. Run the "skills.sql" sql file and open the database. (This will add a data table to the existing "players" database which will hold the skill value for "Scraping" as well as other jobs)

## B. QB-CORE/SHARED/ITEMS.LUA

3. Add the following items to qb-core/shared/items.lua 

PLEASE NOTE: If you are using other mz- resources you will not need to re-add certain items. Also be sure not to have conflicting items with the same name in your qb-core/items.lua.

```lua
		-- mz-storerobbery
	["liquorkey"] 					 = {["name"] = "liquorkey", 					["label"] = "Liquor Storeroom", 		["weight"] = 200, 		["type"] = "item", 		["image"] = "liquorkey.png", 			["unique"] = false, 		["useable"] = true, 	["shouldClose"] = false,   ["combinable"] = nil,   ["description"] = "A curious key with the label 'Liquor Storeroom'."},
    ["dirtymoney"]                   = {["name"] = "dirtymoney",                    ["label"] = "Dirty Money",              ["weight"] = 0,         ["type"] = "item",      ["image"] = "dirtymoney.png",           ["unique"] = false,		["useable"] = true,     ["shouldClose"] = false,    ["combinable"] = nil,  ["description"] = "The ill-gotten proceeds of criminal activity."},  
```

## C. IMAGES

4. Add the images which appear in the "images" folder to your inventory images folder. 

If using lj-inventory, add the images to: lj-inventory/html/images/ - if you are using qb-inventory, add the images to qb-inventory/html/images/

## D. DOORLOCKS

5. Add the file "Liquorstore.lua" contaiend within the resource files to qb-doorlock/Configs to configure all alcohol doorlock configurations. (All alcohol store doorlocks are designed to operate with the conventional GTA V map, not MLO modifications)

## E. PS-DISPATCH

6. Please make sure you add the following to your ps-dispatch/server/sv_dispatchcodes.lua if you are using ps-dispatch:

```lua
["mz-storerobbery-register"] =  {displayCode = '10-90', description = "Forced Entry: Cash Register", radius = 0, recipientList = {'LEO', 'police'}, blipSprite = 628, blipColour = 1, blipScale = 1.5, blipLength = 2, sound = "Lose_1st", sound2 = "GTAO_FM_Events_Soundset", offset = "false", blipflash = "false"},
["mz-storerobbery-safe"] =  {displayCode = '10-90', description = "Store Robbery In Progress", radius = 0, recipientList = {'LEO', 'police'}, blipSprite = 350, blipColour = 1, blipScale = 1.5, blipLength = 2, sound = "Lose_1st", sound2 = "GTAO_FM_Events_Soundset", offset = "false", blipflash = "false"},
["mz-storerobbery-liquor"] =  {displayCode = '10-90', description = "Liquor Store Robbery", radius = 0, recipientList = {'LEO', 'police'}, blipSprite = 350, blipColour = 1, blipScale = 1.5, blipLength = 2, sound = "Lose_1st", sound2 = "GTAO_FM_Events_Soundset", offset = "false", blipflash = "false"},

```

## F. FINALISATION

7. If you attend to all of the above steps you will need to restart the server in order for the new added items to be recognised by qb-core. 

8. Please restart your server ensuring that mz-storerobbery is ensured/starts after qb-core starts (ideally it should just form part of your [qb] folder).

9. Big thanks to Savage#2092 for configuring mz-storerobbery with the gabz MLO coordinates. If you experience errors, please do not annoy either of us as I am not offering supporting for MLO location changes - it's very easy to change vector coordinates in the config file.
