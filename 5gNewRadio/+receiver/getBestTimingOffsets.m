function timingOffsetsFiltered = getBestTimingOffsets(timingOffsets, mag)
    groups_inds = timingOffsets(1 : end - 1) - timingOffsets(2 : end);
    splits = find(groups_inds ~= -1);
    splits = [0; splits; length(timingOffsets)];
    timingOffsetsFiltered = zeros(length(splits) - 1, 1);
    for i = 1 : length(splits) - 1
        to = timingOffsets(splits(i) + 1 : splits(i + 1));
        [~, ind] = max(mag(to));
        ind = ind + splits(i);
        timingOffsetsFiltered(i) = timingOffsets(ind);
    end
end

