% function psychDemo

sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

% To draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen.
screenNumber = max(screens);

% Define black and white (white will be 1 and black 0). This is because
% in general luminace values are defined between 0 and 1 with 255 steps in
% between. All values in Psychtoolbox are defined between 0 and 1
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

%% draw rectangles
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of 200 by 200 pixels
baseRect = [0 0 200 200];

% Screen X positions of our three rectangles
stimXpos = [screenXpixels * 0.25 screenXpixels * 0.25 screenXpixels * 0.25];
stimYpos = [screenYpixels * 0.25 screenYpixels * 0.5 screenYpixels * 0.75];

outpXpos = [screenXpixels * 0.75 screenXpixels * 0.75 screenXpixels * 0.75];
outpYpos = [screenYpixels * 0.25 screenYpixels * 0.5 screenYpixels * 0.75];

numSqaures = length(stimXpos);

% Set the colors to Red, Green and Blue
allColors = [1 0 0; 0 1 0; 0 0 1];

% Make our rectangle coordinates
stimRects = nan(4, 3);
outpRects = nan(4, 3);
for i = 1:numSqaures
    stimRects(:, i) = CenterRectOnPointd(baseRect, stimXpos(i), stimYpos(i));
    outpRects(:, i) = CenterRectOnPointd(baseRect, outpXpos(i), outpYpos(i));
end

%% setup timing
% Measure the vertical refresh rate of the monitor
ifi = Screen('GetFlipInterval', window);

% Retreive the maximum priority number
topPriorityLevel = MaxPriority(window);

% Length of time and number of frames we will use for each drawing test
numSecs = 1;
numFrames = round(numSecs / ifi);

% Numer of frames to wait when specifying good timing. Note: the use of
% wait frames is to show a generalisable coding. For example, by using
% waitframes = 2 one would flip on every other frame. See the PTB
% documentation for details. In what follows we flip every frame.
waitframes = 2;

% Finally we do the same as the last example except now we additionally
% tell PTB that no more drawing commands will be given between coloring the
% screen and the flip command. This, can help acheive good timing when one
% is needing to do additional non-PTB processing between setting up drawing
% and flipping to the screen. Thus, you would only use this technique if
% you were doing this. So, if you are not, go with example #3

% [sensor, channel, settings, aH] = test;

Priority(topPriorityLevel);
vbl = Screen('Flip', window);
for frame = 1:numFrames

%     data = sensor.inputSingleScan;
%     data = sensor.startForeground
%     channel.data.adc
%     plotADC(data, aH, settings)

    % Draw the rect to the screen
    
    
    % Color the screen blue
    Screen('FillRect', window, [0 0 0.5]);
    
    Screen('FillRect', window, allColors, stimRects);
    Screen('FillRect', window, allColors, outpRects);
    
    % Tell PTB no more drawing commands will be issued until the next flip
    Screen('DrawingFinished', window);

    % One would do some additional stuff here to make the use of
    % "DrawingFinished" meaningful / useful

    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

end
Priority(0);

% Clear the screen.
sca;
% end

function plotADC(adc, aH, settings)
    xdataOld = get(aH, 'XData');
    
    if length(xdataOld) == 1 && isnan(xdataOld(1))
        ydata = adc;
        xdata = linspace(0, settings.sampleInt, length(adc))';
    else
        ydata = [get(aH,'YData')'; adc];
        xStart = xdataOld(end) + 1/settings.fs;
        xNew = linspace(xStart, xStart + settings.sampleInt, length(adc));
        xdata = [xdataOld'; xNew'];
    end
    
    set(aH,'XData', xdata, 'YData', ydata);
end