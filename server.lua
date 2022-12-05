ESX = nil
QBcore = nil

if Config.UseESX then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
elseif Config.UseQBCore then
    QBCore = exports['qb-core']:GetCoreObject()
end

--- Are LEOs Available

if Config.UseESX then
    ESX.RegisterServerCallback('angelicxs-gangheist:PoliceAvailable:ESX',function(source,cb)
        local xPlayers = ESX.GetPlayers()
        local cops = 0

        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == Config.LEOJobName then
                cops = cops + 1
            end
        end
        
        if cops >= Config.RequiredNumberLEO then
            cb(true)
        else
            cb(false)
        end	
    end)
elseif Config.UseQBCore then
    QBCore.Functions.CreateCallback('angelicxs-gangheist:PoliceAvailable:QBCore', function(source, cb)
        local cops = 0
        local players = QBCore.Functions.GetQBPlayers()
        for k, v in pairs(players) do
            if v.PlayerData.job.name == Config.LEOJobName then
                cops = cops + 1
            end
        end

        if cops >= Config.RequiredNumberLEO then
            cb(true)
        else
            cb(false)
        end	
    end)
end

--- Are GangMembers Available

if Config.UseESX then
    ESX.RegisterServerCallback('angelicxs-gangheist:GangAvailable:ESX',function(source,cb, name)
        local xPlayers = ESX.GetPlayers()
        local gang = 0

        for i=1, #xPlayers, 1 do
            local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
            if xPlayer.job.name == name then
                gang = gang + 1
		TriggerClientEvent('angelicxs-gangheist:Notify',xPlayers[i], Config.Lang['steal_attempt'], Config.LangType['info'])
            end
        end
        
        if gang >= Config.RequiredNumberGang then
            cb(true)
        else
            cb(false)
        end	
    end)
elseif Config.UseQBCore then
    QBCore.Functions.CreateCallback('angelicxs-gangheist:GangAvailable:QBCore', function(source, cb, name)
        local gang = 0
        local players = QBCore.Functions.GetQBPlayers()
        for k, v in pairs(players) do
            if v.PlayerData.gang.name == name then
                gang = gang + 1
		TriggerClientEvent('angelicxs-gangheist:Notify',v.PlayerData.source, Config.Lang['steal_attempt'], Config.LangType['info'])
            end
        end

        if gang >= Config.RequiredNumberGang then
            cb(true)
        else
            cb(false)
        end	
    end)
end
-- Item Callback & Removal
if Config.UseESX then
    ESX.RegisterServerCallback('angelicxs-gangheist:itemcheck:ESX', function(source,cb)
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer.getInventoryItem(Config.ItemName).count >= 1 then
            if Config.RemoveItem then
                xPlayer.removeInventoryItem(Config.ItemName,1)
            end
            cb(true)
        else
            cb(false)
        end
    end)
elseif Config.UseQBCore then
    QBCore.Functions.CreateCallback('angelicxs-gangheist:itemcheck:QBCore', function(source, cb)
        local Player = QBCore.Functions.GetPlayer(source)
        Player.Functions.RemoveItem(Config.ItemName, 1)
    end)
end
--- Rewards


RegisterServerEvent('angelicxs-gangheist:Server:Completion')
AddEventHandler('angelicxs-gangheist:Server:Completion', function(gangSafe)
    local funds = 0
    local reward = 0
    local src = source
    if Config.SocietySteal then
        if Config.UseESX then
            TriggerEvent('esx_addonaccount:getSharedAccount', gangSafe, function(account)
                funds = account.money
            end)
        elseif Config.UseQBCore then
            MySQL.Async.fetchAll('SELECT * FROM management_funds WHERE job_name = @job_name', {
                ['@job_name'] = gangSafe,
            }, function (result)
                local table = table.unpack(result)
                if table~=nil then
                    funds = table.amount
                end
            end)
        end
        Wait(400)
        if Config.TakeFromSocietyFlat then
            reward = Config.TakeFromSocietyFlatAmount
        else
            reward = (funds * Config.TakeFromSocietyPercentAmount)
        end
    else
        if Config.RandomMoneyAmount then
            reward = math.random(Config.RandomMoneyAmountMin, Config.RandomMoneyAmountMax)
        else
            reward = Config.MoneyAmount
        end
    end

    if Config.SocietySteal then
        if Config.UseESX then
            TriggerEvent('esx_addonaccount:getSharedAccount', gangSafe, function(account)
                if account.money >= reward then
                    account.removeMoney(reward)
                end
            end)
        elseif Config.UseQBCore then
            exports['qb-management']:RemoveGangMoney(gangSafe, reward)
        end
    end

    if Config.UseESX then
        local xPlayer = ESX.GetPlayerFromId(src)
		xPlayer.addAccountMoney(Config.AccountMoney,reward)
    elseif Config.UseQBCore then
        local Player = QBCore.Functions.GetPlayer(src)
        Player.Functions.AddMoney(Config.AccountMoney, reward)
    end
end)
