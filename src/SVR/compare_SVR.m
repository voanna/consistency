function [] = compare_SVR(z)
rng(1);
%Save results as
name = '2016-04-10-MIT_CC_sAUC_S_consistency_sAUC_CC_S_for_paper';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% MODELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
models = {'JUDD_mit'};
% In the case of predicting consistency, put the names of the matfiles
% storing the consistency values as the model names
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% SCORE TYPES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
score_types = {'MIT-AUC_shuffled_scores'}%'MIT_crossCorrelation_scores','MIT_similarity_scores'};
% these names are just keys to access the response vectors, so the
% score_type has to also contain whether it's from pascal or MIT, separated
% by a dash
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% KERNELS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kernels = {'Xi^2'}; %can be 'linear' or 'RBF'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FEATURES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
features = {'MIT_conv4'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% NORMS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
norms = {@zscore};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% WHAT TO OPTIMIZE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

combinations = allcomb(1:numel(models), 1:numel(score_types), 1:numel(kernels), 1:numel(features), 1:numel(norms));
disp(['Iter ' num2str(z) ' of ' num2str(length(combinations))])
if  ~exist(['~/predicting_consistency/outputs/svr/' name ],'dir')
    mkdir(['~/predicting_consistency/outputs/svr/' name ]);
end
filename = ['~/predicting_consistency/outputs/svr/' name '_setup.mat'];
if ~exist(filename, 'file')
    save(filename,...
        'models', 'score_types', 'kernels', 'features', 'norms', 'combinations');
end


i = combinations(z, 1);
j = combinations(z, 2);
k = combinations(z, 3);
l = combinations(z, 4);
m = combinations(z, 5);

disp('STARTING NEW ITERATION')
%disp(['Iteration ' num2str(count) ' out of ' num2str(numel(C_param))])
disp([' ']);
disp([models{i} ' ' score_types{j} ' ' features{l} ' ' kernels{k}  ' ' func2str(norms{m})]);
%Actually run the SVR
[C, gamma, p, crl, error, spear] = runSVR(models{i}, score_types{j}, kernels{k}, features{l}, norms{m}, name);

%save best params
C_param = C;
gamma_param = gamma;
p_param = p;
% save error = svr loss, crl = pearson's correlation between predicted and
% true labels, spear is spearman's correlation
Error_performance = error;
Correlation = crl;
SpearCorrelation = spear;

% display status of loop
disp([' ']);
disp([models{i} ' ' score_types{j} ' ' features{l} ' ' kernels{k}  ' ' func2str(norms{m})]);
disp([' ']);
savedir = ['~/predicting_consistency/outputs/svr/' name '/'];
if ~exist(savedir, 'dir')
	mkdir(savedir)
end
save([savedir num2str(z) '.mat'],...
    'C_param', 'gamma_param', 'p_param', 'Correlation', 'Error_performance', 'SpearCorrelation','z');
end
