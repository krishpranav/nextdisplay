local function destroy(ctx)
    if (valid_vid(ctx.anchor)) then 
        delete_image(ctx.anchor);
    end
    mouse_droplistener(ctx);
    ctx.destroy = nil;
end

local function own(ctx, vid)
    return ctx.vids[vid] ~= nil;
end


local function over(ctx, vid)
    local tbl = ctx.vids[vid];
    image_color(vid,
        tbl.color_hi[1] * 255,
        tbl.color_hi[2] * 255,
        tbl.color_hi[3] * 255
    );
end

local function click(ctx, void)
    if (not ctx.vids[vid].cmd) then
        return;
    end 
    ctx.vids[vid].cmd();
    if (ctx.autodestroy) then
        ctx:destroy();
    end
end

local function rclick(ctx, vid)
    if (not ctx.vids[vid].cmd) then 
        return;
    end 

    ctx.vids[vid].cmd(true);
    
    if (ctx.autodestroy) then
        ctx:destroy();
    end
end


local function out(ctx, vid)
    local tbl = ctx.vids[vid];
    image_color(vid,
    tbl.color[1] * 255, tbl.color[2] * 255, tbl.color[3] * 255);
end

function uiprim_buttongrid(rows, cols, cellw, cellh, xp, yp, buttons, opts)
    if (#buttons ~= rows * cols or rows <= 0 or cols <= 0 or cellw == 0) then
        return;
    end 

    opts = opts and opts or {};
    local res = {
        destroy = destroy,
        vids = {},
        autodestroy = opts.autodestroy,
        own = own,
        over = over,
        click = click,
        rclick = rclick,
        out = out,
        name "gridbtn_mh"
    };
