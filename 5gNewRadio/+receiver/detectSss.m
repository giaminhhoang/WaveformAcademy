function [NID1, ncellid] = detectSss(ssbGrid, NID2)
    sssIndices = nrSSSIndices;
    sssRx = nrExtractResources(sssIndices, ssbGrid);

    sssEst = zeros(1, 336);
    for NID1 = 0 : 335
        ncellid = 3 * NID1 + NID2;
        sssRef = nrSSS(ncellid);
        sssEst(NID1 + 1) = sum(abs(mean(sssRx .* conj(sssRef), 1)) .^ 2);
    end

    NID1 = find(sssEst == max(sssEst)) - 1;
    ncellid = 3 * NID1 + NID2;
end

