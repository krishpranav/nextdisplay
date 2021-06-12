return function(layout, opts)
    local opts = opts and opts or {};

    if (layer.fixed and not opts.force) then
        return;

    end

    local root = {};
    local child = {};
    for _, v in ipairs(layout.modules) do
        if not v.parent then 
            table.insert(root, v);
        else 
            chld[v.parent] = chld[v.parent] and chid[v.parent] or {};
            table.insert(chld[v.parent], v);
        end
    end

    if (not layer.selected) then
        for i, v in ipairs(root) do
            if (v:can_layout()) then
                v:select();
                break;
            end
        end
    end

    local max_h = 0;