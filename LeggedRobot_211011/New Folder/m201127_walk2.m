clear

% methods classDYNAMIXEL % to show method list
xm430 = classDYNAMIXEL('COM4', 1e6); % (port, baud)
if (xm430.failed == 1)
    return;
end
try
    
    DynIDAll = zeros(18,1);
    DynIDAll = 1:18;

    DynId = cell(6);
    DynId{1} = [1; 2; 3];
    DynId{2} = [4; 5; 6];
    DynId{3} = [7; 8; 9];
    DynId{4} = [10; 11; 12];
    DynId{5} = [13; 14; 15];
    DynId{6} = [16; 17; 18];

    xm430.writeOperatingMode(DynIDAll, 3*ones(18,1));
    xm430.writeTorqueEnable(DynIDAll, 1*ones(18,1));

    Home = cell(6);
    Home{1} = [1345; 2282; 2526];
    Home{2} = [2067; 2045; 2034];
    Home{3} = [2042; 2072; 2015]; % Position Restriction is NOT set.
    Home{4} = [2036; 2083; 2035];
    Home{5} = [2049; 2103; 2014];
    Home{6} = [1551; 2032; 2030];
    
    Len = [ 0.076; 0.129 ];
    Ang = cell(6,1);
    Ang{1} = [ -pi/3; -pi/4; -pi/4 ];
    Ang{4} = [ 0; -pi/4; -pi/4 ];
    Ang{5} = [ pi/3; -pi/4; -pi/4 ];
    Ang{2} = [ pi/3; -pi/4; -pi/4 ];
    Ang{3} = [ 0; -pi/4; -pi/4 ];
    Ang{6} = [ -pi/3; -pi/4; -pi/4 ];
    
    BasePos = cell(6,1);
    Pos = cell(6,1);
    Ref = cell(6,1);
    for ii=1:6
        BasePos{ii} = funcFwKine(Ang{ii}, Len);
        xm430.writeGoalPosition(DynId{ii}, Ang{ii}/0.088*180/pi+Home{ii});
    end
    pause(1.0);
    
    yCoordinateDirection = [1; -1; 1; -1; 1; -1];
    rate = 2/3*1.1;
    leftRightDelay = pi;
    mod = pi/6;
    phaseDelay = [0; leftRightDelay; ...
                pi/3+mod; pi/3+leftRightDelay+mod;...
                2*pi/3+2*mod; 2*pi/3+leftRightDelay+2*mod]; % 4-legs move
%     rate = 0.5;
%     phaseDelay = [0; pi; pi; 0; 0; pi]; % 3-legs move
  
% Forward
%     r = 0.030;
%     p1 = [0; r];
%     p2 = [0; -r];
% Right hand side
%     r = 0.030;
%     p1 = [r; 0];
%     p2 = [-r; 0];
% Forward-Right hand side
    r = 0.020;
    p1 = [r; r];
    p2 = [-r; -r];

    h = 0.060;
    time = tic;
    nowTime = toc(time);
    ExTime = 12;
    while ( nowTime < ExTime )
        Phase = 2*pi*nowTime/ExTime*5;
        while Phase > 2*pi
            Phase = Phase - 2*pi;
        end
%         vec = [1;5;3];
%         for jj=1:2
%             ii = vec(jj);
        for ii=1:6
            Phaseii = Phase-phaseDelay(ii);
            if Phaseii < 0
                Phaseii = Phaseii + 2*pi;
            elseif Phaseii > 2*pi
                Phaseii = Phaseii - 2*pi;
            end
            variation = FootTrajectory( Phaseii, rate, h, p1, p2);
            sign1 = yCoordinateDirection(ii);
            Ref{ii} =  diag([sign1; sign1; 1])*variation + BasePos{ii};
%             Ref{ii} =  diag([sign1; sign1; 1])*variation + BasePos{ii} + [0;0;0.05];
            % Ref =  [ 0; 0; 0 ] + BasePos;
            Pos{ii} = funcFwKine(Ang{ii}, Len);
            dX = (Ref{ii}-Pos{ii})/10;
            Ang{ii} = Ang{ii}+funcJacbInvKine(Ang{ii}, dX, Len);
        end

        for jj=1:6
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        end

        nowTime = toc(time);
    end

    pause(1.0);
%     xm430.writeTorqueEnable(DynId, 0*ones(3,1));
    
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end

function ret = FootTrajectory( Phase, rate, h, p1, p2)
    ret = zeros(3,1);
    % Phase modification
    rateRad = rate*2*pi;
    if Phase <= rateRad
        Phi = pi*Phase/rateRad;
    else
        Phi = pi*(Phase-rateRad)/(2*pi-rateRad) + pi;
    end
    
    if Phi <= pi
        % p1 -> p2 ( ground )
        ret(1:2) = (p2-p1)*Phi/pi + p1;
    else
        % p2 -> p1 ( float )
        Phi = Phi - pi;
        ret(1:2) = (p1-p2)*Phi/pi + p2;
        ret(3) = h*sin(Phi);
    end
    
end
