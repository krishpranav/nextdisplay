local system_log;


local known_displays = {
};

local display_action = function()
	system_log("kind=display:status=ignored");
end

WM = {};
local SYMTABLE;
local wait_for_display;
local preview;


local function console_forward(...)
	system_log("kind=dispatch:" .. string.format(...));
end


local function vr_autorun()
	if (resource("autorun.lua", APPL_RESOURCE)) then
		local list = system_load("autorun.lua")();
		if type(list) == "table" then
			for _,v in ipairs(list) do
				dispatch_symbol(v);
			end
		end
	end
end

function safespaces(args)
	system_load("suppl.lua")();
	system_log = suppl_add_logfn("system");

	system_load("gconf.lua")();
	system_load("timer.lua")();
	system_load("menu.lua")();

-- enable IPC system and intercept logging
	if (gconfig_get("allow_ipc")) then
		system_load("ipc.lua")();
	end

-- map config to keybindings, and load keymap (if specified)
	SYMTABLE = system_load("builtin/keyboard.lua")();
	SYMTABLE.bindings = system_load("keybindings.lua")();
	SYMTABLE.meta_1 = gconfig_get("meta_1");
	SYMTABLE.meta_2 = gconfig_get("meta_2");
	SYMTABLE.mstate = {false, false};

-- just map the args into a table and look for
	local argtbl = {};
	for k,v in ipairs(args) do
		local a = string.split(v, "=");
		if (a and a[1] and a[2]) then
			argtbl[a[1]] = a[2];
		end
	end

-- pick device profile from args or config
	local device = argtbl.device and argtbl.device or gconfig_get("device");
	if (not device) then
		return shutdown(
			"No device specified (in config.lua or device=... arg)", EXIT_FAILURE);
	end
	local dev = system_load("devices/" .. device .. ".lua")();
	if (not dev) then
		return shutdown(
			"Device map (" .. device .. ") didn't load", EXIT_FAILURE);
	end

-- project device specific bindings, warn on conflict
	if (dev.bindings) then
		for k,v in pairs(dev.bindings) do
			if (SYMTABLE.bindings[k]) then
				warning("igoring conflicting device binding (" .. k .. ")");
			else
				SYMTABLE.bindings[k] = v;
			end
		end
	end


	preview = alloc_surface(gconfig_get("preview_w"), gconfig_get("preview_h"));

	image_tracetag(preview, "preview");

-- append the menu tree for accessing / manipulating the VR setup
	WM.menu = (system_load("vr_menus.lua")())(WM, prefix);
	WM.mouse_mode = "direct";
	WM.dev = dev;
	(system_load("ssmenus.lua")())(WM.menu);
	dispatch_symbol =
	function(sym)
		print(sym);
		return menu_run(WM.menu, sym, console_forward);
	end

	dispatch_meta = function()
		return SYMTABLE.mstate[1], SYMTABLE.mstate[2]
	end

	local on_vr =
	function(device, comb, l, r)
		if valid_vid(comb) and dev.no_combiner then
			delete_image(comb);
		else
			dispatch_symbol("/map_display=0");
		end
		vr_autorun();
	end

-- rebuild the WM context to add the basic VR setup / management functions
	local setup = system_load("vrsetup.lua")();
	setup(WM, preview);

-- but if we want a specific display, we need something else, this becomes
-- a bit more weird when there are say two displays we need to map, one for
-- each eye with different synch.
	if (dev.display or dev.display_id) then
		on_vr =
		function(device, comb, l, r)
			wait_for_display(dev,
			function(dispid)
				WM.dev.display_id = dispid;

-- map the preview to all other displays, map the combiner to this one,
-- don't know how many they are but it's a cheap call so just sweep
				for i=0,8 do
					map_video_display(i == dispid and comb or preview, i);
				end
				vr_autorun();
			end);
		end
	end

	WM:setup_vr(on_vr, dev);
	show_image(preview);

-- tool-loading code and UI primitives shared with durden
	system_load("icon.lua")();
	system_load("uiprim/uiprim.lua")();
	suppl_scan_tools();

-- space can practically be empty and the entire thing controlled from IPC
	WM:load_space(argtbl.space and argtbl.space or "default.lua");

-- just hook for custom things
	system_log("kind=status:message=init over");
end

-- intercept so we always log this call given how complex it can get
local map_video = map_video_display;
function map_video_display(src, id, hint, ...)

-- let device profile set platform video mapping option
	if not hint then
		if WM.dev.display_id == id then
			system_log("kind=display:status=map_target");
			hint = HINT_PRIMARY;
			if (WM.dev.map_hint) then
				hint = bit.bor(hint, WM.dev.map_hint);
			end
		else
			hint = 0;
		end
	end

	hint = bit.bor(hint, HINT_FIT);

	system_log(string.format(
		"kind=display:status=map:src=%d:id=%d:hint=%d", src, id, hint));
	return map_video(src, id, hint, ...);
end

wait_for_display =
function(dev, callback)
	system_log(string.format(
		"kind=display:status=waiting:device=%s", dev.display));

	timer_add_periodic("rescan", 200, false, function()
		video_displaymodes();
	end);

-- when a display arrives that match the known/desired display,
-- map the VR combiner stage to it and map the console to the default display
	display_action =
	function(name, id)
		local match =
			(dev.display_id and dev.display_id == id)
			or string.match(name, dev.display);

		system_log(string.format(
			"kind=display:status=added:name=%s:target=%s:match=%s",
			name, dev.display, match and "yes" or "no"));

		if (not match) then
			return;
		end

		timer_delete("rescan");
		callback(id);
		display_action = function()
		end
	end

-- we might already know about the display, then just trigger the action
	for i,v in pairs(known_displays) do
		display_action(v, i);
	end
end

local function keyboard_input(iotbl)
	local sym, lutsym = SYMTABLE:patch(iotbl);

-- meta keys are always consumed
	if (sym == SYMTABLE.meta_1) then
		SYMTABLE.mstate[1] = iotbl.active;
		return;
	elseif (sym == SYMTABLE.meta_2) then
		SYMTABLE.mstate[2] = iotbl.active;
		return;
	end

-- then we build the real string
	if not iotbl.active then
		sym = "release_" .. sym
	end

	if SYMTABLE.mstate[2] then
		sym = "m2_" .. sym
	end

	if SYMTABLE.mstate[1] then
		sym = "m1_" .. sym
	end

	system_log("kind=input:symbol=" .. tostring(sym));

-- and if a match, consume / execute
	local path = SYMTABLE.bindings[sym];

	if (path) then
		dispatch_symbol(path);
		return;
	end

-- otherwise forward
	return iotbl;
end

function safespaces_input(iotbl)
-- don't care about plug/unplug
	if (iotbl.kind == "status") then
		return;
	end

-- find our destination
	local model = (WM.selected_layer and WM.selected_layer.selected);
	local target = model and model.external;

	if (iotbl.mouse) then
		if (WM.mouse_handler) then
			WM:mouse_handler(iotbl);
			return;
		end

-- apply keymap, check binding state
	elseif (iotbl.translated) then
		iotbl = keyboard_input(iotbl);
	end

-- and forward if valid
	if (not iotbl or not valid_vid(target, TYPE_FRAMESERVER)) then
		return;
	end

-- let the currently selected object apply its coordinate transforms etc.
-- should perhaps move the target input call there as well
	iotbl = model:preprocess_input(iotbl);
	target_input(target, iotbl);
end

function safespaces_display_state(action, id)
	if (action == "reset") then
		system_log("kind=display:status=reset");
		SYMTABLE.mstate = {false, false};

	elseif (action == "added") then
		local name = suppl_display_name(id);
		if not name then
			system_log("kind=display:status=error:" ..
				"message=couldn't parse EDID for " .. tostring(id));
			return;
		end
		system_log(string.format("kind=display:status=added:id=%d:name=%s", id, name));
		known_displays[id] = name;
-- if we are waiting for this display, then go for it
		display_action( name, id );

-- plug / unplug is not really handled well now
	elseif (action == "removed") then
		system_log(string.format("kind=display:status=removed:id=%d", id));
		known_displays[id] = nil;
	else
		system_log(string.format("kind=display:status=" .. action));
	end
end

function VRES_AUTORES(w, h, vppcm, flags, source)
	SYMTABLE.mstate[1] = false;
	SYMTABLE.mstate[2] = false;

	if not WM.dev then
		system_log("kind=display:status=autores_fail:message=no device");
		return;
	end


	resize_video_canvas(w, h);


	if (WM.vr_state and valid_vid(WM.vr_state.combiner)) then
		image_resize_storage(WM.vr_state.combiner, w, h);
		WM.vr_state:relayout();
		map_video_display(WM.vr_state.combiner, 0);
	else
		map_video_display(preview, 0);
	end

	camtag_model(
		WM.camera, 0.01, 100.0, 45.0, w/h, true, true, 0, surf);
end