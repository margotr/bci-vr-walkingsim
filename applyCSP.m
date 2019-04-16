function [pred,prob,cost] = applyCSP(CSP_Model,data)
%APPLYCSP Summary of this function goes here
%   Detailed explanation goes here
%   model and CSP matrix are the outputs of the function trainCSP
%   data is a 3D matrix [chan x time x trial]
if nargin < 2
    error('Too few arguments');
end

W = CSP_Model.matrix;

% Apply spatial filter to *all trials*
S_hat = nan(size(W, 1), size(data,2), size(data,3));
for trIdx = 1:size(data,3)
    S_hat(:,:,trIdx) =  W*data(:,:,trIdx);
end

% Convert features to power
X = var(S_hat, [], 2);
X = reshape(X, [], size(data,3));
dataX = X';
[pred, prob, cost] = predict(CSP_Model.discriminant, dataX);
end

