clear

% methods classDYNAMIXEL % メソッド表示
xm430 = classDYNAMIXEL('COM3', 1e6); % (port, baud)

try
    
    DynId = [1; 2; 3];
    xm430.writeOperatingMode(DynId, 3*ones(3,1));
    xm430.writeTorqueEnable(DynId, 1*ones(3,1));

    Home = cell(6);
    Home{1} = [1345; 2282; 2526];
    Home{2} = [2067; 2045; 1032];
    Home{3} = [2042; 2072; 2015]; % 範囲未設定
    Home{4} = [2036; 2083; 2035];
    Home{5} = [2049; 2103; 2014];
    Home{6} = [1551; 2032; 2030];
    
    Len = [ 0.076; 0.129 ];
    Ang = [-pi/3; -pi/4; -pi/4 ];
    
    Goal = Ang/0.088*180/pi;
    xm430.writeGoalPosition(DynId, Goal+Home{1});
    pause(1.0);
%     fprintf('PresentPosition1: %d\n',xm430.readPresentPosition(DynId));
%     tic;
%     toc

    BasePos = funcFwKine(Ang, Len);
    Ref =  [ 0; -0.030; 0 ] + BasePos;
    Pos = BasePos;
    
%     time = tic;
%     while ( toc(time) < 1 )
%         dX = (Ref-Pos)/10;
%         Ang = Ang+funcJacbInvKine(Ang, dX, Len);
%         xm430.writeGoalPosition(DynId, Ang/0.088*180/pi+Home{1});
%         Pos = funcFwKine(Ang, Len);
%     end
    
    
    r = 0.030;
    h = 0.060;
    rate = 0.5;
    time = tic;
    nowTime = toc(time);
    ExTime = 5;
%     for ii=0:0.1:2*pi
%         Phase = ii;
%         xy = FootTrajectory( Phase, r, h, rate )
%     end
    ii=0;
    while ( nowTime < ExTime )
        ii=ii+1;
        Phase = 2*pi*nowTime/ExTime*3;
        while Phase > 2*pi
            Phase = Phase - 2*pi;
        end
        xy = FootTrajectory( Phase, r, h, rate );
        Ref =  [ 0; xy(1); xy(2) ] + BasePos;
%         Ref =  [ 0; 0; 0 ] + BasePos;

        Pos = funcFwKine(Ang, Len);
        dX = (Ref-Pos)/10;
        Ang = Ang+funcJacbInvKine(Ang, dX, Len);
        xm430.writeGoalPosition(DynId, Ang/0.088*180/pi+Home{1});

        nowTime = toc(time);
    end

%     Goal = [ 0; 0; 0];
%     xm430.writeGoalPosition(DynId, Goal+Home{1}); pause(1.0);
    pause(1.0);
%     xm430.writeTorqueEnable(DynId, 0*ones(3,1));
    
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end

function xy = FootTrajectory( Phase, r, h, rate )
    xy = zeros(2,1);
    if ( Phase < 2*pi*(1-rate) )
        Theta = Phase/(1-rate)/2;
        xy(1) = r*cos(Theta);
        xy(2) = h*sin(Theta);
    else % 2*pi*(1-rate) <= Phase <= 2*pi
        Theta = (Phase-2*pi*(1-rate))/rate/2;
        xy(1) = -r*cos(Theta);
        xy(2) = 0;
    end
end
