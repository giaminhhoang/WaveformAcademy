function cfg = ssb(fc, bw)
    cfg = nrWavegenSSBurstConfig;
    cfg.TransmittedBlocks = [1 1 0 1 0 0 0 1];
    cfg.Period = 20;
    cfg.DMRSTypeAPosition = 3;
    cfg.PDCCHConfigSIB1 = 0;

    cfg.BlockPattern = 'Case B';
    scs = utils.ssbSubcarrierSpacing(cfg.BlockPattern);
    cfg.SubcarrierSpacingCommon = scs;

    raster = utils.syncRaster(fc / 1e6, bw, scs);
    offset = raster(abs(raster) == min(abs(raster)));
    u = log2(scs / 15);
    center = (utils.maxTransBwConfig(bw, scs) - 20) / 2 * (u + 1);
    offsetCoarse = floor(offset / 12 * (u + 1));

    cfg.NCRBSSB = center + offsetCoarse;
    cfg.KSSB = (offset - offsetCoarse * 12 / (u + 1)) * 2;
end

