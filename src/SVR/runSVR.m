function [C, gamma, p, crl, error, spear] = runSVR(model, metric, kernel, feature, response_vector_fun, name)

[response_vector, mu, sigma] = get_response_vector(model, metric, response_vector_fun);
training_instance_matrix = get_training_matrix(feature);

save_dir = ['~/predicting_consistency/outputs/svr/SVR_Prediction_per_image/' name '/'];
if ~exist(save_dir, 'dir')
    mkdir(save_dir)
end

param.s = 3; % epsilon SVR
param.v = 10; % cross-validation

%   Divide into training and validation
idx = randperm(length(response_vector));
val_idx = idx(1:floor(0.4*length(response_vector)));
tr_idx =  idx(floor(0.4*length(response_vector))+1:end);
switch kernel
    case 'Xi^2'
        param.t = 4; % precomputed Chi^2 kernel
        
        %  Compute Kernels        
        K_train = chi_sq_kernel_training(training_instance_matrix(tr_idx, :));
        K_train = [(1:size(K_train,1))' K_train];
        
        K_val = chi_sq_kernel_testing(training_instance_matrix(tr_idx, :),...
            training_instance_matrix(val_idx, :));
        K_val = [(1:size(K_val,1))' K_val];
        
        %  Set Grid Search Params    
        C_range = -4:2:6;
        gamma_range = 0.5; % not needed to optimize actually
        p_range = -8:2:-1;
       
    case 'RBF'
        param.t = 2; % RBF kernel
        
        %   Normalise Data
        training_instance_matrix = zscore(training_instance_matrix);
        K_train = training_instance_matrix(tr_idx,:);
        K_val = training_instance_matrix(val_idx,:);
        
        %   Find Model Parameters
        %these are defaults from gridregression.py
        C_range = -1:2:6;
        gamma_range = 0:-2:-8;
        p_range = -8:2:-1;
        
    case 'linear'
        param.t = 0; % linear
        training_instance_matrix = zscore(training_instance_matrix);
        K_train = training_instance_matrix(tr_idx,:);
        K_val = training_instance_matrix(val_idx,:);
      
        %   Set gridsearch values
        C_range = -4:2:6;
        gamma_range = 0.5;
        p_range = -8:2:-6;
end

%  Find Model Parameters

[C, gamma, p] = gridsearch_epsSVR(response_vector(tr_idx), K_train, C_range, gamma_range, p_range, param);

param.c = C;
param.p = p;
disp(['C param = ' num2str(C)])
disp(['p param = ' num2str(p)])

% generate new parameter string with best found parameters.
param = rmfield(param, 'v'); % no more cross-validation
svm_options = param_string_libsvm(param);
%   Train Model
svm_model = svmtrain(response_vector(tr_idx), K_train, [, svm_options]);

%   Predict on Validation
[predicted_label, ~, ~] = svmpredict(response_vector(val_idx), K_val, svm_model);

crl = corr(predicted_label, response_vector(val_idx));
spear = corr(predicted_label, response_vector(val_idx), 'type','Spearman')
error = sumsqr(predicted_label - response_vector(val_idx))/length(predicted_label);

save([save_dir model '_' metric '_' kernel '_' feature '_'  func2str(response_vector_fun)], 'predicted_label', 'val_idx', 'mu', 'sigma', 'param');        
end

