function scsSsb = ssbSubcarrierSpacing(blockPattern)
    if all(blockPattern == 'Case A')
        scsSsb = 15;
    elseif all(blockPattern == 'Case B') || all(blockPattern == 'Case C')
        scsSsb = 30;
    end
end

