-- auto_cohoot_nest.lua : written by archwizard1204
-- cohoot nest data credit to Annihilate

local settings = {
	enable = true;
	maxStock = 5;
}

local elgadoMap = {[6]=true}
local kamuraMap = {[0]=true, [1]=true, [2]=true, [3]=true, [4]=true, [7]=true}

function autoPickNest(retval)
	if not settings.enable then
		return
	end
	
	local villageAreaManager = sdk.get_managed_singleton("snow.VillageAreaManager")
	
	if not villageAreaManager then
		return
	end
	
	local villageNum = villageAreaManager:call("get__CurrentAreaNo")
	
	local owlNestManagerSingleton = sdk.get_managed_singleton("snow.progress.ProgressOwlNestManager")
	local progressOwlNestSaveData = owlNestManagerSingleton:get_SaveData()

	if not owlNestManagerSingleton or not progressOwlNestSaveData then
		return
	end
	
	local owlNestCount = 0
	if elgadoMap[villageNum] then
		owlNestCount = progressOwlNestSaveData:get_field("_StackCount2")
	elseif kamuraMap[villageNum] then
		owlNestCount = progressOwlNestSaveData:get_field("_StackCount")
	end
	
	if owlNestCount >= settings.maxStock and owlNestManagerSingleton then
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