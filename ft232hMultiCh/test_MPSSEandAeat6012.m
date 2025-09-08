
clear;

mpsse = py.MPSSEMultiCh.MPSSEMultiCh('./libMPSSE.dll');
mpsse.showDevices();
% mpsse.openChannel(0, 3e5, 1, 0);
ch = mpsse.openChannelFromSerial('FTL35PIN', 1e6, 1, 0);
cs = 1;
aeat6012 = classAeat6012(mpsse);
disp(aeat6012.readAsDigit(ch, cs));
disp(aeat6012.readAsFloat(ch, cs));
disp(aeat6012.readAsDigitAtOnce(ch, [0;1;2;3;4;5;6;7])');
disp(aeat6012.readAsFloatAtOnce(ch, [0;1;2;3;4;5;6;7])');

tic;
for ii=1:5
    aeat6012.readAsDigitAtOnce(ch, (0:7)');
end
toc
mpsse.closeChannel(ch);


