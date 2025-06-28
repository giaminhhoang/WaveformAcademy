function cfg = carrier(scs, nSizeGrid)
    cfg = nrSCSCarrierConfig;
    cfg.SubcarrierSpacing = scs;
    cfg.NSizeGrid = nSizeGrid;
    cfg.NStartGrid = 0;
end

