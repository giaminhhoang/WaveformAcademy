function [str] = rand_str(n_characters)
    characters = ['a':'z' 'A':'Z' '0':'9'];
    str = characters(randi(numel(characters), 1, n_characters));
end

