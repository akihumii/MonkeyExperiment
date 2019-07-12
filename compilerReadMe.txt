To run the program:
1. download NI-DAQmx:
http://www.ni.com/en-sg/support/downloads/drivers/download.ni-daqmx.html#311818

2. edit matlab script: 
C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\MonkeySetup\src\experiment.m
line 28: defaultPath: change to the directory leads to [MonkeyExperiment\MonkeySetup\src]
line 60: resourcePath: change to directory leads to [MonkeyExperiment\MonkeySetup\src\resources]


To compile:
1. add:
C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\Psychtoolbox\Psychtoolbox\PsychOpenGL\MOGL\wrap\glmGetConst.m
C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\Psychtoolbox\Psychtoolbox\PsychOpenGL\MOGL\core\oglconst.mat

2.
copy: C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\Psychtoolbox\Psychtoolbox\PsychOpenGL\MOGL\core\x64\freeglut.dll
to: C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\Psychtoolbox\Psychtoolbox\PsychBasic\MatlabWindowsFilesR2007a
add this freeglut.dll into compiler

3.
add:
C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\Psychtoolbox\Psychtoolbox\PsychSound\portaudio_x64.dll
C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\Psychtoolbox\Psychtoolbox\PsychSound\portaudio_x86.dll

4.
copy:
C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\Psychtoolbox\Psychtoolbox\PsychContributed\x64\libusb-1.0.dll
to:
C:\Users\lsitsai\Documents\GitHub\MonkeyExperiment\Psychtoolbox\Psychtoolbox\PsychBasic\MatlabWindowsFilesR2007a
and add to compiler
