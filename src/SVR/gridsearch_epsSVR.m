function [best_C, best_gamma, best_p] = gridsearch_epsSVR(training_label_vector, training_instance_matrix, C_range, ...
    gamma_range, p_range, param)
% Finds the best C, gamma, and p parameters for training an epsilon SVR
% with RBF kernel

svm_options = param_string_libsvm(param);
gridsearch_record = struct('correlation', -Inf, 'error', Inf, 'C', 0, 'gamma', 0, 'p', 0);
for C = C_range
    for gamma = gamma_range
        parfor p_range_idx = 1:length(p_range)
            p = p_range(p_range_idx);
            svm_options_upd = [' -c ' num2str(2^C) ' -g ' ...
                num2str(2^gamma), ' -p ', num2str(2^p), ' -q ' svm_options];
            obj_fun = svmtrain(training_label_vector, training_instance_matrix, svm_options_upd);
            
            gridsearch_record = reduce_gridsearch_record(gridsearch_record, ...
                struct(obj_fun, 'C', 2^C , 'gamma', 2^gamma, 'p', 2^p));
        end
    end
end
best_C = gridsearch_record.C;
best_gamma = gridsearch_record.gamma;
best_p = gridsearch_record.p;
end

function [c] = reduce_gridsearch_record(candidate, old)

if candidate.error <= old.error
    c = candidate;
else
    c = old;
end

end