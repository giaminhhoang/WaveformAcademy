function cfg = bwp(scs, nSizeBwp)
    cfg = nrWavegenBWPConfig;
    cfg.SubcarrierSpacing = scs;
    cfg.NSizeBWP = nSizeBwp;
    cfg.NStartBWP = 0;
end

