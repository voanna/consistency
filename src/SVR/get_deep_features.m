function [feat] = get_deep_features(dataset, layer, type)
file = ['~/predicting_consistency/outputs/features/' dataset{1} '/' type '/' layer{1} '.mat'];
if ~exist(file, 'file')
    dir = ['~/predicting_consistency/outputs/features/' dataset{1} '/' type '/' layer{1} '/'];
    feature_paths = filePaths(dir, '*.txt');
    s = length(getDeepfeature(feature_paths{1}));
    feat = zeros(numel(feature_paths), s);
    for i = 1:numel(feature_paths)
        feat(i,:) = getDeepfeature(feature_paths{i});
    end
    save(file, 'feat');
else
    feat = load(file);
    feat = feat.feat;
end


