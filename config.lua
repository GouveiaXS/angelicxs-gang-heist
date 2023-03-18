Config = {}


Config.UseESX = false						-- Use ESX Framework
Config.UseQBCore = true					-- Use QBCore Framework (Ignored if Config.UseESX = true)

Config.UseCustomNotify = false				-- Use a custom notification script, must complete event below.

-- Only complete this event if Config.UseCustomNotify is true; mythic_notification provided as an example
RegisterNetEvent('angelicxs-gangheist:CustomNotify')
AddEventHandler('angelicxs-gangheist:CustomNotify', function(message, type)
    --exports.mythic_notify:SendAlert(type, message, 4000)
end)

-- Blip Preference
-- Blip info: https://docs.fivem.net/docs/game-references/blips/
Config.GangLocationBlips = true 			-- If true will mark the gang safe on the map


Config.GangInformation = {
	--	if Config.GangLocationBlips = false leave icon and colour as example numbers
	-- x, y, z are the coords that the safe can be breached at
	-- name is job/gang name
	-- sname is name of gang/job society fund (example for esx = society_vagos)
	-- example
	-- ['vagos'] = {icon = 84, colour = 40, x = , y = , z = , h = , name = 'vagos', sname = 'vagos'}
}

-- Visual Preference
Config.Use3DText = false 					-- Use 3D text for interactions; only turn to false if Config.UseThirdEye is turned on and IS working.
Config.UseThirdEye = true 					-- Enables using a third eye (third eye requires the following arguments debugPoly, useZ, options {event, icon, label}, distance)
Config.ThirdEyeName = 'qb-target' 			-- Name of third eye aplication

--LEO Configuration
Config.RequireMinimumLEO = true 			-- When true will require a minimum number of LEOs to be available to rob a gang
Config.RequiredNumberLEO = 1 				-- Minimum number of LEO needed when Config.RequireMinimumLEO = true
Config.LEOJobName = 'police' 				-- Job name of law enforcement officers

--Gang Configuration
Config.RobOwnGang = false				-- If true will allow players to rob their own gang
Config.RequireMinimumGang = true 			-- When true will require a minimum number of gang members to be available to rob a gang
Config.RequiredNumberGang = 1				-- Minimum number of gang members needed when Config.RequireMinimumGang = true

-- Game
Config.CustomGame = true					-- If true, use event below to set up desired minigame.
RegisterNetEvent('angelicxs-gangheist:CustomGame', function(gangFund)
	--Example using utk_fingerprint minigame:
	TriggerEvent("utk_fingerprint:Start", 4, 2, 2, function(outcome, reason)
		if outcome == true then -- reason will be nil if outcome is true
			Prize(gangFund)
		end
	end)


	-- Prize(gangFund)
	-- Success of game should trigger the above commented function as is.
end)

-- Item Requirement
Config.NeedItem = true 					-- If true will require players to have Config.ItemName in order to steal gang cash.
Config.ItemName = 'lockpick'			-- Name of the lockpicking device used if Config.NeedItem = true 
Config.RemoveItem = true				-- If true will remove Config.ItemName upon use when Config.NeedItem = true


-- Rewards Configuration
Config.AccountMoney = 'cash' 				-- How you want the thief paid.

Config.SocietySteal = false 				-- When true will remove money from gang society. By Default only supports qb-management(qbcore) or esx_addonaccount:getSharedAccount (ESX).
Config.TakeFromSocietyFlat = true 			-- When true will only take a Config.TakeFromSocietyFlatAmount otherwise will take the a % of funds.
Config.TakeFromSocietyFlatAmount = 100		-- How much money will be removed from gang and given to thief.
Config.TakeFromSocietyPercentAmount = 0.20	-- How much money (% of current total) will be removed from gang and given to thief.

Config.MoneyAmount = 5000 					-- If Config.SocietySteal = false, Amount paid out in Config.AccountMoney for a successful delivery.
Config.RandomMoneyAmount = true 			-- If Config.SocietySteal = false and set to true, will randomly award money ammount on successful completion instead of Config.MoneyAmount.
Config.RandomMoneyAmountMin = 1000 			-- Minimum money gained on successful completion.
Config.RandomMoneyAmountMax = 10000 		-- Maximum money gained on successful completion.

-- Language Configuration
Config.LangType = {
	['error'] = 'error',
	['success'] = 'success',
	['info'] = 'primary',
}

Config.Lang = {
	['steal'] = 'Press ~r~[E]~w~ to begin stealing funds.',
	['minnotmet'] = 'No risk, no reward. Come back later!',
	['missing_item'] = 'You need a '..Config.ItemName..'!',
	['win'] = 'You have successfully stolen funds from the ',
	['steal_attempt'] = 'Someone is trying to steal your shit!',
	['noselfrob'] = 'You cannot rob your own gang!',

}
