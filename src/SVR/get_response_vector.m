function [response_vector, mu, sigma] =  get_response_vector(model, metric, response_vector_fun)

words = strsplit(model, '-');
if strcmp(words(1), 'CC')|| strcmp(words(1), 'S') || strcmp(words(1), 'sROC_borji')
  
        scores = load(['~/predicting_consistency/outputs/consistencies/MIT/' model '.mat']);
        accuracy_scores = mean(scores.score, 2);
else
    switch model
        case {'AIM_mit','AWS_mit','BMS_mit','COVSAL_mit', 'FES_mit','GBVS_mit'...
            'GAUSS_mit','ITTI_mit','JUDD_mit','OBJ_mit','MRCNN_mit', ...
            'SALICON_mit', 'SUN_mit'}
        words = strsplit(model, '_');
        model = words(1);
        acc_matfile = ['~/predicting_consistency/outputs/accuracies/MIT/'  model{1} '_scores.mat'];
        accMAT = load(acc_matfile);
        words = strsplit(metric, '-');
        metric = words(2);
        accuracy_scores = accMAT.(metric{1});
        case {
            'AIM_pascal', ...
            'AWS_pascal', ...
            'BMS_pascal',...
            'DVA_pascal',...
            'GBVS_pascal',...
            'ITTI_pascal',...
            'SIG_pascal',...
            'SUN_pascal',...
            'SALICON_pascal'
            }       
            words = strsplit(model, '_');
            model = words(1);
            acc_matfile = ['~/predicting_consistency/outputs/accuracies/pascal/'  model{1} '_scores.mat'];

            words = strsplit(metric, '-');
            metric = words(2);
            accuracy_scores = accMAT.(metric{1});
            accMAT = load(acc_matfile);
            accuracy_scores = accMAT.(metric);
    end
end
if strcmp(func2str(response_vector_fun), 'zscore')
    mu = mean(accuracy_scores);
    sigma = std(accuracy_scores);
    response_vector = (accuracy_scores - mu)/sigma;
    assert(isequal(response_vector, response_vector_fun(accuracy_scores)))
end
end