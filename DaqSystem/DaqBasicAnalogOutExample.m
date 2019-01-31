%% Simple illustration of the typical use of dspdemo.DAQPlayer 

% Copyright 2014 The MathWorks, Inc.

%% Getting started
% In order to use dspdemo.DAQPlayer, first make sure you have a supported
% device installed. dspdemo.DAQPlayer can be used with all
% devices supported by Data Acquisition Toolbox(TM) through the
% Session-Based Interface, which also support Continuous Acquisition.
% dspdemo.DAQPlayer has only been tested on a limited number of
% National Instruments(R) Data Acquisition devices.
% Please refer to the Data Acquisition Toolbox documentation and support
% pages for further details.

%% Discover available devices
% To get a list of installed device types run the following code. 
% For more general information of discovering installed devices please
% refer to the Data Acquisition Toolbox example "Discover NI Devices Using
% the Session-Based Interface"

% Create an instance of dspdemo.DAQPlayer
daqtest = dspdemo.DAQPlayer;

% In the command window, type the following
% >> daqtest.DeviceName = '
% then press the Tab key on your keyboard. If a device with AnalogInput
% support is installed on your machine, you should see its name appear
% within a context list. Then select the desired device and press Enter.

%% Select desired device

% Use the manually selected device to run the remainder of this example
deviceName = daqtest.DeviceName;
clear daqtest

%% Setup parameters
% Choose a number of parameters for the acquisition 

samplesPerFrame = 16000;
playTime = 20;

%% Initialize needed resources

% File reader
Afile = dsp.AudioFileReader('Filename', 'guitar10min.ogg',...
    'SamplesPerFrame', samplesPerFrame);

% Data player
DataPlayer = dspdemo.DAQPlayer(...
    'DeviceName', deviceName,...
    'SampleRate', Afile.SampleRate,...
    'FirstChannelNumber',0,...
    'OutputDeviceUnderrunStatus', true,...
    'TargetLatencyFrames', 2);

%% Best practice: manually setup all System objects prior to main loop
% Run setup on all System objects prior to entering main loop, to take away
% any avoidable latency between the first two calls to teh step method of
% dspdemo.DAQPlayer.
% In general, any one-time large latency between two subsequent calls to
% the step method of dspdemo.DAQPlayer could cause the output queue to
% underrun, with consequent automatic release of the device.
% If you still observe underrun events consider
% - Increasing the number of samples per frame, i.e. the number of rows of
%   the first input to the step method of dspdemo.DAQPlayer
% - Increasing the value of TargetLatencyFrames (see method help for more
%   details)
% - Decreasing the sample rate

setup(Afile)
setup(DataPlayer, zeros(samplesPerFrame,1))

%% Generate output signal continuously
% Generate data through a simple while loop, until the time reaches the
% value previously defined in playTime.
% To terminate the loop manually press CTRL+C 

tstart = tic;
while toc(tstart) < playTime

    % Read audio from file
    data = step(Afile);
    
    % Play one channel of attenuated audio data through DAQ Analog output
    underrun = step(DataPlayer, 0.2 * data(:,1));
    
    if(underrun)
        fprintf('DAQPlayer returned device underrun!\n')
        break
    end
end

% Release resources
release(DataPlayer)
release(Afile)

