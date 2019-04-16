%clean;
dataSourcePath = 'Data\';
dataSourceName = 'subject4';
load([dataSourcePath,dataSourceName]);
disp(['Analysis of ',dataSourceName,' - Neural Network']);

%%% experiment removing baseline class
excludeBaseline = true;
if excludeBaseline
    collectedData = collectedData(:,:,collectedEvents~=0);
    collectedEvents = collectedEvents(collectedEvents~=0);
end

nTrials = length(collectedEvents);
shuffIdx = randperm(nTrials);
shuffData = collectedData(:,:,shuffIdx);
collectedEvents = collectedEvents(shuffIdx);

mask = linspace(0,1,nTrials);
trMask = mask < 0.85; % 85%
testMask = ((mask <= 1) - trMask) == 1; % 15%

trData = collectedData(:,:,trMask);
trLabel = collectedEvents(trMask);

testData = collectedData(:,:,testMask);
testLabel = categorical(collectedEvents(testMask));

trainedNet = train_classification_NN(trData,trLabel);

[YPred,scores] = apply_classification_NN(trainedNet,testData);

classValues = categorical(sort(unique(collectedEvents)));
nClasses = length(classValues);
confMatrix = zeros(nClasses);
for trIdx = 1:length(YPred)
    for realIdx = 1:nClasses
        if testLabel(trIdx) == classValues(realIdx)
            for predIdx = 1:nClasses
                if YPred(trIdx) == classValues(predIdx)
                    confMatrix(predIdx,realIdx) = confMatrix(predIdx,realIdx) + 1;
                else
                    continue;
                end
            end
        else
            continue;
        end
    end
end

disp(classValues);
disp(confMatrix);

acc = trace(confMatrix)/sum(sum(confMatrix));
fprintf('Test accuracy %.2f%%\n',acc*100);
