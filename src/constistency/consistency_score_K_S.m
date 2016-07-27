function[] = consistency_score_K_S (K, S, metric)
disp([num2str(K) ' observers in subset, ' num2str(S) ' splits, using ' metric])
cd ('~/predicting_consistency/data/MIT/DatabaseCode/')
%Run from DatabaseCode folder
folder = '~/predicting_consistency/data/MIT/ALLSTIMULI/';
P = 6; % comes from readme in database code folder
M = 10;

if nargin == 0
    K = 5;
    S = 5;
end

fixationdir = '~/predicting_consistency/data/MIT/ALLFIXATIONMAPS/';
fixPtfiles = filePaths(fixationdir, '*_fixPts.jpg');
fixmapfiles = filePaths(fixationdir, '*_fixMap.jpg');
users = {'CNG', 'ajs', 'emb', 'ems', 'ff', 'hp', 'jcw', 'jw', 'kae', 'krl', 'po', 'tmj', 'tu', 'ya', 'zb'};
% Cycle through all images
files = dir(strcat(folder, '/*.jpeg'));
score = zeros(length(files), S);
tic
for i = 1:length(files)
    disp(['on image ' num2str(i)])
    filename = files(i).name;
    % Get image
    img = imread(fullfile(folder, filename));
    dims = size(img);
    for j = 1:S
        disp(['iteration ' num2str(j)])
        heldout = randsample(length(users), K);
        one = zeros(dims(1:2));
        all_but_one = zeros(dims(1:2));
        %compute fixation one on other users
        for k = 1:length(users)
            user = users{k};
            idx = fixation_idx(user, filename, P, dims);
            if ismember(k, heldout)
                one(idx) = 1;
            else
                all_but_one(idx) = 1;
            end
        end
        gauss = fspecial('gaussian', 149, 35);
        all_but_one_map = normalise_map(imfilter(all_but_one, gauss));
        one_map = normalise_map(imfilter(one, gauss));

        % get othermap for use in shuffled AUC, also of size s
        otherMap = othermap(fixPtfiles, M, i, dims(1:2));
        switch metric
            case 'S'
                score(i,j)= similarity(one_map, all_but_one_map);
            case 'sROC_borji'
                score(i,j) = AUC_shuffled(one_map, all_but_one, otherMap);
            case 'CC'
                score(i,j) = CC(one_map,all_but_one_map);
            otherwise
                error([metric 'is not a known metric'])
        end
        
    end

end
if  ~exist('~/predicting_consistency/outputs/consistencies/MIT/','dir')
    mkdir('~/predicting_consistency/outputs/consistencies/MIT/');
end

    save(['~/predicting_consistency/outputs/consistencies/MIT/' metric '-K_' num2str(K) '-S_' num2str(S) '.mat'],...
        'score');
disp(['Saved results to file'])
toc
end
function [idx] = fixation_idx(user,filename,S,dims)
% Get eyetracking data for this image
datafolder = ['~/predicting_consistency/data/MIT/DATA/' user];
datafile = strcat(filename(1:end-4), 'mat');
stimFile = load(fullfile(datafolder, datafile));
stimFile = stimFile.([datafile(1:end-4)]);
eyeData = stimFile.DATA(1).eyeData;
[eyeData Fix Sac] = checkFixations(eyeData);
s=find(eyeData(:, 3)==2, 1)+1; % to avoid the first fixation
eyeData=eyeData(s:end, :);
fixs = find(eyeData(:,3)==0);

fix_locations = floor(Fix.medianXY(1:end,:));
fix_locations = reshape(fix_locations,[], 2);
fix_locationsX = fix_locations(:,1);
fix_locationsY = fix_locations(:,2);
fix_locationsX = fix_locationsX(fix_locationsX <= dims(2));
fix_locationsY = fix_locationsY(fix_locationsX <= dims(2));
fix_locationsX = fix_locationsX(fix_locationsY <= dims(1));
fix_locationsY = fix_locationsY(fix_locationsY <= dims(1));
fix_locationsX = fix_locationsX(fix_locationsX >  0);
fix_locationsY = fix_locationsY(fix_locationsX >  0);
fix_locationsX = fix_locationsX(fix_locationsY >  0);
fix_locationsY = fix_locationsY(fix_locationsY >  0);
fix_locations = [fix_locationsX, fix_locationsY];
if S < length(fix_locations)
    fix_locations = fix_locations(1:S,:);
end
idx = sub2ind(dims(1:2), fix_locations(:,2)', fix_locations(:,1)');
end