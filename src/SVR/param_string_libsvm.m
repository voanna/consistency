function [svm_options] = param_string_libsvm(param)
% generates a string to input into the svmtrain function
svm_options = [];

% if option not set - will be default
fields = fieldnames(param);
for i = 1:numel(fields)
  svm_options = [svm_options ' -'  ...
      fields{i} blanks(1) num2str(param.(fields{i}))];
end