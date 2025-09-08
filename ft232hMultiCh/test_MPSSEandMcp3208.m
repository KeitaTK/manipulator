
clear;

mpsse = py.MPSSEMultiCh.MPSSEMultiCh('./libMPSSE.dll');
mpsse.showDevices();
% mpsse.openChannel(0, 3e5, 1, 0);
ch = mpsse.openChannelFromSerial('FTNPK1U0', 3e5, 1, 0);
cs = 0;
mcp3208 = classMcp3208(mpsse);
disp(mcp3208.analogReadAsDigit(ch, cs, 0));
disp(mcp3208.analogReadAsFloat(ch, cs, 0));
disp(mcp3208.analogReadAsDigitAtOnce(ch, cs, [0;1;2;3;4;5;6;7])');
disp(mcp3208.analogReadAsFloatAtOnce(ch, cs, [0;1;2;3;4;5;6;7])');

tic;
for ii=1:5
    mcp3208.analogReadAsDigitAtOnce(ch, cs, (0:7)');
end
toc
mpsse.closeChannel(ch);


