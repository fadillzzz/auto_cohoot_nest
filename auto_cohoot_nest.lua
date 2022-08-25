-- auto_cohoot_nest.lua : written by archwizard1204
-- cohoot nest data credit to Annihilate

local settings = {
	enable = true;
	maxStock = 5;
}

local elgadoMap = {[6]=true, [7]=true}
local kamuraMap = {[0]=true, [1]=true, [2]=true, [3]=true, [4]=true}

function autoPickNest()
	if not settings.enable then
		return nil
	end

	local villageAreaManager = sdk.get_managed_singleton("snow.VillageAreaManager")

	if not villageAreaManager then
		return nil
	end

	local villageNum = villageAreaManager:call("get__CurrentAreaNo")

	local owlNestManagerType = sdk.find_type_definition("snow.progress.ProgressOwlNestManager")
	local getSaveDataMethod = owlNestManagerType:get_method("get_SaveData")
	local stack_item_count_field = owlNestManagerType:get_field("StackItemCount")

	local owlNestSaveData = sdk.find_type_definition("snow.progress.ProgressOwlNestSaveData")
	local stackCount1Field = owlNestSaveData:get_field("_StackCount")
	local stackCount2Field = owlNestSaveData:get_field("_StackCount2")

	local ID1 = owlNestSaveData:get_field("_StackItemID")
	local ID2 = owlNestSaveData:get_field("_StackItemID2")

	local owlNestManagerSingleton = sdk.get_managed_singleton("snow.progress.ProgressOwlNestManager")
	local owlNestSaveData = getSaveDataMethod:call(owlNestManagerSingleton)

	local kamuraCount = stackCount1Field:get_data(owlNestSaveData)
	local elgadoCount = stackCount2Field:get_data(owlNestSaveData)

	if kamuraCount >= settings.maxStock then
		villageAreaManager:call("set__CurrentAreaNo", 2)
		owlNestManagerSingleton:supply()
	end

	if elgadoCount >= settings.maxStock then
		villageAreaManager:call("set__CurrentAreaNo", 6)
		owlNestManagerSingleton:supply()
	end

end

local function SaveSettings()
	json.dump_file("Auo_cohoot_nest.json", settings)
end

local function LoadSettings()
	local loadedSettings = json.load_file("Auo_cohoot_nest.json");
	if loadedSettings then
		settings = loadedSettings;
	end

	if not settings.enable then settings.enable = true end
	if not settings.maxStock then settings.maxStock = 5 end
end

re.on_draw_ui(function()
	local changed = false;

	if imgui.tree_node("Auto cohoot nest") then

		changed, settings.enable = imgui.checkbox("Enabled", settings.enable);
		changed, settings.maxStock = imgui.slider_int("Maximum stock", settings.maxStock, 1, 5);
		imgui.tree_pop()
	end
end)

re.on_config_save(function()
	SaveSettings()
end)

LoadSettings()

sdk.hook(sdk.find_type_definition("snow.VillageMapManager"):get_method("getCurrentMapNo"),
	nil,
	autoPickNest)
