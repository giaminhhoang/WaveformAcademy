function [crcBch, trblk, sfn4lsb, msbidxoffset] = pbchDecode(...
    ssbGrid, ncellid, hest, nVar, iSsb, nSsbHalfFrame)
    % Extract PBCH Symbols
    [pbchIndices, pbchIndicesInfo] = nrPBCHIndices(ncellid);
    pbchRx = nrExtractResources(pbchIndices, ssbGrid);

    % PBCH Equalization and CSI Calculation
    pbchHest = nrExtractResources(pbchIndices, hest);
    [pbchEq, csi] = nrEqualizeMMSE(pbchRx, pbchHest, nVar);
    Qm = pbchIndicesInfo.G / pbchIndicesInfo.Gd;
    csi = repmat(csi.', Qm, 1);
    csi = reshape(csi, [], 1);

    figure;
    plot(pbchEq, 'o');
    xlabel('In-Phase'); ylabel('Quadrature');
    m = max(abs([real(pbchEq(:)); imag(pbchEq(:))])) * 1.1;
    axis([-m m -m m]);

    % PBCH Demodulation & Descrambling
    if nSsbHalfFrame == 4
        v = mod(iSsb, 4);
    else
        v = iSsb;
    end
    pbchBits = nrPBCHDecode(pbchEq, ncellid, v, nVar);
    pbchBits = pbchBits .* csi;

    % Decode BCH
    polarListLength = 8;
    [~, crcBch, trblk, sfn4lsb, ~, msbidxoffset] = ...
        nrBCHDecode(pbchBits, polarListLength, nSsbHalfFrame, ncellid);
    if (nSsbHalfFrame == 64)
        msbidxoffset = 0;
    else
        msbidxoffset = msbidxoffset * 16;
    end
end