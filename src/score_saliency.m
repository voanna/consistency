function [] = score_saliency(model)
% locations of folders
imdir = '~/voanna_scratch/data/MIT/ALLSTIMULI/';
salmapdir = ['~/voanna_scratch/maps/MIT/' model '/'];
fixationdir = '~/voanna_scratch/data/MIT/ALLFIXATIONMAPS/';
fixationptdir = '~/voanna_scratch/data/MIT/ALLFIXATIONMAPS/';

% directory to save these metrics
accuracydir = ['~/voanna_scratch/outputs/accuracies/MIT/'];
if  ~exist(accuracydir,'dir')
    mkdir(accuracydir);
end

% Compute metrics for all salmaps
NUMIMGS = 1003;
M = 10;

% create complete path to images
imgfiles = filePaths(imdir, '*.jpeg');
salmapfiles = filePaths(salmapdir, '*.jpg');
fixMapfiles = filePaths(fixationdir, '*_fixMap.jpg');
fixPtfiles = filePaths(fixationptdir, '*_fixPts.jpg');

% initialize arrays to store scores
AUC_shuffled_scores        = zeros(NUMIMGS, 1);
crossCorrelation_scores    = zeros(NUMIMGS, 1);
similarity_scores          = zeros(NUMIMGS, 1);

for i = 1:NUMIMGS
    disp(['Image ' num2str(i) ' of ' num2str(NUMIMGS)])
    % read in necessary images
    img = imread(imgfiles{i});
    salmap = imread(salmapfiles{i});
    fixMap = imread(fixMapfiles{i});
    fixPt = imread(fixPtfiles{i});
    
    % resize all images to size of img
    s = size(img);
    s = s(1:2); % to ignore color dimension
    salmap = im2double(imresizepad(salmap, s, 'nearest', 0));
    fixPt = im2double(fixPt); % should be same size as img already
    fixMap = im2double(fixMap); % should be same size as img already
    
    % get othermap for use in shuffled AUC, also of size s
    otherMap = othermap(fixPtfiles, M, i, s);
    
    % compute all metrics we want
    AUC_shuffled_scores(i) = AUC_shuffled(salmap, fixPt, otherMap);
    crossCorrelation_scores(i) = CC(salmap, fixMap);
    similarity_scores(i) = similarity(salmap, fixMap);
    
end
save([accuracydir model '_scores.mat'], 'imgfiles', ...
    'AUC_shuffled_scores',...
    'crossCorrelation_scores',...
    'similarity_scores'...
    ); 
disp(['Saving to ' accuracydir model '_scores.mat'])
disp(['Done!'])
end
