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