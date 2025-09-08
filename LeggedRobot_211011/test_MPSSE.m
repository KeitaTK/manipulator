clear;

%     mpsse = MPSSE('./libMPSSE.dll')
%     mpsse.showDevices()
%     mpsse.openChannel(0)
% 
%     print(mpsse.gpioRead())

mpsse = MPSSE();
mpsse.showDevices();
mpsse.openChannel(1);
% mpsse.gpioRead();
disp(mpsse.gpioRead());
OrderMatrix = [ 0 1 0 0 0 0 0 0;
                1 0 0 0 0 0 0 0;
                0 0 1 0 0 0 0 0;
                0 0 0 1 0 0 0 0;
                0 0 0 0 1 0 0 0;
                0 0 0 0 0 1 0 0;
                0 0 0 0 0 0 1 0;
                0 0 0 0 0 0 0 1 ];
X = OrderMatrix*mpsse.gpioReadAsVector();
disp(X.');

% a = py.MPSSE.MPSSE('./libMPSSE.dll');