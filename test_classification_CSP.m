%clean;
dataSourcePath = 'Data\';
dataSourceName = 'subject4';
load([dataSourcePath,dataSourceName]);
disp(['Analysis of ',dataSourceName,' - Cascading CSP']);

%%% experiment removing baseline class
doExperiment = true;
if doExperiment
    collectedData = collectedData(:,:,collectedEvents~=0);
    collectedEvents = collectedEvents(collectedEvents~=0);
    orderIdx = [3 2 1];%forward>right>left
else
    orderIdx = [1 4 2 3];%baseline>forward>left>right
end

classValues = sort(unique(collectedEvents));
nClasses = length(classValues);

nTrials = length(collectedEvents);
shuffIdx = randperm(nTrials);
shuffData = collectedData(:,:,shuffIdx);
collectedEvents = collectedEvents(shuffIdx);

mask = linspace(0,1,nTrials);
trMask = mask < 0.80; % 80%
testMask = ~trMask; % 20%

trData = shuffData(:,:,trMask);
trLabel = collectedEvents(trMask);

testData = shuffData(:,:,testMask);
testLabel = collectedEvents(testMask);

[models, classOrder] = train_classification_CSP(trData, trLabel, orderIdx);
[predictedClass] = apply_classification_CSP(testData, models, classOrder);

confMatrix = zeros(nClasses);
for trIdx = 1:length(predictedClass)
    for realIdx = 1:nClasses
        if testLabel(trIdx) == classValues(realIdx)
            for predIdx = 1:nClasses
                if predictedClass(trIdx) == classValues(predIdx)
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
disp('real classes');
disp(classValues);
disp(confMatrix);

acc = trace(confMatrix)/sum(sum(confMatrix));
fprintf('Accuracy of %.2f%%\n',acc*100);
