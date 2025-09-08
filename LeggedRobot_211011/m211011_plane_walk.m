% clear

%% setup
% methods classDYNAMIXEL % to show method list
xm430 = classDYNAMIXEL('COM4', 1e6); % (port, baud)
if (xm430.failed == 1)
    return;
end
try
    exit_flag = 0;
    subPyGameInit;
    if exit_flag == 1
        disp('no joystick.');
        return;
    end
    
    mpsse = MPSSE();
    mpsse.showDevices();
    mpsse.openChannel(0);
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
    
    subDynInit;
    
    yCoordinateDirection = [1; -1; 1; -1; 1; -1];
    rate = 2/3*1.01;
    leftRightDelay = 2*pi/3;
    phaseDelay = [0; leftRightDelay; ...
                2*pi/3; 2*pi/3+leftRightDelay;...
                4*pi/3; 4*pi/3+leftRightDelay]; % 4-legs move
%     rate = 0.5*1.01;
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
%     r = 0.020;
%     p1 = [r; r];
%     p2 = [-r; -r];
% Sonoba
    p1 = [0; 0];
    p2 = [0; 0];
    Euler = [0; 0; 0];

    h = 0.060;
    time = tic;
    nowTime = toc(time);

%%  Initialize Leg angle
    while ( nowTime < 3 )
        Phase = 0;
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
            Pos{ii} = funcFwKine(Ang{ii}, Len);
            dX = (Ref{ii}-Pos{ii})/20;
            Ang{ii} = Ang{ii}+funcJacbInvKine(Ang{ii}, dX, Len);
        end

        for jj=1:6
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        end
        nowTime = toc(time);
    end
    
%% Walk   
    data = zeros( 1e4, 15);
    total_time = tic;
    counter = 0;
    time = tic;
    dt = 0;
    Phase = 0;
    while startButton==0
        time = tic;
%         torque = zeros(6,1);
%         torque = xm430.readPresentCurrent([2,5,8,11,14,17]);
        py.pygame.event.pump();
        startButton = double(joy.get_button(int8(7)));
        bButton = double(joy.get_button(int8(0)));
        lStick = [joy.get_axis(int8(0)); joy.get_axis(int8(1))];
        rStick = [joy.get_axis(int8(3)); joy.get_axis(int8(4))];
        if abs(lStick(1)) < 0.1
            lStick(1) = 0;
        end
        if abs(lStick(2)) < 0.1
            lStick(2) = 0;
        end
        if abs(rStick(1)) < 0.1
            rStick(1) = 0;
        end
        sNorm = norm([ lStick(1); lStick(2); rStick(1) ]);
        if (sNorm > 1)
            lStick = lStick/sNorm;
            rStick = rStick/sNorm;
        end

%     while ( nowTime < ExTime )
        Phase = Phase + 4*dt*norm([rStick(1); lStick(1); lStick(2)]);
        while Phase > 2*pi
            Phase = Phase - 2*pi;
        end
        Euler = zeros(3,1);
        
        dEuler = [ 0; 0; -rStick(1)*0.1];
        Vel = [-lStick(2)*0.025; -lStick(1)*0.020; 0];
        Phaseii = zeros(6,1);
        for ii=1:6
            Phaseii(ii) = Phase-phaseDelay(ii);
            while Phaseii(ii) > 2*pi
                Phaseii(ii) = Phaseii(ii) - 2*pi;
            end
            while Phaseii(ii) < 0 
                Phaseii(ii) = Phaseii(ii) + 2*pi;
            end
            % Issue
            % - body height control,
            % - solving leg float problem
            % - Inverse kinematics solver
            %    * Error processing
            variation = FootTrajectory( Phaseii(ii), rate, h, p1, p2);
            dRootMod = functionR_IB([0;0;-yCoordinateDirection(ii)*pi/2])*(Vel+funcdPosMatrix(Euler, RootPos{ii})*dEuler);
            RootMod{ii} = RootMod{ii} + dRootMod*dt;
            % Soft Reset for mod. 
            RootMod{ii} = RootMod{ii} - RootMod{ii}*variation(3)*1e3*dt;
            % if variation(3) > h/5
            %     RootMod{ii} = [0; 0; 0];
            % end
            sign1 = yCoordinateDirection(ii);
            Ref{ii} =  diag([sign1; sign1; 1])*variation + BasePos{ii} + RootMod{ii};
            % Ref{ii} =  diag([sign1; sign1; 1])*variation + BasePos{ii} + [0;0;0.05];
            % Ref{ii} =  [ 0; 0; 0 ] + BasePos{ii};
        end

        AngAll = zeros(18,1);
        HomeAll = zeros(18,1);
        for ii=1:6
            Pos{ii} = funcFwKine(Ang{ii}, Len);
            dX = (Ref{ii}-Pos{ii})/3;
            Ang{ii} = Ang{ii}+funcJacbInvKine(Ang{ii}, dX, Len);
            AngAll(1+3*(ii-1):3+3*(ii-1)) = Ang{ii};
            HomeAll(1+3*(ii-1):3+3*(ii-1)) = Home{ii};
%             xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        end
        xm430.writeGoalPosition(DynIDAll, AngAll/0.088*180/pi+HomeAll);
        
        % data save
        counter = counter + 1;
        nowTime = toc(total_time);
        X = OrderMatrix*mpsse.gpioReadAsVector();
%         variation(3)
        data(counter,:) = [nowTime, Ref{1}(3), Ref{2}(3), Ref{3}(3), Ref{4}(3), Ref{5}(3), Ref{6}(3), X.'];

        dt = toc(time);
    end

    pause(1.0);
    data = data(1:counter,:);
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
%         ret(3) = h*sin(Phi);
        ret(3) = h*(1+cos(Phi))/2;
    end
    
end
