local idle_timers = {};
local timers = {};
local wakeups = {};

local clockkey = APPLID .. "_clock_pulse";
local old_clock = _G[clockkey];
if not old_clock then
	old_clock = function() end
end

local idle_count = 0;
local tick_count = 0;
local idle_masked = false;

local leave_fmtstr = "type=idle:state=leave:once=%d:name=%s";
local enter_fmtstr = "type=idle:state=enter:once=%d:name=%s";
local timer_debug = suppl_add_logfn("timers");

local function run_idle_timers()
	for i=#idle_timers,1,-1 do
		local timer = idle_timers[i];


		if (idle_count >= timer.delay and
			not timer.passive and not timer.suspended) then

			if (timer.wakeup) then
				table.insert(wakeups, 1, {timer.wakeup, timer.once, timer.name});
			end

			if (timer.once) then
				table.remove(idle_timers, i);
			else
				timer.passive = true;
			end

			timer_debug(string.format(enter_fmtstr, timer.once and 1 or 0, timer.name));
			timer.trigger();
		end
	end
end

function timer_tick(...)
	tick_count = tick_count + 1;

-- idle timers are more complicated in the sense that they require both
-- a possible 'wakeup' stage and tracking so that they are not called repeatedly.
	if (not idle_masked) then
		idle_count = idle_count + 1;
		run_idle_timers();
	end

	for i=#timers,1,-1 do
		if (not timers[i].suspended) then
			timers[i].count = timers[i].count - 1;
			if (timers[i].count == 0) then
				local hfunc = timers[i].trigger;
				timer_debug(
					string.format("type=normal:once=%d:name=%s",
					timers[i].once and 1 or 0, timers[i].name)
				);
				if (timers[i].once) then
					table.remove(timers, i);
				else
					timers[i].count = timers[i].delay;
				end
				hfunc();
			end
		end
	end

	old_clock(...);
end

_G[clockkey] = timer_tick;

function timer_mask_idle(state)
	if (nil == state) then
		return idle_masked;
	end
	if (true == state) then
		idle_masked = true;
		idle_count = 0;
	elseif (false == state) then
		idle_masked = false;
	end
end

function timer_list(group, active)
	local groups = {timers, idle_timers};
	if (group) then
		if (group == "timers") then
			group = {timers};
		elseif (group == "idle_timers") then
			group = {idle_timers};
		end
	end

	local res = {};
	for i,j in ipairs(groups) do
		for k,l in ipairs(j) do
			if (not l.hidden and (
				active == nil or ((active == true and not l.suspended) or
				(active == false and l.suspended)))) then
				table.insert(res, l.name);
			end
		end
	end

	return res;
end

function timer_reset_idle()
	idle_count = 0;

	for i,v in ipairs(wakeups) do
		timer_debug(string.format(leave_fmtstr, v[2] and 1 or 0, v[3]));
		v[1]();
	end
	local wakeup = {};


	for i,v in ipairs(idle_timers) do
		if (v.passive) then
			v.passive = nil;
		end
	end
	wakeups = {};
end

local function find(name, drop)
	for k,v in ipairs(idle_timers) do
		if (v.name == name) then
			if (drop) then
				table.remove(idle_timers, k);
			end
			return v;
		end
	end
	for k,v in ipairs(timers) do
		if (v.name == name) then
			if (drop) then
				table.remove(timers, k);
			end
			return v;
		end
	end
end

function timer_delete(name)
	find(name, true);
end

function timer_suspend(name)
	local timer = find(name);
	if (not timer) then
		warning("unknown timer " .. name .. " requested");
	end
	timer.suspended = true;
end

function timer_resume(name)
	local timer = find(name);
	if (not timer) then
		warning("unknown timer " .. name .. " requested");
	end

	timer.suspended = false;
end

local function add(dst, name, delay, once, trigger, wtrigger, hidden)
	assert(name);
	assert(delay);
	assert(trigger and type(trigger) == "function");

	local res = find(name, true);
	if (res) then
		res.delay = delay;
		res.once = once;
		res.trigger = trigger;
		res.wakeup = wtrigger;
	else
		res = {
			name = name,
			delay = delay,
			once = once,
			trigger = trigger,
			wakeup = wtrigger
		};
	end
	res.hidden = hidden;
	table.insert(dst, res);

	return res;
end

function timer_add_idle(name, delay, once, trigger, wtrigger, hidden)
	local grp = add(idle_timers, name, delay, once, trigger, wtrigger, hidden);
	grp.kind = "idle";
end

function timer_add_periodic(name, delay, once, trigger, hidden)
	local grp = add(timers, name, delay, once, trigger, hidden);
	grp.count = delay;
	grp.kind = "periodic";
end