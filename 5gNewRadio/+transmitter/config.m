function cfg = config(numSubframes, fc, bw)
    cfg = nrDLCarrierConfig;

    % Basic Configuration
    cfg.NCellID = 101;
    cfg.FrequencyRange = 'FR1';
    cfg.NumSubframes = numSubframes;
    cfg.CarrierFrequency = fc;

    % SSB Configuration
    cfg.SSBurst = transmitter.ssb(fc, bw);

    % Carrier & BWP Configuration
    scs = cfg.SSBurst.SubcarrierSpacingCommon;
    nRb = utils.maxTransBwConfig(bw, scs);
    cfg.SCSCarriers{1} = transmitter.carrier(scs, nRb);
    cfg.BandwidthParts{1} = transmitter.bwp(scs, nRb);

    % PDCCH Configuration
    pdcch = nrWavegenPDCCHConfig;
    pdcch.Enable = false;
    cfg.PDCCH{1} = pdcch;

    % PDSCH Configuration
    pdsch = nrWavegenPDSCHConfig;
    pdsch.Enable = false;
    cfg.PDSCH{1} = pdsch;
end

