function [training_instance_matrix] = get_training_matrix(feature)
words = strsplit(feature, '_');
dataset = words(1);
layer = words(2);
if length(words) == 3
    type = words(3);
else
    type = 'whole';
end
training_instance_matrix = get_deep_features(dataset, layer, type);
end
