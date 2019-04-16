function [models, classValues] = train_classification_CSP_prob(collectedData, collectedEvents)
classValues = sort(unique(collectedEvents));
nClasses = length(classValues);

DataTr = cell(1,nClasses);
for cIdx = 1:nClasses
    myClass = classValues(cIdx);
    DataTr{cIdx} = collectedData(:,:,collectedEvents == myClass);
end

models = cell(1, nClasses);
for modelIdx = 1:nClasses
    mainData = DataTr{modelIdx};
    againstData = [];
    for agIdx = 1:nClasses
        if agIdx ~= modelIdx
            againstData = cat(3, againstData, DataTr{agIdx});
        end
    end
    models{modelIdx} = trainCSP(mainData, againstData, 6);
end
