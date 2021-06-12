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
    if (not defalts[key]) then
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

