function [hest, nVar, iSsb] = pbchDmrsChanEst(ssbGrid, ncellid)
    dmrsIndices = nrPBCHDMRSIndices(ncellid);

    % Find i_SSB
    dmrsEst = zeros(1, 8);
    refGrid = zeros([240 4]);
    for i = 0 : 7
        refGrid(dmrsIndices) = nrPBCHDMRS(ncellid, i);
        [hest, nest] = nrChannelEstimate(ssbGrid, refGrid, ...
            'AveragingWindow', [0 1]);
        dmrsEst(i + 1) = 10 * log10(mean(abs(hest(:).^2)) / nest);
    end
    iSsb = find(dmrsEst == max(dmrsEst)) - 1;

    % Channel Estimation Using PBCH DM-RS and SSS
    sssIndices = nrSSSIndices;
    refGrid(dmrsIndices) = nrPBCHDMRS(ncellid, iSsb);
    refGrid(sssIndices) = nrSSS(ncellid);
    [hest, nVar, ~] = nrChannelEstimate(ssbGrid, refGrid, ...
        'AveragingWindow', [0 1]);
end