clean;

myInit;
if tooLong %when using randomly generated signals
    error('The classifiers are not trained for random signals');
end

buffer('con',[],buffhost,buffport);

load('subject4');
% should contain data and events collected during calibration as well as
% electrodes and reference
if ~exist('electrodes','var')
    electrodes = []; %selection of electrodes, empty for all
end
if isempty(electrodes)
    electrodes = 1:hdr.nChans;
end
if ~exist('reference','var')
    reference = []; %reference electrode, empty for no reference
end
displayMode = 'application';

% calls all the trainers
load('model_subject4'); % should contain the model trained with classificationLearner
trainedNet = train_classification_NN(collectedData, collectedEvents);
[modelsCSP, classOrderCSP] = train_classification_CSP(collectedData, collectedEvents, [1 4 2 3]);%baseline>forward>left>right
[modelsProb, classValuesProb] = train_classification_CSP_prob(collectedData, collectedEvents);

segmLen = round(0.25*hdr.fSample);%250ms
myData = zeros(1,5*hdr.fSample);
stat = buffer('wait_dat',[1 Inf 1000],buffhost,buffport);
curr = stat.nSamples;

myFig = figure;
while isvalid(myFig)
    status = buffer('wait_dat',[curr+segmLen+1 Inf 4000],buffhost,buffport); %waits until the right amount of data is arrived (or timeout)
    
    if status.nSamples < curr+segmLen
        fprintf('Buffer stall detected...\n');
        pause(1);
        curr=status.nSamples;
        continue;
    elseif status.nSamples > curr+1*hdr.fSample % missed some samples of data (missing less then 1s is still reasonable)s
        fprintf('Warning: Can''t keep up with the data!\n%d Dropped samples...\n',status.nSamples-segmLen-1-curr);
        curr=status.nSamples - segmLen-1; % jump to the current time
    end
    d = buffer('get_dat',[curr curr+segmLen-1],buffhost,buffport);
    newDat = d.buf(electrodes,:);
    curr = curr+segmLen;
    
    %Application goes HERE
    switch displayMode
        case 'application'
            pause(0);
            if ~isempty(reference)
                refSig = d.buf(reference,:);
                newDat = newDat - refSig;
            end
            
            fprintf('CL: ');
            newDatCL = reshape(newDat,[],1);
            predictedCL = trainedModel.predictFcn(newDatCL');
            switch predictedCL
                case 0
                    fprintf('none');
                case 1
                    fprintf('left');
                case 2
                    fprintf('right');
                case 3
                    fprintf('forw');
            end
            
            fprintf('\tNN: ');
            [predictedNN, ~] = apply_classification_NN(trainedNet, newDat);
            switch predictedNN
                case categorical(0)
                    fprintf('none');
                case categorical(1)
                    fprintf('left');
                case categorical(2)
                    fprintf('right');
                case categorical(3)
                    fprintf('forw');
            end
            
            fprintf('\tCSP: ');
            predictedCSP = apply_classification_CSP(newDat, modelsCSP, classOrderCSP);
            switch predictedCSP
                case 0
                    fprintf('none');
                case 1
                    fprintf('left');
                case 2
                    fprintf('right');
                case 3
                    fprintf('forw');
            end
            
            fprintf('\tProb: ');
            predictedProb = apply_classification_CSP_prob(newDat, modelsProb, classValuesProb, 0.25);
            switch predictedProb
                case 0
                    fprintf('none');
                case 1
                    fprintf('left');
                case 2
                    fprintf('right');
                case 3
                    fprintf('forw');
            end
            fprintf('\n');
    end
    %Application ends HERE
end
