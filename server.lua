ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local aktif = false

ESX.RegisterUsableItem('bodycam', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'sheriff' and not aktif then
		local data = isimcek(source)
		aktif = true
		TriggerClientEvent('bodycam:show', source, data.firstname.. " " .. data.lastname, " " ..  xPlayer.job.grade_label)
		--TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'inform', text = "Bodycam açıldı."})	
	else
		TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = "Polis veya doktor olmadan kullanamazsın."})
		aktif = false
	end
end)

function isimcek(source)
	local identifier = GetPlayerIdentifiers(source)[1]
	local result = MySQL.Sync.fetchAll("SELECT firstname,lastname FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
	if result[1] ~= nil then
		local identity = result[1]

		return {
			firstname = identity['firstname'],
			lastname = identity['lastname'],
		}
	else
		return nil
	end
end

AddEventHandler('esx:onRemoveInventoryItem', function(source, item, count)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if xPlayer ~= nil and xPlayer.job ~= nil and xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' or xPlayer.job.name == 'sheriff' then
		if item.name == 'bodycam' and item.count < 1 then
			if aktif then
				aktif = false
				TriggerClientEvent('bodycam:close', _source)
				TriggerClientEvent('mythic_notify:client:SendAlert', xPlayer.source, { type = 'error', text = "Bodycam kapatıldı."})
			end
        end
    end
end)
