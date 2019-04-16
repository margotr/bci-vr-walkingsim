clean;

myInit;

buffer('con',[],buffhost,buffport);

if ~exist('electrodes','var')
    electrodes = [];%[1 3]; %selection of electrodes, empty for all
end
if isempty(electrodes)
    electrodes = 1:hdr.nChans;
end
if ~exist('reference','var')
    reference = []; %reference electrode, empty for no reference
end
displayMode = 'show';

segmLen = round(0.25*hdr.fSample);%250ms
DispLen = 5*hdr.fSample;
myData = zeros(length(electrodes),DispLen);
myFFT = zeros(size(myData));
stat = buffer('wait_dat',[1 Inf 1000],buffhost,buffport);
curr = stat.nSamples;

if tooLong %when using randomly generated signals
    [bFilt, aFilt] = butter(3,[0.1 45]/(hdr.fSample/2),'bandpass');
    t = (0:DispLen-1)/hdr.fSample;
    freq = linspace(0,hdr.fSample,length(t));
end

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
        case 'show'
            myData(:,1:end-segmLen) = myData(:,segmLen+1:end);
            myData(:,end-segmLen+1:end) = newDat;
            pause(0.05);%"awakes" matlab before plotting
            for elIdx = 1:length(electrodes)
                myFiltData = filtfilt(bFilt, aFilt, myData(elIdx,:));
                myFFT(elIdx,:) = fft(myFiltData);
            end
            if isvalid(myFig)
                figure(myFig);
                subplot(2,1,1);
                plot(t,myData);
                xlim([t(1) t(end)]);
                title('Time domain');
                xlabel('time [s]');

                subplot(2,1,2);
                plot(freq,abs(myFFT));
                xlim([0 min(95,hdr.fSample/2)]);
                title('Frequency domain');
                xlabel('freq [Hz]');
            else
                break;
            end
    end
    %Application ends HERE
end
