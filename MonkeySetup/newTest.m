function newTest
%     s = daq.createSession('ni');
%     s.Rate = 100;
%     s.DurationInSeconds = 5;
% 
%     ch1 = addAnalogInputChannel(s,'Dev1','_sensor0_5V','Voltage');
%     
%     s.NotifyWhenDataAvailableExceeds = 100;
%     lh = addlistener(s,'DataAvailable', @(src,event) plot(event.TimeStamps, event.Data));
% 
%     s.startBackground();
%     
%     disp('Go')
%     s.wait();
%     delete(lh)

audioInPT
    
end

% function plotData(src,event)
%     plot(event.TimeStamps, event.Data)
% end

function audioInPT

BasicSoundInputDemo(test, 0, inf)

end
