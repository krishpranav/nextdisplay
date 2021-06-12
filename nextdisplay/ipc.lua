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
