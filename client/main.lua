local QBCore = exports['qb-core']:GetCoreObject()

local currentRegister = 0
local currentSafe = 0
local copsCalled = false
local CurrentCops = 0
local PlayerJob = {}
local onDuty = false
local usingAdvanced = false

---------------
--PS-DISPATCH--
---------------

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
end)

RegisterNetEvent('mz-storerobbery:client:mzSafeHit', function()
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
end)

RegisterNetEvent('mz-storerobbery:client:mzLiquorHit', function()
    local currentPos = GetEntityCoords(PlayerPedId())
    local locationInfo = getStreetandZone(currentPos)
    local gender = GetPedGender()
    TriggerServerEvent("dispatch:server:notify",{
        dispatchcodename = "mz-storerobbery-liquor",          -- has to match the codes in sv_dispatchcodes.lua so that it generates the right blip
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
        dispatchMessage = "Liquor Store Robbery",             -- message
        job = {"police"}                                    -- jobs that will get the alerts
    })
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
    QBCore.Functions.TriggerCallback('qb-storerobbery:server:getRegisterStatus', function(Registers)
        for k in pairs(Registers) do
            Config.Registers[k].robbed = Registers[k].robbed
        end
    end)
end

function setupSafes()
    QBCore.Functions.TriggerCallback('qb-storerobbery:server:getSafeStatus', function(Safes)
        for k in pairs(Safes) do
            Config.Safes[k].robbed = Safes[k].robbed
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

RegisterNetEvent('qb-storerobbery:client:circleLockpick', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"uncuff"})
    exports['ps-ui']:Circle(function(success)
        if success then
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            if currentRegister ~= 0 then
                TriggerServerEvent('qb-storerobbery:server:setRegisterStatus', currentRegister)
                local lockpickTime = (Config.RegisterTime * 1000)
                LockpickDoorAnim(lockpickTime)
                QBCore.Functions.Progressbar("search_register", "Emptying the till...", lockpickTime, false, true, {
                    disableMovement = true,
                    disableCarMovement = true,
                    disableMouse = false,
                    disableCombat = true,
                }, {
                    animDict = "veh@break_in@0h@p_m_one@",
                    anim = "low_force_entry_ds",
                    flags = 16,
                }, {}, {}, function() -- Done
                    openingDoor = false
                    ClearPedTasks(PlayerPedId())
                    TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, true)
                end, function() -- Cancel
                    openingDoor = false
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
                        TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                        Wait(10000)
                    end
                end)
            else
                SendNUIMessage({
                    action = "kekw",
                })
            end
        else
            TriggerEvent('animations:client:EmoteCommandStart', {"c"})
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify("Your hand slipped and the lockpick bends...", "error", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("LOCKPICK FAILED", "Your hand slipped and the lockpick bends...", 3500, "error")
            end 
            Wait(2000)
            if usingAdvanced then
                if math.random(1, 100) <= Config.AdvancedBreakChance then
                    TriggerServerEvent("QBCore:Server:RemoveItem", "advancedlockpick", 1)
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify('You broke the lockpick...', "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("IT BROKE!", "You broke the lockpick...", 3500, "error")
                    end 
                end
            else
                if math.random(1, 100) <= Config.LockpickBreakChance then
                    TriggerServerEvent("QBCore:Server:RemoveItem", "lockpick", 1)
                    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
                    if Config.NotifyType == 'qb' then
                        QBCore.Functions.Notify('You broke the lockpick...', "error", 3500)
                    elseif Config.NotifyType == "okok" then
                        exports['okokNotify']:Alert("IT BROKE!", "You broke the lockpick...", 3500, "error")
                    end 
                end
            end
            if (IsWearingHandshoes() and math.random(1, 100) <= 25) then
                local pos = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
            end
        end
    end, Config.circleparses, Config.circletime) 
end)

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(100)
    end
end

function takeAnim()
    local ped = PlayerPedId()
    while (not HasAnimDictLoaded("amb@prop_human_bum_bin@idle_b")) do
        RequestAnimDict("amb@prop_human_bum_bin@idle_b")
        Wait(100)
    end
    TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_b", "idle_d", 8.0, 8.0, -1, 50, 0, false, false, false)
    Wait(2500)
    TaskPlayAnim(ped, "amb@prop_human_bum_bin@idle_b", "exit", 8.0, 8.0, -1, 50, 0, false, false, false)
end

local openingDoor = false

local function lockpickFinish(success)
    if success then
        if currentRegister ~= 0 then
            openLockpick(false)
            TriggerServerEvent('qb-storerobbery:server:setRegisterStatus', currentRegister)
            local lockpickTime = (Config.RegisterTime * 1000)
            LockpickDoorAnim(lockpickTime)
            QBCore.Functions.Progressbar("search_register", "Emptying the till...", lockpickTime, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, {
                animDict = "veh@break_in@0h@p_m_one@",
                anim = "low_force_entry_ds",
                flags = 16,
            }, {}, {}, function() -- Done
                openingDoor = false
                ClearPedTasks(PlayerPedId())
                TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, true)
            end, function() -- Cancel
                openingDoor = false
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
                    TriggerServerEvent('hud:server:GainStress', math.random(1, 3))
                    Wait(10000)
                end
            end)
        else
            SendNUIMessage({
                action = "kekw",
            })
        end
        --cb('ok')
    else
        if usingAdvanced then
            if math.random(1, 100) <= Config.AdvancedBreakChance then
                TriggerServerEvent('mz-storerobbery:server:RemoveAdvanced')
                Wait(500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Your sturdy lockpick snapped! Damn!', "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("ADVANCED LOCKPICK SNAPPED", 'Your sturdy lockpick snapped! Damn!', 3500, "error")
                end 
            end
        else
            if math.random(1, 100) <= Config.LockpickBreakChance then
                TriggerServerEvent('mz-storerobbery:server:RemoveLockpick')
                Wait(500)
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify('Your lockpick snapped! Damn!', "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("LOCKPICK SNAPPED", 'Your lockpick snapped! Damn!', 3500, "error")
                end 
            end
        end
        if (IsWearingHandshoes() and math.random(1, 100) <= 25) then
            local pos = GetEntityCoords(PlayerPedId())
            TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
        end
        openLockpick(false)
        --cb('ok')
    end
end

function LockpickDoorAnim(time)
    time = time / 1000
    loadAnimDict("veh@break_in@0h@p_m_one@")
    TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds" ,3.0, 3.0, -1, 16, 0, false, false, false)
    openingDoor = true
    CreateThread(function()
        while openingDoor do
            TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 3.0, 3.0, -1, 16, 0, 0, 0, 0)
            Wait(2000)
            time = time - 2
            TriggerServerEvent('qb-storerobbery:server:takeMoney', currentRegister, false)
            if time <= 0 then
                openingDoor = false
                StopAnimTask(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0)
            end
        end
        currentRegister = 0
    end)
end

RegisterNUICallback('fail', function(_ ,cb)
    if usingAdvanced then
        if math.random(1, 100) < 20 then
            TriggerServerEvent("QBCore:Server:RemoveItem", "advancedlockpick", 1)
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["advancedlockpick"], "remove")
        end
    else
        if math.random(1, 100) < 40 then
            TriggerServerEvent("QBCore:Server:RemoveItem", "lockpick", 1)
            TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["lockpick"], "remove")
        end
    end
    if (IsWearingHandshoes() and math.random(1, 100) <= 25) then
        local pos = GetEntityCoords(PlayerPedId())
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
        QBCore.Functions.Notify("You Broke The Lock Pick")
    end
    openLockpick(false)
    cb('ok')
end)

RegisterNUICallback('exit', function(_, cb)
    openLockpick(false)
    cb('ok')
end)

-------------
--LOCKPICKS--
-------------

RegisterNetEvent('lockpicks:UseLockpick', function(isAdvanced)
    usingAdvanced = isAdvanced
    for k in pairs(Config.Registers) do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local dist = #(pos - Config.Registers[k][1].xyz)
        if dist <= 1 and not Config.Registers[k].robbed then
            if CurrentCops >= Config.MinimumStoreRobberyPolice then
                if usingAdvanced then
                    if Config.psdispatch then 
                        if not copsCalled then 
                            TriggerEvent('mz-storerobbery:client:mzRegisterHit')
                            copsCalled = true
                            Wait(60000)
                            copsCalled = false 
                        end 
                    end 
                    if Config.BreakRegister == "standard" then 
                        TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
                    elseif Config.BreakRegister == "circle" then 
                        if Config.psdispatch then 
                            if not copsCalled then 
                                TriggerEvent('mz-storerobbery:client:mzRegisterHit')
                                copsCalled = true
                                Wait(60000)
                                copsCalled = false 
                            end 
                        end 
                        TriggerEvent('qb-storerobbery:client:circleLockpick')
                    else 
                        print("Your 'Config.BreakRegister' is not configured properly. Please see config.lua")
                    end
                    currentRegister = k
                    print(k)
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
                            TriggerServerEvent("qb-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                            copsCalled = true
                        end
                    end 
                else
                    if Config.psdispatch then 
                        if not copsCalled then 
                            TriggerEvent('mz-storerobbery:client:mzRegisterHit')
                            copsCalled = true
                            Wait(60000)
                            copsCalled = false 
                        end 
                    end 
                    if Config.BreakRegister == "standard" then 
                        TriggerEvent('qb-lockpick:client:openLockpick', lockpickFinish)
                    elseif Config.BreakRegister == "circle" then 
                        TriggerEvent('qb-storerobbery:client:circleLockpick')
                    else 
                        print("Your 'Config.BreakRegister' is not configured properly. Please see config.lua")
                    end
                    currentRegister = k
                    print(k)
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
                            TriggerServerEvent("qb-storerobbery:server:callCops", "cashier", currentRegister, streetLabel, pos)
                            copsCalled = true
                        end
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
end)

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
    while true do
        Wait(1)
        local inRange = false
        if QBCore ~= nil then
            local pos = GetEntityCoords(PlayerPedId())
            for safe,_ in pairs(Config.Safes) do
                local dist = #(pos - Config.Safes[safe][1].xyz)
                if dist < 3 then
                    inRange = true
                    if dist < 1.0 then
                        if not Config.Safes[safe].robbed then
                            DrawText3Ds(Config.Safes[safe][1].xyz, '~g~[E]~w~ - Breach Safe')
                            if IsControlJustPressed(0, 38) then
                                if CurrentCops >= Config.MinimumStoreRobberyPolice then
                                    currentSafe = safe
                                    if math.random(1, 100) <= 65 and not IsWearingHandshoes() then
                                        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
                                    end
                                    if Config.Safes[safe].type == "keypad" then
                                        if QBCore.Functions.HasItem("usb2") then
                                            if Config.Hacktype == 'numberMatch' then 
                                                TriggerServerEvent("qb-storerobbery:server:setSafeStatus", currentSafe)
                                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel"})
                                                if Config.psdispatch then 
                                                    TriggerEvent('mz-storerobbery:client:mzSafeHit')
                                                end 
                                                TriggerServerEvent("qb-storerobbery:server:ItemRemoval")
                                                if Config.UsingSkills then
                                                    local lvl8 = false
                                                    local lvl7 = false
                                                    local lvl6 = false
                                                    local lvl5 = false
                                                    local lvl4 = false
                                                    local lvl3 = false
                                                    local lvl2 = false
                                                    local lvl1 = false
                                                    local lvl0 = false
                                                    exports["mz-skills"]:CheckSkill("Hacking", 12800, function(hasskill)
                                                        if hasskill then lvl8 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 6400, function(hasskill)
                                                        if hasskill then lvl7 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 3200, function(hasskill)
                                                        if hasskill then lvl6 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 1600, function(hasskill)
                                                        if hasskill then lvl5 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 800, function(hasskill)
                                                        if hasskill then lvl4 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 400, function(hasskill)
                                                        if hasskill then lvl3 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 200, function(hasskill)
                                                        if hasskill then lvl2 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 100, function(hasskill)
                                                        if hasskill then lvl1 = true end
                                                    end)
                                                    TriggerEvent("mhacking:show") 
                                                    if lvl8 then  
                                                        TriggerEvent("mhacking:start", math.random(5, 6), 20, HackingSuccessSafe)
                                                    elseif lvl7 then
                                                        TriggerEvent("mhacking:start", math.random(5, 5), 18, HackingSuccessSafe)
                                                    elseif lvl6 then
                                                        TriggerEvent("mhacking:start", math.random(4, 5), 16, HackingSuccessSafe)
                                                    elseif lvl5 then 
                                                        TriggerEvent("mhacking:start", math.random(4, 4), 14, HackingSuccessSafe)
                                                    elseif lvl4 then 
                                                        TriggerEvent("mhacking:start", math.random(3, 4), 14, HackingSuccessSafe)
                                                    elseif lvl3 then
                                                        TriggerEvent("mhacking:start", math.random(3, 3), 18, HackingSuccessSafe)
                                                    elseif lvl2 then
                                                        TriggerEvent("mhacking:start", math.random(2, 3), 16, HackingSuccessSafe)
                                                    elseif lvl1 then 
                                                        TriggerEvent("mhacking:start", math.random(2, 2), 14, HackingSuccessSafe)
                                                    else 
                                                        TriggerEvent("mhacking:start", math.random(2, 2), 12, HackingSuccessSafe)
                                                    end
                                                elseif not Config.UsingSkills then
						    TriggerEvent("mhacking:show")
                                                    TriggerEvent("mhacking:start", math.random(5, 5), 20, HackingSuccessSafe)
                                                else
                                                    print('You need to configure whether you are using mz-skills or not')
                                                end
                                            elseif Config.Hacktype == 'varHack' then
                                                TriggerServerEvent("qb-storerobbery:server:setSafeStatus", currentSafe)
                                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel"})
                                                TriggerServerEvent("qb-storerobbery:server:ItemRemoval")
                                                if Config.UsingSkills then
                                                    local lvl8 = false
                                                    local lvl7 = false
                                                    local lvl6 = false
                                                    local lvl5 = false
                                                    local lvl4 = false
                                                    local lvl3 = false
                                                    local lvl2 = false
                                                    local lvl1 = false
                                                    local lvl0 = false
                                                    exports["mz-skills"]:CheckSkill("Hacking", 12800, function(hasskill)
                                                        if hasskill then lvl8 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 6400, function(hasskill)
                                                        if hasskill then lvl7 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 3200, function(hasskill)
                                                        if hasskill then lvl6 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 1600, function(hasskill)
                                                        if hasskill then lvl5 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 800, function(hasskill)
                                                        if hasskill then lvl4 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 400, function(hasskill)
                                                        if hasskill then lvl3 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 200, function(hasskill)
                                                        if hasskill then lvl2 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 100, function(hasskill)
                                                        if hasskill then lvl1 = true end
                                                    end)
                                                    Wait(500)
                                                    if lvl8 then
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 3, 10) -- Number of Blocks, Time (seconds)
                                                    elseif lvl7 then 
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 4, 10) -- Number of Blocks, Time (seconds)
                                                    elseif lvl6 then 
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 5, 12) -- Number of Blocks, Time (seconds)
                                                    elseif lvl5 then 
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 6, 12) -- Number of Blocks, Time (seconds)
                                                    elseif lvl4 then 
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 7, 12) -- Number of Blocks, Time (seconds)
                                                    elseif lvl3 then 
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 8, 12) -- Number of Blocks, Time (seconds)
                                                    elseif lvl2 then 
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 9, 12) -- Number of Blocks, Time (seconds)
                                                    elseif lvl1 then 
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 9, 10) -- Number of Blocks, Time (seconds)
                                                    elseif lvl0 then 
                                                        exports['ps-ui']:VarHack(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 9, 8) -- Number of Blocks, Time (seconds)
                                                    end
                                                elseif not Config.UsingSkills then
                                                    exports['ps-ui']:VarHack(function(success)
                                                        if success then
                                                            ExchangeSuccessSafe()
                                                        else
                                                            ExchangeFailSafe()
                                                        end
                                                    end, 7, 10) -- Number of Blocks, Time (seconds)
                                                else
                                                    print('You need to configure whether you are using mz-skills or not')
                                                end
                                            elseif Config.Hacktype == 'scrambler' then
                                                TriggerServerEvent("qb-storerobbery:server:setSafeStatus", currentSafe)
                                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel"})
                                                TriggerServerEvent("qb-storerobbery:server:ItemRemoval")
                                                if Config.UsingSkills then
                                                    local lvl8 = false
                                                    local lvl7 = false
                                                    local lvl6 = false
                                                    local lvl5 = false
                                                    local lvl4 = false
                                                    local lvl3 = false
                                                    local lvl2 = false
                                                    local lvl1 = false
                                                    local lvl0 = false
                                                    exports["mz-skills"]:CheckSkill("Hacking", 12800, function(hasskill)
                                                        if hasskill then lvl8 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 6400, function(hasskill)
                                                        if hasskill then lvl7 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 3200, function(hasskill)
                                                        if hasskill then lvl6 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 1600, function(hasskill)
                                                        if hasskill then lvl5 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 800, function(hasskill)
                                                        if hasskill then lvl4 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 400, function(hasskill)
                                                        if hasskill then lvl3 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 200, function(hasskill)
                                                        if hasskill then lvl2 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 100, function(hasskill)
                                                        if hasskill then lvl1 = true end
                                                    end)
                                                    if lvl8 then  
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "numeric", 18, 0) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                    elseif lvl7 then 
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "alphabet", 17, 0) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                    elseif lvl6 then 
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "alphanumeric", 16, 0) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                    elseif lvl5 then 
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "greek", 15, 1) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                    elseif lvl4 then 
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "braille", 15, 1) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                    elseif lvl3 then 
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "runes", 14, 1) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )\
                                                    elseif lvl2 then 
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "greek", 13, 1) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                    elseif lvl1 then 
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "braille", 12, 1) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                    elseif lvl0 then 
                                                        exports['ps-ui']:Scrambler(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, "runes", 12, 1) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                    end
                                                elseif not Config.UsingSkills then
                                                    exports['ps-ui']:Scrambler(function(success)
                                                        if success then
                                                            ExchangeSuccessSafe()
                                                        else
                                                            ExchangeFailSafe()
                                                        end
                                                    end, "alphanumeric", 15, 1) -- Type (alphabet, numeric, alphanumeric, greek, braille, runes), Time (Seconds), Mirrored (0: Normal, 1: Normal + Mirrored 2: Mirrored only )
                                                else
                                                    print('You need to configure whether you are using mz-skills or not')
                                                end        
                                            elseif Config.Hacktype == 'maze' then
                                                TriggerServerEvent("qb-storerobbery:server:setSafeStatus", currentSafe)
                                                TriggerEvent('animations:client:EmoteCommandStart', {"kneel"})
                                                TriggerServerEvent("qb-storerobbery:server:ItemRemoval")
                                                if Config.UsingSkills then
                                                    local lvl8 = false
                                                    local lvl7 = false
                                                    local lvl6 = false
                                                    local lvl5 = false
                                                    local lvl4 = false
                                                    local lvl3 = false
                                                    local lvl2 = false
                                                    local lvl1 = false
                                                    local lvl0 = false
                                                    exports["mz-skills"]:CheckSkill("Hacking", 12800, function(hasskill)
                                                        if hasskill then lvl8 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 6400, function(hasskill)
                                                        if hasskill then lvl7 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 3200, function(hasskill)
                                                        if hasskill then lvl6 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 1600, function(hasskill)
                                                        if hasskill then lvl5 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 800, function(hasskill)
                                                        if hasskill then lvl4 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 400, function(hasskill)
                                                        if hasskill then lvl3 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 200, function(hasskill)
                                                        if hasskill then lvl2 = true end
                                                    end)
                                                    exports["mz-skills"]:CheckSkill("Hacking", 100, function(hasskill)
                                                        if hasskill then lvl1 = true end
                                                    end)
                                                    Wait(500)
                                                    if lvl8 then
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 20) -- Hack Time Limit
                                                    elseif lvl7 then 
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 18) -- Hack Time Limit
                                                    elseif lvl6 then 
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 16) -- Hack Time Limit
                                                    elseif lvl5 then 
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 15) -- Hack Time Limit
                                                    elseif lvl4 then 
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 14) -- Hack Time Limit
                                                    elseif lvl3 then 
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 13) -- Hack Time Limit
                                                    elseif lvl2 then 
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 12) -- Hack Time Limit
                                                    elseif lvl1 then 
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 11) -- Hack Time Limit
                                                    elseif lvl0 then 
                                                        exports['ps-ui']:Maze(function(success)
                                                            if success then
                                                                ExchangeSuccessSafe()
                                                            else
                                                                ExchangeFailSafe()
                                                            end
                                                        end, 11) -- Hack Time Limit
                                                    end
                                                elseif not Config.UsingSkills then
                                                    exports['ps-ui']:Maze(function(success)
                                                        if success then
                                                            ExchangeSuccessSafe()
                                                        else
                                                            ExchangeFailSafe()
                                                        end
                                                    end, 15) -- Hack Time Limit
                                                else
                                                    print('You need to configure whether you are using mz-skills or not')
                                                end      
                                            end
                                        else
                                        local requiredItems = {
                                            [1] = {name = QBCore.Shared.Items["usb2"]["name"], image = QBCore.Shared.Items["usb2"]["image"]},
                                            }
                                            if Config.NotifyType == 'qb' then
                                                QBCore.Functions.Notify('You need a Red USB to breach the safe...', "error", 3500)
                                            elseif Config.NotifyType == "okok" then
                                                exports['okokNotify']:Alert("RED USB REQUIRED", "You need a Red USB to breach the safe...", 3500, "error")
                                            end 
                                            TriggerEvent('inventory:client:requiredItems', requiredItems, true)
                                            Wait(3500)
                                            TriggerEvent('inventory:client:requiredItems', requiredItems, false)
                                        end
                                    else
                                        if Config.psdispatch then 
                                            TriggerEvent('mz-storerobbery:client:mzLiquorHit')
                                        end
                                        QBCore.Functions.TriggerCallback('qb-storerobbery:server:getPadlockCombination', function(combination)
                                            TriggerEvent("SafeCracker:StartMinigame", combination)
                                        end, safe)
                                    end
                                    if not Config.psdispatch then 
                                        if not copsCalled then
                                            pos = GetEntityCoords(PlayerPedId())
                                            local s1, s2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z)
                                            local street1 = GetStreetNameFromHashKey(s1)
                                            local street2 = GetStreetNameFromHashKey(s2)
                                            local streetLabel = street1
                                            if street2 ~= nil then
                                                streetLabel = streetLabel .. " " .. street2
                                            end
                                            TriggerServerEvent("qb-storerobbery:server:callCops", "safe", currentSafe, streetLabel, pos)
                                            copsCalled = true
                                        end
                                    end 
                                else
                                    QBCore.Functions.Notify("Not Enough Police (".. Config.MinimumStoreRobberyPolice .." Required)", "error")
                                end
                            end
                        else
                            DrawText3Ds(Config.Safes[safe][1].xyz, '~r~Safe has been compromised.~w~')
                        end
                    end
                end
            end
        end
        if not inRange then
            Wait(2000)
        end
    end
end)

function ExchangeSuccessSafe() 
    SetNuiFocus(false, false)
    SendNUIMessage({
        action = "closeKeypad",
        error = false,
    })
    currentSafe = 0
    if Config.UsingSkills then
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
        exports["mz-skills"]:UpdateSkill("Hacking", chance)
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
        TriggerServerEvent("qb-storerobbery:server:SafeReward", currentSafe)
        ClearPedTasks(PlayerPedId())
    end, function() -- Cancel
        ClearPedTasks(PlayerPedId())
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
        end 
    end)
end

function ExchangeFailSafe()
    TriggerEvent('animations:client:EmoteCommandStart', {"c"})
    TriggerServerEvent("qb-storerobbery:server:SafeFail")
    TriggerServerEvent("qb-storerobbery:server:setSafeStatus", currentSafe)
    Wait(1000)
    TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
    Wait(1000)
    if Config.UsingSkills then
        local deteriorate = -Config.HackingXPLoss
        exports["mz-skills"]:UpdateSkill("Hacking", deteriorate)
        if Config.NotifyType == 'qb' then
            QBCore.Functions.Notify('-'..Config.HackingXPLoss..'XP to Hacking', "error", 3500)
        elseif Config.NotifyType == "okok" then
            exports['okokNotify']:Alert("SKILLS", '-'..Config.HackingXPLoss..'XP to Hacking', 3500, "error")
        end
    end
    TriggerEvent("police:SetCopAlert")
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
		ExchangeFailSafe()
	end
end

RegisterNUICallback('callcops', function(_, cb)
    TriggerEvent("police:SetCopAlert")
    --cb('ok')
end)

RegisterNetEvent('SafeCracker:EndMinigame', function(won)
    if currentSafe ~= 0 then
        if won then
            if currentSafe ~= 0 then
                if not Config.Safes[currentSafe].robbed then
                    SetNuiFocus(false, false)
                    TriggerServerEvent("qb-storerobbery:server:setSafeStatus", currentSafe)
                    local saferobtime = (Config.AlcoholSafeTime * 1000)
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
                        TriggerServerEvent("qb-storerobbery:server:SafeRewardAlcohol", currentSafe)
                        currentSafe = 0
                        ClearPedTasks(PlayerPedId())
                    end, function() -- Cancel
                        ClearPedTasks(PlayerPedId())
                        if Config.NotifyType == 'qb' then
                            QBCore.Functions.Notify('Process Cancelled', "error", 3500)
                        elseif Config.NotifyType == "okok" then
                            exports['okokNotify']:Alert("TASK STOPPED", "Process Cancelled", 3500, "error")
                        end 
                    end)
                end
            else
                SendNUIMessage({
                    action = "kekw",
                })
            end
        end
    end
    copsCalled = false
end)

RegisterNUICallback('PadLockSuccess', function(_, cb)
    if currentSafe ~= 0 then
        if not Config.Safes[currentSafe].robbed then
            SendNUIMessage({
                action = "kekw",
            })
        end
    else
        SendNUIMessage({
            action = "kekw",
        })
    end
    cb('ok')
end)

RegisterNUICallback('PadLockClose', function(_, cb)
    SetNuiFocus(false, false)
    copsCalled = false
    cb('ok')
end)

RegisterNUICallback("CombinationFail", function(_, cb)
    PlaySound(-1, "Place_Prop_Fail", "DLC_Dmod_Prop_Editor_Sounds", 0, 0, 1)
    cb("ok")
end)

RegisterNetEvent('qb-storerobbery:client:setRegisterStatus', function(batch, val)
    if(type(batch) ~= "table") then
        Config.Registers[batch] = val
    else
        for k in pairs(batch) do
            Config.Registers[k] = batch[k]
        end
    end
end)

RegisterNetEvent('qb-storerobbery:client:setSafeStatus', function(safe, bool)
    Config.Safes[safe].robbed = bool
end)

RegisterNetEvent('qb-storerobbery:client:robberyCall', function(_, _, _, coords)
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
        Wait(1000 * 60 * 5)
        if copsCalled then
            copsCalled = false
        end
    end
end)

CreateThread(function()
    Wait(1000)
    setupRegister()
    setupSafes()
    while true do
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local inRange = false
        for k in pairs(Config.Registers) do
            local dist = #(pos - Config.Registers[k][1].xyz)
            if dist <= 1 and Config.Registers[k].robbed then
                inRange = true
                DrawText3Ds(Config.Registers[k][1].xyz, '~r~Cash register has been raided...~w~')
            end
        end
        if not inRange then
            Wait(2000)
        end
        Wait(3)
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
                event = "qb-storerobbery:client:LiquorOuter1",
                icon = 'fas fa-key',
                label = 'Unlock Outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorOuter1', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
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
            TriggerServerEvent('hud:server:GainStress', Config.StressForFailing)
            Wait(1000)
            if math.random(1, 100) <= Config.BreakChance then 
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorInner1",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorInner1', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
        if success then
            TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner1, false, false, false, true)
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
            end
            TriggerServerEvent('qb-storerobbery:server:KeyRemovalSuccess')
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorBoth1",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorBoth1', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (Config.TripLocks * 1000), false, true, {
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
                event = "qb-storerobbery:client:LiquorOuter2",
                icon = 'fas fa-key',
                label = 'Unlock Outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorOuter2', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorInner2",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorInner2', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
        if success then
            TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner2, false, false, false, true)
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
            end
            TriggerServerEvent('qb-storerobbery:server:KeyRemovalSuccess')
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorBoth2",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorBoth2', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (Config.TripLocks * 1000), false, true, {
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
                event = "qb-storerobbery:client:LiquorOuter3",
                icon = 'fas fa-key',
                label = 'Unlock outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorOuter3', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorInner3",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorInner3', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
        if success then
            TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner3, false, false, false, true)
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
            end
            TriggerServerEvent('qb-storerobbery:server:KeyRemovalSuccess')
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorBoth3",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorBoth3', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (Config.TripLocks * 1000), false, true, {
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
                event = "qb-storerobbery:client:LiquorOuter4",
                icon = 'fas fa-key',
                label = 'Unlock outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorOuter4', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorInner4",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorInner4', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
        if success then
            TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner4, false, false, false, true)
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
            end
            TriggerServerEvent('qb-storerobbery:server:KeyRemovalSuccess')
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorBoth4",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorBoth4', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (Config.TripLocks * 1000), false, true, {
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
                event = "qb-storerobbery:client:LiquorOuter5",
                icon = 'fas fa-key',
                label = 'Unlock outer door'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorOuter5', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorInner5",
                icon = 'fas fa-key',
                label = 'Unlock Storeroom'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorInner5', function()
    if QBCore.Functions.HasItem("liquorkey") then
        TriggerEvent('animations:client:EmoteCommandStart', {"knock2"})
        local success = exports['qb-lock']:StartLockPickCircle(Config.UnlockParses, Config.UnlockParseTime) --StartLockPickCircle(1,10) 1= how many times, 30 = time in seconds
        if success then
            TriggerServerEvent('qb-doorlock:server:updateState', Config.LiquorInner5, false, false, false, true)
            if Config.NotifyType == 'qb' then
                QBCore.Functions.Notify("The door will auto lock in 30 seconds.", "info", 3500)
            elseif Config.NotifyType == "okok" then
                exports['okokNotify']:Alert("BACKUP LOCK", "The door will auto lock in 30 seconds.", 3500, "info")
            end
            TriggerServerEvent('qb-storerobbery:server:KeyRemovalSuccess')
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
                TriggerServerEvent('qb-storerobbery:server:KeyRemoval')
            else
                if Config.NotifyType == 'qb' then
                    QBCore.Functions.Notify("Careful... the key feels a little brittle. ", "error", 3500)
                elseif Config.NotifyType == "okok" then
                    exports['okokNotify']:Alert("KEY STRAINED", "Careful... the key feels a little brittle.", 3500, "error")
                end
            end
        end
    else
        local requiredItems = {
            [1] = {name = QBCore.Shared.Items["liquorkey"]["name"], image = QBCore.Shared.Items["liquorkey"]["image"]},
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
                event = "qb-storerobbery:client:LiquorBoth5",
                icon = 'fas fa-hand-scissors',
                label = 'Trip Locks'
            },
        },
        distance = 1.2,
     })
end)

RegisterNetEvent('qb-storerobbery:client:LiquorBoth5', function()
    TriggerEvent('animations:client:EmoteCommandStart', {"mechanic4"})
    QBCore.Functions.Progressbar("deliver_reycle_package", "Tripping locks...", (Config.TripLocks * 1000), false, true, {
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
