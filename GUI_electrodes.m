function varargout = GUI_electrodes(varargin)
% GUI_ELECTRODES MATLAB code for GUI_electrodes.fig
%      GUI_ELECTRODES, by itself, creates a new GUI_ELECTRODES or raises the existing
%      singleton*.
%
%      H = GUI_ELECTRODES returns the handle to a new GUI_ELECTRODES or the handle to
%      the existing singleton*.
%
%      GUI_ELECTRODES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_ELECTRODES.M with the given input arguments.
%
%      GUI_ELECTRODES('Property','Value',...) creates a new GUI_ELECTRODES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_electrodes_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_electrodes_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI_electrodes

% Last Modified by GUIDE v2.5 02-Jul-2018 16:01:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_electrodes_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_electrodes_OutputFcn, ...
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


% --- Executes just before GUI_electrodes is made visible.
function GUI_electrodes_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI_electrodes (see VARARGIN)

% Choose default command line output for GUI_electrodes
handles.output = hObject;

global electrodes;
global reference;
newData = num2cell(zeros(18,1));
handles.elTable = uitable(hObject,'Tag','elTable','Data',newData,...
    'Units','normalized','Position',[0.125 0.125 0.75 0.83],...
    'ColumnEditable',true,'ColumnName',{'Electrodes'},...
    'RowName',{'B5 (ref)','A9','A10','A11','A12','A13','A14','A19','A32','B12','B13','B14','B15','B16','B17','B18','B19','B24'});%

if ~isempty(reference)
    newData(1) = num2cell(reference);
end
if ~isempty(electrodes)
    newData(2:end) = num2cell(electrodes);
end

set(handles.elTable,'Data',newData);

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes GUI_electrodes wait for user response (see UIRESUME)
% uiwait(handles.setElectrodesGUI);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_electrodes_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in saveBtn.
function saveBtn_Callback(hObject, eventdata, handles)
% hObject    handle to saveBtn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = handles.elTable.Data;
global electrodes;
global reference;

reference = cell2mat(data(1));
myElectrodes = cell2mat(data(2:end));
%%% some kind of check
electrodes = myElectrodes;

h = findall(0, 'tag', 'resetElectrodes');
if ~isempty(h)
    h.Callback(h, []);
else
    disp('no control for feedback');
end

thisFig = findall(0, 'tag', 'setElectrodesGUI');
delete(thisFig);
