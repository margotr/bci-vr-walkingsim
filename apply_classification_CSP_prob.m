function class = apply_classification_CSP_prob(data, models, classValues, probabilityThreshold)
% models is a cell array of CSP models (the output of trainCSP)
% classValues are the lables of each model positive output
if nargin < 3
    error('Too few arguments');
else
    if length(classValues) ~= length(models)
        error('classValues length does not correspond to models length');
    end
end
if nargin < 4
    baselineAsClass = true;
else
    baselineAsClass = false;
end

nClasses = length(classValues);
prob = zeros(size(data,3), nClasses);
if baselineAsClass
    for modelIdx = 1:nClasses
        [~, myProb, ~] = applyCSP(models{modelIdx}, data);
        prob(:,modelIdx) = myProb(:,1);
    end

    class = zeros(1, size(data,3));
    for trIdx = 1:size(data,3)
        currProb = 0;
        currBestClass = NaN;
        for cIdx = 1:nClasses
            if currProb <= prob(trIdx, cIdx)
                currBestClass = classValues(cIdx);
                currProb = prob(trIdx, cIdx);
            end
        end
        class(trIdx) = currBestClass;
    end
else
    for modelIdx = 2:nClasses
        [~, myProb, ~] = applyCSP(models{modelIdx}, data);
        prob(:,modelIdx) = myProb(:,1);
    end

    class = zeros(1, size(data,3));
    for trIdx = 1:size(data,3)
        currProb = 0;
        currBestClass = NaN;
        for cIdx = 1:nClasses
            if currProb <= prob(trIdx, cIdx)
                currBestClass = classValues(cIdx);
                currProb = prob(trIdx, cIdx);
            end
        end
        if currProb < probabilityThreshold
            currBestClass = classValues(1);
        end
        class(trIdx) = currBestClass;
    end
end
end