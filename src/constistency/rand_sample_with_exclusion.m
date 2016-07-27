function [idx] = rand_sample_with_exclusion(range, id_to_exclude, M)
% randomly select M numbers from 1:range, excluding id_to_exclude
% samples drawn without replacement
% idx               array of indices, in the range from 1 to numfiles
% range             integer, samples are drawn from 1:range
% id_to_exclude     idx will not contain this element
% M                 number of samples to draw

idx = [id_to_exclude];
while ismember(id_to_exclude, idx)
    idx = randsample(range,M);
end
end