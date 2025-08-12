function [bw] = availableBandwidths(fs)
    % TS 38.104, Table 5.3.2-1
    bw = [5:5:50, 60:10:100] * 1e6;
    bw = bw(bw < 0.9 * fs);
end