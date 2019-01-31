function varargout = interface(varargin)
% INTERFACE MATLAB code for interface.fig
%      INTERFACE, by itself, creates a new INTERFACE or raises the existing
%      singleton*.
%
%      H = INTERFACE returns the handle to a new INTERFACE or the handle to
%      the existing singleton*.
%
%      INTERFACE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in INTERFACE.M with the given input arguments.
%
%      INTERFACE('Property','Value',...) creates a new INTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before interface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to interface_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help interface

% Last Modified by GUIDE v2.5 23-Feb-2018 13:26:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @interface_OpeningFcn, ...
                   'gui_OutputFcn',  @interface_OutputFcn, ...
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

function interface_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to interface (see VARARGIN)

if nargin == 3
    exp = experiment;
elseif nargin == 4
    exp = varargin{1};
end

% Choose default command line output for interface
handles.output = hObject;

expData.experiment = exp;
expData.runNumber = 1;
expData.plotExperiment = exp;

set(handles.interface, 'UserData', expData)

% Update handles structure
guidata(hObject, handles);

setupGUI(handles)

function varargout = interface_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Experiment
function editExpName_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');

filename = get(handles.editExpName, 'String');

cd(expData.experiment.defaultPath)

if ~ischar(filename)
    filename = expData.experiment.defaultName;
    pathname = expData.experiment.defaultPath;
end

set(handles.editExpName, 'String', filename)

expData.experiment.defaultName = filename;

function buttonFolder_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');

oldFilename = get(handles.editExpName, 'String');
cd(expData.experiment.defaultPath)
[filename, pathname, filterindex] = uiputfile('*.mat', 'Select experiment name', expData.experiment.defaultName);

if ~ischar(filename)
    filename = oldFilename;
    pathname = expData.experiment.defaultPath;
end

set(handles.editExpName, 'String', filename)

expData.experiment.defaultPath = pathname;
expData.experiment.defaultName = filename;

function buttonNextSession_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');

if ~expData.experiment.saved
    % Construct a questdlg with three options
    choice = questdlg('Data not saved. Would you like to save now?', ...
        'Unsaved data', ...
        'Save','Do not save','Cancel', 'Save');
    % Handle response
    switch choice
        case 'Save'
            buttonSave_Callback(handles.buttonSave, eventdata, handles)
        case 'Do not save'
            disp(['*** Data: ', expData.experiment.defaultName,' NOT saved ***'])
        case 'Cancel'
            return
    end
end

if expData.runNumber > 1
    delete(expData.plotExperiment)
end
expData.plotExperiment = expData.experiment;

expData.runNumber = expData.runNumber + 1;
expData.experiment = experiment(expData.runNumber);

set(handles.editExpName, 'String', expData.experiment.defaultName)
set(handles.editRunNum, 'String', num2str(expData.runNumber))
set(handles.interface, 'UserData', expData)

function checkAutoSave_Callback(hObject, eventdata, handles)

function editRunNum_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 100
    set(hObject, 'String', num2str(10))
    bin = 10;
else
    set(hObject, 'String', num2str(int32(bin)))
end

expData = get(handles.interface, 'UserData');
expData.runNumber = int32(bin);
expData.experiment.setDefaultName(expData.runNumber);

set(handles.editExpName, 'String', expData.experiment.defaultName)
set(handles.interface, 'UserData', expData)

function buttonSave_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');
exp = expData.experiment;

save(exp)

disp(['*** Data: ', exp.defaultName,' WAS saved ***'])

% Edit force
function editTargetSize_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 500
    set(hObject, 'String', num2str(200))
else
    set(hObject, 'String', num2str(int32(bin)))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.squareHeight = str2double(get(handles.editTargetSize, 'String'));

function checkLvlRandom_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');
exp = expData.experiment;

if get(handles.checkLvlRandom, 'Value')
    set(handles.popupForMax, 'Enable', 'on')
    exp.forceRandom = true;
else
    set(handles.popupForMax, 'Enable', 'off')
    exp.forceRandom = false;
end

function checkTriforce_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');
exp = expData.experiment;

if get(handles.checkTriforce, 'Value')
    exp.triForce = true;
    set(handles.popupForMin, 'String', [{'1'},{'2'},{'3'}])
    set(handles.popupForMax, 'String', [{'1'},{'2'},{'3'}])
    
    if get(handles.popupForMin, 'Value') > 3
        set(handles.popupForMin, 'Value', 3)
    end
    
    if get(handles.popupForMax, 'Value') > 3
        set(handles.popupForMax, 'Value', 3)
    end
    
    set(handles.editTargetSize, 'String', num2str(330))
    
else
    exp.triForce = false;
    set(handles.popupForMin, 'String', [{'1'},{'2'},{'3'},{'4'},{'5'}])
    set(handles.popupForMax, 'String', [{'1'},{'2'},{'3'},{'4'},{'5'}])
    
    set(handles.editTargetSize, 'String', num2str(200))
end

function checkLock_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');
exp = expData.experiment;

if get(handles.checkLvlRandom, 'Value')
    exp.lockTarget = true;
else
    exp.lockTarget = false;
end

function popupForMin_Callback(hObject, eventdata, handles)
lvl1 = get(hObject, 'Value');
lvl2 = get(handles.popupForMax, 'Value');

if lvl1 > lvl2
    warndlg('Minimum value needs to be smaller than maximum value', 'Invalid value')
    if lvl2 == 1
        set(hObject, 'Value', 1)
    else
        set(hObject, 'Value', lvl2 - 1)
    end
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.forceMin = get(handles.popupForMin, 'Value');

function popupForMax_Callback(hObject, eventdata, handles)
lvl1 = get(handles.popupForMin, 'Value');
lvl2 = get(hObject, 'Value');

if lvl1 > lvl2
    warndlg('Maximum value needs to be bigger than minimum value', 'Invalid value')
    if lvl1 == 1
        set(hObject, 'Value', 1)
    else
        set(hObject, 'Value', lvl1 + 1)
    end
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.forceMax = get(handles.popupForMax, 'Value');

function editLVLsens_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 100
    set(hObject, 'String', num2str(5))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.sensorSensitivity = str2double(get(handles.editLVLsens, 'String'));

function editSmoothing_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 100
    set(hObject, 'String', num2str(5))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.sensorSmoothing = str2double(get(handles.editSmoothing, 'String'));

% Edit trial
function editTrialSucc_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 100
    set(hObject, 'String', num2str(10))
else
    set(hObject, 'String', num2str(int32(bin)))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.numTrial = str2double(get(handles.editTrialSucc, 'String'));

function editTrialMax_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 1000
    set(hObject, 'String', num2str(100))
else
    set(hObject, 'String', num2str(int32(bin)))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.maxTrial = str2double(get(handles.editTrialMax, 'String'));

function editDurStim_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin < 0 || bin > 100
    set(hObject, 'String', num2str(1))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.durStim = str2double(get(handles.editDurStim, 'String'));

function editDurRespo_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 100
    set(hObject, 'String', num2str(10))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.durResps = str2double(get(handles.editDurRespo, 'String'));

function editDurSuccess_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 100
    set(hObject, 'String', num2str(0.5))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.durSuccess = str2double(get(handles.editDurSuccess, 'String'));

function editDurRew_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
if isnan(bin) || bin <= 0 || bin > 100
    set(hObject, 'String', num2str(1))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.durRewar = str2double(get(handles.editDurRew, 'String'));

function checkITIrandom_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');
exp = expData.experiment;

if get(handles.checkITIrandom, 'Value')
    set(handles.editITImax, 'Enable', 'on')
    exp.intRandom = true;
else
    set(handles.editITImax, 'Enable', 'off')
    exp.intRandom = false;
end

function editITImin_Callback(hObject, eventdata, handles)
bin = str2double(get(hObject, 'String'));
bin2 = str2double(get(handles.editITImax, 'String'));

if isnan(bin) || bin <= 0 || bin > 100 
    set(hObject, 'String', num2str(1))
elseif bin > bin2
    warndlg('Minimum value needs to be smaller than maximum value', 'Invalid value')
    set(hObject, 'String', num2str(bin2-1))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.intTrialMin = str2double(get(handles.editITImin, 'String'));

function editITImax_Callback(hObject, eventdata, handles)
bin = str2double(get(handles.editITImin, 'String'));
bin2 = str2double(get(hObject, 'String'));
if isnan(bin2) || bin2 <= 0 || bin2 > 100
    set(hObject, 'String', num2str(1))
elseif bin2 < bin
    warndlg('Maximum value needs to be bigger than minimum value', 'Invalid value')
    set(hObject, 'String', num2str(bin+1))
end

expData = get(handles.interface, 'UserData');
exp = expData.experiment;

exp.intTrialMax = str2double(get(handles.editITImax, 'String'));

% Info
function buttonPlot_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');
plot(expData.plotExperiment)

% Control experiment
function buttonStart_Callback(hObject, eventdata, handles)
expData = get(handles.interface, 'UserData');

expData.experiment.forceRandom = get(handles.checkLvlRandom, 'Value');
expData.experiment.triForce = get(handles.checkTriforce, 'Value');
expData.experiment.lockTarget = get(handles.checkLock, 'Value');
expData.experiment.forceMin = get(handles.popupForMin, 'Value');
expData.experiment.forceMax = get(handles.popupForMax, 'Value');
expData.experiment.sensorSensitivity = str2double(get(handles.editLVLsens, 'String'));
expData.experiment.sensorSmoothing = str2double(get(handles.editSmoothing, 'String'));
expData.experiment.squareHeight = str2double(get(handles.editTargetSize, 'String'));

expData.experiment.numTrial = str2double(get(handles.editTrialSucc, 'String'));
expData.experiment.maxTrial = str2double(get(handles.editTrialMax, 'String'));
expData.experiment.durStim = str2double(get(handles.editDurStim, 'String'));
expData.experiment.durResps = str2double(get(handles.editDurRespo, 'String'));
expData.experiment.durSuccess = str2double(get(handles.editDurSuccess, 'String'));
expData.experiment.durRewar = str2double(get(handles.editDurRew, 'String'));

expData.experiment.intRandom = get(handles.checkITIrandom, 'Value');
expData.experiment.intTrialMin = str2double(get(handles.editITImin, 'String'));
expData.experiment.intTrialMax = str2double(get(handles.editITImax, 'String'));

expData.results = expData.experiment.startExperiment;

succTrial = sum(expData.results.succTrials);
totalTrial = length(expData.results.succTrials);
percentCorr = (succTrial/totalTrial)*100;

set(handles.textCalcPerc, 'String', num2str(percentCorr))
set(handles.textTrialNum, 'String', num2str(totalTrial))
set(handles.textSuccTrial, 'String', num2str(succTrial))

if get(handles.checkAutoSave, 'Value')
    buttonSave_Callback(handles.buttonSave, eventdata, handles)
    buttonNextSession_Callback(handles.buttonNextSession, eventdata, handles)
end

expData = get(handles.interface, 'UserData');
set(handles.interface, 'UserData', expData);

% Helper
function setupGUI(handles)
handles = guidata(handles.interface);
expData = get(handles.interface, 'UserData');
exp = expData.experiment;

set(handles.editTargetSize, 'String', num2str(exp.squareHeight))
set(handles.editExpName, 'String', expData.experiment.defaultName)
set(handles.checkAutoSave, 'Value', 1)
set(handles.popupForMin, 'Value', exp.forceMin)
set(handles.popupForMax, 'Value', exp.forceMax)
set(handles.checkTriforce, 'Value', exp.triForce)
set(handles.checkLock, 'Value', exp.lockTarget)

if exp.forceRandom
    set(handles.checkLvlRandom, 'Value', true)
    set(handles.popupForMax, 'Enable', 'on')
else
    set(handles.checkLvlRandom, 'Value', false)
    set(handles.popupForMax, 'Enable', 'off')
end

set(handles.editLVLsens, 'String', num2str(exp.sensorSensitivity))
set(handles.editSmoothing, 'String', num2str(exp.sensorSmoothing))
set(handles.editTrialSucc, 'String', num2str(exp.numTrial))
set(handles.editTrialMax, 'String', num2str(exp.maxTrial))
set(handles.editDurRespo, 'String', num2str(exp.durResps))
set(handles.editDurStim, 'String', num2str(exp.durStim))
set(handles.editDurSuccess, 'String', num2str(exp.durSuccess))
set(handles.editDurRew, 'String', num2str(exp.durRewar))

if exp.intRandom
    set(handles.checkITIrandom, 'Value', true)
    set(handles.editITImax, 'Enable', 'on')
else
    set(handles.checkITIrandom, 'Value', false)
    set(handles.editITImax, 'Enable', 'off')
end

set(handles.editITImin, 'String', num2str(exp.intTrialMin))
set(handles.editITImax, 'String', num2str(exp.intTrialMax))
