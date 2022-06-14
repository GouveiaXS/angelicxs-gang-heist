ESX = nil
QBcore = nil
playerData = {}
PlayerJob = nil
PlayerGrade = nil
PlayerGang = nil
local win = false

RegisterNetEvent('angelicxs-gangheist:Notify', function(message, type)
	if Config.UseCustomNotify then
        TriggerEvent('angelicxs-gangheist:CustomNotify',message, type)
	elseif Config.UseESX then
		ESX.ShowNotification(message)
	elseif Config.UseQBCore then
		QBCore.Functions.Notify(message, type)
	end
end)

CreateThread(function()
    if Config.UseESX then
        while ESX == nil do
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            Wait(0)
        end
    
        while not ESX.IsPlayerLoaded() do
            Wait(100)
        end
    
        local playerData = ESX.GetPlayerData()
        CreateThread(function()
            while true do
                if playerData ~= nil then
                    PlayerJob = playerData.job.name
                    PlayerGrade = playerData.job.grade
                    break
                end
                Wait(100)
            end
        end)
        RegisterNetEvent('esx:setJob', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade
        end)

    elseif Config.UseQBCore then

        QBCore = exports['qb-core']:GetCoreObject()
        
        CreateThread(function ()
			while true do
                playerData = QBCore.Functions.GetPlayerData()
				if playerData.citizenid ~= nil then
					PlayerJob = playerData.job.name
					PlayerGrade = playerData.job.grade.level
                    PlayerGang = playerData.gang.name
					break
				end
				Wait(100)
			end
		end)

        RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
            PlayerJob = job.name
            PlayerGrade = job.grade.level
            PlayerGang = playerData.gang.name
        end)
    end
    
    if Config.GangLocationBlips then
        for gang, info in pairs(Config.GangInformation) do
            local blip = AddBlipForCoord(info.x,info.y,info.z)
            SetBlipSprite(blip, info.icon)
            SetBlipColour(blip, info.colour)
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(gang)
            EndTextCommandSetBlipName(blip)
        end
	end
end)

-- Events

CreateThread(function()
    if Config.UseThirdEye then
        for gang, info in pairs(Config.GangInformation) do
            exports[Config.ThirdEyeName]:AddBoxZone(gang..info.name, vector3(info.x,info.y,info.z), 3, 3, {
                name = gang..info.name,
                heading = info.h,
                debugPoly = true,
                minZ = info.z - 1.5,
                maxZ = info.z + 1.5,
            },
            {
                options = {
                    {
                        icon = "fas fa-hand-point-up",
                        label = "Steal from " .. info.name,
                        action = function(entity)
                            TriggerEvent('angelicxs-gangheist:StealCheck', info.name)
                        end,
                    },
                },
                distance = 1.5 
            })
        end
    end

    while Config.Use3DText do
        local Player = PlayerPedId()
        local Pos = GetEntityCoords(Player)
        local Sleep = 2000
        for gang, info in pairs(Config.GangInformation) do
            local Dist = #(Pos - vector3(info.x,info.y,info.z))
            if Dist <= 100 then
                Sleep = 500
                if Dist <= 3 then
                    Sleep = 0
                    DrawText3Ds(info.x,info.y,info.z, Config.Lang['steal'])
                    if IsControlJustReleased(0, 38) then
                        TriggerEvent('angelicxs-gangheist:StealCheck', info.name, info.sname)
                    end
                end
            end
        end
        Wait(Sleep)
    end
end)

RegisterNetEvent('angelicxs-gangheist:StealCheck', function(gangSafe, gangFund)
    local Player = PlayerPedId()
    local enoughcops = false
    local enoughgang = false
    local hasItem = false
    if Config.RequireMinimumLEO then
        if Config.UseESX then
            ESX.TriggerServerCallback('angelicxs-gangheist:PoliceAvailable:ESX', function(cb)
                enoughcops = cb
            end)                                    
        elseif Config.UseQBCore then
            QBCore.Functions.TriggerCallback('angelicxs-gangheist:PoliceAvailable:QBCore', function(cb)
                enoughcops = cb
            end)
        end
    else
        enoughcops = true
    end
    if Config.RequireMinimumGang then
        if Config.UseESX then
            ESX.TriggerServerCallback('angelicxs-gangheist:GangAvailable:ESX', function(cb)
                enoughgang = cb
            end, gangSafe)                                    
        elseif Config.UseQBCore then
            QBCore.Functions.TriggerCallback('angelicxs-gangheist:GangAvailable:QBCore', function(cb)
                enoughgang = cb
            end, gangSafe)
        end
    else
        enoughgang = true
    end
    Wait(600)
    if enoughcops then
        if enoughgang then
            if Config.NeedItem then
                if Config.UseESX then
                    ESX.TriggerServerCallback('angelicxs-gangheist:itemcheck:ESX', function(cb) 
                        hasItem = cb
                    end)                                
                elseif Config.UseQBCore then
                    hasItem = QBCore.Functions.HasItem(Config.ItemName)
                    if hasItem then
                        if Config.RemoveItem then
                            QBCore.Functions.TriggerCallback('angelicxs-gangheist:itemcheck:QBCore', function(cb)
                            end)
                        end
                    end
                end
            else
                hasItem = true
            end
            Wait(600)
            if hasItem then
                if Config.CustomGame then
                    win = true
                    TriggerEvent('angelicxs-gangheist:CustomGame',gangFund)
                else
                    win = true
                    Animation(Player,"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer",3000)
                    Wait(3000)
                    Prize(gangFund)
                end
            else
                TriggerEvent('angelicxs-gangheist:Notify', Config.Lang['missing_item'], Config.LangType['error'])
            end
        else
            TriggerEvent('angelicxs-gangheist:Notify', Config.Lang['minnotmet'], Config.LangType['error'])
        end
    else
        TriggerEvent('angelicxs-gangheist:Notify', Config.Lang['minnotmet'], Config.LangType['error'])
    end
end)

function Prize(gangFund)
    if win then
        if gangFund ~= nil then
            win = false
            TriggerServerEvent('angelicxs-gangheist:Server:Completion', gangFund)
            TriggerEvent('angelicxs-gangheist:Notify', Config.Lang['win']..gangFund, Config.LangType['success'])
        end
    end
end

-- Functions
function Animation(ped, dict, name, time)
    FreezeEntityPosition(ped, true)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
    TaskPlayAnim(ped, dict, name,1.0, -1.0, -1, 49, 0, 0, 0, 0)
    Wait(time)	
    ClearPedTasks(ped)
    FreezeEntityPosition(ped, false)
end

function HashGrabber(model)
    local hash = GetHashKey(model)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        Wait(10)
    end
    while not HasModelLoaded(hash) do
      Wait(10)
    end
    return hash
end

-- 3D Text Functionality
function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.30, 0.30)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end