latmode = 4;
freq = 48000;
minLatency = 1;

painput = PsychPortAudio('Open', [], 2, latmode, freq, 2, [], minLatency);
paoutput = PsychPortAudio('Open', [], 1, latmode, freq, 2, [], minLatency);