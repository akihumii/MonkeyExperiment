function [ chan index ] = addAnalogInput( sessionobj, channel, devicename, type )
%ADDANALOGINPUT Add a Vernier SensorDAQ analog input to a DAT session
%   sdaq.addAnalogInput(sessionobj,channel) adds a SensorDAQ analog input
%   channel (pins 11 and 12 on the terminal block) to a Data Acquisition 
%   Toolbox session. This will automatically detect a single SensorDAQ connected to
%   the computer. Channel can be a number (0 or 1) or a string ('ai0' or
%   'ai1').
%
%   sdaq.addAnalogInput(sessionobj,channel,devicename) adds an analog input
%   of a specified device to the session. Device names are set by NI's
%   software and typically look like 'DevX', where X is a number. Use
%   <a href="matlab:help daq.getDevices">daq.getDevices</a> to get a list of device names.
%
%   sdaq.addAnalogInput(sessionobj,channel,devicename,type) is like the
%   above except that the type of input is specified. By default, analog
%   inputs are set as single ended outputs (only one port is used, with
%   ground as a reference). By specifying type as either 'SingleEnded' or
%   'Differential', the type of input can be controlled. Differential
%   inputs measure the voltage difference between the two channels.
%
%   [chan index] = sdaq.addAnalogInput(...) returns the channel object
%   and the index of the channel within the session. This is the same
%   syntax as for the Session <a href="matlab:help daq.Session.addAnalogInputChannel">addAnalogInputChannel</a> method.
% 
%   Example usage:
%
%       % Create a DAT session
%       s = sdaq.createSession; 
%
%       % Add analog input 0 (pin 11)
%       sdaq.addAnalogInput(s,0);
%
%       % Read and scale one sample from the device
%       pressure = s.inputSingleScan;
%
%   See also sdaq.createSession, sdaq.addSensor, sdaq.addAnalogOutput, sdaq.addCounter

    %   MATLAB Support Package for Vernier SensorDAQ
    %   Version 1.0
    %   Copyright 2011 The MathWorks, Inc.

validateattributes(sessionobj,{'daq.ni.Session'},{'scalar'});
if ischar(channel)
    validateattributes(channel,{'char'},{'row'});
else
    if channel == 11 || channel == 12 % if pin# instead of channel # is given, change to channel #
        channel = channel - 11;
    end
    validateattributes(channel,{'numeric'},{'integer','>=',0,'<=',1});
end

if ~exist('devicename','var')
    devices = daq.getDevices;
    sdaqindex = [];
    for i = 1:length(devices)
        if strcmp(devices(i).Model,'SensorDAQ')
            sdaqindex = [sdaqindex i];
        end
    end
    if isempty(sdaqindex)
        error('SENSORDAQ:noDevices','No SensorDAQ device detected.');
    elseif length(sdaqindex) > 1
        msg = ['Multiple SensorDAQ devices detected. Please specify the device name. Valid device names are:' char(10)];
        msg = [msg '''' devices(sdaqindex(1)).ID ''''];
        for i = 2:length(sdaqindex)
            msg = [msg ', ''' devices(sdaqindex(i)).ID ''''];
        end
        error('SENSORDAQ:multipleDevices',msg);
    else
    	devicename = devices(sdaqindex).ID;
    end
end
validateattributes(devicename,{'char'},{'row'});

if ~exist('type','var')
    type = 'SingleEnded';
end
validateattributes(type,{'char'},{'row'});

switch lower(type)
    case 'singleended'
        [chan index] = sessionobj.addAnalogInputChannel(devicename,channel,'Voltage');
        chan.InputType = 'SingleEnded';
        chan.Range = [-10 10];
    case 'differential'
        if channel == 1;
            error('SENSORDAQ:unsupportedChannel','Analog input 1 does not support differential input')
        end
        [chan index] = sessionobj.addAnalogInputChannel(devicename,channel,'Voltage');
        chan.InputType = 'Differential';
        chan.Range = [-20 20];
end

end

