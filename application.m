function application(hdr, buffhost, buffport, calibrationDataPath)

buffer('con',[],buffhost,buffport);

load(calibrationDataPath,'collectedData','collectedEvents','electrodes','reference');

% train the classifier
[modelsProb, classValuesProb] = train_classification_CSP_prob(collectedData, collectedEvents);
lastPredictions = zeros(1,11); %starts with a majotity of baselines
currCommand = mode(lastPredictions);
message = '';

segmLen = round(0.25*hdr.fSample);%250ms
stat = buffer('wait_dat',[1 Inf 1000],buffhost,buffport);
curr = stat.nSamples;

myFig = figure;
tic();
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
    pause(0.01);
    if ~isempty(reference)
        refSig = d.buf(reference,:);
        newDat = newDat - refSig;
    end

    fprintf('Class: ');
    predictedProb = apply_classification_CSP_prob(newDat, modelsProb, classValuesProb, 0.23);
    lastPredictions(1:end-1) = lastPredictions(2:end);
    lastPredictions(end) = predictedProb;
    newCommand = mode(lastPredictions);
    switch newCommand %uses the most frequent class predicted in the last period (basically it is a low pass filter)
        case 0
            message = 'stop';
            fprintf('none');
        case 1
            message = 'left';
            fprintf('left');
        case 2
            message = 'right';
            fprintf('right');
        case 3
            message = 'forward';
            fprintf('forward');
    end
    fprintf('\n');
    figure(myFig);
    histogram(lastPredictions,[-0.5 0.5 1.5 2.5 3.5]);
    ylim([0 length(lastPredictions)]);
    
    %%% send message to Unity %%%
    if (newCommand ~= currCommand || toc() > 30) && toc() > 3%newCommand ~= 0 && 
        tic();
        currCommand = newCommand;
        SendMessageFromMatlab(message);
    end
    
    %Application ends HERE
end
