function [models, classOrder] = train_classification_CSP(collectedData, collectedEvents, trainOrder)
% trainOrder is a vector of indices that indicates what is the order of
% classes to compare (classes values computed sorting the unique values of 
% collectedEvents). It must have the length of the classes array (as
% computed before).
classValues = sort(unique(collectedEvents));
nClasses = length(classValues);
if nargin < 2
    error('Too few arguments');
elseif nargin == 2
    trainOrder = 1:nClasses;
else
    if length(trainOrder) ~= nClasses
        error('trainOrder''s length should contiain all and only the indexes up to the number of classes');
    end
    if any(sort(trainOrder) ~= 1:nClasses)
        error('trainOrder does not include all classes');
    end
end

DataTr = cell(1,nClasses);
for cIdx = 1:nClasses
    myClass = classValues(cIdx);
    DataTr{cIdx} = collectedData(:,:,collectedEvents == myClass);
end

classOrder = classValues(trainOrder);
models = cell(1,nClasses-1);
for modelIdx = 1:nClasses-1
    classIdx = trainOrder(modelIdx);
    mainData = DataTr{classIdx};
    againstData = [];
    for agIdx = modelIdx+1:nClasses
        againstData = cat(3, againstData, DataTr{trainOrder(agIdx)});
    end
    models{modelIdx} = trainCSP(mainData, againstData, 6);
end
