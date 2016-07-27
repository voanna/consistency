function [] = assemble_SVR_results(name)
savedir = ['~/predicting_consistency/outputs/svr/' name '/'];
filename = ['~/predicting_consistency/outputs/svr/' name '_setup.mat'];

x = load(filename)
dims = [numel(x.models),...
	 numel(x.score_types),...
	 numel(x.kernels),...
	 numel(x.features),...
	 numel(x.norms)];

MC_param             = zeros(dims);
Mgamma_param         = zeros(dims);
Mp_param             = zeros(dims);
MError_performance   = zeros(dims);
MCorrelation         = zeros(dims);
MSpearCorrelation    = zeros(dims);


for z = 1:size(x.combinations, 1)
    load([savedir num2str(z) '.mat'])
    i = x.combinations(z, 1);
    j = x.combinations(z, 2);
    k = x.combinations(z, 3);
    l = x.combinations(z, 4);
    m = x.combinations(z, 5);
    
    %save best params
    MC_param(i,j,k,l,m) = C_param;
    Mgamma_param(i,j,k,l,m) = gamma_param;
    Mp_param(i,j,k,l,m) = p_param;
    % save errors
    MError_performance(i,j,k,l,m) = Error_performance;
    MCorrelation(i,j,k,l,m) = Correlation;
    MSpearCorrelation(i,j,k,l,m) = SpearCorrelation;
end
C_param = MC_param;
gamma_param = Mgamma_param;
p_param = Mp_param;
Error_performance = MError_performance;
Correlation = MCorrelation;
SpearCorrelation = MSpearCorrelation;
save(['~/predicting_consistency/outputs/svr/' name '.mat'],...
    'C_param', 'gamma_param', 'p_param', 'Correlation', 'SpearCorrelation', 'Error_performance');

end

