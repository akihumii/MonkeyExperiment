% Checks that the current MATLAB version is R2011b or later, and that Data 
% Acquisition Toolbox and NI-DAQmx are installed. Generates an error
% if these conditions aren't satisfied.

%   MATLAB Support Package for Vernier SensorDAQ
%   Version 1.0
%   Copyright 2011 The MathWorks, Inc.

function check
    
% Check the MATLAB is 2011b or later
matlabversion = version('-release');
if ~(strcmp(matlabversion,'2011b') || str2double(matlabversion(3:4)) >= 12)
    error('SENSORDAQ:unsupportedMATLAB',['The Support Package requires MATLAB release 2011b or later' ...
                                        '\nCurrent MATLAB version: %s'],matlabversion);
end

% Check that Data Acquisition Toolbox is installed
if ~license('test','data_acq_toolbox')
    error('SENSORDAQ:noDAT',['Data Acquisition Toolbox was not detected.'...
        '\nThe Support Package requires that Data Acquisition Toolbox is installed.']);
end

% Check that NI-DAQmx is installed and visible to DAT
vendors = daq.getVendors;
index = arrayfun(@(x) strcmp(x.ID,'ni'),vendors);
if vendors(index).IsOperational == 0
    error('SENSORDAQ:noNIDAQmx',['Data Acquisition Toolbox reported that NI-DAQmx is not installed. '...
        'Your NI-DAQmx install may be missing or corrupted. Install or reinstall NI-DAQmx and try again.']);
end
end