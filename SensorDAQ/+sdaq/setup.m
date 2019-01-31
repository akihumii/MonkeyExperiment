function setup
%SETUP Installation script for the Support Package
%   Run this script before using the Support Package. This will add the
%   package to the MATLAB path so it can be used at any time.

    %   MATLAB Support Package for Vernier SensorDAQ
    %   Version 1.0
    %   Copyright 2011 The MathWorks, Inc.

%% check system
sdaq.private.check;
    
%% add package to MATLAB path
packageParentDir = fileparts(fileparts(mfilename('fullpath')));
addpath(packageParentDir);
fprintf('Added "%s" to MATLAB path\n', packageParentDir);

%% save the path
result = savepath;
if result==1
    warning('SENSORDAQ:couldNotSavePath',['Unable to save updated MATLAB path\n',...
        '  To save the path, you can: \n',...
        '   1) Exit MATLAB \n',...
        '   2) Right-click the MATLAB icon and select "Run as administrator" \n',...
        '   3) Re-run sdaq.setup \n']);
else
    fprintf('Saved updated MATLAB path.\n');
    fprintf(['\nSetup successful. You can now use the functions in the MATLAB Support\n'...
        'MATLAB Support Package for Vernier SensorDAQ.\n']);
end

end