clear

% methods classDYNAMIXEL % ���\�b�h�\��
xm430 = classDYNAMIXEL('COM3', 1e6); % (port, baud)

try
    
    DynIDAll = zeros(18,1);
    DynIDAll = 1:18;
    xm430.writeOperatingMode(DynIDAll, 3*ones(18,1));
    xm430.writeTorqueEnable(DynIDAll, 0*ones(18,1));
    xm430.writeStatusReturnLevel(DynIDAll, 1*ones(18,1));
    xm430.writeReturnDelayTime(DynIDAll, 5*ones(18,1));
    disp(xm430.readStatusReturnLevel(DynIDAll).' );
    disp(xm430.readReturnDelayTime(DynIDAll).' );
    disp(xm430.readDriveMode(DynIDAll).' );
%     Drive Mode
%     1     0     1     1     0     1     1     1     0     1     1     0     1     0     1     1     1     0
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end
