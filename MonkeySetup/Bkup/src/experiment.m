classdef experiment < handle

    %% Edit parameters below %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    properties
        % Please only edit values in this block
        forceRandom = true;     % Randomise force levels
        triForce = false;       % for only 3 pressure targets
        lockTarget = false;     % lock the cursor once in the target area
        forceMin = 2            % Minimum force level to be executed
        forceMax = 3            % Maximum force level to be executed
        sensorSensitivity = 4;  % Factor for sensitivity of dynamometer
        sensorSmoothing = 5;

        numTrial = 3    % Number of successful trials
        maxTrial = 100    % Maximum number of trials
        durStim = 1     % Duration pre response time [s]
        durResps = 4    % Duration response time [s]
        durSuccess = 1  % Trial duration in [s]
        durRewar = 3    % Duration reward time [s]
        durAudio = 1    % Duration of sounds, not implemented yet
        volAudio = 0.5  % Volume of sounds
   
        intRandom = true % Randomise interstimulus intervals 
        intTrialMin = 2   % Inter trial duration [s] 
        intTrialMax = 6   % Inter trial duration [s] 
        
        defaultPath = 'D:\Science\Data\Pro_CRP\chronicEMG'
        defaultName = [date, '_RUN_', num2str(1),'.mat']
        
        squareHeight = 330;      % size of squares in pixels
        
    end
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties(GetAccess = private, SetAccess = private)
        squareWidth = 180;
        maxForceValue = 100;
                        
        results
    end
 
    properties(Transient, SetAccess = private)
        saved = false
    end
    
    properties(Transient, GetAccess = private, SetAccess = private)
        session        % SensorDAQ object
        window         % Psychtoolbox object
        presentation   % Elements for stimulus presentation
        sequence       % Sequence for the trials
        audio
        dynamometer

        resourcePath = 'C:\Users\Kai\Matlab\MonkeySetup\src\resources';
    end
    
    methods
        function obj = experiment(varargin)
            if nargin == 1
                runNumber = varargin{1};
                obj.setDefaultName(runNumber);
            end
        end
        
        %% Control experiment
        function results = startExperiment(obj)
            s = obj.createDAQSession;
            [w, p] = obj.createOnScreen;
            q = obj.createSequence;
            obj.createAudio;
 
            k = 1; % counter
            results = 0;
            
            topPriorityLevel = MaxPriority(w);
            Priority(topPriorityLevel);
            
            vbl = Screen('Flip', w);
            
            tempData = zeros(obj.maxTrial, q.frames.response);
            data = zeros(obj.maxTrial, q.frames.response);
            smoothData = zeros(obj.maxTrial, q.frames.response);
            scaleData = zeros(q.frames.response, 1);
            succ = zeros(obj.maxTrial, q.frames.response);
            trialSucc = zeros(obj.maxTrial, 1);
            
            for trial = 1:obj.maxTrial
                
                target = q.force(k);
                
                % pre stim time
                for i = 1:q.frames.interval(k)
                    task = 'interval';
                    stop = obj.displayInterval(w, p, task);
                    
                    if ~stop
                        vbl = Screen('Flip', w, vbl + (p.waitframes - 0.5) * p.ifi);
                    else
                        return
                    end
                end

                % stim presentation
                for i = 1:q.frames.presentation
                    stop = obj.displayStimulus(w, p, target, 0);
                    
                    if ~stop
                        vbl = Screen('Flip', w, vbl + (p.waitframes - 0.5) * p.ifi);
                    else
                        return
                    end
                    
                    % only continue when no force is applied
                    tempData(k, i) = obj.dynamometer.scale(s.inputSingleScan);
                    while tempData(k, i) > 0.1
                        tempData(k, i) = obj.dynamometer.scale(s.inputSingleScan);
                        stop = obj.displayStimulus(w, p, target, 666);
                        
                        if ~stop
                            vbl = Screen('Flip', w, vbl + (p.waitframes - 0.5) * p.ifi);
                        else
                            return
                        end
                    end
                end
                
                obj.playSound('start');
                
                % response time
                for i = 1:q.frames.response

                    data(k, i) = obj.dynamometer.scale(s.inputSingleScan);
                    
                    scaleData(i) = (1 - ((data(k, i) / obj.maxForceValue) * obj.sensorSensitivity)) * p.screenYpixels;
                    
                    % smoothing
                    if i > (obj.sensorSmoothing - 1)
                        smoothData(k, i) = mean(scaleData(i - (obj.sensorSmoothing - 1):i));
                        
                        % make sure cursor stays on the screen
                        if smoothData(k, i) > p.screenYpixels
                            smoothData(k, i) = p.screenYpixels - 10;
                            scaleData(i) =  p.screenYpixels - 10;
                        elseif smoothData(k, i) < 0
                            smoothData(k, i) = 10;
                            scaleData(i) = 10;
                        end
                        
                        % Determine succesful frame
                        if smoothData(k, i) < p.rectangleMaxY(target) && smoothData(k, i) > p.rectangleMinY(target)
                            succ(k, i) = 1;
                        else
                            succ(k, :) = 0;
                        end
                        
                        stop = obj.displayStimulus(w, p, target, succ(k, :));
                        
                        if succ(k, i) && obj.lockTarget
                            smoothData(k, i) = p.rectangleMaxY(target) - (obj.squareHeight / 2);
                        end
                        
                        stop = obj.displayResponse(w, p, target, succ(k, :), smoothData(k, i));
                    end
                    
                    if ~stop
                        vbl = Screen('Flip', w, vbl + (p.waitframes - 0.5) * p.ifi);
                    else
                        return
                    end

                    % Determine succesful trial
                    if (sum(succ(k, :)) ~= 0) && (~mod(sum(succ(k, :)), obj.sequence.frames.success))
                        trialSucc(k) = 1;
                        break
                    end
                end
                
                if trialSucc(k)
                    task = 'success';
                else
                    task = 'fail';
                end
                    
                obj.playSound(task);
                
                % reward time
                for i = 1:q.frames.reward
                    stop = obj.displayInterval(w, p, task);
                    
                    if ~stop
                        vbl = Screen('Flip', w, vbl + (p.waitframes - 0.5) * p.ifi);
                    else
                        return
                    end
                end              
                
                % enough successful trials or trials in total
                if sum(trialSucc) == obj.numTrial || k == obj.maxTrial
                    task = 'interval';
                    obj.displayInterval(w, p, task)
                    Screen('Flip', w, vbl + (p.waitframes - 0.5) * p.ifi);
                    obj.stopExperiment(1)
                    
                    obj.results.data = data(1:k, :);
                    obj.results.succFrames = succ(1:k, :);
                    obj.results.succTrials = trialSucc(1:k);
                    obj.results.frameRate = p.frameRate;
                    
                    results = obj.results;
                    
                    obj.playSound('stop');
                    
                    obj.cleanUp
                    return
                end
                
                k = k + 1;
                
            end
            
            obj.playSound('stop');
            obj.cleanUp
        end
        
        function stop = stopExperiment(obj, varargin)
            if nargin == 2
                stop = varargin{1};
            else
                % Poll the keyboard for the space key
                [~, ~, keyCode] = KbCheck(-1);
                stop = keyCode(KbName('ESCAPE'));
            end
            
            if stop
                obj.cleanUp;
            end
        end
        
        function save(obj)
            fName = fullfile(obj.defaultPath, obj.defaultName);
            save(fName, 'obj')
            
            obj.saved = true;
        end
        
        function saveAs(obj, fPath, fName)
            fName = fullfile(fPath, fName);
            save(fName, 'obj')
            
            obj.saved = true;
        end
        
        function plot(obj)
            
            if isempty(obj.results)
                disp('*** Results not present ***')
                disp('*** Run an experiment first ***')
                return
            end
            
            numTrials = length(obj.results.succTrials);
            numPoints = length(obj.results.data(1, :));
            
            figure
            hold on
            
            time = linspace(0, numPoints/obj.results.frameRate, numPoints);
            time = time(1:numPoints);
            
            for i = 1:numTrials
                kgResults = obj.results.data(i,:)'./ 9.81;
                if obj.results.succTrials(i) 
                    plot(time, kgResults, 'g')
                else
                    plot(time, kgResults, 'r')
                end
            end
            
            xlabel('Time [s]')
            ylabel('Force [kg]')
            title(obj.defaultName)
        end
        
        function setDefaultName(obj, num)
            if isnumeric(num)
                obj.defaultName = [date, '_RUN_', num2str(num),'.mat'];
            else
                obj.defaultName = num;
            end   
        end
        
        function delete(obj)
            obj.cleanUp;
        end

    end
    
    methods(Access = private)
        %% Setup
        function [w, p] = createOnScreen(obj)
            % Default settings
            PsychDefaultSetup(2);
            
            % Determine screen and colors
            screens = Screen('Screens');
            screenNumber = max(screens);
            white = WhiteIndex(screenNumber);
            p.grey = white / 2;
            
            % Open an on screen window and prepare rectangles for stim and
            % feedback
            w = PsychImaging('OpenWindow', screenNumber, p.grey);

            [screenXpixels, screenYpixels] = Screen('WindowSize', w);
            p.screenXpixels = screenXpixels;
            p.screenYpixels = screenYpixels;
            
            baseRect = [0 0 obj.squareWidth obj.squareHeight];
            basePointerRect = [0 0 obj.squareWidth*0.66 20];
            
            halfSquare = obj.squareHeight / 2;
            halfScreen = p.screenYpixels / 2;

            if obj.triForce
                stimXpos = [screenXpixels * 0.5 screenXpixels * 0.5 screenXpixels * 0.5]; 
                
                yPos = [halfScreen * ((halfScreen + halfSquare * 2) / halfScreen)...
                    halfScreen * ((halfScreen) / halfScreen)...
                    halfScreen * ((halfScreen - halfSquare * 2) / halfScreen)];
                
                p.allColors = [1 1 1 ; 1 1 1 ; 1 1 1 ];
            else
                stimXpos = [screenXpixels * 0.5 screenXpixels * 0.5 screenXpixels * 0.5 screenXpixels * 0.5 screenXpixels * 0.5];
                
                yPos = [halfScreen * ((halfScreen + halfSquare * 4) / halfScreen)...
                    halfScreen * ((halfScreen + halfSquare * 2) / halfScreen)...
                    halfScreen * ((halfScreen) / halfScreen)...
                    halfScreen * ((halfScreen - halfSquare * 2) / halfScreen)...
                    halfScreen * ((halfScreen - halfSquare * 4) / halfScreen)];
                
                p.allColors = [1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1];
            end
                                                
            numSquares = length(stimXpos);
            
            p.stimRects = nan(4, numSquares);
            
            for i = 1:numSquares
                p.stimRects(:, i) = CenterRectOnPointd(baseRect, stimXpos(i), yPos(i));
            end
            
            p.outpPointer = CenterRectOnPointd(basePointerRect, stimXpos(1), screenYpixels);
            p.rectangleMaxY = yPos + obj.squareHeight/2;
            p.rectangleMinY = yPos - obj.squareHeight/2;
            
            % Keybpard setup
            p.spaceKey = KbName('space');
            p.escapeKey = KbName('ESCAPE');
            RestrictKeysForKbCheck([p.spaceKey p.escapeKey]);
            
            % setup timing
            p.ifi = Screen('GetFlipInterval', w);

            p.frameRate = round(1/p.ifi);
            p.waitframes = 1;
            
            % setup images
            imageLocationCross = fullfile(obj.resourcePath, 'cross.png');
            crossImg = imread(imageLocationCross);
            p.crossTexture = Screen('MakeTexture', w, crossImg);
            
            imageLocationCheck = fullfile(obj.resourcePath, 'checkMark.jpg');
            checkImg = imread(imageLocationCheck);
            p.checkTexture = Screen('MakeTexture', w, checkImg);
            
            obj.window = w;
            obj.presentation = p;
        end
        
        function a = createAudio(obj)
            InitializePsychSound(1);

            a.nrchannels = 2;
            a.freq = 48000;

            a.repetitions = 1;
            a.beepLengthSecs = 1;
            a.beepPauseTime = 1;
            a.startCue = 0;
            
            a.waitForDeviceStart = 1;
                       
            a.myBeep = MakeBeep(500, a.beepLengthSecs, a.freq);
            
            try
                a.pahandle = PsychPortAudio('Open', [], 1, 1, a.freq, a.nrchannels);
            catch
                PsychPortAudio('Stop', obj.audio.pahandle);
                a.pahandle = PsychPortAudio('Open', [], 1, 1, a.freq, a.nrchannels);
            end
            
            PsychPortAudio('Volume', a.pahandle, obj.volAudio);
            
            [wavedata, freq] = audioread(fullfile(obj.resourcePath, 'buzzer.wav'));
            
            a.buzzer.wave = wavedata';
            a.buzzer.freq = freq;
            
            [wavedata, freq] = audioread(fullfile(obj.resourcePath, 'jingle.wav'));
            
            a.jingle.wave = wavedata(:, 2)';
            a.jingle.freq = freq;

            obj.audio = a;
        end
        
        function s = createDAQSession(obj)
            endTime = 0.002;
            fs = 1000;

            s = sdaq.createSession;
            s.Rate = fs;
            s.DurationInSeconds = endTime;
            
            dyno.scale = sdaq.getScaleFun(sdaq.Sensors.HandDynamometer);
            sdaq.addSensor(s,1,sdaq.Sensors.HandDynamometer);
            
            dyno.lh = addlistener(s,'DataAvailable', @(src,event)appendADC(channel, event.TimeStamps, event.Data));
            s.NotifyWhenDataAvailableExceeds = 1;
            
            obj.dynamometer = dyno;
            obj.session = s;
        end
        
        function q = createSequence(obj)
            if obj.intRandom
                rNum = rand(obj.maxTrial, 1);
                iDiff = obj.intTrialMax - obj.intTrialMin;
                
                interval = obj.intTrialMin + iDiff .* rNum;
            else
                interval = ones(obj.maxTrial, 1) * obj.intTrialMin;
            end

            framesInterval = round(interval * obj.presentation.frameRate);
            
            if obj.triForce && ((obj.forceMax > 3) || (obj.forceMin > 3))
                if obj.forceMax > 3
                    obj.forceMax = 3;
                end
                
                if obj.forceMin > 3
                    obj.forceMin = 3;
                end
            end

            if obj.forceRandom
                if obj.forceMin == 1
                    fMin = 0;
                else
                    fMin = obj.forceMin - 1;
                end
                
                factor = obj.forceMax - fMin; 
                force = fMin + ceil(rand(obj.maxTrial, 1) * factor);
            else
                force = ones(obj.maxTrial, 1) * obj.forceMin;
            end
            
            obj.sequence.interval = interval;
            obj.sequence.frames.interval = framesInterval;
            obj.sequence.frames.presentation = obj.durStim * obj.presentation.frameRate;
            obj.sequence.frames.response = obj.durResps * obj.presentation.frameRate;
            obj.sequence.frames.success = obj.durSuccess * obj.presentation.frameRate;
            obj.sequence.frames.reward = obj.durRewar * obj.presentation.frameRate;
            obj.sequence.force = force;
            
            q = obj.sequence;
        end
        
        %% Display
        function stop = displayInterval(obj, w, p, task)
            switch task
                case 'interval'
                    color = p.grey;
                    Screen('FillRect', w, color);
                    
                case 'success'
                    color = [0 1 0];
                    Screen('FillRect', w, color);
                    Screen('DrawTexture', w, p.checkTexture, [], [], 0);
                    
                case 'fail'
                    color = [1 0 0];
                    Screen('FillRect', w, color);
                    Screen('DrawTexture', w, p.crossTexture, [], [], 0);
            end
            
            stop = obj.stopExperiment;
        end

        function stop = displayStimulus(obj, w, p, target, succ)
            
            if succ == 666
                correctFrames = succ;
                factor = 10 * (correctFrames / obj.sequence.frames.success);
                p.stimRects([1, 2], target) = p.stimRects([1, 2], target) - factor;
                p.stimRects([3, 4], target) = p.stimRects([3, 4], target) + factor;
                
                penWidthPixels = 10 + (10 * (correctFrames / obj.sequence.frames.success));
                
                color = [1 0 0];
            elseif sum(succ)
                correctFrames = sum(succ);
                factor = 10 * (correctFrames / obj.sequence.frames.success);
                p.stimRects([1, 2], target) = p.stimRects([1, 2], target) - factor;
                p.stimRects([3, 4], target) = p.stimRects([3, 4], target) + factor;
                
                penWidthPixels = 10 + (10 * (correctFrames / obj.sequence.frames.success));
                
                color = [0 1 0];
            else
                penWidthPixels = 6;
                
                color = [0 0 1];
            end
            
            % Color the screen grey
            Screen('FillRect', w, p.grey);
            
            % Draw rectangles
            Screen('FillRect', w, p.allColors, p.stimRects);
            
            Screen('FillRect', w, color, p.stimRects(:, target));
            Screen('FrameRect', w, color, p.stimRects(:, target), penWidthPixels);
            
            stop = obj.stopExperiment;
        end
        
        function stop = displayResponse(obj, w, p, target, succ, scaleData)
            if sum(succ)
                color = [0 1 0];
                colorPointer = [0 1 0];
                correctFrames = sum(succ);
                factor = (obj.squareHeight / 2) * (correctFrames / obj.sequence.frames.success);
                penWidthPixels = 10; %+ (10 * (correctFrames / obj.sequence.frames.success));
                
                if factor < 10
                    factor = 10;
                elseif factor > ((obj.squareHeight / 2) + 10)
                    factor = obj.squareHeight / 2 + 10;
                end
                
                p.outpPointer(2) = scaleData; % - factor;
%                 p.outpPointer(4) = scaleData + factor;
            else
                color = [0 0 1];
                colorPointer = [1 0 0];
                penWidthPixels = 10;
                p.outpPointer(2) = scaleData - 10;
%                 p.outpPointer(4) = scaleData + 10;
            end
            
            Screen('FillRect', w, color, p.stimRects(:, target));
            Screen('FillRect', w, colorPointer, p.outpPointer, penWidthPixels);
            Screen('FrameRect', w, [0 0 0], p.outpPointer, penWidthPixels);
            
            stop = obj.stopExperiment;
        end
        
        function playSound(obj, type)
            aux = obj.audio;
            
            switch type
                case 'start'                    
                    PsychPortAudio('FillBuffer', aux.pahandle, [aux.myBeep; aux.myBeep]);
                    PsychPortAudio('Start', aux.pahandle, aux.repetitions, aux.startCue, aux.waitForDeviceStart);
                    
                case 'success'
                    PsychPortAudio('FillBuffer', aux.pahandle, [aux.jingle.wave; aux.jingle.wave]);
                    PsychPortAudio('Start', aux.pahandle, aux.repetitions, aux.startCue, aux.waitForDeviceStart);
                    
                case 'fail'
                    PsychPortAudio('FillBuffer', aux.pahandle, [aux.buzzer.wave; aux.buzzer.wave]);
                    PsychPortAudio('Start', aux.pahandle, aux.repetitions, aux.startCue, aux.waitForDeviceStart);
                    
                case 'stop'
                    try
                        PsychPortAudio('Stop', aux.pahandle);
                    catch
                    end
            end
            
            obj.audio = aux;
        end
        
        %% Helper
        function cleanUp(obj)
            Priority(0);
            sca;
            obj.playSound('stop')
            delete(obj.session)
            
            try
                PsychPortAudio('Close', obj.audio.pahandle);
                disp('*** Closed Audio Port ***')
            catch
                disp('*** Could not close Audio Port ***')
            end
            
            disp('*** Experiment terminated ***');
        end
    end
end