function nRb = maxTransBwConfig(bw, scs)
    % TS 38.101 Table 5.3.2-1 (Maximum transmission bandwidth configuration)
    tab = [25  52 79 106 133 160 188 216 242 270 NaN NaN NaN NaN NaN
           11  24 38 51  65  78  92 106  119 133 162 189 217 245 273
           NaN 11 18 24  31  38  44 51   58  65  79  93  107 121 135];
    bws = [5 : 5 : 50, 60 : 10 : 100];
    spacings = [15, 30, 60];
    nRb = tab(spacings == scs, bws == bw);
end

