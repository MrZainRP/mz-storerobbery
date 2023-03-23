local QBCore = exports['qb-core']:GetCoreObject()

local SafeCodes = {}

CreateThread(function()
    while true do
        SafeCodes = {
            [1] = math.random(1000, 9999),
            [2] = {math.random(1, 149), math.random(500.0, 600.0), math.random(360.0, 400), math.random(600.0, 900.0)},
            [3] = {math.random(150, 359), math.random(-300.0, -60.0), math.random(0, 100), math.random(-500.0, -160.0)},
            [4] = math.random(1000, 9999),
            [5] = math.random(1000, 9999),
            [6] = {math.random(1, 149), math.random(150.0, 200.0), math.random(100, 140), math.random(150.0, 220.0), math.random(-100, 100), math.random(140, 300)},
            [7] = math.random(1000, 9999),
            [8] = math.random(1000, 9999),
            [9] = math.random(1000, 9999),
            [10] = {math.random(1, 149), math.random(300.0, 500.0), math.random(200, 260), math.random(500.0, 800.0), math.random(300, 440), math.random(650, 900)},
            [11] = math.random(1000, 9999),
            [12] = math.random(1000, 9999),
            [13] = math.random(1000, 9999),
            [14] = {math.random(150, 450), math.random(-360.0, 0.0), math.random(360, 720)},
            [15] = math.random(1000, 9999),
            [16] = math.random(1000, 9999),
            [17] = math.random(1000, 9999),
            [18] = {math.random(150, 450), math.random(1.0, 100.0), math.random(360, 450), math.random(300.0, 340.0), math.random(350, 400), math.random(320.0, 340.0), math.random(350, 600)},
            [19] = math.random(1000, 9999),
        }
        Wait((1000 * 60) * 40)
    end
end)

QBCore.Functions.CreateCallback('mz-storerobbery:server:isCombinationRight', function(_, cb, safe)
    cb(SafeCodes[safe])
end)

RegisterNetEvent('mz-storerobbery:server:OpenDoor', function(door)
    -- ox_doorlock stuff starts here
    local LiquorDoor = exports.ox_doorlock:getDoorFromName(door)
    TriggerClientEvent('ox_doorlock:setState', -1, LiquorDoor.id, 0, source)
    SetTimeout(Config.AutoLock * 1000, function()
        TriggerClientEvent('ox_doorlock:setState', -1, LiquorDoor.id, 1)
        TriggerEvent('ox_doorlock:stateChanged', nil, LiquorDoor.id, 1)
    end)
    -- ox_doorlock stuff ends here
    -- implement your own below if needed
end)

--Cash register return
RegisterNetEvent('mz-storerobbery:server:takeMoney', function(register, isDone)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then 
        return 
    end
    local playerPed = GetPlayerPed(src)
    local playerCoords = GetEntityCoords(playerPed)
    -- if #(playerCoords - Config.Registers[register][1].xyz) > 3.0 or (not Config.Registers[register].robbed and not isDone) or (Config.Registers[register].time <= 0 and not isDone) then
    --     return DropPlayer(src, "Attempted exploit abuse")
    -- end
    -- Add any additional code you want above this comment to do whilst robbing a register, everything above the if statement under this will be triggered every 2 seconds when a register is getting robbed.
    if isDone then
        if Config.CashRegisterReturn == "dirtymoney" then 
            local amount = math.random(Config.minRegisterEarn, Config.maxRegisterEarn)
            Player.Functions.AddItem('dirtymoney', amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['dirtymoney'], "add", amount)
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, "You stole $" ..amount.. " from the till!", 'success')
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE TILL", "You stole $" ..amount.. " from the till!", 4500, 'success')
            end
            Wait(1500)
            if math.random(1, 100) <= Config.liquorKey then 
                Player.Functions.AddItem('liquorkey', 1, false)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['liquorkey'], "add", 1)
            end
        elseif Config.CashRegisterReturn == "markedbills" then 
            local info = {
                worth = math.random(Config.minRegisterEarn, Config.maxRegisterEarn)
            }
            Player.Functions.AddItem('markedbills', 1, false, info)
			TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['markedbills'], "add")
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, "You stole $" ..info.worth.. " from the till!", 'success')
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE TILL", "You stole $" ..info.worth.. " from the till!", 4500, 'success')
            end
            Wait(1500)
            if math.random(1, 100) <= Config.liquorKey then 
                Player.Functions.AddItem('liquorkey', 1, false)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['liquorkey'], "add", 1)
            end
        elseif Config.CashRegisterReturn == "cash" then 
            local cleanmoney = math.random(Config.minRegisterEarn, Config.maxRegisterEarn)
            Player.Functions.AddMoney('cash', cleanmoney)
            if Config.NotifyType == 'qb' then
                TriggerClientEvent('QBCore:Notify', src, "You stole $" ..cleanmoney.. " from the till!", 'success')
            elseif Config.NotifyType == "okok" then
                TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE TILL", "You stole $" ..cleanmoney.. " from the till!", 4500, 'success')
            end
        else 
            print("You have not properly configured 'Config.CashRegisterReturn', please refer to config.lua")
        end
    end
end)

RegisterNetEvent('mz-storerobbery:server:setRegisterStatus', function(register)
    Config.Registers[register].robbed = true
    Config.Registers[register].time = Config.resetTime
    TriggerClientEvent('mz-storerobbery:client:setRegisterStatus', -1, register, Config.Registers[register])
end)

RegisterNetEvent('mz-storerobbery:server:setSafeStatus', function(safe)
    Config.Safes[safe].robbed = true
    TriggerClientEvent('mz-storerobbery:client:setSafeStatus', -1, safe, true)
    SetTimeout(math.random(40, 80) * (60 * 1000), function()
        Config.Safes[safe].robbed = false
        TriggerClientEvent('mz-storerobbery:client:setSafeStatus', -1, safe, false)
    end)
end)

RegisterNetEvent('mz-storerobbery:server:SafeReward', function(safe)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if not Player then 
        return 
    end
    -- local playerPed = GetPlayerPed(src)
    -- local playerCoords = GetEntityCoords(playerPed)
    -- if #(playerCoords - Config.Safes[safe][1].xyz) > 5.0 or Config.Safes[safe].robbed then
    --     return DropPlayer(src, "Attempted exploit abuse")
    -- end
    if Config.SafeReturn == "dirtymoney" then 
        local amount = math.random(Config.minSafeEarn, Config.maxSafeEarn)
        Player.Functions.AddItem('dirtymoney', amount, false)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['dirtymoney'], "add")
        if Config.NotifyType == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, "You stole $" ..amount.. " from the safe!", 'success', 4500)
        elseif Config.NotifyType == "okok" then
            TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE SAFE", "You stole $" ..amount.. " from the safe!", 4500, 'success')
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem1Chance then 
            Player.Functions.AddItem(Config.RareItem1, Config.RareItemAmount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem1], "add", Config.RareItemAmount)
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem2Chance then 
            Player.Functions.AddItem(Config.RareItem2, Config.RareItem2Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem2], "add", Config.RareItem2Amount)
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem3Chance then 
            Player.Functions.AddItem(Config.RareItem3, Config.RareItem3Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem3], "add", Config.RareItem3Amount)
        end
    elseif Config.SafeReturn == "markedbills" then
        local info = {
            worth = math.random(Config.minSafeEarn, Config.maxSafeEarn)
        }
        Player.Functions.AddItem('markedbills', 1, false, info)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['markedbills'], "add")
        if Config.NotifyType == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, "You stole $" ..info.worth.. " from the safe!", 'success', 4500)
        elseif Config.NotifyType == "okok" then
            TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE SAFE", "You stole $" ..info.worth.. " from the safe!", 4500, 'success')
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem1Chance then 
            Player.Functions.AddItem(Config.RareItem1, Config.RareItemAmount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem1], "add", Config.RareItemAmount)
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem2Chance then 
            Player.Functions.AddItem(Config.RareItem2, Config.RareItem2Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem2], "add", Config.RareItem2Amount)
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem3Chance then 
            Player.Functions.AddItem(Config.RareItem3, Config.RareItem3Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem3], "add", Config.RareItem3Amount)
        end
    elseif Config.SafeReturn == "cash" then
        local cleanmoney = math.random(Config.minSafeEarn, Config.maxSafeEarn)
        Player.Functions.AddMoney('cash', cleanmoney)
        if Config.NotifyType == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, "You stole $" ..cleanmoney.. " from the safe!", 'success')
        elseif Config.NotifyType == "okok" then
            TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE TILL", "You stole $" ..cleanmoney.. " from the safe!", 4500, 'success')
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem1Chance then 
            Player.Functions.AddItem(Config.RareItem1, Config.RareItemAmount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem1], "add", Config.RareItemAmount)
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem2Chance then 
            Player.Functions.AddItem(Config.RareItem2, Config.RareItem2Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem2], "add", Config.RareItem2Amount)
        end
        Wait(1000)
        if math.random(1, 100) <= Config.RareItem3Chance then 
            Player.Functions.AddItem(Config.RareItem3, Config.RareItem3Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.RareItem3], "add", Config.RareItem3Amount)
        end 
    else
        print("You have not properly configured 'Config.SafeReturn', please refer to config.lua")
    end
end)

RegisterNetEvent('mz-storerobbery:server:SafeRewardAlcohol', function(safe)
    local src = source
	local Player = QBCore.Functions.GetPlayer(src)
    if not Player then 
        return 
    end
    -- local playerPed = GetPlayerPed(src)
    -- local playerCoords = GetEntityCoords(playerPed)
    -- if #(playerCoords - Config.Safes[safe][1].xyz) > 5.0 or Config.Safes[safe].robbed then
    --     return DropPlayer(src, "Attempted exploit abuse")
    -- end
    if Config.AlcoholReturn == "dirtymoney" then 
        local amount = math.random(Config.AlcoholminSafeEarn, Config.AlcoholmaxSafeEarn)
        Player.Functions.AddItem('dirtymoney', amount, false)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['dirtymoney'], "add")
        if Config.NotifyType == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, "You stole $" ..amount.. " from the safe!", 'success', 4500)
        elseif Config.NotifyType == "okok" then
            TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE SAFE", "You stole $" ..amount.. " from the safe!", 4500, 'success')
        end
        Wait(1500)
        if math.random(1, 100) <= Config.AlcoholRareItem1Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem1, Config.AlcoholRareItemAmount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem1], "add", Config.AlcoholRareItemAmount)
        end
        Wait(1500)
        if math.random(1, 100) <= Config.AlcoholRareItem2Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem2, Config.AlcoholRareItem2Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem2], "add", Config.AlcoholRareItem2Amount)
        end
        Wait(1500)
        if math.random(1, 100) <= Config.AlcoholRareItem3Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem3, Config.AlcoholRareItem3Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem3], "add", Config.AlcoholRareItem3Amount)
        end
    elseif Config.AlcoholReturn == "markedbills" then 
        local info = {
            worth = math.random(Config.AlcoholminSafeEarn, Config.AlcoholmaxSafeEarn)
        }
        Player.Functions.AddItem('markedbills', 1, false, info)
        TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items['markedbills'], "add")
        if Config.NotifyType == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, "You stole $" ..info.worth.. " from the safe!", 'success', 4500)
        elseif Config.NotifyType == "okok" then
            TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE SAFE", "You stole $" ..info.worth.. " from the safe!", 4500, 'success')
        end
        Wait(1000)
        if math.random(1, 100) <= Config.AlcoholRareItem1Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem1, Config.AlcoholRareItemAmount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem1], "add", Config.AlcoholRareItemAmount)
        end
        Wait(1500)
        if math.random(1, 100) <= Config.AlcoholRareItem2Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem2, Config.AlcoholRareItem2Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem2], "add", Config.AlcoholRareItem2Amount)
        end
        Wait(1500)
        if math.random(1, 100) <= Config.AlcoholRareItem3Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem3, Config.AlcoholRareItem3Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem3], "add", Config.AlcoholRareItem3Amount)
        end
    elseif Config.AlcoholReturn == "cash" then 
        local cleanmoney = math.random(Config.AlcoholminSafeEarn, Config.AlcoholmaxSafeEarn)
        Player.Functions.AddMoney('cash', cleanmoney)
        if Config.NotifyType == 'qb' then
            TriggerClientEvent('QBCore:Notify', src, "You stole $" ..cleanmoney.. " from the safe!", 'success')
        elseif Config.NotifyType == "okok" then
            TriggerClientEvent('okokNotify:Alert', source, "RAIDED THE TILL", "You stole $" ..cleanmoney.. " from the safe!", 4500, 'success')
        end
        Wait(1000)
        if math.random(1, 100) <= Config.AlcoholRareItem1Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem1, Config.AlcoholRareItemAmount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem1], "add", Config.AlcoholRareItemAmount)
        end
        Wait(1500)
        if math.random(1, 100) <= Config.AlcoholRareItem2Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem2, Config.AlcoholRareItem2Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem2], "add", Config.AlcoholRareItem2Amount)
        end
        Wait(1500)
        if math.random(1, 100) <= Config.AlcoholRareItem3Chance then 
            Player.Functions.AddItem(Config.AlcoholRareItem3, Config.AlcoholRareItem3Amount, false)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.AlcoholRareItem3], "add", Config.AlcoholRareItem3Amount)
        end
    else
        print("You have not properly configured 'Config.AlcoholReturn', please refer to config.lua")
    end
end)

RegisterServerEvent('mz-storerobbery:server:ItemRemoval', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem('usb2', 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['usb2'], "remove", 1)
end)

RegisterServerEvent('mz-storerobbery:server:RemoveLockpick', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem('lockpick', 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['lockpick'], "remove", 1)
end)

RegisterServerEvent('mz-storerobbery:server:RemoveAdvanced', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem('advancedlockpick', 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['advancedlockpick'], "remove", 1)
end)

RegisterServerEvent('mz-storerobbery:server:SafeFail', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Config.NotifyType == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, "You failed to infiltrate the safe...", 'error', 3500)
    elseif Config.NotifyType == "okok" then
        TriggerClientEvent('okokNotify:Alert', source, "WASTED USB", "You failed to infiltrate the safe...", 3500, 'error')
    end
end)

RegisterNetEvent('mz-storerobbery:server:callCops', function(type, safe, streetLabel, coords)
    local cameraId
    if type == "safe" then
        cameraId = Config.Safes[safe].camId
    else
        cameraId = Config.Registers[safe].camId
    end
    local alertData = {
        title = "10-33 | Shop Robbery",
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Someone Is Trying To Rob A Store At "..streetLabel.." (CAMERA ID: "..cameraId..")"
    }
    TriggerClientEvent("mz-storerobbery:client:robberyCall", -1, type, safe, streetLabel, coords)
    TriggerClientEvent("qb-phone:client:addPoliceAlert", -1, alertData)
end)

CreateThread(function()
    while true do
        local toSend = {}
        for k in ipairs(Config.Registers) do
            if Config.Registers[k].time > 0 and (Config.Registers[k].time - Config.tickInterval) >= 0 then
                Config.Registers[k].time = Config.Registers[k].time - Config.tickInterval
            else
                if Config.Registers[k].robbed then
                    Config.Registers[k].time = 0
                    Config.Registers[k].robbed = false
                    toSend[#toSend+1] = Config.Registers[k]
                end
            end
        end
        if #toSend > 0 then
            TriggerClientEvent('mz-storerobbery:client:setRegisterStatus', -1, toSend, false)
        end
        Wait(Config.tickInterval)
    end
end)

QBCore.Functions.CreateCallback('mz-storerobbery:server:getPadlockCombination', function(_, cb, safe)
    cb(SafeCodes[safe])
end)

QBCore.Functions.CreateCallback('mz-storerobbery:server:getRegisterStatus', function(_, cb)
    cb(Config.Registers)
end)

QBCore.Functions.CreateCallback('mz-storerobbery:server:getSafeStatus', function(_, cb)
    cb(Config.Safes)
end)

RegisterServerEvent('mz-storerobbery:server:KeyRemoval', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem('liquorkey', 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['liquorkey'], "remove", 1)
    if Config.NotifyType == 'qb' then
        TriggerClientEvent('QBCore:Notify', src, "You broke the key... Well done...", 'error')
    elseif Config.NotifyType == "okok" then
        TriggerClientEvent('okokNotify:Alert', source, "KEY BROKE", "You broke the key... Well done...", 4500, 'error')
    end
end)

RegisterServerEvent('mz-storerobbery:server:KeyRemovalSuccess', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveItem('liquorkey', 1)
	TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['liquorkey'], "remove", 1)
end)

