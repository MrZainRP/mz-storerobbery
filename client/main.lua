local QBCore = exports['qb-core']:GetCoreObject()

local currentRegister = 0
local currentSafe = 0
local copsCalled = false
local CurrentCops = 0
local PlayerJob = {}
local onDuty = false
local usingAdvanced = false
local openingDoor = false 

local lvl8 = false
local lvl7 = false
local lvl6 = false
local lvl5 = false
local lvl4 = false
local lvl3 = false
local lvl2 = false
local lvl1 = false
local lvl0 = false

---------------
--PS-DISPATCH--
---------------

-- IF YOU ARE USING PS-DISPATCH v2 IGNORE THE FOLLOWING, OTHERWISE YOU CONFIGURE YOUR PS-DISPATCH v1 AS FOLLOWS:
-- YOU MUST MAKE SURE YOU ADD THESE TO YOUR PS-DISPATCH/SERVER/SV_DISPATCHCODES.LUA FILE (of course remove the "--" at the start of the code for each): 

-- ["mz-storerobbery-register"] =  {displayCode = '10-90', description = "Forced Entry: Cash Register", radius = 0, recipientList = {'police'}, blipSprite = 628, blipColour = 1, blipScale = 1.5, blipLength = 2, sound = "Lose_1st", sound2 = "GTAO_FM_Events_Soundset", offset = "false", blipflash = "false"},
-- ["mz-storerobbery-safe"] =  {displayCode = '10-90', description = "Store Robbery In Progress", radius = 0, recipientList = {'police'}, blipSprite = 350, blipColour = 1, blipScale = 1.5, blipLength = 2, sound = "Lose_1st", sound2 = "GTAO_FM_Events_Soundset", offset = "false", blipflash = "false"},
-- ["mz-storerobbery-liquor"] =  {displayCode = '10-90', description = "Liquor Store Robbery", radius = 0, recipientList = {'police'}, blipSprite = 350, blipColour = 1, blipScale = 1.5, blipLength = 2, sound = "Lose_1st", sound2 = "GTAO_FM_Events_Soundset", offset = "false", blipflash = "false"},

function getStreetandZone(coords)
    local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
    local currentStreetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
    currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    playerStreetsLocation = currentStreetName .. ", " .. zone
    return playerStreetsLocation
end

function GetPedGender()
    local gender = "Male"
    if QBCore.Functions.GetPlayerData().charinfo.gender == 1 then gender = "Female" end
    return gender
end

RegisterNetEvent('mz-storerobbery:client:mzRegisterHit', function()
    if not Config.dispatchver2 then 
        local currentPos = GetEntityCoords(PlayerPedId())
        local locationInfo = getStreetandZone(currentPos)
        local gender = GetPedGender()
        TriggerServerEvent("dispatch:server:notify",{
            dispatchcodename = "mz-storerobbery-register",          -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
            dispatchCode = "10-90",
            firstStreet = locationInfo,
            gender = gender,
            camId = camId,
            model = nil,
            plate = nil,
            priority = 1,                                           -- priority
            firstColor = nil,
            automaticGunfire = false,
            origin = {
                x = currentPos.x,
                y = currentPos.y,
                z = currentPos.z
            },
            dispatchMessage = "Forced Entry: Cash Register",        -- message
            job = {"police"}                                        -- jobs that will get the alerts
        })
    elseif Config.dispatchver2 then 
        exports['ps-dispatch']:mzRegisterStoreRobbery(camId)
    end 
end)

RegisterNetEvent('mz-storerobbery:client:mzSafeHit', function()
    if not Config.dispatchver2 then 
        local currentPos = GetEntityCoords(PlayerPedId())
        local locationInfo = getStreetandZone(currentPos)
        local gender = GetPedGender()
        TriggerServerEvent("dispatch:server:notify",{
            dispatchcodename = "mz-storerobbery-safe",          -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
            dispatchCode = "10-90",
            firstStreet = locationInfo,
            gender = gender,
            camId = camId,
            model = nil,
            plate = nil,
            priority = 1,                                       -- priority
            firstColor = nil,
            automaticGunfire = false,
            origin = {
                x = currentPos.x,
                y = currentPos.y,
                z = currentPos.z
            },
            dispatchMessage = "24/7 Store Robbery",             -- message
            job = {"police"}                                    -- jobs that will get the alerts
        })
    elseif Config.dispatchver2 then 
        exports['ps-dispatch']:mz711StoreRobbery(camId)
    end 
end)

RegisterNetEvent('mz-storerobbery:client:mzLiquorHit', function()
    if not Config.dispatchver2 then 
        local currentPos = GetEntityCoords(PlayerPedId())
        local locationInfo = getStreetandZone(currentPos)
        local gender = GetPedGender()
        TriggerServerEvent("dispatch:server:notify",{
            dispatchcodename = "mz-storerobbery-liquor",        -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
            dispatchCode = "10-90",
            firstStreet = locationInfo,
            gender = gender,
            camId = camId,
            model = nil,
            plate = nil,
            priority = 1,                                       -- priority
            firstColor = nil,
            automaticGunfire = false,
            origin = {
                x = currentPos.x,
                y = currentPos.y,
                z = currentPos.z
            },
            dispatchMessage = "Liquor Store Robbery",           -- message
            job = {"police"}                                    -- jobs that will get the alerts
        })
    elseif Config.dispatchver2 then 
        exports['ps-dispatch']:mzLiquorStoreRobbery(camId)
    end 
end)

-------------
--FUNCTIONS--
-------------

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerJob = QBCore.Functions.GetPlayerData().job
    onDuty = true
end)

RegisterNetEvent('QBCore:Client:SetDuty', function(duty)
    onDuty = duty
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = true
end)

RegisterNetEvent('police:SetCopCount', function(amount)
    CurrentCops = amount
end)

function setupRegister()
    QBCore.Functions.TriggerCallback('mz-storerobbery:server:getRegisterStatus', function(Registers)
        for k in pairs(Registers) do
            if Config.UseGabz then 
                Config.RegistersTargetGabz[k].robbed = Registers[k].robbed
            else
                Config.RegistersTarget[k].robbed = Registers[k].robbed
            end 
        end
    end)
end

function setupSafes()
    QBCore.Functions.TriggerCallback('mz-storerobbery:server:getSafeStatus', function(Safes)
        for k in pairs(Safes) do
            if not Config.UseGabz then 
                Config.SafesTarget[k].robbed = Safes[k].robbed
            else 
                Config.SafesTargetGabz[k].robbed = Safes[k].robbed
            end 
        end
    end)
end

DrawText3Ds = function(coords, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function openLockpick(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        toggle = bool,
    })
    SetCursorLocation(0.5, 0.2)
end

------------------
--CASH REGISTERS--
------------------

CreateThread(function()
    if not Config.UseGabz then 
        for k, v in pairs(Config.RegistersTarget) do
            exports["qb-target"]:AddBoxZone("zainregisters" .. k, v.coords, 1, 1, {
                name = "zainregisters" .. k,
                heading = 90,
                minZ = v.coords.z - 0.2,
                maxZ = v.coords.z + 0.4,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        icon = "fa fa-hand",
                        label = "Attempt to open register",
                        action = function()
                            StealFromRegister(k)
                        end,
                        canInteract = function()
                            if v.robbed then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.5
            })
        end
    else 
        for k, v in pairs(Config.RegistersTargetGabz) do
            exports["qb-target"]:AddBoxZone("zainregisters" .. k, v.coords, 1, 1, {
                name = "zainregisters" .. k,
                heading = 90,
                minZ = v.coords.z - 0.2,
                maxZ = v.coords.z + 0.4,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        icon = "fa fa-hand",
                        label = "Attempt to open register",
                        action = function()
                            StealFromRegister(k)
                        end,
                        canInteract = function()
                            if v.robbed then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.5
            })
        end
    end 
end)

function StealFromRegister(k)
    QBCore.Functions.TriggerCallback('mz-storerobbery:server:getCops', function(cops)
        if QBCore.Functions.HasItem("advancedlockpick") then
            if not Config.UseGabz then
                if not Config.RegistersTarget[k].robbed then
                    if cops >= Config.MinimumStoreRobberyPolice then
                        currentRegister = k
                        print(k)
                        TriggerServerEvent('mz-storerobbery:server:setRegisterStatus', currentRegister)
                        if Config.BreakRegister == "standard" then 
                            print('Config.BreakRegister == "standard" is no longer supported - please select "circle"')
                        elseif Config.BreakRegister == "circle" then 
                            TriggerEvent('mz-storerobbery:client:circleLockpickAdvanced')
                            if Config.psdispatch then 
                                if not copsCalled then 
                                    TriggerEvent('mz-storerobbery:client:mzRegisterHit')
                                    copsCalled = true
                                    Wait(Config.DispatchRegisterDelay * 1000)
                                    copsCalled = false 
                                end 
                            end 
                        else 
                            print("Your 'Config.BreakRegister' is not configured properly. Please see config.lua")
                        end
                        if not IsWearingHandshoes() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        end
                        if not Config.psdispatch then 
                            if not copsCalled then
                                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                local street1 = GetStreetNameFromHashKey(s1)
                                local street2 = GetStreetNameFromHashKey(s2)
                                local streetLabel = street1
                                if street2 ~= nil then
                                    streetLabel = streetLabel .. " " .. street2
                                end
                                TriggerServerEvent("mz-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                                copsCalled = true
                            end
                        end 
                    else
                        if Config.NotifyType == 'qb' then
                            QBCore.Functions.Notify("Not Enough Police ("..Config.MinimumStoreRobberyPolice.. " required)", "error", 3500)
                        elseif Config.NotifyType == "okok" then
                            exports['okokNotify']:Alert("MORE COPS", "Not enough Police ("..Config.MinimumStoreRobberyPolice.. " required)", 3500, "error")
                        end 
                    end
                end
            else
                if not Config.RegistersTargetGabz[k].robbed then
                    if cops >= Config.MinimumStoreRobberyPolice then
                        currentRegister = k
                        print(k)
                        TriggerServerEvent('mz-storerobbery:server:setRegisterStatus', currentRegister)
                        if Config.BreakRegister == "standard" then 
                            print('Config.BreakRegister == "standard" is no longer supported - please select "circle"')
                        elseif Config.BreakRegister == "circle" then 
                            TriggerEvent('mz-storerobbery:client:circleLockpickAdvanced')
                            if Config.psdispatch then 
                                if not copsCalled then 
                                    TriggerEvent('mz-storerobbery:client:mzRegisterHit')
                                    copsCalled = true
                                    Wait(Config.DispatchRegisterDelay * 1000)
                                    copsCalled = false 
                                end 
                            end 
                        else 
                            print("Your 'Config.BreakRegister' is not configured properly. Please see config.lua")
                        end
                        if not IsWearingHandshoes() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        end
                        if not Config.psdispatch then 
                            if not copsCalled then
                                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                local street1 = GetStreetNameFromHashKey(s1)
                                local street2 = GetStreetNameFromHashKey(s2)
                                local streetLabel = street1
                                if street2 ~= nil then
                                    streetLabel = streetLabel .. " " .. street2
                                end
                                TriggerServerEvent("mz-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                                copsCalled = true
                            end
                        end 
                    else
                        if Config.NotifyType == 'qb' then
                            QBCore.Functions.Notify("Not Enough Police ("..Config.MinimumStoreRobberyPolice.. " required)", "error", 3500)
                        elseif Config.NotifyType == "okok" then
                            exports['okokNotify']:Alert("MORE COPS", "Not enough Police ("..Config.MinimumStoreRobberyPolice.. " required)", 3500, "error")
                        end 
                    end
                end
            end  
        elseif QBCore.Functions.HasItem("lockpick") and QBCore.Functions.HasItem("screwdriverset") then
            if not Config.UseGabz then 
                if not Config.RegistersTarget[k].robbed then
                    if cops >= Config.MinimumStoreRobberyPolice then
                        currentRegister = k
                        print(k)
                        TriggerServerEvent('mz-storerobbery:server:setRegisterStatus', currentRegister)
                        if Config.BreakRegister == "standard" then 
                            print('Config.BreakRegister == "standard" is no longer supported, please select "circle"')
                        elseif Config.BreakRegister == "circle" then 
                            TriggerEvent('mz-storerobbery:client:circleLockpick')
                            if Config.psdispatch then 
                                if not copsCalled then 
                                    TriggerEvent('mz-storerobbery:client:mzRegisterHit')
                                    copsCalled = true
                                    Wait(Config.DispatchRegisterDelay * 1000)
                                    copsCalled = false 
                                end 
                            end 
                        else 
                            print("Your 'Config.BreakRegister' is not configured properly. Please see config.lua")
                        end
                        if not IsWearingHandshoes() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        end
                        if not Config.psdispatch then 
                            if not copsCalled then
                                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                local street1 = GetStreetNameFromHashKey(s1)
                                local street2 = GetStreetNameFromHashKey(s2)
                                local streetLabel = street1
                                if street2 ~= nil then
                                    streetLabel = streetLabel .. " " .. street2
                                end
                                TriggerServerEvent("mz-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                                copsCalled = true
                            end
                        end 
                    else
                        if Config.NotifyType == 'qb' then
                            QBCore.Functions.Notify("Not Enough Police ("..Config.MinimumStoreRobberyPolice.. " required)", "error", 3500)
                        elseif Config.NotifyType == "okok" then
                            exports['okokNotify']:Alert("MORE COPS", "Not enough Police ("..Config.MinimumStoreRobberyPolice.. " required)", 3500, "error")
                        end 
                    end
                end
            else
                if not Config.RegistersTargetGabz[k].robbed then
                    if cops >= Config.MinimumStoreRobberyPolice then
                        currentRegister = k
                        print(k)
                        TriggerServerEvent('mz-storerobbery:server:setRegisterStatus', currentRegister)
                        if Config.BreakRegister == "standard" then 
                            print('Config.BreakRegister == "standard" is no longer supported, please select "circle"')
                        elseif Config.BreakRegister == "circle" then 
                            TriggerEvent('mz-storerobbery:client:circleLockpick')
                            if Config.psdispatch then 
                                if not copsCalled then 
                                    TriggerEvent('mz-storerobbery:client:mzRegisterHit')
                                    copsCalled = true
                                    Wait(Config.DispatchRegisterDelay * 1000)
                                    copsCalled = false 
                                end 
                            end 
                        else 
                            print("Your 'Config.BreakRegister' is not configured properly. Please see config.lua")
                        end
                        if not IsWearingHandshoes() then
                            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                        end
                        if not Config.psdispatch then 
                            if not copsCalled then
                                local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                local street1 = GetStreetNameFromHashKey(s1)
                                local street2 = GetStreetNameFromHashKey(s2)
                                local streetLabel = street1
                                if street2 ~= nil then
                                    streetLabel = streetLabel .. " " .. street2
                                end
                                TriggerServerEvent("mz-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                                copsCalled = true
                            end
                        end 
                    else
                        if Config.NotifyType == 'qb' then
                            QBCore.Functions.Notify("Not Enough Police ("..Config.MinimumStoreRobberyPolice.. " required)", "error", 3500)
                        elseif Config.NotifyType == "okok" then
                            exports['okokNotify']:Alert("MORE COPS", "Not enough Police ("..Config.MinimumStoreRobberyPolice.. " required)", 3500, "error")
                        end 
                    end
                end
            end  
        else
            local requiredItems = {
                [1] = {name = QBCore.Shared.Items["lockpick"]["name"], image = QBCore.Shared.Items["lockpick"]["image"]},
                [2] = {name = QBCore.Shared.Items["screwdriverset"]["name"], image = QBCore.Shared.Items["screwdriverset"]["image"]},
            }
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify('You need something to attempt to open the register...', "error", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("NEED LOCKPICK", 'You need something to attempt to open the register...', 3500, "error")
            end 
            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
            Wait(3500)
            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
        end 
    end)
end

local registerDone = true 

RegisterNetEvent('mz-storerobbery:client:circleLockpick', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"uncuff"})
    exports['ps-ui']:Circle(function(success)
        if success then
            if currentRegister ~= 0 then
                openingDoor = true 
                local lockpickTime = (Config.RegisterTime * 1000)
                QBCore.Functions.Progressbar("search_register", "Emptying the till...", lockpickTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    openingDoor = false
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    ClearPedTasks(PlayerPedId())
                    registerDone = false 
                    TriggerServerEvent('mz-storerobbery:server:takeMoney', currentRegister, true, registerDone)
                    registerDone = true
                    Wait(1000)
                    if Config.mzskills then 
                        local BetterXP = math.random(Config.HeistXPLow2, Config.HeistXPHigh2)
                        local hackerchance = math.random(1, 10)
                        if hackerchance > 8 then
                            chance = BetterXP
                        elseif hackerchance < 9 and hackerchance > 6 then
                            chance = math.random(Config.HeistXPmid2)
                        else
                            chance = Config.HeistXPlow2
                        end
                        exports["mz-skills"]:UpdateSkill(Config.CriminalXPSkill, chance)
                    end
                end, function() -- Cancel
                    openingDoor = false
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    ClearPedTasks(PlayerPedId())
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify('Process Cancelled', "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
                    end 
                    currentRegister = 0
                end)
                CreateThread(function()
                    while openingDoor do
                        if Config.StressEnabled then 
                            TriggerServerEvent('hud:server:GainStress', 1)
                        end 
                        Wait(2500)
                        if openingDoor then 
                            TriggerServerEvent("InteractSound_SV:PlayOnSource", "lockpick", 1)
                        end 
                    end
                end)
            end
        else
            TriggerServerEvent('mz-storerobbery:server:setRegisterStatusFailed', currentRegister)
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify("Your hand slipped and the lockpick bends...", "error", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("LOCKPICK FAILED", "Your hand slipped and the lockpick bends...", 3500, "error")
            end 
            Wait(2000)
            if math.random(1, 100) <= Config.LockpickBreakChance then
                TriggerServerEvent("mz-storerobbery:server:RemoveLockpick")
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('You broke the lockpick...', "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("IT BROKE!", "You broke the lockpick...", 3500, "error")
                end 
            end
            if (IsWearingHandshoes() and math.random(1, 100) <= Config.PrintChanceRegister) then
                local pos = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
            end
        end
    end, Config.circleparses, Config.circletime) 
end)

RegisterNetEvent('mz-storerobbery:client:circleLockpickAdvanced', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"uncuff"})
    exports['ps-ui']:Circle(function(success)
        if success then
            if currentRegister ~= 0 then
                openingDoor = true 
                local lockpickTime = (Config.RegisterTime * 1000)
                QBCore.Functions.Progressbar("search_register", "Emptying the till...", lockpickTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function() -- Done
                    openingDoor = false
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    ClearPedTasks(PlayerPedId())
                    registerDone = false 
                    TriggerServerEvent('mz-storerobbery:server:takeMoney', currentRegister, true, registerDone)
                    registerDone = true
                end, function() -- Cancel
                    openingDoor = false
                    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                    ClearPedTasks(PlayerPedId())
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify('Process Cancelled', "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
                    end 
                    currentRegister = 0
                end)
                CreateThread(function()
                    while openingDoor do
                        if Config.StressEnabled then 
                            TriggerServerEvent('hud:server:GainStress', 1)
                        end 
                        Wait(2500)
                        if openingDoor then 
                            TriggerServerEvent("InteractSound_SV:PlayOnSource", "lockpick", 1)
                        end 
                    end
                end)
            end
        else
            TriggerServerEvent('mz-storerobbery:server:setRegisterStatusFailed', currentRegister)
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify("Your hand slipped and the lockpick bends...", "error", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("LOCKPICK FAILED", "Your hand slipped and the lockpick bends...", 3500, "error")
            end 
            Wait(2000)
            if math.random(1, 100) <= Config.AdvancedBreakChance then
                TriggerServerEvent("mz-storerobbery:server:RemoveAdvanced", 1)
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('You broke the lockpick...', "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("IT BROKE!", "You broke the lockpick...", 3500, "error")
                end 
            end
            if (IsWearingHandshoes() and math.random(1, 100) <= Config.PrintChanceRegister) then
                local pos = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
            end
        end
    end, Config.circleparses, Config.circletime) 
end)

local openingDoor = false

function IsWearingHandshoes()
    local armIndex = GetPedDrawableVariation(PlayerPedId(), 3)
    local model = GetEntityModel(PlayerPedId())
    local retval = true
    if model == `mp_m_freemode_01` then
        if Config.MaleNoHandshoes[armIndex] ~= nil and Config.MaleNoHandshoes[armIndex] then
            retval = false
        end
    else
        if Config.FemaleNoHandshoes[armIndex] ~= nil and Config.FemaleNoHandshoes[armIndex] then
            retval = false
        end
    end
    return retval
end

-------------------
--STEAL FROM SAFE--
-------------------

CreateThread(function()
    if not Config.UseGabz then 
        for safe, v in pairs(Config.SafesTarget) do
            exports["qb-target"]:AddBoxZone("zainsafes" .. safe, v.coords, 1, 1, {
                name = "zainsafes" .. safe,
                heading = 40,
                minZ = v.coords.z - 1,
                maxZ = v.coords.z + 1,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        icon = "fa fa-hand",
                        label = "Break into safe",
                        action = function()
                            StealfromSafe(safe)
                        end,
                        canInteract = function()
                            if v.robbed then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.5
            })
        end
    else
        for safe, v in pairs(Config.SafesTargetGabz) do
            exports["qb-target"]:AddBoxZone("zainsafes" .. safe, v.coords, 1, 1, {
                name = "zainsafes" .. safe,
                heading = 40,
                minZ = v.coords.z - 1,
                maxZ = v.coords.z + 1,
                debugPoly = false
            }, {
                options = {
                    {
                        type = "client",
                        icon = "fa fa-hand",
                        label = "Break into safe",
                        action = function()
                            StealfromSafe(safe)
                        end,
                        canInteract = function()
                            if v.robbed then
                                return false
                            end
                            return true
                        end,
                    }
                },
                distance = 1.5
            })
        end
    end  
end)

RegisterNetEvent('mz-storerobbery:client:CheckXPLevel', function()
    lvl8 = false
    lvl7 = false
    lvl6 = false
    lvl5 = false
    lvl4 = false
    lvl3 = false
    lvl2 = false
    lvl1 = false
    lvl0 = false
    if Config.mzskills then 
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl8, function(hasskill)
            if hasskill then lvl8 = true end
        end)
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl7, function(hasskill)
            if hasskill then lvl7 = true end
        end)
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl6, function(hasskill)
            if hasskill then lvl6 = true end
        end)
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl5, function(hasskill)
            if hasskill then lvl5 = true end
        end)
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl4, function(hasskill)
            if hasskill then lvl4 = true end
        end)
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl3, function(hasskill)
            if hasskill then lvl3 = true end
        end)
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl2, function(hasskill)
            if hasskill then lvl2 = true end
        end)
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl1, function(hasskill)
            if hasskill then lvl1 = true end
        end)
        exports["mz-skills"]:CheckSkill(Config.HackXPSkill, Config.HackXPlvl0, function(hasskill)
            if hasskill then lvl0 = true end
        end)
    else
        Wait(10)
    end     
end)

function StealfromSafe(safe)
    QBCore.Functions.TriggerCallback('mz-storerobbery:server:getCops', function(cops)
        if not Config.UseGabz then
            if not Config.SafesTarget[safe].robbed then
                if cops >= Config.MinimumStoreRobberyPolice then
                    currentSafe = safe
                    print(currentSafe)
                    if math.random(1, 100) <= Config.PrintChanceSafe and not IsWearingHandshoes() then
                        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                    end
                    if Config.SafesTarget[safe].type == "keypad" then -- CONVENIENCE STORE PARTICULARS (NON-GABZ CONFIGURATION)
                        if QBCore.Functions.HasItem(Config.SafeReqItem) then
                            TriggerServerEvent('mz-storerobbery:server:setSafeStatus', currentSafe)
                            if Config.psdispatch then 
                                TriggerEvent('mz-storerobbery:client:mzSafeHit')
                            else 
                                if not copsCalled then
                                    pos = GetEntityCoords(PlayerPedId())
                                    local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                    local street1 = GetStreetNameFromHashKey(s1)
                                    local street2 = GetStreetNameFromHashKey(s2)
                                    local streetLabel = street1
                                    if street2 ~= nil then
                                        streetLabel = streetLabel .. " " .. street2
                                    end
                                    TriggerServerEvent("mz-storerobbery:server:callCops", "safe", currentSafe, streetLabel, pos)
                                    copsCalled = true
                                end
                            end 
                            TriggerEvent('mz-storerobbery:client:CheckXPLevel')
                            if Config.Hacktype == "mHacking" then 
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                TriggerServerEvent("mz-storerobbery:server:ItemRemoval")
                                if Config.mzskills then
                                    TriggerEvent("mhacking:show") 
                                    if lvl8 then  
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl8low, Config.mhacklvl8high), Config.mhacklvl8time, HackingSuccessSafe)
                                    elseif lvl7 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl7low, Config.mhacklvl7high), Config.mhacklvl7time, HackingSuccessSafe)
                                    elseif lvl6 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl6low, Config.mhacklvl6high), Config.mhacklvl6time, HackingSuccessSafe)
                                    elseif lvl5 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl5low, Config.mhacklvl5high), Config.mhacklvl5time, HackingSuccessSafe)
                                    elseif lvl4 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl4low, Config.mhacklvl4high), Config.mhacklvl4time, HackingSuccessSafe)
                                    elseif lvl3 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl3low, Config.mhacklvl3high), Config.mhacklvl3time, HackingSuccessSafe)
                                    elseif lvl2 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl2low, Config.mhacklvl2high), Config.mhacklvl2time, HackingSuccessSafe)
                                    elseif lvl1 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl1low, Config.mhacklvl1high), Config.mhacklvl1time, HackingSuccessSafe)
                                    else 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl0low, Config.mhacklvl0high), Config.mhacklvl0time, HackingSuccessSafe)
                                    end
                                elseif not Config.mzskills then
                                    TriggerEvent("mhacking:show") 
                                    TriggerEvent("mhacking:start", math.random(Config.mhacklvlNOXPlow, Config.mhacklvlNOXPlow), Config.mhacklvlNOXPtime, HackingSuccessSafe)
                                else
                                    print('You need to configure whether you are using mz-skills or not - see Config.mzskills')
                                end
                            elseif Config.Hacktype == "varHack" then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                TriggerServerEvent("mz-storerobbery:server:ItemRemoval")
                                if Config.mzskills then
                                    if lvl8 then
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl8blocks, Config.varhacklvl8time) -- Number of Blocks, Time (seconds)
                                    elseif lvl7 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl7blocks, Config.varhacklvl7time) -- Number of Blocks, Time (seconds)
                                    elseif lvl6 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl6blocks, Config.varhacklvl6time) -- Number of Blocks, Time (seconds)
                                    elseif lvl5 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl5blocks, Config.varhacklvl5time) -- Number of Blocks, Time (seconds)
                                    elseif lvl4 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl4blocks, Config.varhacklvl4time) -- Number of Blocks, Time (seconds)
                                    elseif lvl3 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl3blocks, Config.varhacklvl3time) -- Number of Blocks, Time (seconds)
                                    elseif lvl2 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl2blocks, Config.varhacklvl2time) -- Number of Blocks, Time (seconds)
                                    elseif lvl1 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl1blocks, Config.varhacklvl1time) -- Number of Blocks, Time (seconds)
                                    elseif lvl0 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl0blocks, Config.varhacklvl0time) -- Number of Blocks, Time (seconds)
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:VarHack(function(success)
                                        if success then
                                            ExchangeSuccessSafe()
                                        else
                                            ExchangeFailSafe(safe)
                                        end
                                    end, Config.varhacklvlNOXPblocks, Config.varhacklvlNOXPtime) -- Number of Blocks, Time (seconds)
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end
                            elseif Config.Hacktype == "scrambler" then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                TriggerServerEvent("mz-storerobbery:server:ItemRemoval")
                                if Config.mzskills then
                                    if lvl8 then  
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl8Type, Config.ScramLvl8Time, Config.ScramLvl8Mod)
                                    elseif lvl7 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl7Type, Config.ScramLvl7Time, Config.ScramLvl7Mod)
                                    elseif lvl6 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl6Type, Config.ScramLvl6Time, Config.ScramLvl6Mod)
                                    elseif lvl5 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl5Type, Config.ScramLvl5Time, Config.ScramLvl5Mod)
                                    elseif lvl4 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl4Type, Config.ScramLvl4Time, Config.ScramLvl4Mod)
                                    elseif lvl3 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl3Type, Config.ScramLvl3Time, Config.ScramLvl3Mod)
                                    elseif lvl2 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl2Type, Config.ScramLvl2Time, Config.ScramLvl2Mod)
                                    elseif lvl1 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl1Type, Config.ScramLvl1Time, Config.ScramLvl1Mod)
                                    elseif lvl0 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl0Type, Config.ScramLvl0Time, Config.ScramLvl0Mod)
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:Scrambler(function(success)
                                        if success then
                                            ExchangeSuccessSafe()
                                        else
                                            ExchangeFailSafe(safe)
                                        end
                                    end, Config.ScramNOXPType, Config.ScramNOXPTime, Config.ScramNOXPMod)
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end        
                            elseif Config.Hacktype == "maze" then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                TriggerServerEvent("mz-storerobbery:server:ItemRemoval")
                                if Config.mzskills then
                                    if lvl8 then
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze8Time) -- Hack Time Limit
                                    elseif lvl7 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze7Time) -- Hack Time Limit
                                    elseif lvl6 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze6Time) -- Hack Time Limit
                                    elseif lvl5 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze5Time) -- Hack Time Limit
                                    elseif lvl4 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze4Time) -- Hack Time Limit
                                    elseif lvl3 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze3Time) -- Hack Time Limit
                                    elseif lvl2 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze2Time) -- Hack Time Limit
                                    elseif lvl1 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze1Time) -- Hack Time Limit
                                    elseif lvl0 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze0Time) -- Hack Time Limit
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:Maze(function(success)
                                        if success then
                                            ExchangeSuccessSafe()
                                        else
                                            ExchangeFailSafe(safe)
                                        end
                                    end, Config.MazeNOXPTime) -- Hack Time Limit
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end      
                            end
                        else
                            local requiredItems = {
                            [1] = {name = QBCore.Shared.Items[Config.SafeReqItem]["name"], image = QBCore.Shared.Items[Config.SafeReqItem]["image"]},
                            }
                            if Config.NotifyType == 'qb' then
                                QBCore.Functions.Notify('You need a '..QBCore.Shared.Items[Config.SafeReqItem]["label"]..' to breach the safe...', "error", 3500)
                            elseif Config.NotifyType == "okok" then
                                exports['okokNotify']:Alert(QBCore.Shared.Items[Config.SafeReqItem]["label"].." REQUIRED", "You need a "..QBCore.Shared.Items[Config.SafeReqItem]["label"].." to breach the safe...", 3500, "error")
                            end 
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                            Wait(3500)
                            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        end 
                    else -- LIQUOR STORE PARTICULARS (NON-GABZ CONFIGURATION)
                        if QBCore.Functions.HasItem(Config.LiquorReqItem) then
                            if Config.psdispatch then 
                                TriggerEvent('mz-storerobbery:client:mzLiquorHit')
                            else 
                                if not copsCalled then
                                    pos = GetEntityCoords(PlayerPedId())
                                    local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                    local street1 = GetStreetNameFromHashKey(s1)
                                    local street2 = GetStreetNameFromHashKey(s2)
                                    local streetLabel = street1
                                    if street2 ~= nil then
                                        streetLabel = streetLabel .. " " .. street2
                                    end
                                    TriggerServerEvent("mz-storerobbery:server:callCops", "safe", currentSafe, streetLabel, pos)
                                    copsCalled = true
                                end
                            end
                            TriggerServerEvent('mz-storerobbery:server:setSafeStatus', currentSafe)
                            Wait(250)
                            TriggerServerEvent("mz-storerobbery:server:ItemRemovalLiquor")
                            TriggerEvent('mz-storerobbery:client:CheckXPLevel')
                            if Config.HacktypeLiquor == "mHacking" then 
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                if Config.mzskills then
                                    TriggerEvent("mhacking:show") 
                                    if lvl8 then  
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl8low, Config.mhacklvl8high), Config.mhacklvl8time, HackingSuccessSafeLiquor)
                                    elseif lvl7 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl7low, Config.mhacklvl7high), Config.mhacklvl7time, HackingSuccessSafeLiquor)
                                    elseif lvl6 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl6low, Config.mhacklvl6high), Config.mhacklvl6time, HackingSuccessSafeLiquor)
                                    elseif lvl5 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl5low, Config.mhacklvl5high), Config.mhacklvl5time, HackingSuccessSafeLiquor)
                                    elseif lvl4 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl4low, Config.mhacklvl4high), Config.mhacklvl4time, HackingSuccessSafeLiquor)
                                    elseif lvl3 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl3low, Config.mhacklvl3high), Config.mhacklvl3time, HackingSuccessSafeLiquor)
                                    elseif lvl2 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl2low, Config.mhacklvl2high), Config.mhacklvl2time, HackingSuccessSafeLiquor)
                                    elseif lvl1 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl1low, Config.mhacklvl1high), Config.mhacklvl1time, HackingSuccessSafeLiquor)
                                    else 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl0low, Config.mhacklvl0high), Config.mhacklvl0time, HackingSuccessSafeLiquor)
                                    end
                                elseif not Config.mzskills then
                                    TriggerEvent("mhacking:show") 
                                    TriggerEvent("mhacking:start", math.random(Config.mhacklvlNOXPlow, Config.mhacklvlNOXPlow), Config.mhacklvlNOXPtime, HackingSuccessSafeLiquor)
                                else
                                    print('You need to configure whether you are using mz-skills or not - see "Config.mzskills"')
                                end
                            elseif Config.HacktypeLiquor == "varHack" then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                if Config.mzskills then
                                    if lvl8 then
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl8blocks, Config.varhacklvl8time) -- Number of Blocks, Time (seconds)
                                    elseif lvl7 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl7blocks, Config.varhacklvl7time) -- Number of Blocks, Time (seconds)
                                    elseif lvl6 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl6blocks, Config.varhacklvl6time) -- Number of Blocks, Time (seconds)
                                    elseif lvl5 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl5blocks, Config.varhacklvl5time) -- Number of Blocks, Time (seconds)
                                    elseif lvl4 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl4blocks, Config.varhacklvl4time) -- Number of Blocks, Time (seconds)
                                    elseif lvl3 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl3blocks, Config.varhacklvl3time) -- Number of Blocks, Time (seconds)
                                    elseif lvl2 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl2blocks, Config.varhacklvl2time) -- Number of Blocks, Time (seconds)
                                    elseif lvl1 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl1blocks, Config.varhacklvl1time) -- Number of Blocks, Time (seconds)
                                    elseif lvl0 then 
                                        print("Does this even trigger? 1350")
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl0blocks, Config.varhacklvl0time) -- Number of Blocks, Time (seconds)
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:VarHack(function(success)
                                        if success then
                                            ExchangeSuccessSafeLiquor()
                                        else
                                            ExchangeFailSafeLiquor(safe)
                                        end
                                    end, Config.varhacklvlNOXPblocks, Config.varhacklvlNOXPtime) -- Number of Blocks, Time (seconds)
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end
                            elseif Config.HacktypeLiquor == "scrambler" then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                if Config.mzskills then
                                    if lvl8 then  
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl8Type, Config.ScramLvl8Time, Config.ScramLvl8Mod)
                                    elseif lvl7 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl7Type, Config.ScramLvl7Time, Config.ScramLvl7Mod)
                                    elseif lvl6 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl6Type, Config.ScramLvl6Time, Config.ScramLvl6Mod)
                                    elseif lvl5 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl5Type, Config.ScramLvl5Time, Config.ScramLvl5Mod)
                                    elseif lvl4 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl4Type, Config.ScramLvl4Time, Config.ScramLvl4Mod)
                                    elseif lvl3 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl3Type, Config.ScramLvl3Time, Config.ScramLvl3Mod)
                                    elseif lvl2 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl2Type, Config.ScramLvl2Time, Config.ScramLvl2Mod)
                                    elseif lvl1 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl1Type, Config.ScramLvl1Time, Config.ScramLvl1Mod)
                                    elseif lvl0 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl0Type, Config.ScramLvl0Time, Config.ScramLvl0Mod)
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:Scrambler(function(success)
                                        if success then
                                            ExchangeSuccessSafeLiquor()
                                        else
                                            ExchangeFailSafeLiquor(safe)
                                        end
                                    end, Config.ScramNOXPType, Config.ScramNOXPTime, Config.ScramNOXPMod)
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end        
                            elseif Config.HacktypeLiquor == "maze" then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                if Config.mzskills then
                                    if lvl8 then
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze8Time) -- Hack Time Limit
                                    elseif lvl7 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze7Time) -- Hack Time Limit
                                    elseif lvl6 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze6Time) -- Hack Time Limit
                                    elseif lvl5 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze5Time) -- Hack Time Limit
                                    elseif lvl4 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze4Time) -- Hack Time Limit
                                    elseif lvl3 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze3Time) -- Hack Time Limit
                                    elseif lvl2 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze2Time) -- Hack Time Limit
                                    elseif lvl1 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze1Time) -- Hack Time Limit
                                    elseif lvl0 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze1Time) -- Hack Time Limit
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:Maze(function(success)
                                        if success then
                                            ExchangeSuccessSafeLiquor()
                                        else
                                            ExchangeFailSafeLiquor(safe)
                                        end
                                    end, Config.Maze5Time) -- Hack Time Limit
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end            
                            end
                        else
                            local requiredItems = {
                            [1] = {name = QBCore.Shared.Items[Config.LiquorReqItem]["name"], image = QBCore.Shared.Items[Config.LiquorReqItem]["image"]},
                            }
                            if Config.NotifyType == 'qb' then
                                QBCore.Functions.Notify('You need a '..QBCore.Shared.Items[Config.LiquorReqItem]["label"]..' to breach the safe...', "error", 3500)
                            elseif Config.NotifyType == "okok" then
                                exports['okokNotify']:Alert(QBCore.Shared.Items[Config.LiquorReqItem]["label"].." REQUIRED", "You need a "..QBCore.Shared.Items[Config.LiquorReqItem]["label"].." to breach the safe...", 3500, "error")
                            end 
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                            Wait(3500)
                            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        end 
                    end
                else
                    QBCore.Functions.Notify("Not Enough Police (".. Config.MinimumStoreRobberyPolice .." Required)", "error")
                end
            end
        else
            if not Config.SafesTargetGabz[safe].robbed then
                if cops >= Config.MinimumStoreRobberyPolice then
                    currentSafe = safe
                    print(currentSafe)
                    if math.random(1, 100) <= Config.PrintChanceSafe and not IsWearingHandshoes() then
                        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                    end
                    if Config.SafesTargetGabz[safe].type == "keypad" then -- -- CONVENIENCE STORE PARTICULARS (NON-GABZ CONFIGURATION)
                        if QBCore.Functions.HasItem(Config.SafeReqItem) then
                            TriggerServerEvent('mz-storerobbery:server:setSafeStatus', currentSafe)
                            if Config.psdispatch then 
                                TriggerEvent('mz-storerobbery:client:mzSafeHit')
                            else 
                                if not copsCalled then
                                    pos = GetEntityCoords(PlayerPedId())
                                    local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                    local street1 = GetStreetNameFromHashKey(s1)
                                    local street2 = GetStreetNameFromHashKey(s2)
                                    local streetLabel = street1
                                    if street2 ~= nil then
                                        streetLabel = streetLabel .. " " .. street2
                                    end
                                    TriggerServerEvent("mz-storerobbery:server:callCops", "safe", currentSafe, streetLabel, pos)
                                    copsCalled = true
                                end
                            end 
                            TriggerEvent('mz-storerobbery:client:CheckXPLevel')
                            if Config.Hacktype == 'mHacking' then 
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                TriggerServerEvent("mz-storerobbery:server:ItemRemoval")
                                if Config.mzskills then
                                    TriggerEvent("mhacking:show") 
                                    if lvl8 then  
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl8low, Config.mhacklvl8high), Config.mhacklvl8time, HackingSuccessSafe)
                                    elseif lvl7 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl7low, Config.mhacklvl7high), Config.mhacklvl7time, HackingSuccessSafe)
                                    elseif lvl6 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl6low, Config.mhacklvl6high), Config.mhacklvl6time, HackingSuccessSafe)
                                    elseif lvl5 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl5low, Config.mhacklvl5high), Config.mhacklvl5time, HackingSuccessSafe)
                                    elseif lvl4 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl4low, Config.mhacklvl4high), Config.mhacklvl4time, HackingSuccessSafe)
                                    elseif lvl3 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl3low, Config.mhacklvl3high), Config.mhacklvl3time, HackingSuccessSafe)
                                    elseif lvl2 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl2low, Config.mhacklvl2high), Config.mhacklvl2time, HackingSuccessSafe)
                                    elseif lvl1 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl1low, Config.mhacklvl1high), Config.mhacklvl1time, HackingSuccessSafe)
                                    else 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl0low, Config.mhacklvl0high), Config.mhacklvl0time, HackingSuccessSafe)
                                    end
                                elseif not Config.mzskills then
                                    TriggerEvent("mhacking:show") 
                                    TriggerEvent("mhacking:start", math.random(Config.mhacklvlNOXPlow, Config.mhacklvlNOXPlow), Config.mhacklvlNOXPtime, HackingSuccessSafe)
                                else
                                    print('You need to configure whether you are using mz-skills or not - see Config.mzskills')
                                end
                            elseif Config.Hacktype == 'varHack' then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                TriggerServerEvent("mz-storerobbery:server:ItemRemoval")
                                if Config.mzskills then
                                    if lvl8 then
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl8blocks, Config.varhacklvl8time) -- Number of Blocks, Time (seconds)
                                    elseif lvl7 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl7blocks, Config.varhacklvl7time) -- Number of Blocks, Time (seconds)
                                    elseif lvl6 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl6blocks, Config.varhacklvl6time) -- Number of Blocks, Time (seconds)
                                    elseif lvl5 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl5blocks, Config.varhacklvl5time) -- Number of Blocks, Time (seconds)
                                    elseif lvl4 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl4blocks, Config.varhacklvl4time) -- Number of Blocks, Time (seconds)
                                    elseif lvl3 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl3blocks, Config.varhacklvl3time) -- Number of Blocks, Time (seconds)
                                    elseif lvl2 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl2blocks, Config.varhacklvl2time) -- Number of Blocks, Time (seconds)
                                    elseif lvl1 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl1blocks, Config.varhacklvl1time) -- Number of Blocks, Time (seconds)
                                    elseif lvl0 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.varhacklvl0blocks, Config.varhacklvl0time) -- Number of Blocks, Time (seconds)
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:VarHack(function(success)
                                        if success then
                                            ExchangeSuccessSafe()
                                        else
                                            ExchangeFailSafe(safe)
                                        end
                                    end, Config.varhacklvlNOXPblocks, Config.varhacklvlNOXPtime) -- Number of Blocks, Time (seconds)
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end
                            elseif Config.Hacktype == 'scrambler' then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                TriggerServerEvent("mz-storerobbery:server:ItemRemoval")
                                if Config.mzskills then
                                    if lvl8 then  
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl8Type, Config.ScramLvl8Time, Config.ScramLvl8Mod)
                                    elseif lvl7 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl7Type, Config.ScramLvl7Time, Config.ScramLvl7Mod)
                                    elseif lvl6 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl6Type, Config.ScramLvl6Time, Config.ScramLvl6Mod)
                                    elseif lvl5 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl5Type, Config.ScramLvl5Time, Config.ScramLvl5Mod)
                                    elseif lvl4 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl4Type, Config.ScramLvl4Time, Config.ScramLvl4Mod)
                                    elseif lvl3 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl3Type, Config.ScramLvl3Time, Config.ScramLvl3Mod)
                                    elseif lvl2 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl2Type, Config.ScramLvl2Time, Config.ScramLvl2Mod)
                                    elseif lvl1 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl1Type, Config.ScramLvl1Time, Config.ScramLvl1Mod)
                                    elseif lvl0 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.ScramLvl0Type, Config.ScramLvl0Time, Config.ScramLvl0Mod)
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:Scrambler(function(success)
                                        if success then
                                            ExchangeSuccessSafe()
                                        else
                                            ExchangeFailSafe(safe)
                                        end
                                    end, Config.ScramNOXPType, Config.ScramNOXPTime, Config.ScramNOXPMod)
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end        
                            elseif Config.Hacktype == 'maze' then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                TriggerServerEvent("mz-storerobbery:server:ItemRemoval")
                                if Config.mzskills then
                                    if lvl8 then
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze8Time) -- Hack Time Limit
                                    elseif lvl7 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze7Time) -- Hack Time Limit
                                    elseif lvl6 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze6Time) -- Hack Time Limit
                                    elseif lvl5 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze5Time) -- Hack Time Limit
                                    elseif lvl4 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze4Time) -- Hack Time Limit
                                    elseif lvl3 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze3Time) -- Hack Time Limit
                                    elseif lvl2 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze2Time) -- Hack Time Limit
                                    elseif lvl1 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze1Time) -- Hack Time Limit
                                    elseif lvl0 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafe()
                                            else
                                                ExchangeFailSafe(safe)
                                            end
                                        end, Config.Maze0Time) -- Hack Time Limit
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:Maze(function(success)
                                        if success then
                                            ExchangeSuccessSafe()
                                        else
                                            ExchangeFailSafe(safe)
                                        end
                                    end, Config.MazeNOXPTime) -- Hack Time Limit
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end      
                            end
                        else
                            local requiredItems = {
                            [1] = {name = QBCore.Shared.Items[Config.SafeReqItem]["name"], image = QBCore.Shared.Items[Config.SafeReqItem]["image"]},
                            }
                            if Config.NotifyType == 'qb' then
                                QBCore.Functions.Notify('You need a '..QBCore.Shared.Items[Config.SafeReqItem]["label"]..' to breach the safe...', "error", 3500)
                            elseif Config.NotifyType == "okok" then
                                exports['okokNotify']:Alert(QBCore.Shared.Items[Config.SafeReqItem]["label"].." REQUIRED", "You need a "..QBCore.Shared.Items[Config.SafeReqItem]["label"].." to breach the safe...", 3500, "error")
                            end 
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                            Wait(3500)
                            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        end 
                    else -- LIQUOR STORE PARTICULARS (GABZ CONFIGURATION)
                        if QBCore.Functions.HasItem(Config.LiquorReqItem) then
                            if Config.psdispatch then 
                                TriggerEvent('mz-storerobbery:client:mzLiquorHit')
                            else
                                if not copsCalled then
                                    pos = GetEntityCoords(PlayerPedId())
                                    local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                    local street1 = GetStreetNameFromHashKey(s1)
                                    local street2 = GetStreetNameFromHashKey(s2)
                                    local streetLabel = street1
                                    if street2 ~= nil then
                                        streetLabel = streetLabel .. " " .. street2
                                    end
                                    TriggerServerEvent("mz-storerobbery:server:callCops", "safe", currentSafe, streetLabel, pos)
                                    copsCalled = true
                                end
                            end
                            TriggerServerEvent('mz-storerobbery:server:setSafeStatus', currentSafe)
                            Wait(250)
                            TriggerServerEvent("mz-storerobbery:server:ItemRemovalLiquor")
                            TriggerEvent('mz-storerobbery:client:CheckXPLevel')
                            if Config.HacktypeLiquor == 'mHacking' then 
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                if Config.mzskills then
                                    TriggerEvent("mhacking:show") 
                                    if lvl8 then  
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl8low, Config.mhacklvl8high), Config.mhacklvl8time, HackingSuccessSafeLiquor)
                                    elseif lvl7 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl7low, Config.mhacklvl7high), Config.mhacklvl7time, HackingSuccessSafeLiquor)
                                    elseif lvl6 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl6low, Config.mhacklvl6high), Config.mhacklvl6time, HackingSuccessSafeLiquor)
                                    elseif lvl5 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl5low, Config.mhacklvl5high), Config.mhacklvl5time, HackingSuccessSafeLiquor)
                                    elseif lvl4 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl4low, Config.mhacklvl4high), Config.mhacklvl4time, HackingSuccessSafeLiquor)
                                    elseif lvl3 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl3low, Config.mhacklvl3high), Config.mhacklvl3time, HackingSuccessSafeLiquor)
                                    elseif lvl2 then
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl2low, Config.mhacklvl2high), Config.mhacklvl2time, HackingSuccessSafeLiquor)
                                    elseif lvl1 then 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl1low, Config.mhacklvl1high), Config.mhacklvl1time, HackingSuccessSafeLiquor)
                                    else 
                                        TriggerEvent("mhacking:start", math.random(Config.mhacklvl0low, Config.mhacklvl0high), Config.mhacklvl0time, HackingSuccessSafeLiquor)
                                    end
                                elseif not Config.mzskills then
                                    TriggerEvent("mhacking:show") 
                                    TriggerEvent("mhacking:start", math.random(Config.mhacklvlNOXPlow, Config.mhacklvlNOXPlow), Config.mhacklvlNOXPtime, HackingSuccessSafeLiquor)
                                else
                                    print('You need to configure whether you are using mz-skills or not - see Config.mzskills')
                                end
                            elseif Config.HacktypeLiquor == 'varHack' then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                if Config.mzskills then
                                    if lvl8 then
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl8blocks, Config.varhacklvl8time) -- Number of Blocks, Time (seconds)
                                    elseif lvl7 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl7blocks, Config.varhacklvl7time) -- Number of Blocks, Time (seconds)
                                    elseif lvl6 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl6blocks, Config.varhacklvl6time) -- Number of Blocks, Time (seconds)
                                    elseif lvl5 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl5blocks, Config.varhacklvl5time) -- Number of Blocks, Time (seconds)
                                    elseif lvl4 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl4blocks, Config.varhacklvl4time) -- Number of Blocks, Time (seconds)
                                    elseif lvl3 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl3blocks, Config.varhacklvl3time) -- Number of Blocks, Time (seconds)
                                    elseif lvl2 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl2blocks, Config.varhacklvl2time) -- Number of Blocks, Time (seconds)
                                    elseif lvl1 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl1blocks, Config.varhacklvl1time) -- Number of Blocks, Time (seconds)
                                    elseif lvl0 then 
                                        exports['ps-ui']:VarHack(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.varhacklvl0blocks, Config.varhacklvl0time) -- Number of Blocks, Time (seconds)
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:VarHack(function(success)
                                        if success then
                                            ExchangeSuccessSafeLiquor()
                                        else
                                            ExchangeFailSafeLiquor(safe)
                                        end
                                    end, Config.varhacklvlNOXPblocks, Config.varhacklvlNOXPtime) -- Number of Blocks, Time (seconds)
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end
                            elseif Config.HacktypeLiquor == 'scrambler' then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                if Config.mzskills then
                                    if lvl8 then  
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl8Type, Config.ScramLvl8Time, Config.ScramLvl8Mod)
                                    elseif lvl7 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl7Type, Config.ScramLvl7Time, Config.ScramLvl7Mod)
                                    elseif lvl6 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl6Type, Config.ScramLvl6Time, Config.ScramLvl6Mod)
                                    elseif lvl5 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl5Type, Config.ScramLvl5Time, Config.ScramLvl5Mod)
                                    elseif lvl4 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl4Type, Config.ScramLvl4Time, Config.ScramLvl4Mod)
                                    elseif lvl3 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl3Type, Config.ScramLvl3Time, Config.ScramLvl3Mod)
                                    elseif lvl2 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl2Type, Config.ScramLvl2Time, Config.ScramLvl2Mod)
                                    elseif lvl1 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl1Type, Config.ScramLvl1Time, Config.ScramLvl1Mod)
                                    elseif lvl0 then 
                                        exports['ps-ui']:Scrambler(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.ScramLvl0Type, Config.ScramLvl0Time, Config.ScramLvl0Mod)
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:Scrambler(function(success)
                                        if success then
                                            ExchangeSuccessSafeLiquor()
                                        else
                                            ExchangeFailSafeLiquor(safe)
                                        end
                                    end, Config.ScramNOXPType, Config.ScramNOXPTime, Config.ScramNOXPMod)
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end        
                            elseif Config.HacktypeLiquor == 'maze' then
                                TriggerServerEvent("mz-storerobbery:server:setSafeStatus", currentSafe)
                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel2"})
                                Wait(500)
                                TriggerEvent('animations:client:EmoteCommandStart', {"mechanic"})
                                if Config.mzskills then
                                    if lvl8 then
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze8Time) -- Hack Time Limit
                                    elseif lvl7 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze7Time) -- Hack Time Limit
                                    elseif lvl6 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze6Time) -- Hack Time Limit
                                    elseif lvl5 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze5Time) -- Hack Time Limit
                                    elseif lvl4 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze4Time) -- Hack Time Limit
                                    elseif lvl3 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze3Time) -- Hack Time Limit
                                    elseif lvl2 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze2Time) -- Hack Time Limit
                                    elseif lvl1 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze1Time) -- Hack Time Limit
                                    elseif lvl0 then 
                                        exports['ps-ui']:Maze(function(success)
                                            if success then
                                                ExchangeSuccessSafeLiquor()
                                            else
                                                ExchangeFailSafeLiquor(safe)
                                            end
                                        end, Config.Maze1Time) -- Hack Time Limit
                                    end
                                elseif not Config.mzskills then
                                    exports['ps-ui']:Maze(function(success)
                                        if success then
                                            ExchangeSuccessSafeLiquor()
                                        else
                                            ExchangeFailSafeLiquor(safe)
                                        end
                                    end, Config.Maze5Time) -- Hack Time Limit
                                else
                                    print('You need to configure whether you are using mz-skills or not')
                                end            
                            end
                        else
                            local requiredItems = {
                            [1] = {name = QBCore.Shared.Items[Config.LiquorReqItem]["name"], image = QBCore.Shared.Items[Config.LiquorReqItem]["image"]},
                            }
                            if Config.NotifyType == 'qb' then
                                QBCore.Functions.Notify('You need a '..QBCore.Shared.Items[Config.LiquorReqItem]["label"]..' to breach the safe...', "error", 3500)
                            elseif Config.NotifyType == "okok" then
                                exports['okokNotify']:Alert(QBCore.Shared.Items[Config.LiquorReqItem]["label"].." REQUIRED", "You need a "..QBCore.Shared.Items[Config.LiquorReqItem]["label"].." to breach the safe...", 3500, "error")
                            end 
                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                            Wait(3500)
                            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                        end 
                    end
                else
                    QBCore.Functions.Notify("Not Enough Police (".. Config.MinimumStoreRobberyPolice .." Required)", "error")
                end
            end
        end   
    end)
end

----------
--OUTPUT--
----------

local safeCheck = true 

function ExchangeSuccessSafe() 
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeKeypad",
        error = false,
    })
    currentSafe = 0
    if Config.mzskills then
        local BetterXP = math.random(Config.HackingXPLow, Config.HackingXPHigh)
        local MidXP = math.random(Config.HackingXPLow, Config.HackingXPMid)
        local hackerchance = math.random(1, 10)
        if hackerchance >= 8 then
            chance = BetterXP
        elseif hackerchance < 8 and hackerchance >= 6 then
            chance = MidXP
        else
            chance = Config.HackingXPLow
        end
        exports["mz-skills"]:UpdateSkill(Config.HackXPSkill, chance)
    end
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    local saferobtime = math.random(Config.SafeTimelow * 1000, Config.SafeTimehigh * 1000)
    QBCore.Functions.Progressbar("deliver_reycle_package", "Raiding safe...", saferobtime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@ornate_bank@grab_cash",
        anim = "grab",
        flags = 16,
    }, {}, {}, function() -- Done
        safeCheck = false
        TriggerServerEvent("mz-storerobbery:server:SafeReward", currentSafe, safeCheck)
        safeCheck = true
        ClearPedTasks(PlayerPedId())
        Wait(1000)
        if Config.mzskills then  
            local BetterXP = math.random(Config.HeistXPlow, Config.HeistXPhigh)
            local hackerchance = math.random(1, 10)
            if hackerchance > 8 then
                chance = BetterXP
            elseif hackerchance < 9 and hackerchance > 6 then
                chance = Config.HeistXPmid
            else
                chance = Config.HeistXPlow
            end
            exports["mz-skills"]:UpdateSkill(Config.CriminalXPSkill, chance)
        end
    end, function() -- Cancel
        ClearPedTasks(PlayerPedId())
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
        end 
    end)
end

function ExchangeSuccessSafeLiquor() 
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeKeypad",
        error = false,
    })
    currentSafe = 0
    if Config.mzskills then
        local BetterXP = math.random(Config.HackingXPLow, Config.HackingXPHigh)
        local MidXP = math.random(Config.HackingXPLow, Config.HackingXPMid)
        local hackerchance = math.random(1, 10)
        if hackerchance >= 8 then
            chance = BetterXP
        elseif hackerchance < 8 and hackerchance >= 6 then
            chance = MidXP
        else
            chance = Config.HackingXPLow
        end
        exports["mz-skills"]:UpdateSkill(Config.HackXPSkill, chance)
    end
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    local saferobtime = math.random(Config.SafeTimelow * 1000, Config.SafeTimehigh * 1000)
    QBCore.Functions.Progressbar("deliver_reycle_package", "Raiding safe...", saferobtime, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@heists@ornate_bank@grab_cash",
        anim = "grab",
        flags = 16,
    }, {}, {}, function() -- Done
        safeCheck = false
        TriggerServerEvent("mz-storerobbery:server:SafeRewardAlcohol", currentSafe, safeCheck)
        safeCheck = true
        ClearPedTasks(PlayerPedId())
        Wait(1000)
        if Config.mzskills then  
            local BetterXP = math.random(Config.HeistXPlow, Config.HeistXPhigh)
            local hackerchance = math.random(1, 10)
            if hackerchance > 8 then
                chance = BetterXP
            elseif hackerchance < 9 and hackerchance > 6 then
                chance = Config.HeistXPmid
            else
                chance = Config.HeistXPlow
            end
            exports["mz-skills"]:UpdateSkill(Config.CriminalXPSkill, chance)
        end
    end, function() -- Cancel
        ClearPedTasks(PlayerPedId())
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
        end 
    end)
end

function ExchangeFailSafe(safe)
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    TriggerServerEvent("mz-storerobbery:server:SafeFail")
    TriggerServerEvent("mz-storerobbery:server:setSafeStatusFailed", currentSafe)
    Wait(1000)
    if Config.StressEnabled then 
        TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
    end 
    Wait(1000)
    if Config.mzskills then
        local deteriorate = -Config.HackingXPLoss
        exports["mz-skills"]:UpdateSkill(Config.HackXPSkill, deteriorate)
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('-'..Config.HackingXPLoss..'XP to'..Config.HackXPSkill..'.', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("SKILLS", '-'..Config.HackingXPLoss..'XP to'..Config.HackXPSkill..'.', 3500, "error")
        end
    end
    if not Config.psdispatch then 
        TriggerEvent("police:SetCopAlert")
    end 
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeKeypad",
        error = true,
    })
    currentSafe = 0
end

function ExchangeFailSafeLiquor(safe)
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    TriggerServerEvent("mz-storerobbery:server:SafeFail")
    TriggerServerEvent("mz-storerobbery:server:setSafeStatusFailed", currentSafe)
    Wait(1000)
    if Config.StressEnabled then 
        TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
    end 
    Wait(1000)
    if Config.mzskills then
        local deteriorate = -Config.HackingXPLoss
        exports["mz-skills"]:UpdateSkill(Config.HackXPSkill, deteriorate)
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('-'..Config.HackingXPLoss..'XP to'..Config.HackXPSkill..'.', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("SKILLS", '-'..Config.HackingXPLoss..'XP to'..Config.HackXPSkill..'.', 3500, "error")
        end
    end
    if not Config.psdispatch then 
        TriggerEvent("police:SetCopAlert")
    end 
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeKeypad",
        error = true,
    })
    currentSafe = 0
end

function HackingSuccessSafe(success, timeremaining)
    if success then
        TriggerEvent('mhacking:hide')
        ExchangeSuccessSafe()
    else
		TriggerEvent('mhacking:hide')
		ExchangeFailSafe(safe)
	end
end

function HackingSuccessSafeLiquor(success, timeremaining)
    if success then
        TriggerEvent('mhacking:hide')
        ExchangeSuccessSafeLiquor()
    else
		TriggerEvent('mhacking:hide')
		ExchangeFailSafeLiquor(safe)
	end
end

RegisterNUICallback('callcops', function(_, cb)
    TriggerEvent("police:SetCopAlert")
end)

RegisterNetEvent('mz-storerobbery:client:setRegisterStatus', function(k, bool)
    if not Config.UseGabz then 
        Config.RegistersTarget[k].robbed = bool
    else 
        Config.RegistersTargetGabz[k].robbed = bool
    end 
end)

RegisterNetEvent('mz-storerobbery:client:setSafeStatus', function(safe, bool)
    if not Config.UseGabz then
        Config.SafesTarget[safe].robbed = bool
    else 
        Config.SafesTargetGabz[safe].robbed = bool
    end 
end)

RegisterNetEvent('mz-storerobbery:client:robberyCall', function(_, _, _, coords)
    if PlayerJob.name == "police" and onDuty then
        PlaySound(-1, "Lose_1st", "GTAO_FM_Events_Soundset", 0, 0, 1)
        TriggerServerEvent('police:server:policeAlert', 'Storerobbery in progress')
        local transG = 250
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 458)
        SetBlipColour(blip, 1)
        SetBlipDisplay(blip, 4)
        SetBlipAlpha(blip, transG)
        SetBlipScale(blip, 1.0)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("10-31 | Shop Robbery")
        EndTextCommandSetBlipName(blip)
        while transG ~= 0 do
            Wait(180 * 4)
            transG = transG - 1
            SetBlipAlpha(blip, transG)
            if transG == 0 then
                SetBlipSprite(blip, 2)
                RemoveBlip(blip)
                return
            end
        end
    end
end)

CreateThread(function()
    Wait(1000)
    if QBCore.Functions.GetPlayerData().job ~= nil and next(QBCore.Functions.GetPlayerData().job) then
        PlayerJob = QBCore.Functions.GetPlayerData().job
    end
end)

CreateThread(function()
    while true do
        Wait(1000 * 60 * Config.PoliceMinutesCooldown)
        if copsCalled then
            copsCalled = false
        end
    end
end)

CreateThread(function()
    Wait(1000)
    setupRegister()
    setupSafes()
    if Config.Drawtext then 
        while true do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local inRange = false
            if not Config.UseGabz then 
                for k in pairs(Config.RegistersTarget) do
                    local dist = #(pos - Config.RegistersTarget[k]["coords"].xyz)
                    if dist <= 1.5 and Config.RegistersTarget[k].robbed then
                        inRange = true
                        DrawText3Ds(Config.RegistersTarget[k]["coords"].xyz, '~r~Cash register has been emptied...~w~')
                    end
                end
            else 
                for k in pairs(Config.RegistersTargetGabz) do
                    local dist = #(pos - Config.RegistersTargetGabz[k]["coords"].xyz)
                    if dist <= 1.5 and Config.RegistersTargetGabz[k].robbed then
                        inRange = true
                        DrawText3Ds(Config.RegistersTargetGabz[k]["coords"].xyz, '~r~Cash register has been emptied...~w~')
                    end
                end
            end 
            if not inRange then
                Wait(2000)
            end
            Wait(3)
        end
    end 
end)

------------------------
--LIQUOR STORE ROBBERY--
------------------------

---------
--DOORS--
---------

--STORE 1

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorouter1", vector3(-1224.33, -911.06, 12.33), 1.2, 0.18, {
        name = "liquorouter1",
        heading = 125,
        debugPoly = false,
        minZ = 9.53,
        maxZ = 13.53,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorOuter1",
                icon = 'fas fa-key',
                label = 'Unlock Outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorOuter1', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter1, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                if Config.StressEnabled then 
                    TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                end
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
        	end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorinner1", vector3(-1220.22, -912.72, 12.33), 1.2, 0.15, {
        name = "liquorinner1",
        heading = 304,
        debugPoly = false,
        minZ = 9.53,
        maxZ = 13.53,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorInner1",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorInner1', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner1, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
        	end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorboth1", vector3(-1216.95, -915.99, 11.33), 0.4, 0.2, {
        name = "liquorboth1",
        heading = 35,
        debugPoly = false,
        minZ = 8.58,
        maxZ = 12.33,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorBoth1",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorBoth1', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    triplocks = math.random(Config.TripLocksLow, Config.TripLocksHigh)
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (triplocks * 1000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter1, false, false, false, true)
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner1, false, false, false, true)
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
        end 
    end)
end)

--STORE 2

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorouter2", vector3(-1483.25, -379.75, 40.16), 1.2, 0.15, {
        name = "liquorouter2",
        heading = 45,
        debugPoly = false,
        minZ = 37.36,
        maxZ = 41.36,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorOuter2",
                icon = 'fas fa-key',
                label = 'Unlock Outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorOuter2', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter2, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
            end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorinner2", vector3(-1482.29, -375.48, 40.16), 1.2, 0.15, {
        name = "liquorinner2",
        heading = 45,
        debugPoly = false,
        minZ = 37.36,
        maxZ = 41.36,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorInner2",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorInner2', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner2, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end                
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
            end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorboth2", vector3(-1479.69, -371.6, 39.16), 0.5, 0.2, {
        name = "liquorboth2",
        heading = 315,
        debugPoly = false,
        minZ = 36.16,
        maxZ = 40.16,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorBoth2",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorBoth2', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    triplocks = math.random(Config.TripLocksLow, Config.TripLocksHigh)
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (triplocks * 1000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter2, false, false, false, true)
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner2, false, false, false, true)
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
        end 
    end)
end)

--STORE 3

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorouter3", vector3(-2965.68, 387.46, 15.04), 1.2, 0.15, {
        name = "liquorouter3",
        heading = 357,
        debugPoly = false,
        minZ=12.44,
        maxZ=16.44,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorOuter3",
                icon = 'fas fa-key',
                label = 'Unlock outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorOuter3', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter3, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
            end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorinner3", vector3(-2961.88, 389.61, 15.04), 1.2, 0.15, {
        name = "liquorinner3",
        heading = 356,
        debugPoly = false,
        minZ=12.24,
        maxZ=16.24,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorInner3",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorInner3', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner3, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
            end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorboth3", vector3(-2957.27, 390.24, 14.04), 0.4, 0.2, {
        name = "liquorboth3",
        heading = 87,
        debugPoly = false,
        minZ=11.04,
        maxZ=15.04,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorBoth3",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorBoth3', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    triplocks = math.random(Config.TripLocksLow, Config.TripLocksHigh)
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (triplocks * 1000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter3, false, false, false, true)
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner3, false, false, false, true)
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
        end 
    end)
end)

--STORE 4

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorouter4", vector3(1169.32, 2711.74, 38.16), 1.2, 0.15, {
        name = "liquorouter4",
        heading = 91,
        debugPoly = false,
        minZ=35.36,
        maxZ=39.36,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorOuter4",
                icon = 'fas fa-key',
                label = 'Unlock outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorOuter4', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter4, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
            end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorinner4", vector3(1166.94, 2715.46, 38.16), 1.2, 0.15, {
        name = "liquorinner4",
        heading = 269,
        debugPoly = false,
        minZ=35.36,
        maxZ=39.36,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorInner4",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorInner4', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner4, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
            end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorboth4", vector3(1166.02, 2720.0, 37.16), 0.5, 0.2, {
        name = "liquorboth4",
        heading = 0,
        debugPoly = false,
        minZ=34.16,
        maxZ=38.16,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorBoth4",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorBoth4', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    triplocks = math.random(Config.TripLocksLow, Config.TripLocksHigh)
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (triplocks * 1000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter4, false, false, false, true)
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner4, false, false, false, true)
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
        end 
    end)
end)

--STORE 5

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorouter5", vector3(1132.86, -979.28, 46.42), 1.2, 0.15, {
        name = "liquorouter5",
        heading = 8,
        debugPoly = false,
        minZ=43.62,
        maxZ=47.62,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorOuter5",
                icon = 'fas fa-key',
                label = 'Unlock outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorOuter5', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter5, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
            end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorinner5", vector3(1129.51, -982.11, 46.42), 1.2, 0.15, {
        name = "liquorinner5",
        heading = 8,
        debugPoly = false,
        minZ=43.62,
        maxZ=47.62,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorInner5",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorInner5', function()
    if QBCore.Functions.HasItem(Config.LiquorItem) then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        exports['ps-ui']:Circle(function(success)
            if success then
                TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner5, false, false, false, true)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
                end
                
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("You jam the key...", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STUCK", "You jam the key...", 3500, "error")
                end
                TriggerEvent('animations:client:EmoteCommandStart', {"c"})
                Wait(1000)
                TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
                Wait(1000)
                if math.random(1, 100) <= Config.BreakChance then 
                    TriggerServerEvent('mz-storerobbery:server:KeyRemoval')
                else
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                    end
                end
            end
        end, Config.UnlockParses, Config.UnlockParseTime) -- NumberOfCircles, MS
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items[Config.LiquorItem]["name"], image = QBCore.Shared.Items[Config.LiquorItem]["image"]},
        }
		if Config.NotifyType == 'qb' then
        	QBCore.Functions.Notify('You need a key to get to the back', "error", 3500)
		elseif Config.NotifyType == "okok" then
			exports['okokNotify']:Alert("KEY REQUIRED", "You need a key to get to the back", 3500, "error")
		end
        TriggerEvent('inventory:client:requiredItems', requiredItems, true)
        Wait(2000)
		TriggerEvent('inventory:client:requiredItems', requiredItems, false)
    end
end)

CreateThread(function()
    exports['qb-target']:AddBoxZone("liquorboth5", vector3(1125.1, -983.63, 45.42), 0.5, 0.2, {
        name = "liquorboth5",
        heading = 97,
        debugPoly = false,
        minZ=42.42,
        maxZ=46.42,
        }, {
            options = { 
            {
                type = "client",
                event = "mz-storerobbery:client:LiquorBoth5",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('mz-storerobbery:client:LiquorBoth5', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    triplocks = math.random(Config.TripLocksLow, Config.TripLocksHigh)
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (triplocks * 1000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {}, {}, {}, function() -- Done
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorOuter5, false, false, false, true)
        TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner5, false, false, false, true)
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    end, function() -- Cancel
        TriggerEvent('animations:client:EmoteCommandStart', {"c"})
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
        end 
    end)
end)