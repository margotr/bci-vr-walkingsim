function varargout = BCI_GUI(varargin)
% BCI_GUI MATLAB code for BCI_GUI.fig
%      BCI_GUI, by itself, creates a new BCI_GUI or raises the existing
%      singleton*.
%
%      H = BCI_GUI returns the handle to a new BCI_GUI or the handle to
%      the existing singleton*.
%
%      BCI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BCI_GUI.M with the given input arguments.
%
%      BCI_GUI('Property','Value',...) creates a new BCI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BCI_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BCI_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BCI_GUI

% Last Modified by GUIDE v2.5 02-Jul-2018 15:27:53

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BCI_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @BCI_GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before BCI_GUI is made visible.
function BCI_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BCI_GUI (see VARARGIN)

% Choose default command line output for BCI_GUI
handles.output = hObject;

myInit;
handles.hdr = hdr;
handles.buffhost = buffhost;
handles.buffport = buffport;

global reference;
global electrodes;
electrodes = [];
reference = [];
handles.electrodes = [];
handles.reference = [];
handles.needElectrodes = true;

% if tooLong %if cap not connected
%     handles.needElectrodes = false; %won't ask to set the electrodes
%     handles.electrodesBtn.Enable = 'off';
% end

handles.dataPath = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BCI_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BCI_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in electrodesBtn.
function electrodesBtn_Callback(hObject, eventdata, handles)
% hObject    handle to electrodesBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%% GUI window to set the electrodes
GUI_electrodes;


% --- Executes on button press in calibrationBtn.
function calibrationBtn_Callback(hObject, eventdata, handles)
% hObject    handle to calibrationBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
doLoad = questdlg('Do you want to load previously calibrated data?', ...
	'New Data?', ...
	'Yes','No','Yes');

global reference;
global electrodes;
if isempty(doLoad)
    return;
end
if strcmp(doLoad,'Yes')
    [fileName, pathName] = uigetfile('*.mat','Load');
    if ischar(fileName)
        handles.dataPath = [pathName, fileName];
        data = load(calibPath,'reference','electrodes');
        reference = data.reference;
        electrodes = data.electrodes;
        handles.resetElectrodes.Callback(handles.resetElectrodes,[]);
        handles.electrodesBtn.Enable = 'off';
    end
else
    if ~handles.needElectrodes
        calibPath = calibration(handles.hdr, handles.buffhost, handles.buffport, handles.electrodes, handles.reference);
        if ~isempty(calibPath)
            handles.dataPath = calibPath;
            handles.electrodesBtn.Enable = 'off';
        end
    else
        msgbox('You need to set the electrodes before!');
    end
end
guidata(hObject, handles);


% --- Executes on button press in freeBtn.
function freeBtn_Callback(hObject, eventdata, handles)
% hObject    handle to freeBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~handles.needElectrodes && ~isempty(handles.dataPath)
    application(handles.hdr, handles.buffhost, handles.buffport, handles.dataPath);
else
    msgbox('You need to set the electrodes before!');
end


% --- Executes on button press in resetElectrodes.
function resetElectrodes_Callback(hObject, eventdata, handles)
% hObject    handle to resetElectrodes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global reference;
global electrodes;

handles.needElectrodes = true;
handles.reference = reference;
handles.electrodes = electrodes;
handles.dataPath = [];
if handles.reference > handles.hdr.nChans || handles.reference <= 0
    disp('Reference out of range');
    return;
end
for elIdx = 1:length(handles.electrodes)
    if handles.electrodes(elIdx) > handles.hdr.nChans || handles.electrodes(elIdx) <= 0
        disp(['Electrode ',num2str(elIdx),' out of range']);
        return;
    end
end
if length(unique(handles.electrodes)) ~= length(handles.electrodes)
    disp('Some electrodes are repeated');
    return;
end
handles.needElectrodes = false;
guidata(hObject, handles);
