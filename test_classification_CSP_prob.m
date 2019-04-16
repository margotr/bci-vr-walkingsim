%clean;
dataSourcePath = 'Data\';
dataSourceName = 'subject4';
load([dataSourcePath,dataSourceName]);
disp(['Analysis of ',dataSourceName,' - Parallel CSP']);

nTrials = length(collectedEvents);
shuffIdx = randperm(nTrials);
shuffData = collectedData(:,:,shuffIdx);
collectedEvents = collectedEvents(shuffIdx);

mask = linspace(0,1,nTrials);
trMask = mask < 0.70; % 80%
testMask = ~trMask; % 20%

trData = shuffData(:,:,trMask);
trLabel = collectedEvents(trMask);

testData = shuffData(:,:,testMask);
testLabel = collectedEvents(testMask);

[models, classValues] = train_classification_CSP_prob(trData, trLabel);
nClasses = length(classValues);
%%% test of the single models
for modIdx = 1:nClasses
    myModel = models{modIdx};
    myClass = classValues(modIdx);
    [result, myProb, ~] = applyCSP(myModel, testData);
    cMat = zeros(2);
    for trIdx = 1:length(result)
        if result(trIdx) == 0 %classified as main class
            if testLabel(trIdx) == myClass
                cMat(1,1) = cMat(1,1)+1;
            else
                cMat(1,2) = cMat(1,2)+1;
            end
        else
            if testLabel(trIdx) == myClass
                cMat(2,1) = cMat(2,1)+1;
            else
                cMat(2,2) = cMat(2,2)+1;
            end
        end
    end
    fprintf('Model for class %d:\n',myClass);
    disp(cMat);
    acc = trace(cMat)/sum(sum(cMat));
    fprintf('Accuracy %.2f%%\n\n',acc*100);
end

probs = 0:0.001:0.5;
bestConfMatrix = NaN(nClasses);
bestAcc = 0;
roc = zeros(2,length(probs));
bestThRoc = 0;
bestThRocIdx = 1;
bestThLength = inf;
for thIdx = 1:length(probs)
    predictedClass = apply_classification_CSP_prob(testData, models, classValues,probs(thIdx));

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
    falsePositive = sum(confMatrix(1,2:end))/sum(sum(confMatrix(:,2:end)));
    truePositive = confMatrix(1,1)/sum(confMatrix(:,1));
    roc(1,thIdx) = falsePositive;
    roc(2,thIdx) = truePositive;
    acc = trace(confMatrix)/sum(sum(confMatrix));
    rocLength = norm([falsePositive, truePositive]- [0 1], 2);
    if rocLength < bestThLength
        bestThLength = rocLength;
        bestThRoc = probs(thIdx);
        bestThRocIdx = thIdx;
        
        bestAcc = acc;
        bestConfMatrix = confMatrix;
    end
end
figure;
plot(roc(1,:),roc(2,:),'-',roc(1,bestThRocIdx),roc(2,bestThRocIdx),'ro',[0 1],[0 1],'r--',[0 roc(1,bestThRocIdx)],[1 roc(2,bestThRocIdx)],'g--');
title('ROC baseline');
xlabel('FPR');
ylabel('TPR');
xlim([0 1]);
ylim([0 1]);
disp('real classes');
disp(classValues);
disp(bestConfMatrix);
fprintf('Accuracy of %.2f%%\n',bestAcc*100);
fprintf('Threshold for ROC %.3f\n',bestThRoc);
