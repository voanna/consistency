% K = chi2(X1,X2,kerParam,K);
%
% computes exp( -(1/kerParam) * chi2(X1,X2)), cell array output if
% numel(kerParam)>1
% to speed up K=chi2dist(X1,X2) can be given as an argument
function K = chi2(X1,X2,kerParam,K);

if ~exist('kerParam','var')
    kerParam = [];
end

if  ~exist('K','var')
    K = [];
end

warning off
addpath ~/software/mpi-chi2
warning on
if(1)
    if ~numel(K)
	K = chi2dist(X1,X2);
    end
else
    K = zeros(size(X1,1),size(X2,1));

    warning('off', 'MATLAB:divideByZero');
    for i=1:size(X1,2)
	P1=repmat(X1(:,i),1,size(X2,1));
	P2=repmat(X2(:,i)',size(X1,1),1);
	Kcur=((P1-P2).^2) ./ (P1 + P2);
	Kcur(isnan(Kcur))=0;
	K=K+Kcur;
    end
    warning('on', 'MATLAB:divideByZero');

    K=(1/2)*K;
end


if numel(kerParam) > 1
    tK = K;
    K = [];
    for i=1:numel(kerParam)
	K{i}=(exp(-(1/kerParam(i))*tK));
    end
else
    K=exp(-(1/kerParam)*K);
end

