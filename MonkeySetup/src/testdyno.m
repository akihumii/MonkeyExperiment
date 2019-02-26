clear
close all
clc

t = tcpip('127.0.0.1', 45454, 'NetworkRole', 'client');

fopen(t);

d = 0.59021;

endTime = 0.002;
fs = 1250;

s = sdaq.createSession();
s.Rate = fs;
s.DurationInSeconds = endTime;

dyno.scale = sdaq.getScaleFun(sdaq.Sensors.HandDynamometer);
sdaq.addSensor(s,1,sdaq.Sensors.HandDynamometer);

dyno.lh = addlistener(s,'DataAvailable', @(src,event)appendADC(channel, event.TimeStamps, event.Data));
s.NotifyWhenDataAvailableExceeds = 1;

dynamometer = dyno;
session = s;

% sdaq.addAnalogOutput(s);
% s.outputSingleScan(3.3);

while(1)
%     s.outputSingleScan(3.3);
%     pause(1);
%     s.outputSingleScan(0);
%     pause(1);
   fwrite(t, dynamometer.scale(s.inputSingleScan), 'double');
end

fclose(t);