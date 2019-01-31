function InstallMe
% INSTALLEDME Adds all required folders to the MATLAB(R) path
% 
% Copyright 2014 The MathWorks, Inc.


% Add root directory to path
sRoot = pwd;
addpath(sRoot);
addpath([sRoot, filesep, 'Data']);

error_result = savepath;

if error_result == 1
    errordlg('Cannot write to the pathdef.m file. Do you have write permission for this file?');
    disp('Cannot execute this file because cannot write to the pathdef.m file.');
    disp('Do you have write permission for this file?');
end


