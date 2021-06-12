return function(layer, opts)
	local opts = opts and opts or {};

	if (layer.fixed and not opts.force) then
		return;
	end

	local root = {};
	local chld = {};
	for _,v in ipairs(layer.models) do
		if not v.parent then
			table.insert(root, v);
		else
			chld[v.parent] = chld[v.parent] and chld[v.parent] or {};
			table.insert(chld[v.parent], v);
		end
	end


	if (not layer.selected) then
		for i,v in ipairs(root) do
			if (v:can_layout()) then
				v:select();
				break;
			end
		end
	end

	local max_h = 0;
	local h_pi = math.pi * 0.5;

	local function getang(phi)
		phi = math.fmod(-phi + 0.5*math.pi, 2 * math.pi);
		return math.deg(phi);
	end

	local dphi_ccw = h_pi;
	local dphi_cw = h_pi;
	local function ptoc(phi)
		return
			-layer.radius * math.cos(phi),
			-layer.radius * math.sin(phi);
	end

	local as = layer.ctx.animation_speed;
	local interp = layer.ctx.animation_interp and
		layer.ctx.animation_interp or INTERP_SMOOTHSTEP;
	local in_first = true;

	for i,v in ipairs(root) do
		local w,h, _ = v:get_size();
		local x = 0;
		local z = 0;
		local ang = 0;
		local mpx, mpz = ptoc(h_pi);


		local p1x = mpx - 0.5 * (w + layer.spacing);
		local p2x = mpx + 0.5 * (w + layer.spacing);

		local p1p = math.atan(p1x / mpz);
		local p2p = math.atan(p2x / mpz);
		local half_len = 0.5 * (p2p - p1p);

		if (in_first) then
			if (v:can_layout()) then
				dphi_ccw = dphi_ccw + half_len;
				dphi_cw = dphi_cw - half_len;
				ang = h_pi;
				x = 0;
				z = -layer.radius;
				in_first = false;
			end

		elseif (i % 2 == 0) then
			if (v:can_layout()) then
				dphi_ccw = dphi_ccw + half_len;
				x,z = ptoc(dphi_ccw);
				ang = getang(dphi_ccw);
				dphi_ccw = dphi_ccw + half_len;
			else
				x,z = ptoc(dphi_ccw);
			end
		else
			if (v:can_layout()) then
				dphi_cw = dphi_cw - half_len;
				x,z = ptoc(dphi_cw);
				ang = getang(dphi_cw);
				dphi_cw = dphi_cw - half_len;
			else
				x,z = ptoc(dphi_cw);
			end
		end

		if (v:can_layout()) then
			if (math.abs(v.layer_pos[1] - x) ~= 0.0001) or
				(math.abs(v.layer_pos[3] - z) ~= 0.0001) or
				(math.abs(v.layer_ang ~= ang) ~= 0.0001) then

				move3d_model(v.vid, v.rel_pos[1] + x, v.rel_pos[2], v.rel_pos[3] + z, as, interp);
				rotate3d_model(v.vid,
					v.rel_ang[1], v.rel_ang[2], v.rel_ang[3] + ang,
					as
				);

				local sx, sy, sz = v:get_scale();
				scale3d_model(v.vid, sx, sy, 1, as, interp);
			end
		end

		v.layer_ang = ang;
		v.layer_pos = {x, 0, z};
	end

	for k,v in pairs(chld) do
		local dz = 0.0;
		local lp = k.layer_pos;
		local la = k.layer_ang;
		local of_y = 0;


		local pw, ph, pd = k:get_size();
		local mf = k.merged and 0.1 or 1;

		of_y = ph;
		for i=1,#v,2 do
			local j = v[i];
			rotate3d_model(j.vid, 0, 0, la, as, interp);
			local sx, sy, sz = j:get_scale();
			scale3d_model(j.vid, sx, sy, 1, as, interp);
			if (j:can_layout()) then
				pw, ph, pd = j:get_size();
				of_y = of_y + mf * (ph + layer.vspacing);
				move3d_model(j.vid, lp[1], lp[2] + of_y, lp[3] - dz, as, interp);
				dz = dz + 0.01;
			end
		end

		local pw, ph, pd = k:get_size();
		of_y = ph + layer.vspacing;
		dz = 0.0;

		for i=2,#v,2 do
			local j = v[i];
			rotate3d_model(j.vid, 0, 0, la, as, interp);
			local sx, sy, sz = j:get_scale();
			scale3d_model(j.vid, sx, sy, 1, as, interp);
			if (j:can_layout()) then
				pw, ph, pd = j:get_size();
				of_y = of_y + mf * (ph + layer.vspacing);
				move3d_model(j.vid, lp[1], lp[2] - of_y, lp[3] - dz, as, interp);
				dz = dz + 0.01;
			end
		end

	end
end