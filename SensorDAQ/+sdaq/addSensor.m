function [ channel index ] = addSensor( sessionobj, channel, sensor, devicename)
%ADDSENSOR Add an analog Vernier Sensor to a Data Aquisition Toolbox session
%   sdaq.addSensor(sessionobj,channel,sensor) adds the sensor specified by 
%   channel and <a href="matlab:help sdaq.Sensors">sensor</a> to the specified session. This function call will 
%   automatically find a single SensorDAQ device to connect to. If multiple
%   SensorDAQs are connected, see below.
%
%   sdaq.addSensor(sessionobj,channel,sensor,devicename) connects to the
%   SensorDAQ with the specified NI-defined device name. Device names
%   typically look like 'Dev1', 'Dev2', etc. Use <a href="matlab:help daq.getDevices">daq.getDevices</a> to get a
%   list of device names.
%
%   [ channel index ] = sdaq.addSensor(...) specifies a channel object and
%   index in the session as an optional output arguement. Note that this is
%   the same syntax as the Session <a href="matlab:help daq.Session.addAnalogInputChannel">addAnalogInputChannel</a> method.
%
%   Example usage:
%
%       % Create a DAT session
%       s = sdaq.createSession; 
%
%       % Add a barometer sensor connected to channel 1
%       sdaq.addSensor(s,1,sdaq.Sensors.Barometer);
%
%       % Get a <a href="matlab:help sdaq.getScaleFun">scaling function</a>
%       scale = sdaq.getScaleFun(sdaq.Sensors.Barometer);
%
%       % Read and scale one sample from the device
%       pressure = scale(s.inputSingleScan);
%
%   See also sdaq.createSession, sdaq.getScaleFun, sdaq.Sensors, 
%   sdaq.addAnalogInput
%       

    %   MATLAB Support Package for Vernier SensorDAQ
    %   Version 1.0
    %   Copyright 2011 The MathWorks, Inc.

validateattributes(sessionobj,{'daq.ni.Session'},{'scalar'});
validateattributes(channel,{'numeric'},{'integer','>=',1,'<=',3});
validateattributes(sensor,{'struct'},{'scalar'});

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
else
    validateattributes(devicename,{'char'},{'row'});
end

if sensor.Channel == 5
    channame = ['_sensor' num2str(channel-1) '_5V'];
elseif sensor.Channel == 10
    channame = ['_sensor' num2str(channel-1) '_10V'];
end

[channel index] = sessionobj.addAnalogInputChannel(devicename, channame, 'Voltage');

end

