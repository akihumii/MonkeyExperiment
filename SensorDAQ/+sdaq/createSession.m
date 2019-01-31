function [ session ] = createSession
%CREATESESSION Create a Data Acquisition Toolbox session for SensorDAQ
%   session = sdaq.createSession creates a Data Acquisition Toolbox session
%   for accessing SensorDAQ. This session is the main interface to the the
%   SensorDAQ and is used with the rest of the Support Package's functions.
%
%   sdaq.createSession is a direct implementation of the <a href="matlab:help daq.createSession">daq.createSession</a>
%   function and is intended to reduce confusion regarding how Data
%   Acquisition Toolbox is used with the Support Package. The session
%   returned by sdaq.createSession is the exact same session object that
%   daq.createSession would return.
%
%   Example usage:
%       s = sdaq.createSession;
%
%   See also daq.createSession, sdaq.addSensor, sdaq.addAnalogInput,
%   sdaq.addAnalogOutput, sdaq.addCounter

    %   MATLAB Support Package for Vernier SensorDAQ
    %   Version 1.0
    %   Copyright 2011 The MathWorks, Inc.
    
sdaq.private.check;

session = daq.createSession('ni');

end

