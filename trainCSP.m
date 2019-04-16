function CSP_Model = trainCSP(matrA,matrB,nchan)
%TRAINCSP Summary of this function goes here
%   Detailed explanation goes here
%   matrA and matrB are 3D matrices [chan x time x trial]
%   nchan number of channel to select, can be omitted
%   the classes are assumed to be 0 for matrA and 1 for matrB
if nargin < 2
    disp('Too few arguments');
    return;
elseif nargin == 2
    nchan = 0;%default value, all channels
elseif nargin <= 3
    if (size(matrA,1) ~= size(matrB,1)) || (size(matrA,2) ~= size(matrB,2))
        disp('Dimensions mismatch');
        return;
    end
end

sigmas = zeros(size(matrA,1), size(matrA,1), 2);
for trIdx = 1:size(matrA,3) %mean cov class 0
    sigmas(:,:,1) = sigmas(:,:,1) + cov(matrA(:,:,trIdx)')./size(matrA,3);
end
for trIdx = 1:size(matrB,3) %mean cov class 1
    sigmas(:,:,2) = sigmas(:,:,2) + cov(matrB(:,:,trIdx)')./size(matrB,3);
end

if nchan == 0
    nchan = size(matrA,1);
end
W = csp(sigmas(:,:,1), sigmas(:,:,2), nchan);
CSP_Model.matrix = W;

% Apply spatial filter to *all trials*
S_hat = nan(size(W, 1), size(matrA,2), size(matrA,3)+size(matrB,3));
for trIdx = 1:size(matrA,3)
    S_hat(:,:,trIdx) =  W*matrA(:,:,trIdx);
end
for trIdx = 1:size(matrB,3)
    S_hat(:,:,size(matrA,3)+trIdx) =  W*matrB(:,:,trIdx);
end
% Convert features to power
X = var(S_hat, [], 2);
X = reshape(X, [], size(matrA,3)+size(matrB,3));
Y = [zeros(1,size(matrA,3)), ones(1,size(matrB,3))];
trX = X(:,1:size(matrA,3)+size(matrB,3))';
CSP_Model.discriminant = fitcdiscr(trX, Y);
end

