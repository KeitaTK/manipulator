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
Home{1} = [1345; 2282; 2067];
Home{2} = [2067; 2045; 2530];
Home{3} = [2042; 2072; 2015]; % Position Restriction is NOT set.
Home{4} = [2036; 2083; 2573];
Home{5} = [2049; 2103; 2062];
Home{6} = [2048; 2032; 2062];

Len = [ 0.076; 0.129 ];
Ang = cell(6,1);
Ang{1} = [ -pi/4; pi/6; -4*pi/6 ];
Ang{4} = [ 0; pi/6; -4*pi/6 ];
Ang{5} = [ pi/4; pi/6; -4*pi/6 ];
Ang{2} = [ pi/4; pi/6; -4*pi/6 ];
Ang{3} = [ 0; pi/6; -4*pi/6 ];
Ang{6} = [ -pi/4; pi/6; -4*pi/6 ];
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
    xm430.writeGoalPosition(DynId{ii}, Ang{ii}/0.088*180/pi+Home{ii});
end
%     pause(1.0);
