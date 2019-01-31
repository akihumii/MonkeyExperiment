%% Simple illustration of the typical use of dspdemo.DAQRecorder 

% Copyright 2014 The MathWorks, Inc.

%% Getting started
% In order to use dspdemo.DAQRecorder, first make sure you have a supported
% device installed. dspdemo.DAQRecorder can be used with all
% devices supported by Data Acquisition Toolbox(TM) through the
% Session-Based Interface, which also support Continuous Acquisition.
% dspdemo.DAQRecorder has only been tested on a limited number of
% National Instruments(R) Data Acquisition devices.
% Please refer to the Data Acquisition Toolbox documentation and support
% pages for further details.

%% Discover available devices
% To get a list of installed device types run the following code. 
% For more general information of discovering installed devices please
% refer to the Data Acquisition Toolbox example "Discover NI Devices Using
% the Session-Based Interface"

% Create an instance of dspdemo.DAQRecorder
daqtest = dspdemo.DAQRecorder;

% In the command window, type the following
% >> daqtest.DeviceName = '
% then press the Tab key on your keyboard. If a device with AnalogInput
% support is installed on your machine, you should see its name appear
% within a context list. Then select the desired device.

%% Select desired device

% Use the manually selected device to run the remainder of this example
deviceName = daqtest.DeviceName;
clear daqtest

%% Setup parameters
% Choose a number of parameters for the acquisition 

samplesPerFrame = 16000;
sampleRate = 44100;
endTime = 20;

%% Initialize needed resources

DataRecorder = dspdemo.DAQRecorder(...
    'DeviceName', deviceName,...
    'SamplesPerFrame', samplesPerFrame,...
    'SampleRate', sampleRate,...
    'ChannelNumbers', 0,...
    'OutputNumOverrunSamples', true);

%% Acquire data continuously
% Acquire data through a simple while loop, until the time reaches the
% value previously defined in endTime.
% To terminate the acquisition manually press CTRL+C 

tstart = tic;
while (toc(tstart) < endTime)
    % Use step method to acquire SamplesPerFrame at a time from the device
    [data, numov] = step(DataRecorder);
    
    if(~isempty(data))
        plot(data), set(gca,'Xlim',[0, length(data)-1])
        drawnow
    end
    
    if(numov > 0)
        fprintf('Samples overrun: %g\n',numov)
    end
end

% Release the device
release(DataRecorder)
