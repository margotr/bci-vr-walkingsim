function [class] = apply_classification_CSP(data, models, classOrder)
% models is a cell array of CSP models (the output of trainCSP)
% the models will be applied in order, classOrder contains the values of
% the class extracted by each model (output class 1) classOrder must have a
% value more then models in case no classifier fits
class = NaN(1,size(data,3));
for trIdx = 1:size(data,3)
    for modelIdx = 1:length(models)
        myModel = models{modelIdx};
        myClass = classOrder(modelIdx);
        [pred,~,~] = applyCSP(myModel, data(:,:,trIdx));
        if pred == 0
            class(trIdx) = myClass;
            break;
        end
    end
    if isnan(class(trIdx))
        class(trIdx) = classOrder(end);
    end
end
