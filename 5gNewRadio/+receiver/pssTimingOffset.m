function [timingOffsets] = pssTimingOffset(rxWave, NID2, scsSSB, ...
    sampleRate, thresholdPSS)
    nrbSSB = 20;
    refGrid = zeros([nrbSSB * 12 2]);
    refGrid(nrPSSIndices, 2) = nrPSS(NID2);

    nSlot = 0;
    [~, mag] = nrTimingEstimate(rxWave, nrbSSB, scsSSB, nSlot, ...
        refGrid, 'SampleRate', sampleRate);

    threshold = max(mag) * thresholdPSS;
    timingOffsets = find(mag >= threshold);
    timingOffsets = receiver.getBestTimingOffsets(timingOffsets, mag) - 1;
end

