ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local PlayerData = {}

ESX = nil
local PlayerData                = {}
local myPedId = nil

local phoneProp = 0
local phoneModel = "prop_spycam"

local currentStatus = 'text'
local lastDict = nil
local lastAnim = nil
local lastIsFreeze = false
local oIsAnimationOn = false
local oObjectProp = "prop_spycam"
local oObject_net = nil

local aktif = false


local ANIMS = {
	['cellphone@'] = {
		['out'] = {
			['text'] = 'cellphone_text_in',
			['call'] = 'cellphone_call_listen_base',
		},
		['text'] = {
			['out'] = 'cellphone_text_out',
			['text'] = 'cellphone_text_in',
			['call'] = 'cellphone_text_to_call',
		},
		['call'] = {
			['out'] = 'cellphone_call_out',
			['text'] = 'cellphone_call_to_text',
			['call'] = 'cellphone_text_to_call',
		}
	},
	['anim@cellphone@in_car@ps'] = {
		['out'] = {
			['text'] = 'cellphone_text_in',
			['call'] = 'cellphone_call_in',
		},
		['text'] = {
			['out'] = 'cellphone_text_out',
			['text'] = 'cellphone_text_in',
			['call'] = 'cellphone_text_to_call',
		},
		['call'] = {
			['out'] = 'cellphone_horizontal_exit',
			['text'] = 'cellphone_call_to_text',
			['call'] = 'cellphone_text_to_call',
		}
	}
}

function nobleBodycamAnimation()
  local player = PlayerPedId()
  local playerID = PlayerId()
  local plyCoords = GetOffsetFromEntityInWorldCoords(GetPlayerPed(PlayerId()), 0.0, 0.0, -5.0)
  local phoneRspawned = CreateObject(GetHashKey(oObjectProp), plyCoords.x, plyCoords.y, plyCoords.z, 1, 1, 1)
  local netid = ObjToNet(phoneRspawned)
  local ad = "cellphone@"

  if (DoesEntityExist(player) and not IsEntityDead(player)) then
      loadAnimDict(ad)
      RequestModel(GetHashKey(oObjectProp))
      if oIsAnimationOn == true then
          --EnableGui(false)
          TaskPlayAnim(player, ad, "cellphone_text_in", 8.0, 1.0, -1, 50, 0, 0, 0, 0)
          Citizen.Wait(1000)
          DetachEntity(NetToObj(oObject_net), 1, 1)
          DeleteEntity(NetToObj(oObject_net))
          Citizen.Wait(1000)
          ClearPedSecondaryTask(player)
          oObject_net = nil
          oIsAnimationOn = false
      else
          oIsAnimationOn = true
          Citizen.Wait(500)
          --SetNetworkIdExistsOnAllMachines(netid, true)
          --NetworkSetNetworkIdDynamic(netid, true)
          --SetNetworkIdCanMigrate(netid, false)
          TaskPlayAnim(player, ad, "cellphone_text_in", 8.0, 1.0, -1, 50, 0, 0, 0, 0)
          Citizen.Wait(1000)
          AttachEntityToEntity(phoneRspawned,GetPlayerPed(playerID),GetPedBoneIndex(GetPlayerPed(playerID), 28422),-0.005,0.0,0.0,360.0,360.0,0.0,1,1,0,1,0,1)
          oObject_net = netid
          Citizen.Wait(1000)
          deleteRadio()
          --EnableGui(true)
      end
  end
end

function newRadioProp()
	RequestModel(phoneModel)
	while not HasModelLoaded(phoneModel) do
		Citizen.Wait(1)
	end
	phoneProp = CreateObject(phoneModel, 1.0, 1.0, 1.0, 1, 1, 0)
	local bone = GetPedBoneIndex(myPedId, 28422)
    AttachEntityToEntity(phoneProp, myPedId, bone, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1, 1, 0, 0, 2, 1)
    deleteRadio()
end

function deleteRadio ()
	if phoneProp ~= 0 then
		Citizen.InvokeNative(0xAE3CBE5BF394C9C9 , Citizen.PointerValueIntInitialized(phoneProp))
		phoneProp = 0
	end
end

function RadioPlayAnim (status, freeze, force)
	if currentStatus == status and force ~= true then
		return
	end

	myPedId = PlayerPedId()
	local freeze = freeze or false

	local dict = "cellphone@"
	if IsPedInAnyVehicle(myPedId, false) then
		dict = "anim@cellphone@in_car@ps"
	end
	loadAnimDict(dict)

	local anim = ANIMS[dict][currentStatus][status]
	if currentStatus ~= 'out' then
		StopAnimTask(myPedId, lastDict, lastAnim, 1.0)
	end
	local flag = 50
	if freeze == true then
		flag = 14
	end
	TaskPlayAnim(myPedId, dict, anim, 3.0, -1, -1, flag, 0, false, false, false)

	if status ~= 'out' and currentStatus == 'out' then
		Citizen.Wait(1000)
		newRadioProp()
	end

	lastDict = dict
	lastAnim = anim
	lastIsFreeze = freeze
	currentStatus = status

	if status == 'out' then
		Citizen.Wait(1000)
		deleteRadio()
		StopAnimTask(myPedId, lastDict, lastAnim, 1.0)
	end

end

function RadioPlayOut ()
	RadioPlayAnim('out')
end

function RadioPlayText ()
	RadioPlayAnim('text')
end

function PhonePlayCall (freeze)
	RadioPlayAnim('call', freeze)
end

function PhonePlayIn () 
	if currentStatus == 'out' then
		RadioPlayText()
	end
end

bodycama = false

RegisterNetEvent("bodycam:show")
AddEventHandler("bodycam:show", function(daner, job)
    if aktif then 
        TriggerEvent('bodycam:close')
        exports["mythic_notify"]:SendAlert("error","Bodycam kapatıldı.")
    elseif not aktif then
        exports["mythic_notify"]:SendAlert("inform","Bodycam açıldı.")
        aktif = true
        PlayerData = ESX.GetPlayerData()
        while aktif == true do
            local year , month, day , hour , minute , second  = GetLocalTime()

            if string.len(tostring(minute)) < 2 then
                minute = '0' .. minute
            end
            if string.len(tostring(second)) < 2 then
                second = '0' .. second
            end
            SendNUIMessage({
                date = day .. '/'.. month .. '/' .. year .. ' ' .. hour .. ':' .. minute .. ':' .. second,
                daneosoby = daner,
                job = PlayerData.job.name,
                ranga = job,
                open = true,
            })
            Citizen.Wait(1000)
        end
    end
end)

RegisterNetEvent("bodycam:close")
AddEventHandler("bodycam:close", function()
    aktif = false
    bodycama = false
    --clothesoff()
    SendNUIMessage({
        open = false
    })
    
end)

function clotheson()
    local playerPed = PlayerPedId()

    TriggerEvent('skinchanger:getSkin', function(skin)
    TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
        if skin.sex == 0 then
        SetPedComponentVariation(PlayerPedId(), 9, 1, 0, 0)
        yesil = {
            ['bproof_1'] = 1,  ['bproof_2'] = 0
            }
        elseif skin.sex == 1 then 
        SetPedComponentVariation(PlayerPedId(), 9, 1, 0, 0)
        yesil = {
            ['bproof_1'] = 1,  ['bproof_2'] = 0
            }
        end
    end)
end

function clothesoff()
    local playerPed = PlayerPedId()

    TriggerEvent('skinchanger:getSkin', function(skin)
    TriggerEvent('skinchanger:loadClothes', skin, accessorySkin)
        if skin.sex == 0 then
        SetPedComponentVariation(PlayerPedId(), 9, 0, 0, 0)
        yesil = {
            ['bproof_1'] = 0,  ['bproof_2'] = 0
            }
        elseif skin.sex == 1 then 
        SetPedComponentVariation(PlayerPedId(), 9, 0, 0, 0)
        yesil = {
            ['bproof_1'] = 0,  ['bproof_2'] = 0
            }
        end
    end)
end

function playerAnim()
    loadAnimDict( "clothingtie" )
    TaskPlayAnim( PlayerPedId(), "clothingtie", "try_tie_neutral_a", 8.0, 1.0, -1, 16, 0, 0, 0, 0 )
end

function loadAnimDict( dict )
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end 