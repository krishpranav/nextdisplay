local log = suppl_add_logfn("config");
local applname = string.lower(APPLID);


LBL_YES = "yes";
LBL_NO = "no";
LBL_FLIP = "toggle";
LBL_BIND_COMBINATION = "Press and hold the desired combination, %s to Cancel";
LBL_BIND_KEYSYM = "Press and hold single key to bind keysym %s, %s to Cancel";
LBL_BIND_COMBINATION_REP = "Press and hold or repeat- press, %s to Cancel";
LBL_UNBIND_COMBINATION = "Press and hold the combination to unbind, %s to Cancel";
LBL_METAGUARD = "Query Rebind in %d keypresses";
LBL_METAGUARD_META = "Rebind (meta keys) in %.2f seconds, %s to Cancel";
LBL_METAGUARD_BASIC = "Rebind (basic keys) in %.2f seconds, %s to Cancel";
LBL_METAGUARD_MENU = "Rebind (global menu) in %.2f seconds, %s to Cancel";
LBL_METAGUARD_TMENU = "Rebind (target menu) in %.2f seconds, %s to Cancel";

HC_PALETTE = {
	"\\#efd469",
	"\\#43abc9",
	"\\#cd594a",
	"\\#b5c689",
	"\\#f58b4c",
	"\\#ed6785",
	"\\#d0d0d0",
};

local defaults = system_load("config.lua")();
local listeners = {};

function gconfig_listen(key, id, fun)
	if (listeners[key] == nil) then
		listeners[key] = {};
	end
	listeners[key][id] = fun;
end


function gconfig_register(key, val)
	if (not defaults[key]) then
		local v = get_key(key);
		if (v ~= nil) then
			if (type(val) == "number") then
				v = tonumber(v);
			elseif (type(val) == "boolean") then
				v = v == "true";
			end
			defaults[key] = v;
		else
			defaults[key] = val;
		end
	end
end

function gconfig_set(key, val, force)
	if (type(val) ~= type(defaults[key])) then
		log(string.format(
			"key=%s:kind=error:type_in=%s:type_out=%s:value=%s",
			key, type(val), type(defaults[key]), val
		));
		return;
	end

	log(string.format("key=%s:kind=set:new_value=%s", key, val));
	defaults[key] = val;

	if (force) then
		store_key(defaults[key], tostring(val));
	end

	if (listeners[key]) then
		for k,v in pairs(listeners[key]) do
			v(key, val);
		end
	end
end

function gconfig_get(key, opt)
	local res = defaults[key];
	return res and res or opt;
end

local function gconfig_setup()
	for k,vl in pairs(defaults) do
		local v = get_key(k);
		if (v) then
			if (type(vl) == "number") then
				defaults[k] = tonumber(v);

			elseif (type(vl) == "table") then
				local lst = string.split(v, ':');
				local ok = true;
				for i=1,#lst do
					if (not vl[i]) then
						ok = false;
						break;
					end
					if (type(vl[i]) == "number") then
						lst[i] = tonumber(lst[i]);
						if (not lst[i]) then
							ok = false;
							break;
						end
					elseif (type(vl[i]) == "boolean") then
						lst[i] = lst[i] == "true";
					end
				end
				if (ok) then
					defaults[k] = lst;
				end
			elseif (type(vl) == "boolean") then
				defaults[k] = v == "true";
			else
				defaults[k] = v;
			end
		end
	end


	for i,v in ipairs(match_keys("hc_palette_%")) do
		local cl = string.split(v, "=")[2];
		HC_PALETTE[i] = cl;
	end
end

local mask_state = false;
function gconfig_mask_temp(state)
	mask_state = state;
end


function gconfig_shutdown()
	local ktbl = {};
	for k,v in pairs(defaults) do
		if (type(v) ~= "table") then
			ktbl[k] = tostring(v);
		else
			ktbl[k] = table.concat(v, ':');
		end
	end


	if not mask_state then
		for i,v in ipairs(match_keys(applname .. "_temp_%")) do
			local k = string.split(v, "=")[1];
			ktbl[k] = "";
		end
	end
	store_key(ktbl);
end

gconfig_setup();