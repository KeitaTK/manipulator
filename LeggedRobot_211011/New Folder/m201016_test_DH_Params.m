% リンクパラメータ
L1 = 60/10^3;  %% 単位はメートル(m)
L2 = 20/10^3;
L3 = 20/10^3;
L4 = 95/10^3;
L5 = 8/10^3;
Lt = 35/10^3;
% 関節角度（とりあえず）
tht11 = 0;
tht12 = 0;
p1 = 0;
% DHパラメータの作成
dhparams =[0       pi    0     0;    % ベース座標 ∑B
           L1+L3 3*pi/2  Lt  tht11;  % ジョイント J11（能動関節）
           L1       0    0   tht12;  % ジョイント J12（能動関節）
           L2      pi/2  L3    p1;  % ジョイント J13（受動関節）
           L4      pi/2  L5  3*pi/2];    % ジョイント C1（ボールベアリング）
% ツリーオブジェクトの作成
robot = robotics.RigidBodyTree;
% ベース座標系
body1 = robotics.RigidBody('body1');
jnt1 = robotics.Joint('jnt1','revolute');
setFixedTransform(jnt1,dhparams(1,:),'dh');
body1.Joint = jnt1;
addBody(robot,body1,'base')
% ジョイントJ11
body2 = robotics.RigidBody('body2');
jnt2 = robotics.Joint('jnt2','revolute');
setFixedTransform(jnt2,dhparams(2,:),'dh');
body2.Joint = jnt2;
addBody(robot,body2,'body1')
% ジョイントJ12
body3 = robotics.RigidBody('body3');
jnt3 = robotics.Joint('jnt3','revolute');
setFixedTransform(jnt3,dhparams(3,:),'dh');
body3.Joint = jnt3;
addBody(robot,body3,'body2')
% ジョイントJ13
body4 = robotics.RigidBody('body4');
jnt4 = robotics.Joint('jnt4','revolute');
setFixedTransform(jnt4,dhparams(4,:),'dh');
body4.Joint = jnt4;
addBody(robot,body4,'body3')
% ジョイントC1
body5 = robotics.RigidBody('body5');
jnt5 = robotics.Joint('jnt5','revolute');
setFixedTransform(jnt5,dhparams(5,:),'dh');
body5.Joint = jnt5;
addBody(robot,body5,'body4')
% 表示
showdetails(robot)
show(robot);