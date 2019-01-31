function pureDAQ

s = daq.createSession('ni');
addAnalogInputChannel(s,'Dev1', 0, 'Voltage');
s.Rate = 1000;
s.DurationInSeconds = 5;

lh = addlistener(s,'DataAvailable', @(src,event) plot(event.TimeStamps, event.Data));

s.NotifyWhenDataAvailableExceeds = 1000;

s.wait()

delete(lh)