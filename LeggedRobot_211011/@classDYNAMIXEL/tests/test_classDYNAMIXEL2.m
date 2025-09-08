clear

% methods classDYNAMIXEL % メソッド表示
% xm430 = classDYNAMIXEL('COM3', 57600); % (port, baud)
xm430 = classDYNAMIXEL('COM3', 1e6); % (port, baud)
% BAUD, 0:9600, 1:57600(Default), 2:115200, 3:1e6, 4:2e6, 5:3e6, 6:4e6, 7:4.5e6

try
%     xm430.writeTorqueEnable(1, 0);
%     xm430.write1ByteTxRx(1, 9, 1); % ReturnDelayTime 1:2us
%     xm430.write1ByteTxRx(1, 68, 0); % Status Packet will not be returned for all Instructions.
    % xm430.write1ByteTxRx(1, 10, 0); % DriveMode 0:CW, 1:CCW

    %{
    % LEDのテスト
    xm430.write1ByteTxRx(1, 65, bitxor(xm430.read1ByteTxRx(1, 65), 1));
    fprintf("LED1: %d\n", xm430.read1ByteTxRx(1, 65));
    pause(1.0);
    xm430.writeLED([1;2;3], [bitxor(xm430.read1ByteTxRx(1, 65), 1);1;1]); % writeLED(dxl_ID, value)
    fprintf("LED1: %d\n", [1,0,0]*xm430.readLED([1;2;3])); % value = readTxRx(self, protocol_version, dxl_ID, addr, length)
    xm430.writeLED([1;2;3], [bitxor(xm430.read1ByteTxRx(1, 65), 1);1;1]); % writeLED(dxl_ID, value)
    %}
    
    %{
    % Position Control
    %}
    
    Home = cell(3);
    
    DynId = [1; 2];
    xm430.writeOperatingMode(DynId, 3*ones(2,1));
    % disp(xm430.read1ByteTxRx(1, 11));   % read OperatingMode
    % 0: Current, 1: Velocity, 3: Position(default), 4, 5, 16
    xm430.writeTorqueEnable(DynId, 1*ones(2,1));

    Goal = [90; 90]/0.088;
    tic;
    xm430.writeGoalPosition(DynId, Goal);
    dt1 = toc;
    pause(1.0);
    tic;
    Pos = xm430.readPresentPosition(DynId);
    dt2 = toc;
    fprintf('PresentPosition1: %.2f, %.2f\n',Pos(1)*0.088, Pos(2)*0.088);
    fprintf('dt%.2f, %.2f ms\n',dt1*1e3, dt2*1e3);
    Goal = [ 0; 0 ];
    xm430.writeGoalPosition(DynId, Goal); pause(1.0);
    pause(1.0);
%     fprintf('PresentPosition1: %d\n',xm430.readPresentPosition(DynId));
    xm430.writeTorqueEnable(DynId, 0*ones(3,1));
    
    %{
    % Current Control
    xm430.writeTorqueEnable(1, 0);
    xm430.writeOperatingMode(1, 0);
    xm430.writeTorqueEnable(1, 1);
    xm430.writeGoalCurrent(1, 5);
    pause(1.0);
    xm430.writeGoalCurrent(1, 0);
    xm430.writeTorqueEnable(1, 0);
    %}

    %{
    % Velocity Control
    xm430.writeTorqueEnable(1, 0);
    xm430.writeOperatingMode(1, 1);
    xm430.writeTorqueEnable(1, 1);
    tic;
    xm430.writeGoalVelocity(1, 200);    % limit注意、default 200
    toc
    pause(1.0);
    tic;
    xm430.write4ByteTxOnly(1, 104, 50);
    toc
    pause(1.0);
    xm430.writeGoalVelocity(1, 0);    % limit注意、default 200
    xm430.writeTorqueEnable(1, 0);
    %}
    
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end

