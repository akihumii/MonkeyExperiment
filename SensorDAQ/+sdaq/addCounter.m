function [ chan index ] = addCounter( sessionobj, devicename, type )
%ADDCOUNTER Add the Vernier SensorDAQ counter input to a DAT session
%   sdaq.addCounter(sessionobj) adds the SensorDAQ counter input
%   channel (pin 7 on the terminal block) to a Data Acquisition Toolbox
%   session. This will automatically detect a single SensorDAQ connected to
%   the computer.
%
%   sdaq.addCounter(sessionobj,devicename) adds the counter input of
%   a specified device to the session. Device names are set by NI's
%   software and typically look like 'DevX', where X is a number. Use
%   <a href="matlab:help daq.getDevices">daq.getDevices</a> to get a list of device names.
%
%   sdaq.addCounter(sessionobj,devicename,type) adds the counter channel as
%   a specified input type. By default, the type is 'EdgeCount', which
%   counts state changes. SensorDAQ also supports 'Frequency', which
%   measures frequency.
%
%   [chan index] = sdaq.addCounter(...) returns the channel object
%   and the index of the channel within the session. This is the same
%   syntax as for the Session <a href="matlab:help daq.Session.addCounterInputChannel">addCounterInputChannel</a> method.
%   
%   Example usage:
%       %Create the DAT session
%       s = sdaq.createSession; 
%
%       %Add the SensorDAQ counter to the session
%       sdaq.addCounter(s);
%
%       %Read the counter
%       s.inputSingleScan
%
%   See also sdaq.createSession, sdaq.addSensor, sdaq.addAnalogInput, 
%   sdaq.addAnalogOutput

    %   MATLAB Support Package for Vernier SensorDAQ
    %   Version 1.0
    %   Copyright 2011 The MathWorks, Inc.

validateattributes(sessionobj,{'daq.ni.Session'},{'scalar'});

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

if exist('type','var')
    validateattributes(type,{'char'},{'row'});
else
    type = 'EdgeCount';
end

[ chan index ] = sessionobj.addCounterInputChannel(devicename,'ctr0',type);
    
end

