return {
    display = '^Rift/WMHD',
    oversample_w = 1.0,
    oversample_h = 1.0,
    distortion_model = "basic",
    inv_y = true,
-- rift returns a larger width, causing the position to be wrong
    ipd = 1.029
}