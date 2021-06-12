local clients = {};
local control_socket;

local debug_count = 0;
local all_categories = {
    "WARNING",
    "SYSTEM",
    "STDOUT",
    "HMD",
    "WM",
    "CLIENT",
    "TIMERS"
};

local print_override = suppl_add_logfn("stdout");
local warning_override = suppl_add_logfn("warning");

local old_print = print;
print = function(...)
    local tbl = {...};
    local fmtstr = string.rep("%s\t", #tbl);
    local msg = string.format(fmtstr, ...);
    old_print(msg);
end

warning = function(...)
    local tbl = {...};
    local fmtstr = string.rep("%s\t", #tbl);
    local msg = string.format(fmtstr, ...);
    warning_override(msg);
end

local monitor_state = false;
local function toogle_monitoring(on)
    if (on and monitor_state or off and not monitor_state) then
        return;
    end 

    local domains = {
        system = "SYSTEM:",
        config = "CONFIG:",
        stdout = "STDOUT:",
        timers = "TIMERS:",
        hmd = "HMD:",
        wm = "WM:",
        client = "CLIENT:",
        warning = "WARNING:",
    };
