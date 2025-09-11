function [mib, mibParsed] = decodeMib(trblk, nSsbHalfFrame, sfn4lsb, msbidxoffset)
    mib = fromBits(MIB, trblk(2:end));

    if (nSsbHalfFrame == 64)
        scsCommon = [60 120];
    else
        scsCommon = [15 30];
    end

    mibParsed = struct();
    mibParsed.NFrame = mib.systemFrameNumber * 2^4 + bit2int(sfn4lsb, 4);
    mibParsed.SubcarrierSpacingCommon = scsCommon(mib.subCarrierSpacingCommon + 1);
    mibParsed.kSsb = msbidxoffset + mib.ssb_SubcarrierOffset;
    mibParsed.DMRSTypeAPosition = 2 + mib.dmrs_TypeA_Position;
    mibParsed.PDCCHConfigSIB1 = info(mib.pdcch_ConfigSIB1);
    mibParsed.CellBarred = mib.cellBarred;
    mibParsed.IntraFreqReselection = mib.intraFreqReselection;
end