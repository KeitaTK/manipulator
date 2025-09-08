clear

% methods classDYNAMIXEL % メソッド表示
xm430 = classDYNAMIXEL('COM4', 1e6); % (port, baud)
if (xm430.failed == 1)
    return;
end

try
    
    subDynInit;
%     for ii=1:6
%         xm430.writeGoalPosition(DynId{ii}, Home{ii});
%         pause(1.0);
%     end

    % 構え
    Len = [ 0.076; 0.129 ];
    Ang = cell(6,1);
    Goal = cell(6,1);
    Ang{1} = [ -pi/3; pi/3; -2*pi/3 ];
    Ang{4} = [ 0; pi/3; -2*pi/3 ];
    Ang{5} = [ pi/3; pi/3; -2*pi/3 ];
    Ang{2} = [ pi/3; pi/3; -2*pi/3 ];
    Ang{3} = [ 0; pi/3; -2*pi/3 ];
    Ang{6} = [ -pi/3; pi/3; -2*pi/3 ];
    
    for ii=1:6
        Goal{ii} = Ang{ii}/0.088*180/pi;
%         xm430.writeGoalPosition(DynId{ii}, Goal{ii}+Home{ii});
%         pause(0.2);
%         xm430.writeGoalPosition(DynId{ii}, Goal{ii}+Home{ii});
%         pause(0.2);
%         xm430.writeGoalPosition(DynId{ii}, Goal{ii}+Home{ii});
%         pause(0.2);
    end
%     pause(1.0);
    
    % ある程度浮かせる
    Pos = cell(6,1);
    BasePos = cell(6,1);
    Ref = cell(6,1);
    vec = [1; 4; 5];
    for ii=1:3
        jj = vec(ii);
        BasePos{jj} = funcFwKine(Ang{jj}, Len);
        Ref{jj} = [0;0; -0.050] + BasePos{jj};
    end
    time = tic;
    nowTime = toc(time);
    ExTime = 2;
    while ( nowTime < ExTime )

        for ii=1:3
            jj = vec(ii);
            Pos{jj} = funcFwKine(Ang{jj}, Len);
            dX{jj} = (Ref{jj}-Pos{jj})/10;
            Ang{jj} = Ang{jj}+funcJacbInvKine(Ang{jj}, dX{jj}, Len);
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        end

        nowTime = toc(time);
    end
%     pause(1.0);
    
    % ある程度合わせる
    Ang{2} = [  pi/3; pi/4; -pi/2 ];
    Ang{3} = [     0; pi/4; -pi/2 ];
    Ang{6} = [ -pi/3; pi/4; -pi/2 ];
    vec = [2; 3; 6];
    for ii=1:3
        jj = vec(ii);
        xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
    end
%     pause(1.0);
    
    % -0.096に足を持ってくる
    %        0.0269; 0.0465; -0.096
    %     0.0537; 0; -0.096
    %     Ref = cell(6,1);
    Ref{1} = [0.0269; -0.0465; -0.096];
    Ref{6} = [0.0269; -0.0465; -0.096];
    Ref{2} = [0.0269; 0.0465; -0.096];
    Ref{5} = [0.0269; 0.0465; -0.096];
    Ref{3} = [0.0537; 0.0; -0.096];
    Ref{4} = [0.0537; 0.0; -0.096];
    time = tic;
    nowTime = toc(time);
    ExTime = 2;
    vec = [2; 3; 6];
    while ( nowTime < ExTime )

        for ii=1:3
            jj = vec(ii);
            Pos{jj} = funcFwKine(Ang{jj}, Len);
            dX{jj} = (Ref{jj}-Pos{jj})/10;
            Ang{jj} = Ang{jj}+funcJacbInvKine(Ang{jj}, dX{jj}, Len);
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        end

        nowTime = toc(time);
    end
%     pause(1.0);

    % 高さを    -0.1827
    Ref{1} = [0.0269; -0.0465; -0.1827];
    Ref{6} = [0.0269; -0.0465; -0.1827];
    Ref{2} = [0.0269; 0.0465; -0.1827];
    Ref{5} = [0.0269; 0.0465; -0.1827];
    Ref{3} = [0.0537; 0.0; -0.1827];
    Ref{4} = [0.0537; 0.0; -0.1827];
    time = tic;
    nowTime = toc(time);
    ExTime = 2;
    vec = [1;4;5];
    while ( nowTime < ExTime )

        for ii=1:3
            jj = vec(ii);
            Pos{jj} = funcFwKine(Ang{jj}, Len);
            dX{jj} = (Ref{jj}-Pos{jj})/10;
            Ang{jj} = Ang{jj}+funcJacbInvKine(Ang{jj}, dX{jj}, Len);
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        end

        nowTime = toc(time);
    end
%     pause(1.0);
    time = tic;
    nowTime = toc(time);
    ExTime = 2;
    vec = [2;3;6];
    while ( nowTime < ExTime )

        for ii=1:3
            jj = vec(ii);
            Pos{jj} = funcFwKine(Ang{jj}, Len);
            dX{jj} = (Ref{jj}-Pos{jj})/10;
            Ang{jj} = Ang{jj}+funcJacbInvKine(Ang{jj}, dX{jj}, Len);
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
            xm430.writeGoalPosition(DynId{jj}, Ang{jj}/0.088*180/pi+Home{jj});
        end

        nowTime = toc(time);
    end
%     pause(1.0);
%     xm430.writeTorqueEnable(DynIDAll, 0*ones(18,1));
    
    xm430.closePort();
catch MExc
    disp(MExc.message);
    xm430.closePort();
end
