%K = chi2dist(X1,X2);
%
% computes 0.5 * chi2(X1,X2)

function K = chi2dist(X1,X2);

warning off
addpath ~/software/mpi-chi2
warning on

stepsize = 500;

if ~exist('X2','var')
    X2 = [];
end
	   
if numel(X2) == 0
    X1 = X1';
    try
	K = 0.5*chi2_mex(full(X1),full(X1));
    catch
	% compute the matrix in batches
	K = zeros(size(X1,2),size(X1,2));
	for ind1=0:stepsize:size(X1,2)
	    indx1 = ind1 + (1:stepsize);
	    indx1(indx1>size(X1,2)) = [];
	    if ~numel(indx1), continue; end
	    x1 = full(X1(:,indx1));
	    for ind2=0:stepsize:size(X1,2)
		indx2 = ind2 + (1:stepsize);
		indx2(indx2>size(X1,2)) = [];
		if ~numel(indx2), continue; end
		x2 = full(X1(:,indx2));
		K(indx1,indx2) = chi2_mex(x1,x2);
	    end
	end
	K = 0.5 * K;
    end
else
    try
	K = 0.5*chi2_mex(full(X1'),full(X2'));
    catch
	% compute the matrix in batches
	K = zeros(size(X1,1),size(X2,1));
	for ind1=0:stepsize:size(X1,1)
	    indx1 = ind1 + (1:stepsize);
	    indx1(indx1>size(X1,1)) = [];
	    if ~numel(indx1), continue; end
	    x1 = full(X1(indx1,:)');
	    indx1
	    for ind2=0:stepsize:size(X2,1)
		indx2 = ind2 + (1:stepsize);
		indx2(indx2>size(X2,1)) = [];
		if ~numel(indx2), continue; end
		x2 = full(X2(indx2,:)');
		K(indx1,indx2) = chi2_mex(x1,x2);
	    end
	end
	K = 0.5 * K;
    end
end

