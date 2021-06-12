local function destroy(ctx)
    if (valid_vid(ctx.anchor)) then 
        delete_image(ctx.anchor);
    end
    mouse_droplistener(ctx);
    ctx.destroy = nil;
end
