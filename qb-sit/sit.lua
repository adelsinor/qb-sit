---- // list of interactables
local Config = _G.Config
local interactModels = {
	`prop_bench_01a`,
	`prop_bench_01b`,
	`prop_bench_01c`,
	`prop_bench_02`,
	`prop_bench_03`,
	`prop_bench_04`,
	`prop_bench_05`,
	`prop_bench_06`,
	`prop_bench_05`,
	`prop_bench_08`,
	`prop_bench_09`,
	`prop_bench_10`,
	`prop_bench_11`,
	`prop_fib_3b_bench`,
	`prop_ld_bench01`,
	`prop_wait_bench_01`,
	`hei_prop_heist_off_chair`,
	`hei_prop_hei_skid_chair`,
	`prop_chair_01a`,
	`prop_chair_01b`,
	`prop_chair_02`,
	`prop_chair_03`,
	`prop_chair_04a`,
	`prop_chair_04b`,
	`prop_chair_05`,
	`prop_chair_06`,
	`prop_chair_05`,
	`prop_chair_08`,
	`prop_chair_09`,
	`prop_chair_10`,
	`v_club_stagechair`,
	`prop_chateau_chair_01`,
	`prop_clown_chair`,
	`prop_cs_office_chair`,
	`prop_direct_chair_01`,
	`prop_direct_chair_02`,
	`prop_gc_chair02`,
	`prop_off_chair_01`,
	`prop_off_chair_03`,
	`prop_off_chair_04`,
	`prop_off_chair_04b`,
	`prop_off_chair_04_s`,
	`prop_off_chair_05`,
	`prop_old_deck_chair`,
	`prop_old_wood_chair`,
	`prop_rock_chair_01`,
	`prop_skid_chair_01`,
	`prop_skid_chair_02`,
	`prop_skid_chair_03`,
	`prop_sol_chair`,
	`prop_wheelchair_01`,
	`prop_wheelchair_01_s`,
	`p_armchair_01_s`,
	`p_clb_officechair_s`,
	`p_dinechair_01_s`,
	`p_ilev_p_easychair_s`,
	`p_soloffchair_s`,
	`p_yacht_chair_01_s`,
	`v_club_officechair`,
	`v_corp_bk_chair3`,
	`v_corp_cd_chair`,
	`v_corp_offchair`,
	`v_ilev_chair02_ped`,
	`v_ilev_hd_chair`,
	`v_ilev_p_easychair`,
	`v_ret_gc_chair03`,
	`prop_ld_farm_chair01`,
	`prop_table_04_chr`,
	`prop_table_05_chr`,
	`prop_table_06_chr`,
	`v_ilev_leath_chr`,
	`prop_table_01_chr_a`,
	`prop_table_01_chr_b`,
	`prop_table_02_chr`,
	`prop_table_03b_chr`,
	`prop_table_03_chr`,
	`prop_torture_ch_01`,
	`v_ilev_fh_dineeamesa`,
	`v_ilev_fh_kitchenstool`,
	`v_ilev_tort_stool`,
	`v_ilev_fh_kitchenstool`,
	`v_ilev_fh_kitchenstool`,
	`v_ilev_fh_kitchenstool`,
	`v_ilev_fh_kitchenstool`,
	`hei_prop_yah_seat_01`,
	`hei_prop_yah_seat_02`,
	`hei_prop_yah_seat_03`,
	`prop_waiting_seat_01`,
	`prop_yacht_seat_01`,
	`prop_yacht_seat_02`,
	`prop_yacht_seat_03`,
	`prop_hobo_seat_01`,
	`prop_rub_couch01`,
	`miss_rub_couch_01`,
	`prop_ld_farm_couch01`,
	`prop_ld_farm_couch02`,
	`prop_rub_couch02`,
	`prop_rub_couch03`,
	`prop_rub_couch04`,
	`p_lev_sofa_s`,
	`p_res_sofa_l_s`,
	`p_v_med_p_sofa_s`,
	`p_yacht_sofa_01_s`,
	`v_ilev_m_sofa`,
	`v_res_tre_sofa_s`,
	`v_tre_sofa_mess_a_s`,
	`v_tre_sofa_mess_b_s`,
	`v_tre_sofa_mess_c_s`,
	`prop_roller_car_01`,
	`prop_roller_car_02`
}

if Config.DisableSitting then -- disabled?
	exports["hl-target"]:RemoveTargetModel(interactModels)
	return
end

local HLCore = HLCore or exports["hl-core"]:GetCoreObject()

---- // locals
local currentScenario = nil
local currentCoords = nil
local currentObj = nil
local playerPed = nil

---- / booleans
local isSitting = false
local disableControls = false

---- // functions

local function StandUp()
	playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)

	TaskStartScenarioAtPosition(playerPed, currentScenario, 0.0, 0.0, 0.0, 180.0, 2, true, false)
	while IsPedUsingScenario(playerPed, currentScenario) do
		Wait(100)
	end
	ClearPedTasks(playerPed)

	FreezeEntityPosition(playerPed, false)
	FreezeEntityPosition(currentObj, false)
	TriggerServerEvent('sit:leavePlace', currentCoords)
	currentCoords, currentScenario = nil, nil
	isSitting = false
	disableControls = false
	TriggerEvent("HLCore:Client:HideText")
end

local function SitDown(object, name, data)
	playerPed = PlayerPedId()
	if not HasEntityClearLosToEntity(playerPed, object, 17) then return end

	disableControls = true
	currentObj = object
	FreezeEntityPosition(object, true)

	PlaceObjectOnGroundProperly(object)
	local ocoords = GetEntityCoords(object)
	local pcoords = GetEntityCoords(PlayerPedId())

	local objectCoords = ("%s:%s:%s"):format(ocoords.x, ocoords.y, ocoords.z)

	HLCore.Functions.TriggerCallback('sit:getPlace', function(taken)
		if taken then
			HLCore.Functions.Notify("This chair is in use !", "error")
			return
		end

		playerPed = PlayerPedId()
		currentCoords = objectCoords
		TriggerServerEvent("sit:takePlace", objectCoords)
		currentScenario = data.scenario

		local heading = GetEntityHeading(object)
		TaskStartScenarioAtPosition(playerPed, currentScenario, ocoords.x, ocoords.y, ocoords.z + (pcoords.z - ocoords.z) * 0.5, heading + 180.0, 0, true, false)

		Wait(2500)
		if GetEntitySpeed(playerPed) > 0 then
			ClearPedTasks(playerPed)
			TaskStartScenarioAtPosition(playerPed, currentScenario, ocoords.x, ocoords.y, ocoords.z + (pcoords.z - ocoords.z) * 0.5, heading + 180.0, 0, true, true)
		end

		isSitting = true
	end, objectCoords)
end

---- // events

RegisterNetEvent("sit:Sit", function(data)
	playerPed = PlayerPedId()
	if isSitting or not IsPedUsingScenario(playerPed, currentScenario) then
		StandUp()
	end

	if disableControls then
		DisableControlAction(1, 37, true)
	end

	local object = data.entity
	local dist = #(GetEntityCoords(playerPed) - GetEntityCoords(object))
	if dist > 1.7 then return end

	local hash = GetEntityModel(object)
	for k, v in pairs(Config.Sitable) do
		if k == hash then
			SitDown(object, k, v)
			break
		end
	end
end)

---- // exports
exports("sitting", function()
	return isSitting
end)

---- // threads

CreateThread(function()
	--- // build hl-target
	exports["hl-target"]:AddTargetModel(interactModels, {
		options = {{
			event = "sit:Sit",
			icon = "fas fa-chair",
			label = "Sit Down"
		}},
		distance = 1.5
	})

	-- wait for the player to log in
	while not LocalPlayer.state.isLoggedIn do
		Wait(2000)
	end

	local stand = "[E] - Stand Up"
	local sleep = 2000

	while true do
		sleep = 2000
		if isSitting then
			sleep = 10
			playerPed = PlayerPedId()

			TriggerEvent("HLCore:Client:DrawText", stand, "left")

			if not IsPedUsingScenario(playerPed, currentScenario) then
				StandUp()
			end

			if IsControlJustPressed(0, 38) and IsUsingKeyboard(0) and IsPedOnFoot(playerPed) then
				StandUp()
			end
		end
		Wait(sleep)
	end
end)
