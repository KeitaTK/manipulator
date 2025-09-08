clear

%
% Driver: CP2102 vcp
%

methods classDynPickMini
list = seriallist

a = classDynPickMini(list(1));
% a.resetOffset();

[value, num] = a.readRawLSB()
[value, num] = a.read()
[value, num, time_ms] = a.readWithTimeMeasure()

a.startDataSending();
pause(0.5);

[value, num] = a.continuousRead()
[value, num, time_ms] = a.continuousReadWithTimeMeasure()

a.stopDataSending();
% clear;

% xx = [
%         8192
%         8188
%         8203
%         8193
%         8191
%         8183
% ];
