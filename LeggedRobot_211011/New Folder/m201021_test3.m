clear

% methods classDYNAMIXEL % メソッド表示
xm430 = classDYNAMIXEL('COM3', 1e6); % (port, baud)

try
    
    DynIDAll = zeros(18,1);
    DynIDAll = 1:18;
    xm430.writeOperatingMode(DynIDAll, 3*ones(18,1));
    xm430.writeTorqueEnable(DynIDAll, 1*ones(18,1));

    DynId = cell(6);
    DynId{1} = [1; 2; 3];
    DynId{2} = [4; 5; 6];
    DynId{3} = [7; 8; 9];
    DynId{4} = [10; 11; 12];
    DynId{5} = [13; 14; 15];
    DynId{6} = [16; 17; 18];

    Home = cell(6);
    Home{1} = [1345; 2282; 2526];
    Home{2} = [2067; 2045; 1007];
    Home{3} = [2042; 2072; 2015]; % 範囲未設定
    Home{4} = [2036; 2083; 2035];
    Home{5} = [2049; 2103; 2014];
    Home{6} = [1551; 2032; 2030];

    Ang = cell(6,1);
    Ang{2} = [ 0; 0; pi/4];
    
%     xm430.writeGoalPosition(DynId{1}, Home{1});
    xm430.writeGoalPosition(DynId{2}, Home{2});
%     xm430.writeGoalPosition(DynId{3}, Home{3});
%     xm430.writeGoalPosition(DynId{4}, Home{4});
%     xm430.writeGoalPosition(DynId{5}, Home{5});
%     xm430.writeGoalPosition(DynId{6}, Home{6});
    pause(1.0);
    xm430.writeGoalPosition(DynId{2}, Ang{2}/0.088*180/pi+Home{2});
    pause(1.0);

    xm430.writeTorqueEnable(DynIDAll, 0*ones(18,1));
    
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end
