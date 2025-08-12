function [freqOffset, cor, NID2] = pssFreqSync(...
    rxWaveform, scs, freqCandidates, rxSampleRate)
    % Parameters
    nid2 = [0, 1, 2];
    fshifts = freqCandidates * scs * 1e3;

    % SSB OFDM Information
    ssbNfft = 256;
    ssbSampleRate = ssbNfft * scs * 1e3;
    nRbSsb = 20;
    ssbOfdmInfo = nrOFDMInfo(nRbSsb, scs, 'SampleRate', ssbSampleRate, ...
        'Nfft', ssbNfft);

    % PSS Reference Grid
    pssFreqInd = nrPSSIndices;
    refGrid = zeros([nRbSsb * 12 2]);

    % Frequency offset and PSS search
    peakValue = zeros(numel(fshifts), length(nid2));
    peakIndex = zeros(numel(fshifts), length(nid2));
    t = (0 : size(rxWaveform, 1) - 1).' / rxSampleRate;
    for fIdx = 1 : numel(fshifts)
        coarseFrequencyOffset = fshifts(fIdx);
        rxWaveformFreqCorrected = rxWaveform .* ...
            exp(-1i * 2 * pi * coarseFrequencyOffset * t);

        rxWaveformDs = resample(rxWaveformFreqCorrected, ...
            ssbSampleRate, rxSampleRate);

        iter = 1;

        for NID2 = nid2
            refGrid(pssFreqInd, 2) = nrPSS(NID2);

            nSlot = 0;
            [~, corr] = nrTimingEstimate(rxWaveformDs, nRbSsb, scs, ...
                nSlot, refGrid, 'SampleRate', ssbSampleRate, 'Nfft', ssbNfft);

            [peakValue(fIdx, iter), peakIndex(fIdx, NID2 + 1)] = max(corr);
            peakIndex(fIdx, iter) = peakIndex(fIdx, NID2 + 1) + ...
                ssbOfdmInfo.SymbolLengths(1);
            iter = iter + 1;
        end
    end

    [fIdx, NID2] = find(peakValue == max(peakValue(:)));
    coarseFrequencyOffset = fshifts(fIdx);
    cor = peakValue;
    NID2 = nid2(NID2);

    % Apply CFO Correction and Downsample
    rxWaveformFreqCorrected = rxWaveform .* exp(-1i * 2 * pi * ...
        coarseFrequencyOffset * t);
    rxWaveformDs = resample(rxWaveformFreqCorrected, ssbSampleRate, rxSampleRate);

    % Fractional CFO
    offset = peakIndex(fIdx, NID2 + 1) - 1;
    fineFrequencyOffset = fracCfo(...
        rxWaveformDs(1 + offset : end, :), ssbOfdmInfo);

    freqOffset = coarseFrequencyOffset + fineFrequencyOffset;
    freqOffset = freqOffset / scs / 1e3;
end

function frequencyOffset = fracCfo(waveform, ofdmInfo)
    % OFDM Information
    nCpShort = ofdmInfo.CyclicPrefixLengths(2);
    nfft = ofdmInfo.Nfft;
    nSamplesSymbol = nCpShort + nfft;

    % Delayed Correlation
    delayed = [zeros(nfft, 1); waveform(1 : end - nfft)];
    cpProduct = waveform .* conj(delayed);

    % Moving Sum Filter
    cpXCorr = filter(ones([nCpShort 1]), 1, cpProduct);

    % SSB Integration
    y = cpXCorr;
    cpXCorrDelayed = cpXCorr;
    for k = 1 : 3
        cpXCorrDelayed = [zeros(nSamplesSymbol, 1); ...
            cpXCorrDelayed(1 : end - nSamplesSymbol)];
        y = y + cpXCorrDelayed;
    end

    % Extracting the CFO Estimate
    cpCorrIndex = 4 * nSamplesSymbol;
    scs = ofdmInfo.SampleRate / ofdmInfo.Nfft;
    frequencyOffset = scs * angle(mean(y(cpCorrIndex, :))) / (2 * pi);
end
