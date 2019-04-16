function [class, scores] = apply_classification_NN(trainedNet, data)
nTrials =size(data,3);
imData = zeros(size(data,1), size(data,2), 1, nTrials);
for tIdx = 1:nTrials
    imData(:,:,:,tIdx) = data(:,:,tIdx);
end
[class,scores] = classify(trainedNet,imData);
end