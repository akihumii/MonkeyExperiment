function [sensor, channel, settings, aH] = test
    settings.endTime = 0.001;
    settings.sampleInt = 0.010;
    settings.fs = 1000;
    
    channel = channelPkg.chanWaveform;

    aH = plot(NaN,NaN);
    hold on

%     aH = 0;

    s = sdaq.createSession;
    s.Rate = settings.fs;
    s.DurationInSeconds = settings.endTime;

    settings.scale = sdaq.getScaleFun(sdaq.Sensors.HandDynamometer);
    sdaq.addSensor(s,1,sdaq.Sensors.HandDynamometer);
    
    settings.lh = addlistener(s,'DataAvailable', @(src,event)appendADC(channel, event.TimeStamps, event.Data));
    s.NotifyWhenDataAvailableExceeds = 1;
    sensor = s;
    
%     addAnalogInputChannel(s,'Dev1', 0, 'Voltage');
    
%     s.startBackground;
%     s.wait();
%     tstart = tic;
%     while (toc(tstart) < settings.endTime)
%         adc = s.startForeground();
%         plotADC(adc, aH, settings)
%     end
% 
%     delete(s)
%     delete(settings.lh)
end

function appendADC(channel, timing, adc)
    values.adc = adc;
    channel.appendData(values);
end

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
