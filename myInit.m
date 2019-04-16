buffhost='localhost';
buffport=1972;

mfiledir=fileparts(mfilename('fullpath'));
% search for the location of the buffer_bci root
bufferdir=mfiledir(1:strfind(mfiledir,'buffer_bci')+numel('buffer_dir'));
if isempty(bufferdir)
    bufferdir = 'C:\Users\toalu\Desktop\myBuffer\buffer_bci';
end
% guard to prevent running slow path-setup etc. multiple times
% setup the paths
if ( exist(fullfile(bufferdir,'utilities/initPaths.m'),'file') ) % in utilities
    run(fullfile(bufferdir,'utilities','initPaths.m'));
else % or matlab/utilities?
    run(fullfile(bufferdir,'matlab','utilities','initPaths.m'));
end

system([bufferdir,'/dataAcq/startJavaNoSaveBuffer.bat&']);
system([bufferdir,'/dataAcq/startBiosemi.bat&']);

% wait for the buffer to return valid header information
hdr=[];
tic();
tooLong = false;
while ( isempty(hdr) || ~isstruct(hdr) || (isfield(hdr,'nchans') && hdr.nchans==0) ) % wait for the buffer to contain valid data
    if toc()>=5 && ~tooLong
        tooLong = true;
        system([bufferdir,'/dataAcq/startSignalProxy.bat&']);
        continue;
    end
    try
        hdr=buffer('get_hdr',[],buffhost,buffport);
    catch
        hdr=[];
        fprintf('Invalid header info... waiting.\n');
    end
    pause(1);
end

if tooLong
    disp('Using randomly generated signals');
end

% set the real-time-clock to use
initgetwTime;
initsleepSec;

