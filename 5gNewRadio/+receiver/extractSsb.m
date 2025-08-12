function [ssbSymbols] = extractSsb(rxWave, timingOffset, scsSsb, ...
    sampleRate, fc)
    nRbSsb = 20;
    nSlot = 0;
    rxGrid = nrOFDMDemodulate(rxWave(1 + timingOffset : end), nRbSsb, ...
        scsSsb, nSlot, 'SampleRate', sampleRate, 'CarrierFrequency', fc);
    ssbSymbols = rxGrid(:, 2:5, :);
end
