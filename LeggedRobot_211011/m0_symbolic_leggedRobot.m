clear;
tic;

% Pos  = sym( 'Pos%d', [3,1], 'real');
Len = sym( 'Len%d', [2,1], 'real');
Ang = sym('Ang%d', [3,1], 'real');
dPos = sym('dPos%d', [3,1], 'real');

r = Len(1)*cos(Ang(2))+Len(2)*cos(Ang(2)+Ang(3));
Pos = sym(zeros(3,1));
Pos(3) = Len(1)*sin(Ang(2))+Len(2)*sin(Ang(2)+Ang(3));
Pos(1) = r*cos(Ang(1));
Pos(2) = r*sin(Ang(1));

matlabFunction(Pos,  'Vars', {Ang, Len}, 'File', 'funcFwKine');

dAng = jacobian(Pos, Ang)\dPos;

matlabFunction(dAng,  'Vars', {Ang, dPos, Len}, 'File', 'funcJacbInvKine');

%{

% 文字の定義
syms Time param_g param_l param_m param_J positive
syms Theta dTheta real
Xhat  = sym( 'Xhat%d', [3,1], 'real');

% 重心位置
pos = [param_l*cos(Theta); param_l*sin(Theta)];
% 重心速度
vel = jacobian(pos,Theta)*dTheta;

%   d/dt(∂L/∂x') - ∂L/∂x + ∂Q/∂x' = Del W/Del q
%   ∂2L/∂2x'*d2x + ∂(∂L/∂x')/∂x - ∂L/∂x + ∂Q/∂x' = Del W/Del q
%   M d2q + H + G + ... = Tau
%   d/dt (Del L/Del dq) - Del L/Del q +  + Del Q/ Del dq = Del W/Del q
%   q: 一般化座標, 	L = T - U
%   T: 運動EN,      U: 位置EN
%   Del W/Del q: 一般化力,  W: 外部からの仕事
T = param_m*vel.'*vel/2 + param_J*dTheta^2/2;
T = simplify(T);
U = param_m*param_g*pos(2);
U = simplify(U);
L = T - U;
L = simplify(L);

L1 = jacobian(T,dTheta).';         L1 = simplify(L1);
M = jacobian(L1,dTheta);           M = simplify(M);
H = jacobian(L1,Theta)*dTheta + jacobian(U,Theta).';     H = simplify(H);

% 実際のシステムパラメータ
% syms param_g param_l param_m param_J positive
% syms Theta dTheta Tau real
param_g = 9.8;    
param_l = 0.5;
param_m = 0.3;
param_J = 0.1;

ActualM = subs(M);
ActualH = subs(H);

% 公称のシステムパラメータ
param_g = 9.8;    
param_l = 0.6;
param_m = 0.4;
param_J = 0.2;

NominalM = subs(M);
NominalH = subs(H);

% 入力をここで作っておいたほうがよい
K = 2;
W = 0.5;
F = NominalM\NominalH;
DeltaF = ActualM\ActualH-F + K*sin(Time*W);
G = inv(NominalM);
DeltaG = NominalM\ActualM-1;
Kc = [20, 10];
Epsilon = 0.1;
D1 = diag([1/Epsilon,1/Epsilon^2,1/Epsilon^3]);
H  = D1*[5;5;1];
fF = matlabFunction(F, 'vars', [Theta; dTheta]);
Tau = -G\(0*Xhat(3) + fF(Xhat(1),Xhat(2)) + Kc*Xhat(1:2));
Disturbance = DeltaF+DeltaG*G*Tau;

Ac = [ 0 1; 0 0 ];
A = [ 0 1 0; 0 0 1; 0 0 0 ];
Bc = [ 0; 1 ];
B2 = [ 0; 1; 0 ];
dX = [ Ac*[Theta; dTheta] + Bc*(F+DeltaF+(1+DeltaG)*G*Tau);
       A*Xhat + B2*(F+G*Tau) + H*(Theta-Xhat(1))];
fdX          = matlabFunction( dX         , 'vars', [Time; Theta; dTheta; Xhat]);
fDisturbance = matlabFunction( Disturbance, 'vars', [Time; Theta; dTheta; Xhat]);

save('vars.mat', ...
    'fdX','fDisturbance');
toc;

Xc = [Theta; dTheta];
Err  = sym( 'Err%d', [3,1], 'real');
syms param_K param_W positive

S = [ 1 0 0; 0 1 0];
F2 = subs(F, Xc, Xc-S*Err);
DeltaF2 = M\ActualH-F + param_K*sin(Time*param_W);
DeltaG2 = NominalM\M-1;
Disturbance2 = (1+DeltaG2)\( DeltaF2-DeltaG2*( -B2.'*Err+F2-Kc*(Xc-S*Err) ) );
Disturbance2 = simplify(Disturbance2);
X{1} = 1-(1+DeltaG2)\DeltaG2;
X{2} = (Ac-Bc*Kc)*Xc + Bc*(F-F2+(B2.'+Kc*S)*Err);
X{3} = (A-D1*H*[1,0,0])*Err + [0;0;1]*( F-F2 );
dDisturbance2 = X{1}\( diff(Disturbance2,Time) + jacobian(Disturbance2,Xc)*X{2} + jacobian(Disturbance2,Err)*X{3} );
dDisturbance2 = simplify(dDisturbance2);

clear X
X{1} = jacobian(dDisturbance2,Time);
X{2} = jacobian(dDisturbance2,Xc).';
X{3} = jacobian(dDisturbance2,Err).';
for ii=1:3
    X{ii} = simplify(X{ii});
    disp(ii);
    disp(X{ii});
end

%}
toc;
