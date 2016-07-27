function [K] = chi_sq_kernel_training(Xtrain)
% examples usage is svmtrain(these_labels, [(1:size(K,1))' K], sprintf(' -t 4 -c %f -q -p 0.00001', lc));
Dtrain = chi2dist(Xtrain);
chi = mean(Dtrain(:)).^(-1); %this is for RBF-Chi2
K = exp(-chi*Dtrain);
end

