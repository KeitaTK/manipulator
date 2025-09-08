BAUDRATE = uint32(1e6);
DEVICENAME = 'COM4';
try
    if isempty(xm430)
        xm430 =  py.Dynamixel.Dynamixel(DEVICENAME, BAUDRATE);
    end
catch
    xm430 =  py.Dynamixel.Dynamixel(DEVICENAME, BAUDRATE);
end

DynIDAll = cInt(v2c(1:18));
DynId = cell(6);
DynId{1} = cInt(v2c( [1; 2; 3] ));
DynId{2} = cInt(v2c( [4; 5; 6] ));
DynId{3} = cInt(v2c( [7; 8; 9] ));
DynId{4} = cInt(v2c( [10; 11; 12] ));
DynId{5} = cInt(v2c( [13; 14; 15] ));
DynId{6} = cInt(v2c( [16; 17; 18] ));

xm430.writeOperatingMode(DynIDAll,  cInt(v2c( 3*ones(18,1) )) );
pause(0.1);
xm430.writeTorqueEnable(DynIDAll, cInt(v2c( 1*ones(18,1) )) );
pause(0.1);

HomeAll = zeros(18,1);
Home = cell(6);
Home{1} = [1345; 2282; 2526];
Home{2} = [2067; 2045; 2034];
Home{3} = [2042; 2072; 2015]; % Position Restriction is NOT set.
Home{4} = [2036; 2083; 2035];
Home{5} = [2049; 2103; 2014];
Home{6} = [2048; 2032; 2030];

Len = [ 0.076; 0.129 ];
AngAll = zeros(18,1);
Ang = cell(6,1);
Ang{1} = [ -pi/3; pi/6; -4*pi/6 ];
Ang{4} = [ 0; pi/6; -4*pi/6 ];
Ang{5} = [ pi/3; pi/6; -4*pi/6 ];
Ang{2} = [ pi/3; pi/6; -4*pi/6 ];
Ang{3} = [ 0; pi/6; -4*pi/6 ];
Ang{6} = [ -pi/3; pi/6; -4*pi/6 ];

RootPos = cell(6,1);
l1 = 186.9e-3;
l2 = 83.25e-3;
RootPos{1} = [-l2; -l1/2; 0];
RootPos{2} = [-l2;  l1/2; 0];
RootPos{3} = [  0; -l1/2; 0];
RootPos{4} = [  0;  l1/2; 0];
RootPos{5} = [ l2; -l1/2; 0];
RootPos{6} = [ l2;  l1/2; 0];
RootMod = cell(6,1);
RootMod{1} = [0;0;0];
RootMod{2} = [0;0;0];
RootMod{3} = [0;0;0];
RootMod{4} = [0;0;0];
RootMod{5} = [0;0;0];
RootMod{6} = [0;0;0];
BasePos = cell(6,1);
Pos = cell(6,1);
Ref = cell(6,1);
for ii=1:6
    BasePos{ii} = funcFwKine(Ang{ii}, Len);
    HomeAll(1+3*(ii-1):3+3*(ii-1)) = Home{ii};
end

% ç\Ç¶
Goal = cell(6,1);
GoalAll = zeros(18,1);
Ang = cell(6,1);
Ang{1} = [ -pi/3; pi/2; -2*pi/3 ];
Ang{4} = [ 0; pi/2; -2*pi/3 ];
Ang{5} = [ pi/3; pi/2; -2*pi/3 ];
Ang{2} = [ pi/3; pi/2; -2*pi/3 ];
Ang{3} = [ 0; pi/2; -2*pi/3 ];
Ang{6} = [ -pi/3; pi/2; -2*pi/3 ];
for ii=1:6
    Goal{ii} = Ang{ii}/0.088*180/pi;
    GoalAll(1+3*(ii-1):3+3*(ii-1)) = Goal{ii};
    for jj=1:3
%         xm430.writeGoalPosition( {DynId{ii}{jj}}, {uint32(Goal{ii}(jj)+Home{ii}(jj))} );
        pause(0.1);
    end
end
% pause(0.5);

time = tic;
nowTime = toc(time);
dt = 0;
while ( nowTime < 1 )
    sampleTime = tic;
    for ii=1:6
        Pos{ii} = funcFwKine(Ang{ii}, Len);
        dX = (BasePos{ii}-Pos{ii})*dt*10;
        Ang{ii} = Ang{ii}+funcJacbInvKine(Ang{ii}, dX, Len);
    end
    for jj=1:6
%         xm430.writeGoalPosition(DynId{jj}, cInt(v2c( Ang{jj}/0.088*180/pi+Home{jj} )) );
    end
    nowTime = toc(time);
    dt = toc(sampleTime);
end
tic;
for ii=1:100
xm430.readPresentCurrent(DynIDAll)
end
toc
% pause(0.5);
% xm430.readPresentPosition(DynIDAll)

%     pause(1.0);
function ret = v2c( vec )
    len = length(vec);
    ret = cell(1, len);
    for ii=1:len
        ret{ii} = vec(ii);
    end
end
function argCell = cInt( argCell )
    for ii=1:length(argCell)
        argCell{ii} = uint32(argCell{ii});
    end
end
