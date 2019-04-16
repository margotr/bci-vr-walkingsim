function [calibratedDataPath] = calibration(hdr, buffhost, buffport, electrodes, reference)

if nargin < 3
    disp('too few arguments');
    return;
elseif nargin < 4
    electrodes = [];
    reference = [];
elseif nargin < 5
    reference = [];
end
calibratedDataPath = [];

disp('Calibrating');

Fs = hdr.fSample; %it reads 512 with BioSemi instead of 2048

nRepetitions = 15;
sampleDuration = 0.25;% s
sampleOverlap = 0.5;% 50%
baselineDuration = 3/sampleDuration;% samples
eventDuration = 4/sampleDuration;% samples

sampleLength = round(sampleDuration*Fs);
sampleDiffLength = round((1-sampleOverlap)*sampleDuration*Fs);
% baselineLength = baselineDuration*sampleLength;
% eventLength = eventDuration*sampleLength;

if isempty(electrodes)
    disp('all electrodes');
    electrodes = 1:hdr.nChans;
end
if isempty(reference)
    disp('no reference');
end

events = {'left','right','forward'};
%0 for baseline
nEvents = length(events);
dispOrder = zeros(1,nEvents*nRepetitions);
for rIdx = 1:nRepetitions
    dispOrder((rIdx-1)*nEvents+1:rIdx*nEvents) = randperm(nEvents);
end

myFig = figure();
axes();
initFig(myFig);

collectedData = [];%electrode x sampleDuration x trial
collectedEvents = [];%1 x trial
curr = 0;
while curr<sampleLength-sampleDiffLength
    stat = buffer('wait_dat',[1 Inf 1000],buffhost,buffport);
    curr = stat.nSamples;
    pause(sampleDuration);
end

isBaseline = true;
targetNumSamp = baselineDuration;
blockIdx = 1;
eventIdx = 1;
trialIdx = 0;
collecting = true;
tic();
while collecting && isvalid(myFig)
    %this is quite a stupid way, but I'm in a hurry
    if blockIdx == 1
        toc();
        printStim(isBaseline,events{dispOrder(eventIdx)},myFig);%the baseline input overrides the event
        tic();
    end
    
    stat = buffer('wait_dat',[curr+sampleDiffLength, Inf, 1000],buffhost,buffport);
    if stat.nSamples<curr+sampleDiffLength
        disp('Buffer stall...');
        pause(1);
        curr = stat.nSamples;
        continue;
    end
    d = buffer('get_dat',[curr-(sampleLength-sampleDiffLength)+1 curr+sampleDiffLength],buffhost,buffport);
    if isBaseline
        collectedEvents = [collectedEvents, 0]; %#ok<AGROW>
    else
        collectedEvents = [collectedEvents, dispOrder(eventIdx)]; %#ok<AGROW>
    end
    newDat = d.buf(electrodes,:);
    if ~isempty(reference)
        refSig = d.buf(reference,:);
        newDat = newDat-refSig;
    end
    collectedData(:,:,trialIdx+1) = newDat; %#ok<AGROW>
    trialIdx = trialIdx+1;
    curr = curr+sampleDiffLength;
    pause(0);
    
    blockIdx = blockIdx+(1-sampleOverlap);
    if blockIdx > targetNumSamp
        if isBaseline % from baseline to event
            isBaseline = false;
            targetNumSamp = eventDuration;
        else % from event to baseline
            isBaseline = true;
            targetNumSamp = baselineDuration;
            eventIdx = eventIdx+1;
        end
        blockIdx = 1;
    end
    if eventIdx > length(dispOrder)
        collecting = false;
        close(myFig);
        disp('Calibration data collection terminated');
    end
end

% organize data for classificationLearner
myLabelledData = reshape(collectedData,[],size(collectedData,3));
myLabelledData = [collectedEvents; myLabelledData];
myLabelledData = myLabelledData'; %saves time to use data columnwise

nowClock = clock;
dateString = [num2str(nowClock(3)),'-',num2str(nowClock(2)),'-',num2str(nowClock(1)),'_',num2str(nowClock(4)),'-',num2str(nowClock(5))];
doSave = questdlg('Do you want to save this calibration data?', ...
    'Save', ...
    'Yes','No','Yes');

if strcmp(doSave,'Yes')
    [fileName, pathName] = uiputfile('*.mat','Save',['outputCalibration_',dateString,'.mat']);
    if ischar(fileName)
        save([pathName, fileName],'collectedData','collectedEvents','myLabelledData','electrodes','reference');
        calibratedDataPath = [pathName, fileName];
    end
end
end


function initFig(myFig)
unit = myFig.Units;
myFig.Units = 'normalized';
myFig.Position([1,3]) = [0 1]; %width setting
myFig.OuterPosition([2,4]) = [0 1]; %height setting
myFig.Units = unit;
myFig.Color = [0 0 0];
myFig.ToolBar = 'none';

myAxes = myFig.Children;
myAxes.Units = 'normalized';
myAxes.Position = [0.45 0.45 0.1 0.1];
newPos = myFig.Position;
newH = myAxes.Position(4);
oldW = myAxes.Position(3);
newW = newH*newPos(4)/newPos(3);
myAxes.Position(3) = newW;
myAxes.Position(1) = myAxes.Position(1) + oldW/2 -newW/2;
cleanAx(myAxes);
end

function cleanAx(myAx)
myAx.XTick = [];
myAx.YTick = [];
myAx.XColor = [0 0 0];
myAx.YColor = [0 0 0];
myAx.Color = [0 0 0];
end

function printStim(isBaseline, eventName, myFig)
if ~isvalid(myFig)
    return;
end
disp('printing');
figure(myFig);
myAxes = myFig.Children;
if isBaseline
    % print baseline
    domain = linspace(0,2*pi,100);
    plot(myAxes,0.5*(1+cos(domain)),0.5*(1+sin(domain)),'w','LineWidth',8);
    myAxes.Position(1) = 0.5-myAxes.Position(3)/2;
    myAxes.Position(2) = 0.5-myAxes.Position(4)/2;
else
    switch eventName
        case 'left'
            % print left
            plot(myAxes,[0 1],[0.5 0.5],'w-d',[0 0.5],[0.5 1],'w',[0 0.5],[0.5 0],'w','LineWIdth',8,'MarkerSize',0.4,'MarkerIndices',1);
            myAxes.Position(1) = 0.05+myAxes.Position(3)/2;
            myAxes.Position(2) = 0.5-myAxes.Position(4)/2;
        case 'right'
            % print right
            plot(myAxes,[0 1],[0.5 0.5],'w-d',[1 0.5],[0.5 1],'w',[1 0.5],[0.5 0],'w','LineWIdth',8,'MarkerSize',0.4,'MarkerIndices',2);
            myAxes.Position(1) = 1-(0.05+myAxes.Position(3));
            myAxes.Position(2) = 0.5-myAxes.Position(4)/2;
        case 'forward'
            % print forward
            plot(myAxes,[0.5 0.5],[0 1],'w-d',[0 0.5],[0.5 1],'w',[1 0.5],[0.5 1],'w','LineWIdth',8,'MarkerSize',0.4,'MarkerIndices',2);
            myAxes.Position(1) = 0.5-myAxes.Position(3)/2;
            myAxes.Position(2) = 1-(0.05+myAxes.Position(4));
    end
end
xlim([0 1]);
ylim([0 1]);
cleanAx(myAxes);
end
