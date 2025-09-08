clear

% methods classDYNAMIXEL % To display methods
% xm430 = classDYNAMIXEL('COM3', 57600); % (port, baud)
xm430 = classDYNAMIXEL('COM3', 1e6); % (port, baud)
% BAUD, 0:9600, 1:57600(Default), 2:115200, 3:1e6, 4:2e6, 5:3e6, 6:4e6, 7:4.5e6

try
    DynId = [1; 2];
    xm430.writeOperatingMode(DynId, 3*ones(2,1));
    xm430.writeTorqueEnable(DynId, 1*ones(2,1));

    Goal = [90; 90]/0.088;

    tic
    groupNum = xm430.groupSyncWrite(uint16(116), 4);
    result = xm430.groupSyncWriteAddParam(groupNum, 1, Goal(1), 4);
    if result ~= true
        fprintf('[ID:%03d] groupSyncWrite addparam failed', 1);
        return;
    end
    result = xm430.groupSyncWriteAddParam(groupNum, 2, Goal(2), 4);
    if result ~= true
        fprintf('[ID:%03d] groupSyncWrite addparam failed', 2);
        return;
    end
    xm430.groupSyncWriteTxPacket(groupNum);
    toc
    pause(1.0);

    % tic;
    % xm430.writeGoalPosition(DynId, Goal);
    % dt1 = toc;
    % pause(1.0);
    % tic;
    % Pos = xm430.readPresentPosition(DynId);
    % dt2 = toc;
    % fprintf('PresentPosition1: %.2f, %.2f\n',Pos(1)*0.088, Pos(2)*0.088);
    % fprintf('dt%.2f, %.2f ms\n',dt1*1e3, dt2*1e3);
    Goal = [ 0; 0 ];
    xm430.writeGoalPosition(DynId, Goal); pause(1.0);
    pause(1.0);
    xm430.writeTorqueEnable(DynId, 0*ones(3,1));
    
     
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end

