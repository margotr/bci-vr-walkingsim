function trainedNet = train_classification_NN(collectedData, collectedEvents, validationPerc)
% validationPerc is a number between 0 and 1 to indicate how muche data use
% to validate the neural network (10% default)
if nargin < 2
    error('Too few input arguments');
elseif nargin == 2
    validationPerc = 0.1; %default
elseif nargin >= 3
    if validationPerc > 1
        validationPerc = 1;
        warning('validationPerc input out of boundaries, it has been changed');
    elseif validationPerc < 0
        validationPerc = 0;
        warning('validationPerc input out of boundaries, it has been changed');
    end
end

classValues = sort(unique(collectedEvents));
nClasses = length(classValues);
categEvents = categorical(collectedEvents);

nTrials = length(collectedEvents);
% shuffle the data
shuffIdx = randperm(nTrials);
shuffData = collectedData(:,:,shuffIdx);
categEvents = categEvents(shuffIdx);
% converts the data to an image format for the neural network
imData = zeros(size(collectedData,1), size(collectedData,2), 1, nTrials);
for tIdx = 1:nTrials
    imData(:,:,:,tIdx) = shuffData(:,:,tIdx);
end

%selects training and validation data from the shuffled array
mask = linspace(0,1,nTrials);
trMask = mask < (1 - validationPerc);
valMask = ((mask <= 1) - trMask) == 1;
if sum(trMask) == 0
    error('You need at least one trial to train the network, try decreasing validationPerc or increasing the collectedData length');
end

trData = imData(:,:,:,trMask);
trLabel = categEvents(trMask);

valData = imData(:,:,:,valMask);
valLabel = categEvents(valMask);

% NN and options adapted directly from the example, can be modified in the future
layers = [
    imageInputLayer([size(collectedData,1) size(collectedData,2) 1])
    
    convolution2dLayer(3,8,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding',1)
    batchNormalizationLayer
    reluLayer
    
    fullyConnectedLayer(nClasses)
    softmaxLayer
    classificationLayer];
options = trainingOptions('sgdm', ...
    'MaxEpochs',10, ...
    'ValidationData',{valData,valLabel}, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

trainedNet = trainNetwork(trData,trLabel,layers,options);
end
