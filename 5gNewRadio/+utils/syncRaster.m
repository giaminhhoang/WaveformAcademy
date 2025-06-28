function raster = syncRaster(fc, bw, scs)
    % TS 38.104 Table 5.4.3.1-1 (Synchronization raster and numbering)
    % fc  : carrier frequency in MHz
    % bw  : bandwidth in MHz
    % scs : subcarrier spacing in kHz
    raster = [];
    for m = [1, 3, 5]
        raster = [raster, (1 : 2499) * 1.2 + m * 0.05];
    end
    raster = sort(raster);
    raster = [raster, (3000 + (0 : 14756) * 1.44)];
    raster = [raster, (24250.08 + (0 : 4383) * 17.28)];

    raster = raster(fc - bw / 2 < raster);
    raster = raster(raster < fc + bw / 2);
    raster = round((raster - fc) / (scs / 1e3));
end

