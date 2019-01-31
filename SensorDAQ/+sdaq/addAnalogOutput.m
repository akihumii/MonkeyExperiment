function [ chan index ] = addAnalogOutput( sessionobj, devicename )
%ADDANALOGOUTPUT Add the Vernier SensorDAQ analog output to a DAT session
%   sdaq.addAnalogOutput(sessionobj) adds the SensorDAQ analog output
%   channel (pin 9 on the terminal block) to a Data Acquisition Toolbox
%   session. This will automatically detect a single SensorDAQ connected to
%   the computer.
%
%   sdaq.addAnalogOutput(sessionobj,devicename) adds the analog output of
%   a specified device to the session. Device names are set by NI's
%   software and typically look like 'DevX', where X is a number. Use
%   <a href="matlab:help daq.getDevices">daq.getDevices</a> to get a list of device names.
%
%   [chan index] = sdaq.addAnalogOutput(...) returns the channel object
%   and the index of the channel within the session. This is the same
%   syntax as for the Session <a href="matlab:help daq.Session.addAnalogOutputChannel">addAnalogOutputChannel</a> method.
%   
%   Example usage:
%       %Create the DAT session
%       s = sdaq.createSession; 
%
%       %Add the SensorDAQ analog output to the session
%       sdaq.addAnalogOutput(s);
%
%       %Set the analog output to 5 volts
%       s.outputSingleScan(5)
%
%   See also sdaq.createSession, sdaq.addSensor, sdaq.addAnalogInput, 
%   sdaq.addCounter

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

warning('off','daq:Session:onDemandOnlyChannelsAdded');
[chan index] = sessionobj.addAnalogOutputChannel(devicename,0,'Voltage');
warning('off','daq:Session:onDemandOnlyChannelsAdded');

end

